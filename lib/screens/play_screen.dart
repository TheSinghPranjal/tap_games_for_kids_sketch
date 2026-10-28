import 'dart:async';

import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../art/objects.dart';
import '../core/engine/audio_manager.dart';
import '../core/engine/game_canvas.dart';
import '../core/engine/game_definition.dart';
import '../core/engine/game_session.dart';
import '../core/rewards/reward_service.dart';
import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';
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
                        child: GameCanvas(session: s),
                      ),
                    ),
                  ],
                ),
                if (s.phase == SessionPhase.paused) _PauseCard(session: s, onQuit: _quit),
                if (s.phase == SessionPhase.finished) _ResultsCard(session: s),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
      child: Row(
        children: [
          SketchButton(
            semanticLabel: 'Pause',
            padding: const EdgeInsets.all(10),
            onTap: session.acceptsInput ? session.pause : null,
            child: const DoodleIcon(Doodle.pause),
          ),
          const SizedBox(width: 8),
          SketchBox(
            fill: Ink.white,
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
  const _Overlay({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: ColoredBox(
      color: Ink.navy.withValues(alpha: 0.22),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SketchBox(fill: Ink.paperWarm, radius: 24, seed: 8, padding: const EdgeInsets.all(22), child: child),
          ),
        ),
      ),
    ),
  );
}

class _PauseCard extends StatelessWidget {
  const _PauseCard({required this.session, required this.onQuit});
  final GameSessionManager session;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    final settings = AppScope.of(context).settings;
    return _Overlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ScribbleTitle('Paused'),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: SketchButton(
              fill: Ink.blushPink,
              onTap: session.resume,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DoodleIcon(Doodle.play),
                  SizedBox(width: 8),
                  Text('Keep playing', style: Txt.heading),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SketchButton(
                  fill: Ink.white,
                  onTap: () => settings.setMuted(!settings.muted),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DoodleIcon(settings.muted ? Doodle.soundOff : Doodle.soundOn),
                      const SizedBox(width: 6),
                      Text(settings.muted ? 'Sound off' : 'Sound on', style: Txt.body),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SketchButton(
                  fill: Ink.white,
                  onTap: onQuit,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DoodleIcon(Doodle.home),
                      SizedBox(width: 6),
                      Text('Games', style: Txt.body),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Your stars and gems are saved.', style: Txt.small),
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.session});
  final GameSessionManager session;

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final summary = session.summary ?? scope.rewards.summaryFor(session.round.roundId);
    final score = summary?.score ?? session.score.score;
    final gems = summary?.gemsEarned ?? 0;
    final eligibility = scope.rewards.canStartGame(session.def.gameId);
    final cheer = score >= 40 ? 'Amazing!' : (score >= 20 ? 'Great job!' : 'Nice playing!');
    return _Overlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpriteView(
            size: const Size(110, 96),
            painter: (c, s) => SpriteCache.place(c, 'results-mascot', s.center(Offset.zero), (c) {
              Props.mascot(c, mood: Mood.wow);
              Pen.plus(c, const Offset(-40, -26), 6, Ink.gold);
              Pen.plus(c, const Offset(42, -12), 5, Ink.coral);
              Pen.twinkle(c, const Offset(36, -36), 7, Ink.yellow);
            }),
          ),
          ScribbleTitle(cheer),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const DoodleIcon(Doodle.star, size: 40),
              const SizedBox(width: 8),
              Text('$score', style: Txt.title.copyWith(fontSize: 40)),
              const SizedBox(width: 22),
              const GemIcon(size: 40),
              const SizedBox(width: 6),
              Text('+$gems', style: Txt.title.copyWith(fontSize: 40)),
            ],
          ),
          const SizedBox(height: 6),
          Text(gems == 0 ? 'Score 20 to earn a gem!' : 'You earned $gems gem${gems == 1 ? '' : 's'}!', style: Txt.note),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('My gems  ', style: Txt.body),
              GemChip(count: summary?.gemBalance ?? scope.rewards.getGemBalance()),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SketchButton(
                  fill: Ink.white,
                  onTap: () => Navigator.of(context).pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DoodleIcon(Doodle.home),
                      SizedBox(width: 6),
                      Text('Games', style: Txt.heading),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SketchButton(
                  fill: Ink.blushPink,
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
                      Text(eligibility == StartEligibility.needsGem ? '1' : 'Again', style: Txt.heading),
                      if (eligibility == StartEligibility.needsGem) const GemIcon(size: 22),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (eligibility == StartEligibility.noGems) ...[
            const SizedBox(height: 8),
            const Text('Free plays are done for today.', style: Txt.small),
          ],
        ],
      ),
    );
  }
}
