import 'dart:async';

import 'package:flutter/foundation.dart';

import 'reward_models.dart';
import 'reward_store.dart';

export 'reward_models.dart';

typedef Clock = DateTime Function();

enum StartEligibility { free, needsGem, noGems, disabled }

enum StartStatus { started, needsConfirmation, noGems, disabled, failed }

class StartResult {
  const StartResult(this.status, {this.round, required this.gemBalance});
  final StartStatus status;
  final GameRound? round;
  final int gemBalance;
  bool get started => status == StartStatus.started;
}

class AwardResult {
  const AwardResult({
    required this.accepted,
    required this.roundScore,
    required this.gemsAwarded,
    required this.roundGems,
    required this.gemBalance,
  });
  final bool accepted;
  final int roundScore;

  /// Gems granted by this call (milestones crossed).
  final int gemsAwarded;
  final int roundGems;
  final int gemBalance;
}

class RoundSummary {
  const RoundSummary({
    required this.roundId,
    required this.gameId,
    required this.score,
    required this.gemsEarned,
    required this.gemBalance,
    required this.entryType,
  });
  final String roundId;
  final String gameId;
  final int score;
  final int gemsEarned;
  final int gemBalance;
  final EntryType entryType;
}

/// The single source of truth for gems, daily free plays and reward history.
/// Every game goes through this service; no game computes gems itself.
///
/// All mutations are serialised, persisted as one document, and rolled back
/// in memory if persistence fails, so a failed start never costs a gem.
class RewardService extends ChangeNotifier {
  RewardService({
    required RewardStore store,
    Clock? clock,
    bool Function(String gameId)? isGameEnabled,
    this.playerId = 'local-player',
  }) : _store = store,
       _clock = clock ?? DateTime.now,
       _isEnabled = isGameEnabled ?? ((_) => true);

  final RewardStore _store;
  final Clock _clock;
  final bool Function(String gameId) _isEnabled;
  final String playerId;

  late RewardState _state = RewardState(playerId: playerId);
  bool _ready = false;
  Future<void> _lock = Future.value();

  bool get isReady => _ready;

  Future<void> init() async {
    final doc = await _store.load();
    if (doc != null) _state = RewardState.fromJson(doc);
    // Rounds left active by a crash or a killed app still count as used;
    // gems already earned in them are kept.
    final orphaned = _state.rounds.values.where((r) => r.status == RoundStatus.active).toList();
    if (orphaned.isNotEmpty) {
      await _mutate(() {
        for (final r in orphaned) {
          r.status = RoundStatus.abandoned;
          r.completedAt = _clock();
          r.processedEvents.clear();
        }
      });
    }
    _ready = true;
    notifyListeners();
  }

  // ---------------------------------------------------------------- queries

  int getGemBalance() => _state.gemBalance;

  /// Local calendar date used for daily limits. Never moves backwards, so
  /// winding the clock back cannot unlock extra free plays.
  String today() {
    final real = localDateKey(_clock());
    final last = _state.lastSeenDate;
    return (last != null && real.compareTo(last) < 0) ? last : real;
  }

  DailyGameStats? _statsFor(String gameId) => _state.daily['${today()}|$gameId'];

  int freePlaysUsed(String gameId) => _statsFor(gameId)?.freePlaysUsed ?? 0;

  int getRemainingFreePlays(String gameId) =>
      (RewardRules.freePlaysPerDay - freePlaysUsed(gameId)).clamp(0, RewardRules.freePlaysPerDay);

  StartEligibility canStartGame(String gameId) {
    if (!_isEnabled(gameId)) return StartEligibility.disabled;
    if (getRemainingFreePlays(gameId) > 0) return StartEligibility.free;
    return _state.gemBalance >= RewardRules.extraRoundCost ? StartEligibility.needsGem : StartEligibility.noGems;
  }

  List<RewardTransaction> getRewardHistory() => List.unmodifiable(_state.transactions.reversed);

  Map<String, DailyGameStats> getDailyPlayStats() {
    final d = today();
    return {for (final s in _state.daily.values.where((s) => s.localDate == d)) s.gameId: s};
  }

  GameRound? round(String roundId) => _state.rounds[roundId];

  RoundSummary? summaryFor(String roundId) {
    final r = _state.rounds[roundId];
    if (r == null) return null;
    return RoundSummary(
      roundId: r.roundId,
      gameId: r.gameId,
      score: r.score,
      gemsEarned: r.gemsEarned,
      gemBalance: _state.gemBalance,
      entryType: r.entryType,
    );
  }

  /// Call when the app resumes so day-dependent UI refreshes.
  void refreshDay() => notifyListeners();

  // -------------------------------------------------------------- mutations

  /// Starts a round. Free rounds start immediately; once the three daily free
  /// rounds are used, the caller must pass [confirmSpend] after the child
  /// agrees to spend a gem. Repeating a [requestId] returns the same round
  /// instead of starting (or charging for) another.
  Future<StartResult> startGame(String gameId, {required String requestId, bool confirmSpend = false}) {
    return _synchronized(() async {
      final existing = _state.startRequests[requestId];
      if (existing != null && _state.rounds[existing] != null) {
        return StartResult(StartStatus.started, round: _state.rounds[existing], gemBalance: _state.gemBalance);
      }
      final eligibility = canStartGame(gameId);
      switch (eligibility) {
        case StartEligibility.disabled:
          return StartResult(StartStatus.disabled, gemBalance: _state.gemBalance);
        case StartEligibility.noGems:
          return StartResult(StartStatus.noGems, gemBalance: _state.gemBalance);
        case StartEligibility.needsGem when !confirmSpend:
          return StartResult(StartStatus.needsConfirmation, gemBalance: _state.gemBalance);
        case StartEligibility.free || StartEligibility.needsGem:
          break;
      }
      final paid = eligibility == StartEligibility.needsGem;
      try {
        final round = await _mutate(() {
          final now = _clock();
          final date = today();
          _state.lastSeenDate = date;
          final stats = _state.daily.putIfAbsent(
            '$date|$gameId',
            () => DailyGameStats(gameId: gameId, localDate: date),
          );
          final round = GameRound(
            roundId: _id('round'),
            playerId: playerId,
            gameId: gameId,
            startedAt: now,
            entryType: paid ? EntryType.gem : EntryType.free,
            localDate: date,
          );
          if (paid) {
            if (_state.gemBalance < RewardRules.extraRoundCost) throw StateError('Insufficient gems');
            _state.gemBalance -= RewardRules.extraRoundCost;
            stats.paidPlaysUsed++;
            _state.transactions.add(
              RewardTransaction(
                transactionId: _id('tx'),
                roundId: round.roundId,
                type: TxType.spent,
                amount: RewardRules.extraRoundCost,
                reason: 'extra round: $gameId',
                createdAt: now,
              ),
            );
          } else {
            stats.freePlaysUsed++;
          }
          _state.rounds[round.roundId] = round;
          _state.startRequests[requestId] = round.roundId;
          return round;
        });
        return StartResult(StartStatus.started, round: round, gemBalance: _state.gemBalance);
      } catch (e) {
        debugPrint('startGame failed: $e');
        return StartResult(StartStatus.failed, gemBalance: _state.gemBalance);
      }
    });
  }

  /// Adds [points] to an active round and grants one gem per 20-point
  /// milestone crossed. Repeating an [eventId] has no effect.
  Future<AwardResult> awardScore(String gameId, String roundId, int points, {required String eventId}) {
    return _synchronized(() async {
      final r = _state.rounds[roundId];
      AwardResult rejected() {
        final current = _state.rounds[roundId];
        return AwardResult(
          accepted: false,
          roundScore: current?.score ?? 0,
          gemsAwarded: 0,
          roundGems: current?.gemsEarned ?? 0,
          gemBalance: _state.gemBalance,
        );
      }

      if (r == null || r.gameId != gameId || r.status != RoundStatus.active) return rejected();
      if (points <= 0 || points > RewardRules.maxPointsPerEvent) return rejected();
      if (r.processedEvents.contains(eventId)) return rejected();

      var granted = 0;
      try {
        await _mutate(() {
          r.processedEvents.add(eventId);
          r.score += points;
          granted = _grantMilestones(r);
        });
      } catch (e) {
        debugPrint('awardScore failed: $e');
        return rejected();
      }
      return AwardResult(
        accepted: true,
        roundScore: r.score,
        gemsAwarded: granted,
        roundGems: r.gemsEarned,
        gemBalance: _state.gemBalance,
      );
    });
  }

  /// Finishes a round. Idempotent: completing again returns the stored
  /// summary without granting anything new. The service's own tally is
  /// authoritative; [finalScore] is only a consistency hint.
  Future<RoundSummary?> completeGame(String gameId, String roundId, int finalScore) {
    return _synchronized(() async {
      final r = _state.rounds[roundId];
      if (r == null || r.gameId != gameId) return null;
      if (r.status == RoundStatus.active) {
        if (finalScore != r.score) {
          debugPrint('completeGame: client score $finalScore differs from recorded ${r.score}');
        }
        try {
          await _mutate(() {
            _grantMilestones(r);
            r.status = RoundStatus.completed;
            r.completedAt = _clock();
            r.processedEvents.clear();
            final stats = _state.daily.putIfAbsent(
              '${r.localDate}|$gameId',
              () => DailyGameStats(gameId: gameId, localDate: r.localDate),
            );
            stats.totalScore += r.score;
            stats.totalRoundsCompleted++;
          });
        } catch (e) {
          debugPrint('completeGame failed: $e');
        }
      }
      return summaryFor(roundId);
    });
  }

  /// Test/parent helper to grant gems outside a round.
  Future<void> grantGems(int amount, {String reason = 'grant'}) {
    return _synchronized(
      () => _mutate(() {
        _state.gemBalance += amount;
        _state.transactions.add(
          RewardTransaction(
            transactionId: _id('tx'),
            roundId: '-',
            type: TxType.earned,
            amount: amount,
            reason: reason,
            createdAt: _clock(),
          ),
        );
      }),
    );
  }

  // ---------------------------------------------------------------- helpers

  int _grantMilestones(GameRound r) {
    final due = RewardRules.gemsForScore(r.score) - r.gemsEarned;
    if (due <= 0) return 0;
    r.gemsEarned += due;
    _state.gemBalance += due;
    _state.transactions.add(
      RewardTransaction(
        transactionId: _id('tx'),
        roundId: r.roundId,
        type: TxType.earned,
        amount: due,
        reason: 'score milestone ${RewardRules.gemsForScore(r.score) * RewardRules.pointsPerGem}',
        createdAt: _clock(),
      ),
    );
    return due;
  }

  String _id(String prefix) => '$prefix-${_clock().microsecondsSinceEpoch}-${++_state.seq}';

  Future<T> _synchronized<T>(Future<T> Function() fn) {
    final completer = Completer<T>();
    _lock = _lock.then((_) async {
      try {
        completer.complete(await fn());
      } catch (e, s) {
        completer.completeError(e, s);
      }
    });
    return completer.future;
  }

  /// Applies [change], persists the whole state, and rolls back on failure.
  Future<T> _mutate<T>(T Function() change) async {
    final snapshot = _state.toJson();
    try {
      final result = change();
      _state.updatedAt = _clock();
      _prune();
      await _store.save(_state.toJson());
      notifyListeners();
      return result;
    } catch (_) {
      _state = RewardState.fromJson(snapshot);
      rethrow;
    }
  }

  void _prune() {
    final cutoff = localDateKey(_clock().subtract(const Duration(days: 14)));
    _state.daily.removeWhere((_, s) => s.localDate.compareTo(cutoff) < 0 && s.localDate != _state.lastSeenDate);
    if (_state.transactions.length > 500) {
      _state.transactions.removeRange(0, _state.transactions.length - 500);
    }
    if (_state.rounds.length > 200) {
      final done = _state.rounds.values.where((r) => r.status != RoundStatus.active).toList()
        ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
      for (final r in done.take(_state.rounds.length - 200)) {
        _state.rounds.remove(r.roundId);
      }
    }
    while (_state.startRequests.length > 100) {
      _state.startRequests.remove(_state.startRequests.keys.first);
    }
  }
}
