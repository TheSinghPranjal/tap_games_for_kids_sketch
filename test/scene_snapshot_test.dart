import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:tap_games_for_kids_sketch/core/engine/game_canvas.dart';
import 'package:tap_games_for_kids_sketch/core/engine/game_scene.dart';
import 'package:tap_games_for_kids_sketch/games/catalog.dart';

/// Smoke-tests every scene: simulate, tap everywhere, paint without errors.
/// Set SNAPSHOT_DIR to also write PNGs for visual review.
void main() {
  final out = Platform.environment['SNAPSHOT_DIR'];
  for (final def in allGames) {
    testWidgets('scene ${def.gameId} runs and paints', (tester) async {
      final scene = def.create(def.scoreConfig);
      var points = 0;
      final keys = <String>{};
      scene.attach(
        GameContext(
          rng: math.Random(1),
          simple: false,
          reducedMotion: false,
          onScore: (p, k) {
            if (!keys.add(k)) return false;
            points += p;
            return true;
          },
          onSfx: (_) {},
        ),
      );
      final r = math.Random(2);
      for (var i = 0; i < 600; i++) {
        scene.update(1 / 60);
        if (i % 6 == 0) {
          scene.onTap(Offset(r.nextDouble() * 360, r.nextDouble() * 620));
        }
      }
      for (var i = 0; i < 40; i++) {
        scene.update(1 / 60);
      }
      expect(points, greaterThanOrEqualTo(0));
      scene.end();
      final before = points;
      for (var i = 0; i < 30; i++) {
        scene.onTap(Offset(r.nextDouble() * 360, r.nextDouble() * 620));
        scene.update(1 / 60);
      }
      expect(points, before, reason: 'no scoring after the round ends');

      final rec = ui.PictureRecorder();
      final canvas = ui.Canvas(rec);
      paintSceneSnapshot(canvas, scene);
      final pic = rec.endRecording();
      if (out != null) {
        await tester.runAsync(() async {
          final img = await pic.toImage(360, 620);
          final png = await img.toByteData(format: ui.ImageByteFormat.png);
          File('$out/${def.gameId}.png').writeAsBytesSync(png!.buffer.asUint8List());
          final trec = ui.PictureRecorder();
          def.thumbnail(ui.Canvas(trec), const ui.Size(170, 112));
          final timg = await trec.endRecording().toImage(170, 112);
          final tpng = await timg.toByteData(format: ui.ImageByteFormat.png);
          File('$out/${def.gameId}_thumb.png').writeAsBytesSync(tpng!.buffer.asUint8List());
        });
      }
    });
  }
}
