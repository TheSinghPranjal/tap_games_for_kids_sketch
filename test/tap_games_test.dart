import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:tap_games_for_kids_sketch/core/engine/game_canvas.dart';
import 'package:tap_games_for_kids_sketch/core/engine/game_scene.dart';
import 'package:tap_games_for_kids_sketch/core/rewards/reward_models.dart';
import 'package:tap_games_for_kids_sketch/games/cup_shuffle.dart';
import 'package:tap_games_for_kids_sketch/games/gem_mine.dart';
import 'package:tap_games_for_kids_sketch/games/pattern_eggs.dart';

/// Rule checks for the multi-step tap games. Set SNAPSHOT_DIR for PNGs.
void main() {
  final out = Platform.environment['SNAPSHOT_DIR'];

  (GameScene, List<int>) start(GameScene scene, {int seed = 3}) {
    final points = <int>[];
    final keys = <String>{};
    scene.attach(
      GameContext(
        rng: math.Random(seed),
        simple: false,
        reducedMotion: false,
        onScore: (p, k) {
          if (!keys.add(k)) return false;
          points.add(p);
          return true;
        },
        onSfx: (_) {},
      ),
    );
    return (scene, points);
  }

  Future<void> snap(WidgetTester tester, GameScene scene, String name) async {
    if (out == null) return;
    final rec = ui.PictureRecorder();
    paintSceneSnapshot(ui.Canvas(rec), scene);
    await tester.runAsync(() async {
      final img = await rec.endRecording().toImage(360, 620);
      final png = await img.toByteData(format: ui.ImageByteFormat.png);
      File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
    });
  }

  testWidgets('find the gem: tap counts, coins for wrong colours, one gem for the match', (tester) async {
    for (var seed = 1; seed <= 5; seed++) {
      final (scene, points) = start(gemMineGame.create(gemMineGame.scoreConfig), seed: seed);
      final s = scene as GemMineScene;
      s.update(1 / 60);
      final boxes = s.debugBoxes;
      expect(boxes.where((b) => b.$2 == s.target), hasLength(1), reason: 'exactly one matching box');
      for (final b in boxes) {
        expect(b.$3, inInclusiveRange(2, 5));
        expect(b.$4, inInclusiveRange(1, 2));
      }
      // Break every wrong box first, then the matching one.
      final ordered = [...boxes.where((b) => b.$2 != s.target), ...boxes.where((b) => b.$2 == s.target)];
      for (final (at, color, crateHits, colorHits) in ordered) {
        for (var i = 0; i < crateHits - 1; i++) {
          s.onTap(at);
          s.update(1 / 60);
        }
        expect(points.length, lessThan(ordered.length), reason: 'crate not broken yet');
        s.onTap(at); // crate breaks, coloured box appears
        s.update(1 / 60);
        if (seed == 1 && color == s.target) await snap(tester, s, 'gem_mine_reveal');
        final before = points.length;
        for (var i = 0; i < colorHits; i++) {
          s.onTap(at);
          s.update(1 / 60);
        }
        expect(points.length, before + 1);
        expect(points.last, color == s.target ? RewardRules.pointsPerGem : 10);
      }
      // The match is worth exactly one gem under the normal rule.
      expect(RewardRules.gemsForScore(points.last), 1);
      if (seed == 1) await snap(tester, s, 'gem_mine_found');
      // A fresh level follows.
      for (var i = 0; i < 120; i++) {
        s.update(1 / 60);
      }
      expect(s.debugBoxes, hasLength(9));
      if (seed == 1) await snap(tester, s, 'gem_mine_start');
    }
  });

  testWidgets('cup shuffle: slow swaps, only the ball cup scores', (tester) async {
    final (scene, points) = start(cupShuffleGame.create(cupShuffleGame.scoreConfig));
    final s = scene as CupShuffleScene;
    var shuffleTime = 0.0, shot = false;
    for (var round = 0; round < 4; round++) {
      while (s.debugPhase != 'choose') {
        s.update(1 / 60);
        if (s.debugPhase == 'shuffle') shuffleTime += 1 / 60;
        if (!shot && s.debugPhase == 'shuffle' && shuffleTime > 0.5) {
          shot = true;
          await snap(tester, s, 'cups_shuffle');
        }
      }
      // Cups are back on their three slots.
      final xs = s.debugCupPositions.map((p) => p.dx.round()).toList()..sort();
      expect(xs, [76, 180, 284]);
      if (round.isEven) {
        final wrong = s.debugCupPositions.firstWhere((p) => p != s.debugBallCupAt);
        s.onTap(wrong);
        expect(points, hasLength(round ~/ 2), reason: 'wrong cup gives nothing');
      } else {
        s.onTap(s.debugBallCupAt);
        expect(points.last, cupShuffleGame.scoreConfig.base);
      }
      for (var i = 0; i < 30; i++) {
        s.update(1 / 60);
      }
      if (round == 1) await snap(tester, s, 'cups_found');
      while (s.debugPhase == 'reveal') {
        s.update(1 / 60);
      }
    }
    expect(points, hasLength(2));
    // At least 3 swaps per round at ~1s each: the shuffle is slow.
    expect(shuffleTime / 4, greaterThan(3));
  });

  testWidgets('pattern eggs: six distinct eggs, wrong taps shake, right one scores', (tester) async {
    final (scene, points) = start(patternEggGame.create(patternEggGame.scoreConfig));
    final s = scene as PatternEggScene;
    for (var puzzle = 0; puzzle < 6; puzzle++) {
      s.update(1 / 60);
      expect(s.debugChoiceCount, 6);
      if (puzzle == 0) await snap(tester, s, 'pattern_eggs');
      final misses = puzzle.isOdd ? 1 : 0;
      for (var i = 0; i < misses; i++) {
        s.onTap(s.debugWrongAt.first);
      }
      final before = points.length;
      s.onTap(s.debugAnswerAt);
      expect(points.length, before + 1);
      expect(points.last, misses == 0 ? patternEggGame.scoreConfig.bonus : patternEggGame.scoreConfig.base);
      for (var i = 0; i < 120; i++) {
        s.update(1 / 60);
      }
    }
    expect(s.solved, 6);
  });
}
