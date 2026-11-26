import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:tap_games_for_kids_sketch/core/engine/game_canvas.dart';
import 'package:tap_games_for_kids_sketch/core/engine/game_scene.dart';
import 'package:tap_games_for_kids_sketch/games/bouncy_balls.dart';
import 'package:tap_games_for_kids_sketch/games/feed_penguin.dart';
import 'package:tap_games_for_kids_sketch/games/fruit_market.dart';
import 'package:tap_games_for_kids_sketch/games/ice_cream_catch.dart';
import 'package:tap_games_for_kids_sketch/games/jellyfish_glow.dart';
import 'package:tap_games_for_kids_sketch/games/pond_path.dart';
import 'package:tap_games_for_kids_sketch/games/shape_box.dart';
import 'package:tap_games_for_kids_sketch/games/sleeping_monster.dart';
import 'package:tap_games_for_kids_sketch/games/sock_pairs.dart';
import 'package:tap_games_for_kids_sketch/games/sort_scene.dart';
import 'package:tap_games_for_kids_sketch/games/tidy_up.dart';
import 'package:tap_games_for_kids_sketch/games/water_plants.dart';

/// Drives the drag games the way a child would. Set SNAPSHOT_DIR for PNGs.
void main() {
  final out = Platform.environment['SNAPSHOT_DIR'];

  (GameScene, List<int>) start(GameScene scene) {
    final points = <int>[];
    final keys = <String>{};
    scene.attach(
      GameContext(
        rng: math.Random(3),
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

  testWidgets('ice cream: one scoop at a time, at least 1s apart, cone catches', (tester) async {
    final (scene, points) = start(iceCreamCatchGame.create(iceCreamCatchGame.scoreConfig));
    final s = scene as IceCreamCatchScene;
    var falling = false;
    double? goneAt;
    var shot = false;
    for (var i = 0; i < 60 * 40; i++) {
      final t = i / 60;
      s.update(1 / 60);
      final now = s.debugScoopX != null;
      if (now && !falling && goneAt != null) {
        expect(t - goneAt, greaterThanOrEqualTo(0.99), reason: 'next scoop waits at least 1s');
      }
      if (!now && falling) goneAt = t;
      falling = now;
      // Follow every other scoop with the cone so both catches and misses happen.
      final x = s.debugScoopX;
      if (x != null && s.debugScoopIndex.isEven) {
        expect(s.onDragStart(Offset(s.coneX, 540)), isTrue);
        s.onDragMove(Offset(x, 540));
        s.onDragEnd(Offset(x, 540));
      }
      if (!shot && x != null && s.debugScoopY > 300) {
        shot = true;
        await snap(tester, s, 'ice_cream_play');
      }
    }
    expect(s.caught, greaterThan(3));
    expect(points.length, s.caught);
  });

  testWidgets('jellyfish: dragging one off the edge saves it and scores', (tester) async {
    final (scene, points) = start(jellyfishGlowGame.create(jellyfishGlowGame.scoreConfig));
    final s = scene as JellyfishGlowScene;
    for (var i = 0; i < 60 * 12; i++) {
      s.update(1 / 60);
    }
    await snap(tester, s, 'jellyfish_stuck');
    final stuck = s.debugJellyPositions;
    expect(stuck, isNotEmpty);
    // Drag one only part way: it is not saved and swims back.
    final first = stuck.first;
    expect(s.onDragStart(first), isTrue);
    s.onDragMove(first + const Offset(20, 0));
    s.onDragEnd(first + const Offset(20, 0));
    expect(s.saved, 0);
    // Now drag each one right out to the side.
    for (final p in s.debugJellyPositions) {
      if (!s.onDragStart(p)) continue;
      final target = Offset(p.dx < 180 ? 8 : 352, p.dy);
      s.onDragMove(target);
      s.onDragEnd(target);
    }
    expect(s.saved, greaterThan(0));
    expect(points.length, s.saved);
    for (var i = 0; i < 20; i++) {
      s.update(1 / 60);
    }
    await snap(tester, s, 'jellyfish_saved');
  });

  testWidgets('bouncy balls: right bucket scores, wrong bucket bounces back', (tester) async {
    final (scene, points) = start(bouncyBallGame.create(bouncyBallGame.scoreConfig));
    final s = scene as BouncyBallScene;
    for (var i = 0; i < 60 * 5; i++) {
      s.update(1 / 60);
    }
    await snap(tester, s, 'bouncy_balls');
    final balls = s.debugBalls;
    expect(balls, isNotEmpty);
    // Every ball stays above the floor line while bouncing.
    for (final (p, _) in balls) {
      expect(p.dy, lessThanOrEqualTo(BouncyBallScene.floorY));
    }
    final (p0, c0) = balls.first;
    final wrong = s.bucketAt((c0 + 1) % 3);
    expect(s.onDragStart(p0), isTrue);
    s.onDragMove(wrong);
    s.onDragEnd(wrong);
    expect(points, isEmpty);
    for (var round = 0; round < 6; round++) {
      for (var i = 0; i < 40; i++) {
        s.update(1 / 60);
      }
      for (final (p, color) in s.debugBalls) {
        if (!s.onDragStart(p)) continue;
        s.onDragMove(s.bucketAt(color));
        s.onDragEnd(s.bucketAt(color));
      }
    }
    expect(s.sorted, greaterThan(2));
    expect(points.every((p) => p == bouncyBallGame.scoreConfig.base), isTrue);
  });

  for (final def in [fruitMarketGame, tidyUpGame, shapeBoxGame, sockPairGame]) {
    testWidgets('${def.gameId}: right bin scores, wrong bin returns, full batch gives the bonus', (tester) async {
      final (scene, points) = start(def.create(def.scoreConfig));
      final s = scene as SortScene;
      for (var i = 0; i < 30; i++) {
        s.update(1 / 60);
      }
      await snap(tester, s, '${def.gameId}_play');
      for (var batch = 0; batch < 3; batch++) {
        final items = s.debugItems;
        expect(items, isNotEmpty);
        // A wrong bin first: nothing scores and the item goes back.
        final (p0, k0) = items.first;
        final wrongBin = (s.binOf(k0) + 1) % s.binCount;
        expect(s.onDragStart(p0), isTrue);
        s.onDragMove(s.binRect(wrongBin).center);
        s.onDragEnd(s.binRect(wrongBin).center);
        final scored = points.length;
        for (var i = 0; i < 40; i++) {
          s.update(1 / 60);
        }
        for (final (p, kind) in s.debugItems) {
          final bin = s.binRect(s.binOf(kind)).center;
          expect(s.onDragStart(p), isTrue);
          s.onDragMove(bin);
          s.onDragEnd(bin);
        }
        expect(points.length, scored + items.length + 1, reason: 'one per item plus the batch bonus');
        expect(points.last, def.scoreConfig.bonus);
        for (var i = 0; i < 120; i++) {
          s.update(1 / 60);
        }
      }
      expect(s.batches, 3);
    });
  }

  testWidgets('water the plants: pour on thirsty plants, they grow, shrink and ask again', (tester) async {
    final (scene, points) = start(waterPlantsGame.create(waterPlantsGame.scoreConfig));
    final s = scene as WaterPlantsScene;
    s.update(1 / 60);
    expect(s.onDragStart(s.can), isTrue);
    var shot = false;
    for (var i = 0; i < 60 * 30; i++) {
      // Hold the can over whichever plant is thirsty.
      final thirsty = s.debugPlants.where((p) => p.$2 == 'thirsty');
      if (thirsty.isNotEmpty) s.onDragMove(Offset(thirsty.first.$1 + 44, 300));
      s.update(1 / 60);
      if (!shot && points.length == 2) {
        shot = true;
        await snap(tester, s, 'water_plants');
      }
    }
    s.onDragEnd(s.can);
    // Each plant cycles (thirsty -> bloom -> seedling) about every 8s.
    expect(points.length, greaterThanOrEqualTo(6));
    expect(points.every((p) => p == waterPlantsGame.scoreConfig.base), isTrue);
  });

  testWidgets('feed the penguin: reward only when the request is complete', (tester) async {
    final (scene, points) = start(feedPenguinGame.create(feedPenguinGame.scoreConfig));
    final s = scene as FeedPenguinScene;
    for (var meal = 0; meal < 3; meal++) {
      s.update(1 / 60);
      final want = s.request;
      // A fish dropped in the sea does not count.
      expect(s.onDragStart(FeedPenguinScene.pileAt), isTrue);
      s.onDragMove(const Offset(180, 600));
      s.onDragEnd(const Offset(180, 600));
      expect(s.eaten, 0);
      for (var i = 0; i < want; i++) {
        expect(points, hasLength(meal), reason: 'no reward before the meal is done');
        expect(s.onDragStart(FeedPenguinScene.pileAt), isTrue);
        s.onDragMove(FeedPenguinScene.mouth);
        s.onDragEnd(FeedPenguinScene.mouth);
        if (meal == 0 && i == 0) await snap(tester, s, 'feed_penguin');
      }
      expect(points.last, feedPenguinGame.scoreConfig.base * want);
      while (!s.debugReady) {
        s.update(1 / 60);
      }
    }
  });

  testWidgets('pond path: matching stones fill gaps, the frog hops across', (tester) async {
    final (scene, points) = start(pondPathGame.create(pondPathGame.scoreConfig));
    final s = scene as PondPathScene;
    for (var pond = 0; pond < 2; pond++) {
      s.update(1 / 60);
      final gaps = List.of(s.gaps);
      // Wrong shape into the first gap: rejected.
      final wrong = s.debugStones.firstWhere((st) => st.$2 != gaps[0]);
      expect(s.onDragStart(wrong.$1), isTrue);
      s.onDragMove(s.gapAt(0));
      s.onDragEnd(s.gapAt(0));
      expect(points, hasLength(pond * (gaps.length + 1)));
      for (var i = 0; i < 30; i++) {
        s.update(1 / 60);
      }
      for (var g = 0; g < gaps.length; g++) {
        final stone = s.debugStones.firstWhere((st) => st.$2 == gaps[g]);
        expect(s.onDragStart(stone.$1), isTrue);
        s.onDragMove(s.gapAt(g));
        s.onDragEnd(s.gapAt(g));
        expect(points.last, pondPathGame.scoreConfig.base);
        for (var i = 0; i < 40; i++) {
          s.update(1 / 60);
        }
        // After the last stone the frog carries straight on to the far bank.
        expect(
          s.frogStep,
          g == gaps.length - 1 ? greaterThanOrEqualTo(g) : g,
          reason: 'frog hops onto each stone once it is placed',
        );
        if (pond == 0 && g == 1) await snap(tester, s, 'pond_path_play');
      }
      for (var i = 0; i < 60; i++) {
        s.update(1 / 60);
      }
      expect(points.last, pondPathGame.scoreConfig.bonus);
      for (var i = 0; i < 120; i++) {
        s.update(1 / 60);
      }
    }
    expect(s.crossings, 2);
  });

  testWidgets("don't wake the monster: shoo by edge or flick, three pokes wake it", (tester) async {
    final (scene, points) = start(sleepingMonsterGame.create(sleepingMonsterGame.scoreConfig));
    final s = scene as SleepingMonsterScene;
    // Waits for a baby that has walked well inside the screen.
    Offset inside() {
      final safe = GameScene.worldRect.deflate(70);
      for (var i = 0; i < 60 * 20; i++) {
        for (final p in s.debugBabyPositions) {
          if (safe.contains(p)) return p;
        }
        s.update(1 / 60);
      }
      fail('no baby came on screen');
    }

    // A short nudge is not enough: the baby stays and sneaks back in.
    var b = inside();
    expect(s.onDragStart(b), isTrue);
    s.onDragMove(b + const Offset(10, 0));
    s.onDragEnd(b + const Offset(10, 0));
    expect(s.shooed, 0);
    expect(s.babies, isNotEmpty);
    // Dragging right to the edge shoos it.
    b = inside();
    expect(s.onDragStart(b), isTrue);
    s.onDragMove(const Offset(4, 300));
    s.onDragEnd(const Offset(4, 300));
    expect(s.shooed, 1);
    // A quick swipe in the middle of the screen also shoos it.
    b = inside();
    expect(s.onDragStart(b), isTrue);
    for (var i = 1; i <= 3; i++) {
      s.update(1 / 60);
      s.onDragMove(b + Offset(12.0 * i, 0));
    }
    s.onDragEnd(b + const Offset(36, 0));
    expect(s.shooed, 2);
    expect(points.length, 2);
    await snap(tester, s, 'monster_play');
    // Leave the babies alone: they poke, and the third poke wakes the monster.
    var woke = false;
    for (var i = 0; i < 60 * 40 && !woke; i++) {
      s.update(1 / 60);
      woke = s.awake;
    }
    expect(woke, isTrue);
    expect(s.naps, 1);
    expect(s.babies, isEmpty, reason: 'everyone runs in for a hug');
    expect(points.length, 2, reason: 'pokes never give points');
    await snap(tester, s, 'monster_awake');
    for (var i = 0; i < 60 * 3; i++) {
      s.update(1 / 60);
    }
    expect(s.awake, isFalse);
    expect(s.pokes, 0, reason: 'back to sleep with a full sleep meter');
  });
}
