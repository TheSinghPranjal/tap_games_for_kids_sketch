import 'package:flutter_test/flutter_test.dart';
import 'package:tap_games_for_kids_sketch/core/rewards/reward_service.dart';
import 'package:tap_games_for_kids_sketch/core/rewards/reward_store.dart';

void main() {
  late MemoryRewardStore store;
  late DateTime now;
  late Set<String> disabled;

  RewardService make() => RewardService(store: store, clock: () => now, isGameEnabled: (id) => !disabled.contains(id));

  var req = 0;
  String nextReq() => 'req-${req++}';

  Future<GameRound> start(RewardService s, String game, {bool confirm = false}) async {
    final r = await s.startGame(game, requestId: nextReq(), confirmSpend: confirm);
    expect(r.status, StartStatus.started);
    return r.round!;
  }

  setUp(() async {
    store = MemoryRewardStore();
    now = DateTime(2026, 10, 28, 10);
    disabled = {};
  });

  group('Rule A: score to gem conversion', () {
    test('floor(score / 20)', () {
      const expected = {0: 0, 19: 0, 20: 1, 23: 1, 39: 1, 40: 2, 43: 2, 59: 2, 60: 3, 80: 4, 100: 5, 119: 5, 200: 10};
      expected.forEach((score, gems) => expect(RewardRules.gemsForScore(score), gems, reason: 'score $score'));
    });

    for (final entry in {19: 0, 20: 1, 39: 1, 40: 2, 60: 3}.entries) {
      test('a round scoring ${entry.key} earns ${entry.value} gems', () async {
        final s = make();
        await s.init();
        final r = await start(s, 'pond');
        var left = entry.key, i = 0;
        while (left > 0) {
          final p = left >= 7 ? 7 : left;
          await s.awardScore('pond', r.roundId, p, eventId: 'e${i++}');
          left -= p;
        }
        final sum = await s.completeGame('pond', r.roundId, entry.key);
        expect(sum!.score, entry.key);
        expect(sum.gemsEarned, entry.value);
        expect(s.getGemBalance(), entry.value);
      });
    }
  });

  group('Rule B: milestones', () {
    test('19 -> 23 awards exactly one gem', () async {
      final s = make();
      await s.init();
      final r = await start(s, 'pond');
      final a = await s.awardScore('pond', r.roundId, 19, eventId: 'a');
      expect(a.gemsAwarded, 0);
      final b = await s.awardScore('pond', r.roundId, 4, eventId: 'b');
      expect(b.gemsAwarded, 1);
      expect(s.getGemBalance(), 1);
    });

    test('one event crossing several milestones awards all of them', () async {
      final s = make();
      await s.init();
      final r = await start(s, 'pond');
      await s.awardScore('pond', r.roundId, 15, eventId: 'a');
      final b = await s.awardScore('pond', r.roundId, 47, eventId: 'b'); // 15 -> 62
      expect(b.gemsAwarded, 3);
      expect(b.roundGems, 3);
      expect(s.getGemBalance(), 3);
    });

    test('duplicate score events are ignored', () async {
      final s = make();
      await s.init();
      final r = await start(s, 'pond');
      await s.awardScore('pond', r.roundId, 20, eventId: 'fish-1');
      final dup = await s.awardScore('pond', r.roundId, 20, eventId: 'fish-1');
      expect(dup.accepted, isFalse);
      expect(s.round(r.roundId)!.score, 20);
      expect(s.getGemBalance(), 1);
    });

    test('invalid point values are rejected', () async {
      final s = make();
      await s.init();
      final r = await start(s, 'pond');
      expect((await s.awardScore('pond', r.roundId, 0, eventId: 'a')).accepted, isFalse);
      expect((await s.awardScore('pond', r.roundId, -5, eventId: 'b')).accepted, isFalse);
      expect((await s.awardScore('pond', r.roundId, 999, eventId: 'c')).accepted, isFalse);
      expect((await s.awardScore('other', r.roundId, 5, eventId: 'd')).accepted, isFalse);
    });
  });

  group('Rule C/D: daily free plays and gem spending', () {
    test('three free rounds per game, fourth needs a gem', () async {
      final s = make();
      await s.init();
      expect(s.getRemainingFreePlays('pond'), 3);
      for (var i = 0; i < 3; i++) {
        final r = await start(s, 'pond');
        expect(r.entryType, EntryType.free);
      }
      expect(s.getRemainingFreePlays('pond'), 0);
      expect(s.canStartGame('pond'), StartEligibility.noGems);
      final res = await s.startGame('pond', requestId: nextReq(), confirmSpend: true);
      expect(res.status, StartStatus.noGems);
      expect(s.getGemBalance(), 0);
    });

    test('counts are independent per game', () async {
      final s = make();
      await s.init();
      for (var i = 0; i < 3; i++) {
        await start(s, 'pond');
      }
      expect(s.canStartGame('butterfly'), StartEligibility.free);
      expect((await start(s, 'butterfly')).entryType, EntryType.free);
    });

    test('paid round requires confirmation and costs exactly one gem', () async {
      final s = make();
      await s.init();
      await s.grantGems(7);
      for (var i = 0; i < 3; i++) {
        await start(s, 'pond');
      }
      expect(s.getGemBalance(), 7);
      final unconfirmed = await s.startGame('pond', requestId: nextReq());
      expect(unconfirmed.status, StartStatus.needsConfirmation);
      expect(s.getGemBalance(), 7, reason: 'never charge silently');

      final r = await start(s, 'pond', confirm: true);
      expect(r.entryType, EntryType.gem);
      expect(s.getGemBalance(), 6);
      final spent = s.getRewardHistory().where((t) => t.type == TxType.spent).toList();
      expect(spent, hasLength(1));
      expect(spent.single.amount, 1);
      expect(spent.single.roundId, r.roundId);
      expect(s.getDailyPlayStats()['pond']!.paidPlaysUsed, 1);
    });

    test('free rounds never cost gems even when confirmSpend is passed', () async {
      final s = make();
      await s.init();
      await s.grantGems(2);
      await start(s, 'pond', confirm: true);
      expect(s.getGemBalance(), 2);
    });

    test('balance never goes negative', () async {
      final s = make();
      await s.init();
      await s.grantGems(1);
      for (var i = 0; i < 3; i++) {
        await start(s, 'pond');
      }
      await start(s, 'pond', confirm: true);
      expect(s.getGemBalance(), 0);
      final again = await s.startGame('pond', requestId: nextReq(), confirmSpend: true);
      expect(again.status, StartStatus.noGems);
      expect(s.getGemBalance(), 0);
    });

    test('rapid repeated Start with one request id charges once', () async {
      final s = make();
      await s.init();
      await s.grantGems(5);
      for (var i = 0; i < 3; i++) {
        await start(s, 'pond');
      }
      final results = await Future.wait([
        for (var i = 0; i < 5; i++) s.startGame('pond', requestId: 'same-tap', confirmSpend: true),
      ]);
      expect(results.every((r) => r.started), isTrue);
      expect(results.map((r) => r.round!.roundId).toSet(), hasLength(1));
      expect(s.getGemBalance(), 4);
    });

    test('concurrent free starts with different requests never exceed the limit', () async {
      final s = make();
      await s.init();
      final results = await Future.wait([for (var i = 0; i < 6; i++) s.startGame('pond', requestId: 'r$i')]);
      expect(results.where((r) => r.started), hasLength(3));
      expect(results.where((r) => r.status == StartStatus.noGems), hasLength(3));
    });

    test('failed initialisation does not deduct a gem or use a free play', () async {
      final s = make();
      await s.init();
      await s.grantGems(3);
      store.failNextSaves = 1;
      final failedFree = await s.startGame('pond', requestId: nextReq());
      expect(failedFree.status, StartStatus.failed);
      expect(s.getRemainingFreePlays('pond'), 3);

      for (var i = 0; i < 3; i++) {
        await start(s, 'pond');
      }
      store.failNextSaves = 1;
      final failedPaid = await s.startGame('pond', requestId: nextReq(), confirmSpend: true);
      expect(failedPaid.status, StartStatus.failed);
      expect(s.getGemBalance(), 3);
      expect(s.getRewardHistory().where((t) => t.type == TxType.spent), isEmpty);
    });

    test('disabled games cannot start', () async {
      final s = make();
      await s.init();
      disabled.add('pond');
      final r = await s.startGame('pond', requestId: nextReq());
      expect(r.status, StartStatus.disabled);
      expect(s.getRemainingFreePlays('pond'), 3);
    });
  });

  group('Rule E: no refunds', () {
    test('quitting a paid round early keeps it used and the gem spent', () async {
      final s = make();
      await s.init();
      await s.grantGems(2);
      for (var i = 0; i < 3; i++) {
        await start(s, 'pond');
      }
      final r = await start(s, 'pond', confirm: true);
      await s.completeGame('pond', r.roundId, 0);
      expect(s.getGemBalance(), 1);
    });

    test('a round left active by a crash is abandoned on restart but keeps gems', () async {
      var s = make();
      await s.init();
      final r = await start(s, 'pond');
      await s.awardScore('pond', r.roundId, 25, eventId: 'a');
      // App killed here. Relaunch:
      s = make();
      await s.init();
      expect(s.getGemBalance(), 1);
      expect(s.getRemainingFreePlays('pond'), 2);
      expect(s.round(r.roundId)!.status, RoundStatus.abandoned);
      final late = await s.awardScore('pond', r.roundId, 20, eventId: 'b');
      expect(late.accepted, isFalse);
    });
  });

  group('Rule F: daily reset', () {
    test('counters reset on a new local day, gems do not', () async {
      final s = make();
      await s.init();
      final r = await start(s, 'pond');
      await s.awardScore('pond', r.roundId, 40, eventId: 'a');
      await start(s, 'pond');
      await start(s, 'pond');
      expect(s.getRemainingFreePlays('pond'), 0);

      now = DateTime(2026, 10, 28, 23, 59, 59);
      expect(s.getRemainingFreePlays('pond'), 0);
      now = DateTime(2026, 10, 29, 0, 0, 1);
      expect(s.getRemainingFreePlays('pond'), 3);
      expect(s.getGemBalance(), 2);
    });

    test('restart on the same day does not reset counts', () async {
      var s = make();
      await s.init();
      await start(s, 'pond');
      await start(s, 'pond');
      s = make();
      await s.init();
      expect(s.getRemainingFreePlays('pond'), 1);
    });

    test('moving the clock backwards does not unlock free plays', () async {
      final s = make();
      await s.init();
      for (var i = 0; i < 3; i++) {
        await start(s, 'pond');
      }
      now = DateTime(2026, 10, 27, 12);
      expect(s.today(), '2026-10-28');
      expect(s.getRemainingFreePlays('pond'), 0);
    });
  });

  group('completion', () {
    test('completing twice never awards twice', () async {
      final s = make();
      await s.init();
      final r = await start(s, 'pond');
      await s.awardScore('pond', r.roundId, 45, eventId: 'a');
      final a = await s.completeGame('pond', r.roundId, 45);
      final b = await s.completeGame('pond', r.roundId, 45);
      expect(a!.gemsEarned, 2);
      expect(b!.gemsEarned, 2);
      expect(s.getGemBalance(), 2);
      expect(s.getDailyPlayStats()['pond']!.totalRoundsCompleted, 1);
      expect(s.getDailyPlayStats()['pond']!.totalScore, 45);
    });

    test('scores after completion are rejected', () async {
      final s = make();
      await s.init();
      final r = await start(s, 'pond');
      await s.completeGame('pond', r.roundId, 0);
      final late = await s.awardScore('pond', r.roundId, 20, eventId: 'x');
      expect(late.accepted, isFalse);
      expect(s.getGemBalance(), 0);
    });

    test('everything persists across restarts', () async {
      var s = make();
      await s.init();
      final r = await start(s, 'pond');
      await s.awardScore('pond', r.roundId, 30, eventId: 'a');
      await s.awardScore('pond', r.roundId, 30, eventId: 'b');
      await s.completeGame('pond', r.roundId, 60);
      s = make();
      await s.init();
      expect(s.getGemBalance(), 3);
      expect(s.getRewardHistory().first.type, TxType.earned);
      expect(s.summaryFor(r.roundId)!.score, 60);
    });
  });
}
