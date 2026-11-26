import 'dart:math' as math;

import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../art/objects.dart';
import '../core/engine/audio_manager.dart';
import '../core/engine/game_definition.dart';
import '../core/rewards/reward_service.dart';
import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';
import '../l10n/l10n.dart';
import '../ui/sketch_widgets.dart';
import 'play_screen.dart';

/// Step 1 + 2 of the lifecycle: introduce the game, then validate and start
/// the round through the RewardService.
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.gameId});
  final String gameId;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late final _demo = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();

  /// One id per visit: however many times Start is tapped, at most one round
  /// (and at most one gem) results from it.
  final _requestId = 'start-${DateTime.now().microsecondsSinceEpoch}-${math.Random().nextInt(1 << 30)}';
  bool _busy = false;

  @override
  void dispose() {
    _demo.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_busy) return;
    setState(() => _busy = true);
    final scope = AppScope.of(context);
    final rewards = scope.rewards;
    final def = scope.registry.byId(widget.gameId)!;
    scope.audio.play(Sfx.tap);
    try {
      var result = await rewards.startGame(def.gameId, requestId: _requestId);
      if (!mounted) return;
      if (result.status == StartStatus.needsConfirmation) {
        final ok = await _confirmSpend(result.gemBalance);
        if (!mounted || ok != true) return;
        result = await rewards.startGame(def.gameId, requestId: _requestId, confirmSpend: true);
        if (!mounted) return;
      }
      final l = context.l10n;
      switch (result.status) {
        case StartStatus.started:
          await Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 350),
              pageBuilder: (_, _, _) => PlayScreen(def: def, round: result.round!),
              transitionsBuilder: (_, a, _, child) => FadeTransition(
                opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
                child: child,
              ),
            ),
          );
          return;
        case StartStatus.noGems:
          await _message(
            l.noGemsTitle,
            l.noGemsBody(RewardRules.freePlaysPerDay),
            mood: Mood.sleepy,
            backToGames: true,
          );
        case StartStatus.disabled:
          await _message(l.restingTitle, l.restingBody, mood: Mood.sleepy, backToGames: true);
        case StartStatus.failed:
          await _message(l.oops, l.startFailedBody, mood: Mood.wow);
        case StartStatus.needsConfirmation:
          break;
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirmSpend(int balance) {
    return showSketchDialog<bool>(
      context,
      builder: (ctx) {
        final l = ctx.l10n;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GemIcon(size: 56),
            const SizedBox(height: 10),
            Text(l.playAgainTitle, style: Txt.title, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(l.playAgainBody, style: Txt.body, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l.youHave, style: Txt.note.soft(ctx)),
                const GemIcon(size: 20),
                Text(' $balance', style: Txt.heading),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SketchButton(
                    onTap: () => Navigator.of(ctx).pop(false),
                    child: Text(l.notNow, style: Txt.body),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SketchButton(
                    fill: ctx.palette.surfaceAccent,
                    onTap: () => Navigator.of(ctx).pop(true),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l.useOneGem, style: Txt.heading),
                        const GemIcon(size: 22),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _message(String title, String text, {Mood mood = Mood.happy, bool backToGames = false}) async {
    await showSketchDialog<void>(
      context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpriteView(
              size: const Size(80, 90),
              painter: (c, s) => SpriteCache.place(
                c,
                'mascot-${mood.name}',
                s.center(Offset.zero),
                (c) => Props.mascot(c, mood: mood),
              ),
            ),
            const SizedBox(height: 8),
            Text(title, style: Txt.heading, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(text, style: Txt.body, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            SketchButton(
              fill: ctx.palette.surfaceAccent,
              onTap: () => Navigator.of(ctx).pop(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DoodleIcon(backToGames ? Doodle.home : Doodle.check),
                  const SizedBox(width: 8),
                  Text(backToGames ? ctx.l10n.backToGames : ctx.l10n.ok, style: Txt.heading),
                ],
              ),
            ),
          ],
        );
      },
    );
    if (backToGames && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final def = scope.registry.byId(widget.gameId)!;
    final l = context.l10n;
    final p = context.palette;
    return NotebookPage(
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([scope.rewards, scope.registry]),
          builder: (context, _) {
            final rewards = scope.rewards;
            final remaining = rewards.getRemainingFreePlays(def.gameId);
            final eligibility = rewards.canStartGame(def.gameId);
            return LayoutBuilder(
              builder: (context, box) {
                final demoH = math.min(300.0, box.maxHeight * 0.38);
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: box.maxHeight - 34),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SketchButton(
                              semanticLabel: l.backToGames,
                              padding: const EdgeInsets.all(10),
                              onTap: () => Navigator.of(context).maybePop(),
                              child: const DoodleIcon(Doodle.back),
                            ),
                            const Spacer(),
                            GemChip(count: rewards.getGemBalance()),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ScribbleTitle(def.name(l)),
                        const SizedBox(height: 10),
                        Text(
                          def.instructions(l),
                          style: Txt.note.copyWith(fontSize: 18).soft(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        SketchBox(
                          fill: p.surface,
                          seed: 9,
                          padding: const EdgeInsets.all(8),
                          child: SizedBox(
                            height: demoH,
                            width: double.infinity,
                            child: SceneDimmer(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedBuilder(
                                  animation: _demo,
                                  builder: (context, _) => CustomPaint(
                                    painter: DemoPainter(def, _demo.value, scope.settings.effectiveReducedMotion),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          children: [
                            Text(l.freePlaysToday, style: Txt.body),
                            FreePlayDots(remaining: remaining, size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          switch (eligibility) {
                            StartEligibility.free => l.freePlaysRemaining(remaining, RewardRules.freePlaysPerDay),
                            StartEligibility.needsGem => l.nextRoundUsesGem,
                            StartEligibility.noGems => l.comeBackTomorrow,
                            StartEligibility.disabled => l.gameRestingNow,
                          },
                          style: Txt.small.soft(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: 260,
                          child: SketchButton(
                            semanticLabel: l.start,
                            fill: p.surfaceAccent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            onTap: _busy || eligibility == StartEligibility.disabled ? null : _start,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const DoodleIcon(Doodle.play, size: 30),
                                  const SizedBox(width: 10),
                                  Text(
                                    eligibility == StartEligibility.needsGem ? l.startWithGem : l.start,
                                    style: Txt.title.copyWith(fontSize: 30),
                                  ),
                                  if (eligibility == StartEligibility.needsGem) const GemIcon(size: 28),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Animated demonstration: the game's thumbnail with a hand that taps (or
/// drags across) it. Also used by the how-to-play guide.
class DemoPainter extends CustomPainter {
  DemoPainter(this.def, this.t, this.reduced);
  final GameDefinition def;
  final double t;
  final bool reduced;

  @override
  void paint(Canvas canvas, Size size) {
    SpriteCache.draw(
      canvas,
      'demo-${def.gameId}-${size.width.round()}x${size.height.round()}',
      (c) => def.thumbnail(c, size),
    );
    final target = Offset(size.width * 0.55, size.height * 0.5);
    Offset hand;
    double press;
    if (def.interactionType == Interaction.drag) {
      final k = Curves.easeInOut.transform((t * 1.25).clamp(0, 1));
      hand = Offset.lerp(
        Offset(size.width * 0.3, size.height * 0.45),
        Offset(size.width * 0.75, size.height * 0.7),
        k,
      )!;
      press = t < 0.8 ? 1 : 0;
    } else {
      final bob = reduced ? 0.0 : math.max(0.0, math.sin(t * math.pi * 2));
      hand = target + Offset(14, 30 - bob * 16);
      press = t > 0.2 && t < 0.4 ? 1 : 0;
      if (press > 0) {
        final k = (t - 0.2) / 0.2;
        canvas.drawCircle(target, 14 + k * 26, Pen.inkPaint(Ink.coral.withValues(alpha: 1 - k), 3));
      }
    }
    // The fingertip sits at (0, -29) in the hand sprite.
    final s = press > 0 ? 1.15 : 1.3;
    SpriteCache.place(canvas, 'demo-hand', hand + Offset(0, 29 * s), Props.hand, scale: s);
  }

  @override
  bool shouldRepaint(covariant DemoPainter o) => o.t != t;
}
