import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../art/objects.dart';
import '../core/engine/audio_manager.dart';
import '../core/engine/game_canvas.dart';
import '../core/engine/game_definition.dart';
import '../core/engine/game_session.dart';
import '../core/rewards/reward_service.dart';
import '../core/sketch/ink.dart';
import '../core/sketch/paper.dart';
import '../core/sketch/pen.dart';
import '../l10n/l10n.dart';
import '../ui/sketch_widgets.dart';
import 'intro_screen.dart';

/// Steps 3 + 4 of the lifecycle: gameplay with the shared HUD, pause, and
/// the results card.
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.def, required this.round});
  final GameDefinition def;
  final GameRound round;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with WidgetsBindingObserver {
  GameSessionManager? _session;
  StreamSubscription<GameEvent>? _sub;
  int _gemBump = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_session != null) return;
    final scope = AppScope.of(context);
    scope.settings.systemReducedMotion = MediaQuery.of(context).disableAnimations;
    _session = GameSessionManager(
      def: widget.def,
      reward: scope.rewards,
      round: widget.round,
      settings: scope.settings,
      audio: scope.audio,
    );
    _sub = _session!.events.listen((e) {
      if (e.type == GameEventType.gemAwarded && mounted) setState(() => _gemBump++);
      if (e.type == GameEventType.gameCompleted) scope.audio.play(Sfx.cheer);
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Backgrounded: pause. Score and gems are already persisted per event.
    if (state != AppLifecycleState.resumed) _session?.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    final s = _session;
    if (s != null) {
      // Leaving by any route still completes the round exactly once.
      s.finish(linger: false).whenComplete(s.dispose);
    }
    super.dispose();
  }

  Future<void> _quit() async {
    final s = _session!;
    await s.finish();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = _session!;
    final scope = AppScope.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([s, scope.rewards, scope.settings]),
      builder: (context, _) => PopScope(
        canPop: s.phase == SessionPhase.finished,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) s.pause();
        },
        child: NotebookPage(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _Hud(session: s, gems: scope.rewards.getGemBalance(), bump: _gemBump),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                        child: SceneDimmer(child: GameCanvas(session: s)),
                      ),
                    ),
                  ],
                ),
                // Pause and results cards fade and pop in over the game.
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: scope.settings.effectiveReducedMotion ? 0 : 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(a), child: child),
                    ),
                    child: switch (s.phase) {
                      SessionPhase.paused => _PauseCard(key: const ValueKey('pause'), session: s, onQuit: _quit),
                      SessionPhase.finished => _ResultsCard(key: const ValueKey('results'), session: s),
                      _ => const SizedBox.shrink(key: ValueKey('none')),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.session, required this.gems, required this.bump});
  final GameSessionManager session;
  final int gems;
  final int bump;

  @override
  Widget build(BuildContext context) {
    final scene = session.scene;
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
      child: Row(
        children: [
          SketchButton(
            semanticLabel: l.pause,
            padding: const EdgeInsets.all(10),
            onTap: session.acceptsInput ? session.pause : null,
            child: const DoodleIcon(Doodle.pause),
          ),
          const SizedBox(width: 8),
          SketchBox(
            fill: context.palette.surface,
            radius: 14,
            seed: 3,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DoodleIcon(Doodle.star, size: 24),
                const SizedBox(width: 4),
                Text('${session.score.score}', style: Txt.heading),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SpriteView(size: const Size(26, 26), painter: scene.paintProgressIcon),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(scene.progressText, style: Txt.body, overflow: TextOverflow.ellipsis),
                    ),
                    if (scene.lives != null) ...[
                      const SizedBox(width: 6),
                      for (var i = 0; i < scene.lives!; i++) const DoodleIcon(Doodle.heartFilled, size: 18),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                LayoutBuilder(
                  builder: (context, c) =>
                      SketchProgress(value: session.timeFraction, color: Ink.yellow, width: c.maxWidth, height: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GemChip(count: gems, bump: bump, compact: true),
        ],
      ),
    );
  }
}

class _Overlay extends StatelessWidget {
  const _Overlay({required this.child, this.dim = 0.22});
  final Widget child;
  final double dim;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ColoredBox(
      color: p.isDark ? Colors.black.withValues(alpha: dim * 2.2) : Ink.navy.withValues(alpha: dim),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SketchBox(fill: p.surfaceWarm, radius: 28, seed: 8, padding: const EdgeInsets.all(22), child: child),
          ),
        ),
      ),
    );
  }
}

class _PauseCard extends StatelessWidget {
  const _PauseCard({super.key, required this.session, required this.onQuit});
  final GameSessionManager session;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    final l = context.l10n;
    return _Overlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScribbleTitle(l.paused),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: SketchButton(
              fill: context.palette.surfaceAccent,
              onTap: session.resume,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const DoodleIcon(Doodle.play),
                  const SizedBox(width: 8),
                  Text(l.keepPlaying, style: Txt.heading),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SketchButton(
                  onTap: () => settings.setMuted(!settings.muted),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DoodleIcon(settings.muted ? Doodle.soundOff : Doodle.soundOn),
                      const SizedBox(width: 6),
                      Text(settings.muted ? l.soundOff : l.soundOn, style: Txt.body),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SketchButton(
                  onTap: onQuit,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const DoodleIcon(Doodle.home),
                      const SizedBox(width: 6),
                      Text(l.games, style: Txt.body),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Music is the one sound a parent most often wants off mid-game.
          SizedBox(
            width: double.infinity,
            child: SketchButton(
              onTap: () => settings.setMusicOn(!settings.musicOn),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DoodleIcon(Doodle.music, color: settings.musicOn ? null : context.palette.inkSoft),
                  const SizedBox(width: 6),
                  Text(l.settingsMusic, style: Txt.body),
                  const SizedBox(width: 8),
                  DoodleIcon(settings.musicOn ? Doodle.check : Doodle.close, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(l.progressSaved, style: Txt.small.soft(context), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({super.key, required this.session});
  final GameSessionManager session;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final summary = session.summary ?? scope.rewards.summaryFor(session.round.roundId);
    final score = summary?.score ?? session.score.score;
    final gems = summary?.gemsEarned ?? 0;
    final eligibility = scope.rewards.canStartGame(session.def.gameId);
    final l = context.l10n;
    final p = context.palette;
    final cheer = score >= 40 ? l.cheerAmazing : (score >= RewardRules.pointsPerGem ? l.cheerGreat : l.cheerNice);
    return _Overlay(
      dim: 0.12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpriteView(
            size: const Size(240, 130),
            painter: (c, s) => SpriteCache.place(c, 'results-mascot-v2', s.center(Offset.zero), (c) {
              // Soft sunburst behind the cheering pencil.
              c.drawCircle(const Offset(0, 0), 58, Paint()..color = Ink.yellow.withValues(alpha: 0.14));
              for (var i = 0; i < 12; i++) {
                final a = -pi + i * pi / 11;
                final d = Offset(cos(a), sin(a));
                Pen.line(
                  c,
                  d * 50,
                  d * (i.isEven ? 64 : 58),
                  ink: Ink.gold.withValues(alpha: 0.8),
                  width: 2.4,
                  seed: i,
                );
              }
              c.save();
              c.scale(1.25);
              Props.mascot(c, mood: Mood.wow, cheer: true);
              c.restore();
              for (final (o, r) in [
                (const Offset(-78, -22), 11.0),
                (const Offset(-60, 14), 8.0),
                (const Offset(76, -30), 11.0),
                (const Offset(62, 10), 8.0),
              ]) {
                Pen.twinkle(c, o, r, Ink.gold);
                Pen.twinkle(c, o, r * 0.55, Ink.yellow);
              }
            }),
          ),
          _CheerTitle(cheer),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Dashes(left: true),
                const DoodleIcon(Doodle.star, size: 44),
                const SizedBox(width: 6),
                Text('$score', style: Txt.title.copyWith(fontSize: 44)),
                const SizedBox(width: 20),
                const GemIcon(size: 44),
                const SizedBox(width: 4),
                Text('+$gems', style: Txt.title.copyWith(fontSize: 44)),
                const _Dashes(left: false),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            gems == 0 ? l.scoreToEarnGem(RewardRules.pointsPerGem) : l.youEarnedGems(gems),
            style: Txt.body.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SketchBox(
            fill: p.tint(Ink.sky, 0.4),
            radius: 26,
            seed: 4,
            padding: const EdgeInsets.fromLTRB(22, 6, 8, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.myGems, style: Txt.body),
                const SizedBox(width: 14),
                GemChip(count: summary?.gemBalance ?? scope.rewards.getGemBalance()),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SketchButton(
                  fill: p.tint(Ink.sky, 0.45),
                  radius: 24,
                  onTap: () => Navigator.of(context).pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const DoodleIcon(Doodle.home),
                      const SizedBox(width: 6),
                      Text(l.games, style: Txt.heading),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SketchButton(
                  fill: p.tint(Ink.pink, 0.45),
                  radius: 24,
                  onTap: eligibility == StartEligibility.free || eligibility == StartEligibility.needsGem
                      ? () => Navigator.of(
                          context,
                        ).pushReplacement(MaterialPageRoute(builder: (_) => IntroScreen(gameId: session.def.gameId)))
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const DoodleIcon(Doodle.replay),
                      const SizedBox(width: 6),
                      Text(eligibility == StartEligibility.needsGem ? '1' : l.again, style: Txt.heading),
                      if (eligibility == StartEligibility.needsGem) const GemIcon(size: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (eligibility == StartEligibility.noGems) ...[
            const SizedBox(height: 8),
            Text(l.freePlaysDone, style: Txt.small.soft(context), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

/// Big yellow cheer word with a thick navy outline and a coral scribble.
class _CheerTitle extends StatelessWidget {
  const _CheerTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final base = Txt.title.copyWith(fontSize: 46, letterSpacing: 0.5);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedText([(text, Ink.yellow)], style: base),
            SizedBox(height: 14, child: CustomPaint(painter: ScribbleUnderline())),
          ],
        ),
      ),
    );
  }
}

/// Three little "ta-da" strokes beside the score.
class _Dashes extends StatelessWidget {
  const _Dashes({required this.left});
  final bool left;

  @override
  Widget build(BuildContext context) => SpriteView(
    size: const Size(28, 44),
    painter: (c, s) => SpriteCache.place(c, 'score-dashes-$left', s.center(Offset.zero), (c) {
      if (left) c.scale(-1, 1);
      for (final a in [-0.6, 0.0, 0.6]) {
        final d = Offset(cos(a), sin(a));
        Pen.line(
          c,
          d * 2 - const Offset(8, 0),
          d * 12 - const Offset(8, 0),
          ink: Ink.gold,
          width: 3,
          seed: (a * 10).round().abs() + 1,
        );
      }
    }),
  );
}
