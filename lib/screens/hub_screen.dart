import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../art/nature.dart';
import '../art/objects.dart';
import '../core/engine/game_definition.dart';
import '../core/rewards/reward_service.dart';
import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';
import '../l10n/l10n.dart';
import '../ui/sketch_widgets.dart';
import 'intro_screen.dart';
import 'settings_screen.dart';

enum HubFilter { all, tap, drag, favorites }

class HubScreen extends StatefulWidget {
  const HubScreen({super.key});

  @override
  State<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends State<HubScreen> with WidgetsBindingObserver {
  HubFilter _filter = HubFilter.all;
  Timer? _dayTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Free-play counts depend on the date; refresh in case midnight passes.
    _dayTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) AppScope.of(context).rewards.refreshDay();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return NotebookPage(
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListenableBuilder(
              listenable: Listenable.merge([scope.rewards, scope.settings, scope.registry]),
              builder: (context, _) {
                final games = scope.registry.all.where((g) {
                  return switch (_filter) {
                    HubFilter.all => true,
                    HubFilter.tap => g.interactionType.isTap,
                    HubFilter.drag => g.interactionType.isDrag,
                    HubFilter.favorites => scope.settings.favorites.contains(g.gameId),
                  };
                }).toList();
                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _header(scope)),
                    SliverToBoxAdapter(child: _filters()),
                    SliverPadding(
                      // Room at the end so the last row can scroll clear of the meadow.
                      padding: EdgeInsets.fromLTRB(14, 4, 14, _Meadow.height + MediaQuery.paddingOf(context).bottom),
                      sliver: SliverLayoutBuilder(
                        builder: (context, c) {
                          final cols = c.crossAxisExtent > 640 ? 3 : 2;
                          final items = games.isEmpty ? 1 : games.length + (_filter == HubFilter.drag ? 1 : 0);
                          // The card thumbnail is 3:2 and grows with the column, so the row
                          // height must grow with it, plus the text block measured below it.
                          const spacing = 12.0;
                          final colWidth = (c.crossAxisExtent - spacing * (cols - 1)) / cols;
                          final thumbHeight = ((colWidth - 18) / 1.5).roundToDouble();
                          return SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              mainAxisSpacing: 14,
                              crossAxisSpacing: spacing,
                              mainAxisExtent: thumbHeight + _GameCard.bodyHeight(context),
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, i) => _CardEntrance(
                                // Re-runs the pop-in when the filter changes.
                                key: ValueKey('${_filter.name}-$i'),
                                index: i,
                                child: i < games.length ? _GameCard(def: games[i]) : _ComingSoonCard(filter: _filter),
                              ),
                              childCount: items,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: IgnorePointer(child: _Meadow())),
        ],
      ),
    );
  }

  Widget _header(AppScope scope) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Column(
        children: [
          Row(
            children: [
              SketchButton(
                semanticLabel: l.back,
                padding: const EdgeInsets.all(10),
                onTap: () => Navigator.of(context).maybePop(),
                child: const DoodleIcon(Doodle.back),
              ),
              const Spacer(),
              GemChip(count: scope.rewards.getGemBalance()),
              const SizedBox(width: 10),
              SketchButton(
                semanticLabel: l.settings,
                padding: const EdgeInsets.all(10),
                onTap: () => openSettings(context),
                child: const DoodleIcon(Doodle.gear),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpriteView(
                size: const Size(84, 110),
                painter: (c, s) => SpriteCache.place(c, 'mascot-hub-v2', Offset(s.width / 2, s.height / 2 + 2), (c) {
                  c.scale(1.3);
                  Props.mascot(c);
                  // Little "ta-da!" dashes around the pencil.
                  for (final (a, col) in [(-2.5, Ink.coral), (-2.1, Ink.coral), (-0.9, Ink.gold), (-0.5, Ink.gold)]) {
                    final d = Offset(cos(a), sin(a));
                    Pen.line(c, d * 32, d * 40, ink: col, width: 2.4, seed: (a * 10).round().abs());
                  }
                  for (final a in [2.2, 2.6, 0.7]) {
                    final d = Offset(cos(a), sin(a));
                    Pen.line(c, d * 34, d * 41, ink: Ink.gold, width: 2.2);
                  }
                }),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ScribbleTitle(
                        l.hubTitle,
                        style: Txt.title.copyWith(fontSize: 32),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // A lavender crayon scribble behind the tagline.
                        Flexible(
                          child: SketchBox(
                            fill: context.palette.tint(Ink.purple, 0.22),
                            hatch: Ink.purple.withValues(alpha: 0.35),
                            radius: 18,
                            seed: 9,
                            padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
                            child: Text(l.hubSubtitle, style: Txt.note.copyWith(fontSize: 17).soft(context)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SpriteView(
                          size: const Size(40, 30),
                          painter: (c, s) => SpriteCache.place(c, 'hub-star', s.center(Offset.zero), (c) {
                            Pen.shape(
                              c,
                              Pen.star(Offset.zero, 12, 5.5),
                              fill: Ink.yellow,
                              solid: true,
                              hatch: Ink.gold,
                              width: 1.8,
                            );
                            Pen.line(c, const Offset(-20, -2), const Offset(-15, 1), ink: Ink.blue, width: 2);
                            Pen.line(c, const Offset(14, -10), const Offset(18, -15), ink: Ink.coral, width: 2);
                            Pen.line(c, const Offset(16, 2), const Offset(21, 3), ink: Ink.coral, width: 2);
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    final l = context.l10n;
    final p = context.palette;
    final labels = {
      HubFilter.all: l.filterAll,
      HubFilter.tap: l.filterTap,
      HubFilter.drag: l.filterDrag,
      HubFilter.favorites: l.filterFavorites,
    };
    // Each chip keeps its own crayon colour; the selected one is filled in fully.
    const tints = {
      HubFilter.all: Ink.pink,
      HubFilter.tap: Ink.sky,
      HubFilter.drag: Ink.mint,
      HubFilter.favorites: Ink.coral,
    };
    const flex = {HubFilter.all: 10, HubFilter.tap: 6, HubFilter.drag: 6, HubFilter.favorites: 10};
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Row(
        children: [
          for (final f in HubFilter.values) ...[
            if (f != HubFilter.all) const SizedBox(width: 8),
            Expanded(
              flex: flex[f]!,
              child: SketchButton(
                fill: p.tint(tints[f]!, _filter == f ? 0.45 : 0.14),
                seed: f.index + 3,
                radius: 22,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                semanticLabel: labels[f],
                onTap: () => setState(() => _filter = f),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f == HubFilter.favorites) ...[
                      const DoodleIcon(Doodle.heartFilled, size: 20),
                      const SizedBox(width: 6),
                    ],
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      // Built on the theme's text style so the font is kept (this
                      // context sits above the Scaffold's DefaultTextStyle).
                      style: Theme.of(context).textTheme.bodyMedium!
                          .merge(Txt.body)
                          .copyWith(
                            fontSize: 17,
                            fontWeight: _filter == f ? FontWeight.w900 : FontWeight.w700,
                            color: _filter == f ? p.ink : p.inkSoft,
                          ),
                      child: Text(labels[f]!),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.def});
  final GameDefinition def;

  /// A yellow highlighter swipe under each line of the name.
  static final _nameStyle = Txt.body.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w900,
    height: 1.15,
    decoration: TextDecoration.underline,
    decorationColor: Ink.yellow.withValues(alpha: 0.7),
    decorationThickness: 4,
  );
  static final _goalStyle = Txt.small.copyWith(fontSize: 14);
  static final _playStyle = Txt.heading.copyWith(fontSize: 22);

  /// Height of everything below the thumbnail: the tallest name and goal (two
  /// lines each), the tag row and the Play button, measured in the current
  /// font, language and text size so the card has no dead space.
  static double bodyHeight(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    double lines(TextStyle style, int n) {
      final tp = TextPainter(
        text: TextSpan(text: List.filled(n, 'Ág').join('\n'), style: base.merge(style)),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      final h = tp.height;
      tp.dispose();
      return h;
    }

    final tagRow = max(lines(_Tag.style, 1) + 10, 22.0);
    return lines(_nameStyle, 2) +
        lines(_goalStyle, 2) +
        tagRow +
        lines(_playStyle, 1) +
        62; // padding, gaps and borders
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = context.l10n;
    final p = context.palette;
    final rewards = scope.rewards;
    final used = rewards.freePlaysUsed(def.gameId).clamp(0, RewardRules.freePlaysPerDay);
    final fav = scope.settings.favorites.contains(def.gameId);
    final enabled = scope.registry.isEnabled(def.gameId);
    void open() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => IntroScreen(gameId: def.gameId)));

    return Semantics(
      label: '${def.name(l)}. ${def.objective(l)}',
      child: GestureDetector(
        onTap: enabled ? open : null,
        child: SketchBox(
          fill: p.surface,
          seed: def.gameId.length,
          radius: 18,
          padding: const EdgeInsets.fromLTRB(9, 9, 9, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, c) {
                      final size = Size(c.maxWidth, (c.maxWidth / 1.5).roundToDouble());
                      return SceneDimmer(
                        child: SpriteView(
                          size: size,
                          painter: (c, s) => SpriteCache.draw(c, 'thumb-${def.gameId}-${s.width.round()}', (c) {
                            // Clip the scene to a rounded window, then ink its edge.
                            final frame = Pen.rrect((Offset.zero & s).deflate(1.5), 12);
                            c.save();
                            c.clipPath(frame);
                            def.thumbnail(c, s);
                            c.restore();
                            Pen.stroke(c, frame, width: 2.2, seed: def.gameId.length + 2, amp: 0.6);
                          }),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Semantics(
                      button: true,
                      label: fav ? l.favoriteRemove : l.favoriteAdd,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          scope.audio.buttonTap();
                          scope.settings.toggleFavorite(def.gameId);
                        },
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SpriteView(
                                size: const Size(36, 36),
                                painter: (c, s) => SpriteCache.place(
                                  c,
                                  'fav-badge',
                                  s.center(Offset.zero),
                                  (c) => Pen.shape(
                                    c,
                                    Pen.circle(Offset.zero, 16),
                                    fill: Ink.white,
                                    solid: true,
                                    width: 2,
                                    seed: 5,
                                    doubleLine: false,
                                  ),
                                ),
                              ),
                              // The heart pops when it is filled in.
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 260),
                                transitionBuilder: (child, a) => ScaleTransition(
                                  scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                                  child: child,
                                ),
                                child: DoodleIcon(
                                  fav ? Doodle.heartFilled : Doodle.heart,
                                  key: ValueKey(fav),
                                  size: 22,
                                  color: Ink.navy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(def.name(l), style: _nameStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Text(def.objective(l), style: _goalStyle.soft(context), maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: _Tag(
                        def.interactionType.label(l).toUpperCase(),
                        color: def.interactionType.isDrag ? Ink.purple : Ink.sky,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Spacer(),
                  if (used < RewardRules.freePlaysPerDay)
                    Semantics(
                      label: l.freePlaysLeftToday(RewardRules.freePlaysPerDay - used),
                      child: FreePlayDots(remaining: RewardRules.freePlaysPerDay - used, size: 14),
                    )
                  else
                    Semantics(
                      label: l.nextPlayCostsGem,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('1', style: Txt.body.copyWith(fontSize: 15)),
                          const SizedBox(width: 3),
                          const GemIcon(size: 18),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SketchButton(
                  fill: enabled ? p.tint(Ink.pink, 0.3) : p.surface,
                  radius: 20,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onTap: enabled ? open : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DoodleIcon(enabled ? Doodle.play : Doodle.lock, size: 22),
                      const SizedBox(width: 8),
                      Flexible(child: Text(enabled ? l.play : l.resting, style: _playStyle)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, {required this.color});
  final String text;
  final Color color;

  static final style = Txt.small.copyWith(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5);

  @override
  Widget build(BuildContext context) => SketchBox(
    fill: context.palette.tint(color, 0.4),
    radius: 12,
    seed: 6,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    child: Text(text, style: style),
  );
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.filter});
  final HubFilter filter;

  @override
  Widget build(BuildContext context) {
    final text = filter == HubFilter.favorites ? context.l10n.favoritesEmpty : context.l10n.moreDragGamesSoon;
    return SketchBox(
      fill: context.palette.surfaceWarm,
      seed: 12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpriteView(
            size: const Size(90, 90),
            painter: (c, s) => SpriteCache.place(c, 'soon-${filter.name}', s.center(Offset.zero), (c) {
              if (filter == HubFilter.favorites) {
                Pen.heart(c, Offset.zero, 26);
              } else {
                Props.mascot(c, mood: Mood.wow);
              }
              Pen.plus(c, const Offset(34, -30), 5, Ink.gold);
            }),
          ),
          const SizedBox(height: 12),
          Text(text, style: Txt.body, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Cards fade and rise into place, staggered, the first time they are built.
class _CardEntrance extends StatefulWidget {
  const _CardEntrance({super.key, required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_CardEntrance> createState() => _CardEntranceState();
}

class _CardEntranceState extends State<_CardEntrance> with SingleTickerProviderStateMixin {
  // Only the first screenful is staggered; cards scrolled in later barely wait.
  late final _delay = 40 * widget.index.clamp(0, 8);
  late final _ctl = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 420 + _delay),
  );
  late final _curve = CurvedAnimation(
    parent: _ctl,
    curve: Interval(_delay / (420 + _delay), 1, curve: Curves.easeOutCubic),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = AppScope.of(context).settings.effectiveReducedMotion || MediaQuery.disableAnimationsOf(context);
    if (still) {
      _ctl.value = 1;
    } else if (_ctl.isDismissed) {
      _ctl.forward();
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: SlideTransition(
      position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(_curve),
      child: widget.child,
    ),
  );
}

/// Grassy hills with bushes and flowers along the bottom of the hub.
class _Meadow extends StatelessWidget {
  const _Meadow();

  static const height = 64.0;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return SceneDimmer(
      child: LayoutBuilder(
        builder: (context, box) => SpriteView(
          size: Size(box.maxWidth, height + bottom),
          painter: (c, s) => SpriteCache.draw(c, 'hub-meadow-${s.width.round()}x${s.height.round()}', (c) {
            final rng = Random(4);
            // Bushes peek over the hill line.
            for (var x = 10.0; x < s.width + 40; x += 70 + rng.nextDouble() * 50) {
              c.save();
              c.translate(x, 30 + rng.nextDouble() * 8);
              Nature.bush(c, 70 + rng.nextDouble() * 30, seed: x.round());
              c.restore();
            }
            // Rolling hill.
            final hill = Path()..moveTo(-10, 34);
            for (var x = -10.0; x < s.width + 10; x += 60) {
              hill.quadraticBezierTo(x + 30, (x / 60).round().isEven ? 20 : 30, x + 60, 32);
            }
            hill
              ..lineTo(s.width + 10, s.height + 10)
              ..lineTo(-10, s.height + 10)
              ..close();
            Pen.shape(
              c,
              hill,
              fill: Ink.tint(Ink.mint, 0.6),
              solid: true,
              hatch: Ink.leaf.withValues(alpha: 0.5),
              seed: 6,
            );
            for (var x = 20.0; x < s.width; x += 46 + rng.nextDouble() * 30) {
              c.save();
              c.translate(x, 40 + rng.nextDouble() * 14);
              Nature.grass(c, 18, seed: x.round());
              c.restore();
            }
            // A few little flowers.
            const colors = [Ink.pink, Ink.yellow, Ink.coral, Ink.purple];
            var i = 0;
            for (var x = s.width * 0.18; x < s.width; x += s.width * 0.27, i++) {
              c.save();
              c.translate(x + rng.nextDouble() * 20, 44 + rng.nextDouble() * 10);
              Nature.flower(c, colors[i % colors.length], r: 11, face: false, seed: i + 2);
              c.restore();
            }
          }),
        ),
      ),
    );
  }
}
