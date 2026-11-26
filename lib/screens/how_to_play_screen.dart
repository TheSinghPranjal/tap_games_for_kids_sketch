import 'dart:math' as math;

import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../core/rewards/reward_models.dart';
import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';
import '../l10n/l10n.dart';
import '../ui/sketch_widgets.dart';
import 'intro_screen.dart';

Future<void> openHowToPlay(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HowToPlayScreen()));

/// A short swipeable picture guide: picking a game, tap and drag games,
/// stars and gems, free plays and favourites.
class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen> with SingleTickerProviderStateMixin {
  final _pages = PageController();
  late final _demo = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  int _page = 0;

  static const _count = 6;

  @override
  void dispose() {
    _pages.dispose();
    _demo.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _count - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    final still = AppScope.of(context).settings.effectiveReducedMotion;
    if (still) {
      _pages.jumpToPage(_page + 1);
    } else {
      _pages.nextPage(duration: const Duration(milliseconds: 380), curve: Curves.easeInOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final steps = _steps(l);
    final last = _page == _count - 1;
    return NotebookPage(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
              child: Row(
                children: [
                  SketchButton(
                    semanticLabel: l.back,
                    padding: const EdgeInsets.all(10),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const DoodleIcon(Doodle.back),
                  ),
                  Expanded(
                    child: Center(
                      child: FittedBox(fit: BoxFit.scaleDown, child: ScribbleTitle(l.settingsHowToPlay)),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _count,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _StepPage(step: steps[i], index: i, demo: _demo),
              ),
            ),
            Semantics(
              label: l.htpStep(_page + 1, _count),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _count; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 26 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: i == _page ? Ink.coral : context.palette.inkSoft.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: SizedBox(
                width: 280,
                child: SketchButton(
                  fill: context.palette.surfaceAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onTap: _next,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Row(
                      key: ValueKey(last),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(last ? l.htpLetsPlay : l.htpNext, style: Txt.heading.copyWith(fontSize: 24)),
                        const SizedBox(width: 10),
                        DoodleIcon(last ? Doodle.play : Doodle.forward, size: 26),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_Step> _steps(AppLocalizations l) => [
    _Step(l.htpPickTitle, l.htpPickBody, _Art.pick),
    _Step(l.htpTapTitle, l.htpTapBody, _Art.tap),
    _Step(l.htpDragTitle, l.htpDragBody, _Art.drag),
    _Step(l.htpStarsTitle, l.htpStarsBody(RewardRules.pointsPerGem), _Art.stars),
    _Step(l.htpFreeTitle, l.htpFreeBody(RewardRules.freePlaysPerDay), _Art.free),
    _Step(l.htpFavTitle, l.htpFavBody, _Art.favorite),
  ];
}

enum _Art { pick, tap, drag, stars, free, favorite }

class _Step {
  const _Step(this.title, this.body, this.art);
  final String title;
  final String body;
  final _Art art;
}

class _StepPage extends StatelessWidget {
  const _StepPage({required this.step, required this.index, required this.demo});
  final _Step step;
  final int index;
  final Animation<double> demo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final artH = math.min(260.0, box.maxHeight * 0.48);
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  SketchBox(
                    fill: context.palette.surface,
                    seed: index + 30,
                    radius: 22,
                    padding: const EdgeInsets.all(10),
                    child: SizedBox(height: artH, width: double.infinity, child: _art(context)),
                  ),
                  const SizedBox(height: 18),
                  Text(step.title, style: Txt.title.copyWith(fontSize: 26), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(step.body, style: Txt.body.copyWith(fontSize: 18, height: 1.35), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _art(BuildContext context) {
    final scope = AppScope.of(context);
    final reduced = scope.settings.effectiveReducedMotion;
    Widget demoOf(String gameId) {
      final def = scope.registry.byId(gameId) ?? scope.registry.all.first;
      return SceneDimmer(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AnimatedBuilder(
            animation: demo,
            builder: (context, _) => CustomPaint(painter: DemoPainter(def, reduced ? 0.3 : demo.value, reduced)),
          ),
        ),
      );
    }

    switch (step.art) {
      case _Art.pick:
        return demoOf('pond_fish_catch');
      case _Art.tap:
        return demoOf('balloon_tap_parade');
      case _Art.drag:
        return demoOf('bouncy_ball_catch');
      case _Art.stars:
        return Center(
          child: FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DoodleIcon(Doodle.star, size: 54),
                Text(' × ${RewardRules.pointsPerGem}', style: Txt.title.copyWith(fontSize: 40)),
                const SizedBox(width: 14),
                const DoodleIcon(Doodle.forward, size: 40),
                const SizedBox(width: 14),
                _Bounce(animation: demo, still: reduced, child: const GemIcon(size: 70)),
              ],
            ),
          ),
        );
      case _Art.free:
        return Center(
          child: FittedBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FreePlayDots(remaining: RewardRules.freePlaysPerDay, size: 40),
                const SizedBox(height: 22),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const DoodleIcon(Doodle.play, size: 40),
                    Text('  =  1 ', style: Txt.title.copyWith(fontSize: 40)),
                    const GemIcon(size: 48),
                  ],
                ),
              ],
            ),
          ),
        );
      case _Art.favorite:
        return Center(
          child: _Bounce(
            animation: demo,
            still: reduced,
            child: SpriteView(
              size: const Size(160, 150),
              painter: (c, s) => SpriteCache.place(c, 'htp-heart', s.center(Offset.zero), (c) {
                c.scale(2.6);
                Pen.heart(c, Offset.zero, 26);
                Pen.plus(c, const Offset(30, -26), 5, Ink.gold);
                Pen.plus(c, const Offset(-30, -20), 4, Ink.gold);
              }),
            ),
          ),
        );
    }
  }
}

/// Gentle repeating bounce for the guide's pictures.
class _Bounce extends StatelessWidget {
  const _Bounce({required this.animation, required this.child, this.still = false});
  final Animation<double> animation;
  final Widget child;
  final bool still;

  @override
  Widget build(BuildContext context) {
    if (still) return child;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final k = math.sin(animation.value * 2 * math.pi);
        return Transform.translate(
          offset: Offset(0, -6 * k.abs()),
          child: Transform.scale(scale: 1 + 0.04 * k, child: child),
        );
      },
      child: child,
    );
  }
}
