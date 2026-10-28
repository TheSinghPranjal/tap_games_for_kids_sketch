import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../rewards/reward_service.dart';
import 'app_settings.dart';
import 'audio_manager.dart';
import 'game_definition.dart';
import 'game_scene.dart';

enum GameEventType {
  gameStarted,
  objectTapped,
  objectDragged,
  scoreChanged,
  gemAwarded,
  gamePaused,
  gameResumed,
  gameCompleted,
}

class GameEvent {
  const GameEvent(this.type, [this.value = 0]);
  final GameEventType type;
  final int value;
}

/// Tracks the round score locally for instant feedback and forwards each
/// unique scoring event to the [RewardService], which owns gem logic.
class ScoreManager extends ChangeNotifier {
  ScoreManager({required this.reward, required this.gameId, required this.roundId, this.onGems});

  final RewardService reward;
  final String gameId;
  final String roundId;
  final void Function(int gems)? onGems;

  int score = 0;

  /// Gems confirmed by the reward service for this round.
  int roundGems = 0;
  bool _closed = false;
  final _seen = <String>{};
  Future<void> _pending = Future.value();

  bool add(int points, String key) {
    if (_closed || points <= 0 || !_seen.add(key)) return false;
    score += points;
    notifyListeners();
    _pending = _pending.then((_) async {
      final r = await reward.awardScore(gameId, roundId, points, eventId: key);
      if (!r.accepted) return;
      roundGems = r.roundGems;
      if (r.gemsAwarded > 0) onGems?.call(r.gemsAwarded);
      notifyListeners();
    });
    return true;
  }

  /// Stops accepting events and waits for in-flight reward calls.
  Future<void> close() {
    _closed = true;
    return _pending;
  }

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

enum SessionPhase { playing, paused, finishing, finished }

/// Runs one round: timer, pause/resume, input routing and completion.
class GameSessionManager extends ChangeNotifier {
  GameSessionManager({
    required this.def,
    required this.reward,
    required this.round,
    required this.settings,
    required this.audio,
  }) {
    score = ScoreManager(
      reward: reward,
      gameId: def.gameId,
      roundId: round.roundId,
      onGems: (n) {
        audio.play(Sfx.gem);
        _emit(GameEventType.gemAwarded, n);
      },
    );
    score.addListener(notifyListeners);
    remaining = roundLength;
    scene = def.create(def.scoreConfig)
      ..attach(
        GameContext(
          rng: math.Random(),
          simple: settings.simpleMode,
          reducedMotion: settings.effectiveReducedMotion,
          onScore: (p, k) {
            final ok = phase == SessionPhase.playing && score.add(p, k);
            if (ok) _emit(GameEventType.scoreChanged, score.score);
            return ok;
          },
          onSfx: audio.play,
        ),
      );
    _emit(GameEventType.gameStarted);
  }

  final GameDefinition def;
  final RewardService reward;
  final GameRound round;
  final AppSettings settings;
  final AudioManager audio;

  late final ScoreManager score;
  late final GameScene scene;
  late double remaining;
  SessionPhase phase = SessionPhase.playing;
  RoundSummary? summary;
  double _finishLinger = 0;

  final _events = StreamController<GameEvent>.broadcast();
  Stream<GameEvent> get events => _events.stream;

  double get roundLength => def.roundSeconds * (settings.simpleMode ? 1.25 : 1.0);
  double get timeFraction => (remaining / roundLength).clamp(0.0, 1.0);
  bool get acceptsInput => phase == SessionPhase.playing;

  void _emit(GameEventType t, [int v = 0]) {
    if (!_events.isClosed) _events.add(GameEvent(t, v));
  }

  void update(double dt) {
    switch (phase) {
      case SessionPhase.playing:
        scene.update(dt);
        final before = remaining.ceil();
        remaining = math.max(0, remaining - dt);
        if (remaining.ceil() != before) notifyListeners();
        if (remaining <= 0) finish();
      case SessionPhase.finishing:
        // Let in-flight animations land while rewards are finalised.
        scene.update(dt);
        _finishLinger += dt;
      case SessionPhase.paused || SessionPhase.finished:
        break;
    }
  }

  void tap(Offset p) {
    if (!acceptsInput) return;
    _emit(GameEventType.objectTapped);
    scene.onTap(p);
  }

  bool dragStart(Offset p) => acceptsInput && scene.onDragStart(p);

  void dragMove(Offset p) {
    if (!acceptsInput) return;
    _emit(GameEventType.objectDragged);
    scene.onDragMove(p);
  }

  void dragEnd(Offset p) {
    if (acceptsInput) scene.onDragEnd(p);
  }

  void pause() {
    if (phase != SessionPhase.playing) return;
    phase = SessionPhase.paused;
    scene.cancelDrag();
    _emit(GameEventType.gamePaused);
    notifyListeners();
  }

  void resume() {
    if (phase != SessionPhase.paused) return;
    phase = SessionPhase.playing;
    _emit(GameEventType.gameResumed);
    notifyListeners();
  }

  /// Ends the round (timer, or child quitting). Safe to call repeatedly;
  /// rewards are completed exactly once by the RewardService.
  /// [linger] waits briefly so landing animations finish before results.
  Future<RoundSummary?> finish({bool linger = true}) async {
    if (phase == SessionPhase.finishing || phase == SessionPhase.finished) {
      return summary;
    }
    phase = SessionPhase.finishing;
    scene.end();
    notifyListeners();
    await score.close();
    summary = await reward.completeGame(def.gameId, round.roundId, score.score);
    // Give landing animations a moment before showing results.
    final wait = 0.6 - _finishLinger;
    if (linger && wait > 0) await Future<void>.delayed(Duration(milliseconds: (wait * 1000).round()));
    phase = SessionPhase.finished;
    _emit(GameEventType.gameCompleted, summary?.score ?? 0);
    notifyListeners();
    return summary;
  }

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    score.removeListener(notifyListeners);
    score.dispose();
    _events.close();
    super.dispose();
  }
}
