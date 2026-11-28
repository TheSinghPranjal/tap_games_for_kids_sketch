import 'dart:math' as math;

import 'common.dart';
import 'sort_scene.dart';

const _shapeColors = [Ink.coral, Ink.blue, Ink.yellow, Ink.mint, Ink.purple];
const _wood = Color(0xFFE2A866);

/// Shapes: 0 circle, 1 square, 2 triangle, 3 star.
Path _shapePath(int shape, double r) => switch (shape) {
  0 => Pen.circle(Offset.zero, r),
  1 => Pen.rrect(Rect.fromCenter(center: Offset.zero, width: r * 1.8, height: r * 1.8), 4),
  2 => Pen.poly([Offset(0, -r * 1.05), Offset(r * 1.05, r * 0.8), Offset(-r * 1.05, r * 0.8)]),
  _ => Pen.star(Offset.zero, r * 1.1, r * 0.5),
};

/// Push each chunky shape into the hole that has the same shape. Item kinds
/// are shape * 10 + colour so colours vary but only the shape matters.
class ShapeBoxScene extends SortScene {
  ShapeBoxScene(super.cfg);

  @override
  int get binCount => ctx.simple ? 3 : 4;

  @override
  Rect binRect(int bin) {
    final w = 300 / binCount;
    return Rect.fromCenter(center: Offset(30 + w * (bin + 0.5), 500), width: 70, height: 70);
  }

  @override
  int binOf(int kind) => kind ~/ 10;

  @override
  Rect get pileArea => const Rect.fromLTRB(50, 150, 310, 350);

  @override
  List<int> nextBatch() {
    final shapes = List.generate(binCount, (i) => i)..shuffle(rng);
    final n = ctx.simple ? 3 : 4;
    return [for (var i = 0; i < n; i++) shapes[i % shapes.length] * 10 + rng.nextInt(_shapeColors.length)];
  }

  @override
  void drawItem(Canvas c, int kind) {
    final color = _shapeColors[kind % 10];
    final p = _shapePath(kind ~/ 10, 26);
    Pen.shape(c, p.shift(const Offset(3, 4)), fill: Ink.shade(color, 0.3), solid: true, width: 0);
    Pen.shape(c, p, fill: color, solid: true, hatch: Ink.shade(color, 0.15), seed: kind);
    Pen.face(c, const Offset(0, 3), 22);
  }

  @override
  String wrongText(int bin) => tr.gameWrongShape;

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    Pen.shape(
      c,
      Pen.oval(const Offset(180, 250), 160, 120),
      fill: Ink.tint(Ink.sky, 0.35),
      solid: true,
      hatch: Ink.sky,
      seed: 5,
    );
    Pen.text(c, tr.gameMatchShapes, const Offset(180, 60), size: 24, maxWidth: 320);
    // The shape sorter box.
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(14, 440, 332, 150), 18),
      fill: _wood,
      solid: true,
      hatch: Ink.brown.withValues(alpha: 0.35),
      hatchAngle: 0,
      seed: 3,
      width: 2.8,
    );
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(6, 428, 348, 30), 12),
      fill: Ink.shade(_wood, 0.08),
      solid: true,
      seed: 4,
    );
    for (final x in [40.0, 320.0]) {
      Pen.dot(c, Offset(x, 568), 4, Ink.shade(Ink.brown, 0.3));
    }
  }

  @override
  void paintBins(Canvas c, List<double> bounce, int? glow) {
    for (var b = 0; b < binCount; b++) {
      final at = binRect(b).center;
      if (glow == b) c.drawCircle(at, 46, Pen.fillPaint(Ink.yellow.withValues(alpha: 0.4)));
      final s = 1 + math.sin(bounce[b] * math.pi) * 0.12;
      sprite(c, 'shape-hole-$b', at, (c) {
        Pen.shape(
          c,
          _shapePath(b, 30),
          fill: Ink.shade(_wood, 0.55),
          solid: true,
          hatch: Ink.navy.withValues(alpha: 0.4),
          seed: b + 6,
          width: 2.6,
        );
      }, scale: s);
    }
  }

  @override
  String get progressText => tr.progShapes(sorted);

  @override
  void paintProgressIcon(Canvas c, Size s) => sprite(
    c,
    'shape-icon',
    s.center(Offset.zero),
    (c) => Pen.shape(c, Pen.star(Offset.zero, 20, 9), fill: Ink.yellow, solid: true),
  );
}

final shapeBoxGame = GameDefinition(
  gameId: 'shape_box_puzzle',
  name: (l) => l.gameShapeBoxName,
  objective: (l) => l.gameShapeBoxGoal,
  instructions: (l) => l.gameShapeBoxHowTo,
  interactionType: Interaction.drag,
  accent: Ink.blue,
  scoreConfig: const ScoreConfig(base: 3, bonus: 8),
  assetManifest: const ['shape-sorter', 'shapes'],
  create: ShapeBoxScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s, wash: Ink.sand);
    Thumb.put(
      c,
      s,
      0.5,
      1.0,
      (c) => Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-200, -30, 400, 40), 8), fill: _wood, solid: true),
    );
    for (final (x, y, shape, col) in [(0.22, 0.42, 0, 0), (0.5, 0.36, 1, 1), (0.78, 0.44, 2, 2)]) {
      Thumb.put(c, s, x, y, (c) => Pen.shape(c, _shapePath(shape, 18), fill: _shapeColors[col], solid: true));
    }
  },
);
