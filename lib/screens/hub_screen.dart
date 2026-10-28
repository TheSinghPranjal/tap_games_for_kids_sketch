import 'dart:async';

import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../art/objects.dart';
import '../core/engine/game_definition.dart';
import '../core/rewards/reward_service.dart';
import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';
import '../ui/sketch_widgets.dart';
import 'intro_screen.dart';
import 'settings_dialog.dart';

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
      child: SafeArea(
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
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 28),
                  sliver: SliverLayoutBuilder(
                    builder: (context, c) {
                      final cols = c.crossAxisExtent > 640 ? 3 : 2;
                      final items = games.isEmpty ? 1 : games.length + (_filter == HubFilter.drag ? 1 : 0);
                      return SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 344,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) =>
                              i < games.length ? _GameCard(def: games[i]) : _ComingSoonCard(filter: _filter),
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
    );
  }

  Widget _header(AppScope scope) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
      child: Column(
        children: [
          Row(
            children: [
              SketchButton(
                semanticLabel: 'Back',
                padding: const EdgeInsets.all(10),
                onTap: () => Navigator.of(context).maybePop(),
                child: const DoodleIcon(Doodle.back),
              ),
              const Spacer(),
              GemChip(count: scope.rewards.getGemBalance()),
              const SizedBox(width: 10),
              SketchButton(
                semanticLabel: 'Settings',
                padding: const EdgeInsets.all(10),
                onTap: () => showSettingsDialog(context),
                child: const DoodleIcon(Doodle.gear),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpriteView(
                size: const Size(64, 84),
                painter: (c, s) => SpriteCache.place(c, 'mascot-hub', Offset(s.width / 2, s.height / 2 - 2), (c) {
                  Props.mascot(c);
                  Pen.plus(c, const Offset(30, -30), 5, Ink.gold);
                  Pen.plus(c, const Offset(-28, -22), 4, Ink.coral);
                }),
              ),
              const SizedBox(width: 10),
              const Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScribbleTitle('Tap & Drag Games', textAlign: TextAlign.left),
                    SizedBox(height: 4),
                    Text('pick a game and play!', style: Txt.note),
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
    const labels = {
      HubFilter.all: 'All Games',
      HubFilter.tap: 'Tap',
      HubFilter.drag: 'Drag',
      HubFilter.favorites: 'Favorites',
    };
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        children: [
          for (final f in HubFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SketchButton(
                fill: _filter == f ? Ink.blushPink : Ink.white,
                seed: f.index + 3,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onTap: () => setState(() => _filter = f),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (f == HubFilter.favorites) ...[
                      const DoodleIcon(Doodle.heartFilled, size: 20),
                      const SizedBox(width: 6),
                    ],
                    Text(labels[f]!, style: Txt.body.copyWith(color: _filter == f ? Ink.navy : Ink.navySoft)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.def});
  final GameDefinition def;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final rewards = scope.rewards;
    final used = rewards.freePlaysUsed(def.gameId).clamp(0, RewardRules.freePlaysPerDay);
    final fav = scope.settings.favorites.contains(def.gameId);
    final enabled = scope.registry.isEnabled(def.gameId);
    void open() => Navigator.of(context).push(MaterialPageRoute(builder: (_) => IntroScreen(gameId: def.gameId)));

    return Semantics(
      label: '${def.name}. ${def.objective}',
      child: GestureDetector(
        onTap: enabled ? open : null,
        child: SketchBox(
          fill: Ink.white,
          seed: def.gameId.length,
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SpriteView(
                      size: const Size(double.infinity, 104),
                      painter: (c, s) =>
                          SpriteCache.draw(c, 'thumb-${def.gameId}-${s.width.round()}', (c) => def.thumbnail(c, s)),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Semantics(
                      button: true,
                      label: fav ? 'Remove favorite' : 'Add favorite',
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => scope.settings.toggleFavorite(def.gameId),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(child: DoodleIcon(fav ? Doodle.heartFilled : Doodle.heart, size: 26)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                def.name,
                style: Txt.body.copyWith(fontSize: 16, fontWeight: FontWeight.w900),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(def.objective, style: Txt.small, maxLines: 2, overflow: TextOverflow.ellipsis),
              const Spacer(),
              Row(
                children: [
                  _Tag(def.interactionType.label, color: def.interactionType.isDrag ? Ink.purple : Ink.mint),
                  const Spacer(),
                  FreePlayDots(remaining: RewardRules.freePlaysPerDay - used, size: 12),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                used < RewardRules.freePlaysPerDay
                    ? '$used/${RewardRules.freePlaysPerDay} free plays used'
                    : 'Next play: 1 gem',
                style: Txt.small.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SketchButton(
                  fill: enabled ? Ink.blushPink : Ink.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  onTap: enabled ? open : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DoodleIcon(enabled ? Doodle.play : Doodle.lock, size: 20),
                      const SizedBox(width: 6),
                      Text(enabled ? 'Play' : 'Resting', style: Txt.heading.copyWith(fontSize: 18)),
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

  @override
  Widget build(BuildContext context) => SketchBox(
    fill: Ink.tint(color, 0.35),
    radius: 10,
    seed: 6,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    child: Text(text, style: Txt.small.copyWith(color: Ink.navy, fontSize: 12)),
  );
}

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard({required this.filter});
  final HubFilter filter;

  @override
  Widget build(BuildContext context) {
    final text = filter == HubFilter.favorites
        ? 'Tap a heart to save your favorite games here!'
        : 'More drag games are coming soon!';
    return SketchBox(
      fill: Ink.paperWarm,
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
