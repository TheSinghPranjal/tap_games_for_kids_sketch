import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';

/// Scenery doodles. Each draws around the origin.
class Nature {
  Nature._();

  static Path _blobs(List<(Offset, double)> circles) {
    var p = Path();
    for (final (o, r) in circles) {
      p = Path.combine(PathOperation.union, p, Pen.circle(o, r));
    }
    return p;
  }

  static void cloud(Canvas c, double w, {Color fill = Ink.white, Color? hatch, int seed = 2}) {
    final s = w / 100;
    final path = _blobs([
      (Offset(-30 * s, 6 * s), 18 * s),
      (Offset(-8 * s, -6 * s), 24 * s),
      (Offset(18 * s, -2 * s), 20 * s),
      (Offset(34 * s, 9 * s), 14 * s),
      (Offset(4 * s, 12 * s), 18 * s),
    ]);
    Pen.shape(
      c,
      path,
      fill: fill,
      solid: true,
      hatch: hatch ?? Ink.sky.withValues(alpha: 0.5),
      hatchGap: 6,
      seed: seed,
    );
  }

  static void sun(Canvas c, double r, {bool face = true}) {
    final rays = Pen.inkPaint(Ink.orange, 2.4);
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi / 5 + 0.1;
      c.drawLine(Offset(math.cos(a), math.sin(a)) * (r * 1.25), Offset(math.cos(a), math.sin(a)) * (r * 1.6), rays);
    }
    Pen.shape(
      c,
      Pen.circle(Offset.zero, r),
      fill: Ink.yellow,
      solid: true,
      hatch: Ink.orange,
      cross: true,
      ink: Ink.orange,
      seed: 4,
    );
    if (face) Pen.face(c, const Offset(0, 2), r * 1.1, ink: Ink.pencil);
  }

  static void moon(Canvas c, double r) {
    final p = Path.combine(
      PathOperation.difference,
      Pen.circle(Offset.zero, r),
      Pen.circle(Offset(r * 0.55, -r * 0.25), r * 0.85),
    );
    Pen.shape(c, p, fill: Ink.yellow, solid: true, hatch: Ink.gold, ink: Ink.navy, seed: 5);
  }

  static void flower(Canvas c, Color color, {double r = 20, int petals = 5, bool face = true, int seed = 1}) {
    for (var i = 0; i < petals; i++) {
      final a = i * 2 * math.pi / petals - math.pi / 2;
      final o = Offset(math.cos(a), math.sin(a)) * (r * 0.62);
      c.save();
      c.translate(o.dx, o.dy);
      c.rotate(a + math.pi / 2);
      Pen.shape(c, Pen.oval(Offset.zero, r * 0.42, r * 0.58), fill: color, seed: seed + i, doubleLine: false, width: 2);
      c.restore();
    }
    Pen.shape(
      c,
      Pen.circle(Offset.zero, r * 0.42),
      fill: Ink.yellow,
      solid: true,
      hatch: Ink.orange,
      seed: seed + 9,
      width: 2,
    );
    if (face) Pen.face(c, Offset.zero, r * 0.62, blush: false);
  }

  static void bud(Canvas c, Color color, {double r = 14, int seed = 1}) {
    final p = Path()
      ..moveTo(0, -r * 1.3)
      ..quadraticBezierTo(r, -r * 0.4, r * 0.7, r * 0.5)
      ..quadraticBezierTo(0, r * 0.9, -r * 0.7, r * 0.5)
      ..quadraticBezierTo(-r, -r * 0.4, 0, -r * 1.3)
      ..close();
    Pen.shape(c, p, fill: color, seed: seed, width: 2);
    final sepal = Path()
      ..moveTo(-r * 0.8, r * 0.3)
      ..quadraticBezierTo(0, r * 1.2, r * 0.8, r * 0.3)
      ..quadraticBezierTo(0, r * 0.75, -r * 0.8, r * 0.3)
      ..close();
    Pen.shape(c, sepal, fill: Ink.mint, seed: seed + 3, width: 2, doubleLine: false);
  }

  static Path leafPath(double len, double width) => Path()
    ..moveTo(0, 0)
    ..quadraticBezierTo(len * 0.5, -width, len, 0)
    ..quadraticBezierTo(len * 0.5, width, 0, 0)
    ..close();

  static void leaf(Canvas c, double len, {Color color = Ink.mint, double width = 0.32, int seed = 1}) {
    Pen.shape(c, leafPath(len, len * width), fill: color, seed: seed, hatchAngle: -0.3);
    Pen.line(c, Offset(len * 0.05, 0), Offset(len * 0.85, 0), ink: Ink.shade(Ink.leaf, 0.3), width: 1.4, seed: seed);
    for (var i = 1; i < 4; i++) {
      final x = len * i / 4.5;
      c.drawLine(
        Offset(x, 0),
        Offset(x + len * 0.08, -len * width * 0.35),
        Pen.inkPaint(Ink.shade(Ink.leaf, 0.3).withValues(alpha: 0.7), 1.1),
      );
      c.drawLine(
        Offset(x, 0),
        Offset(x + len * 0.08, len * width * 0.35),
        Pen.inkPaint(Ink.shade(Ink.leaf, 0.3).withValues(alpha: 0.7), 1.1),
      );
    }
  }

  static void stem(Canvas c, double h, {int seed = 1, bool leaves = true}) {
    final p = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(4, -h * 0.5, 0, -h);
    Pen.stroke(c, p, ink: Ink.leaf, width: 3, seed: seed);
    if (leaves) {
      c.save();
      c.translate(1, -h * 0.35);
      c.rotate(-0.5);
      leaf(c, 18, seed: seed + 2);
      c.restore();
      c.save();
      c.translate(0, -h * 0.55);
      c.rotate(math.pi + 0.5);
      leaf(c, 15, seed: seed + 4);
      c.restore();
    }
  }

  static void grass(Canvas c, double w, {int seed = 1, Color color = Ink.leaf}) {
    final r = math.Random(seed);
    final p = Pen.inkPaint(color, 2);
    for (var x = -w / 2; x < w / 2; x += 6) {
      final h = 8 + r.nextDouble() * 10;
      c.drawLine(Offset(x, 0), Offset(x + r.nextDouble() * 6 - 3, -h), p);
    }
  }

  static void bush(Canvas c, double w, {Color color = Ink.mint, int seed = 3}) {
    final s = w / 100;
    final path = _blobs([
      (Offset(-28 * s, 4 * s), 22 * s),
      (Offset(0, -10 * s), 28 * s),
      (Offset(28 * s, 4 * s), 22 * s),
    ]);
    final cut = Path.combine(
      PathOperation.intersect,
      path,
      Path()..addRect(Rect.fromLTRB(-60 * s, -60 * s, 60 * s, 18 * s)),
    );
    Pen.shape(c, cut, fill: color, cross: true, seed: seed);
  }

  static void rock(Canvas c, double w, {int seed = 2, Color color = const Color(0xFFB8BCC8)}) {
    final p = Path()
      ..moveTo(-w / 2, w * 0.15)
      ..quadraticBezierTo(-w * 0.45, -w * 0.3, -w * 0.05, -w * 0.32)
      ..quadraticBezierTo(w * 0.45, -w * 0.3, w / 2, w * 0.15)
      ..close();
    Pen.shape(c, p, fill: color, seed: seed, width: 2);
  }

  static void lilyPad(Canvas c, double r, {int seed = 1, bool flower = false}) {
    final p = Path.combine(
      PathOperation.difference,
      Pen.oval(Offset.zero, r, r * 0.62),
      Path()
        ..moveTo(0, 0)
        ..lineTo(r * 1.2, -r * 0.25)
        ..lineTo(r * 1.2, r * 0.15)
        ..close(),
    );
    Pen.shape(c, p, fill: Ink.mint, seed: seed, width: 2);
    if (flower) {
      c.save();
      c.translate(-r * 0.25, -r * 0.1);
      c.scale(1, 0.8);
      Nature.flower(c, Ink.pink, r: r * 0.42, face: false, seed: seed + 5);
      c.restore();
    }
  }

  static void reed(Canvas c, double h, {int seed = 1}) {
    Pen.stroke(
      c,
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-3, -h * 0.6, 2, -h),
      ink: Ink.leaf,
      width: 2.6,
      seed: seed,
    );
    Pen.shape(
      c,
      Pen.rrect(Rect.fromCenter(center: Offset(2, -h + 8), width: 8, height: 20), 4),
      fill: Ink.brown,
      seed: seed,
    );
  }

  static void seaweed(Canvas c, double h, {int seed = 1, Color color = Ink.leaf}) {
    final p = Path()..moveTo(0, 0);
    final steps = (h / 18).round();
    for (var i = 1; i <= steps; i++) {
      final y = -h * i / steps;
      p.quadraticBezierTo(i.isEven ? 10 : -10, y + h / steps / 2, 0, y);
    }
    Pen.stroke(c, p, ink: color, width: 5, seed: seed);
    Pen.stroke(c, p.shift(const Offset(4, 0)), ink: Ink.shade(color, 0.2), width: 2, seed: seed + 3);
  }

  static void coral(Canvas c, Color color, {double h = 60, int seed = 1}) {
    final branches = [
      [const Offset(0, 0), Offset(0, -h)],
      [Offset(0, -h * 0.4), Offset(-h * 0.4, -h * 0.8)],
      [Offset(0, -h * 0.55), Offset(h * 0.38, -h * 0.9)],
      [Offset(-h * 0.2, -h * 0.6), Offset(-h * 0.25, -h * 0.95)],
    ];
    for (final b in branches) {
      Pen.line(c, b[0], b[1], ink: Ink.shade(color, 0.3), width: 9, seed: seed);
      Pen.line(c, b[0], b[1], ink: color, width: 6, seed: seed + 1);
      Pen.dot(c, b[1], 5, color);
    }
  }

  static void rainbow(Canvas c, double r) {
    final colors = [Ink.coral, Ink.orange, Ink.yellow, Ink.mint, Ink.blue, Ink.purple];
    for (var i = 0; i < colors.length; i++) {
      final rr = r - i * 9;
      final p = Path()..addArc(Rect.fromCircle(center: Offset.zero, radius: rr), math.pi, math.pi);
      Pen.stroke(c, p, ink: colors[i].withValues(alpha: 0.85), width: 8, seed: i + 1);
    }
    Pen.stroke(
      c,
      Path()..addArc(Rect.fromCircle(center: Offset.zero, radius: r + 4.5), math.pi, math.pi),
      ink: Ink.navy,
      width: 1.6,
      seed: 9,
    );
  }

  static void snowflake(Canvas c, double r, {Color color = Ink.white}) {
    final p = Pen.inkPaint(color, 1.6);
    for (var i = 0; i < 3; i++) {
      final a = i * math.pi / 3;
      final d = Offset(math.cos(a), math.sin(a)) * r;
      c.drawLine(-d, d, p);
    }
  }

  static void hill(Canvas c, double w, double h, {Color color = Ink.white, Color? hatch, int seed = 1}) {
    final p = Path()
      ..moveTo(-w / 2, 0)
      ..quadraticBezierTo(0, -h * 2, w / 2, 0)
      ..close();
    Pen.shape(c, p, fill: color, solid: true, hatch: hatch ?? Ink.sky.withValues(alpha: 0.6), seed: seed, width: 2);
  }

  static void starShape(Canvas c, double r, {Color color = Ink.yellow, bool face = true, int seed = 1}) {
    Pen.shape(
      c,
      Pen.star(Offset.zero, r, r * 0.5),
      fill: color,
      solid: true,
      hatch: Ink.shade(color, 0.15),
      seed: seed,
    );
    if (face) Pen.face(c, Offset(0, r * 0.08), r * 0.8, blush: true);
  }

  /// Round smiling planet with craters.
  static void planet(Canvas c, double r, {Color color = Ink.purple, int seed = 1}) {
    Pen.shape(
      c,
      Pen.circle(Offset.zero, r),
      fill: color,
      solid: true,
      hatch: Ink.shade(color, 0.15),
      seed: seed,
      width: 2.6,
    );
    for (final (o, cr) in [
      (const Offset(-0.45, -0.35), 0.16),
      (const Offset(0.5, 0.15), 0.12),
      (const Offset(-0.2, 0.55), 0.1),
    ]) {
      Pen.shape(
        c,
        Pen.circle(o * r, cr * r),
        fill: Ink.shade(color, 0.12),
        solid: true,
        width: 1.4,
        seed: seed + 3,
        doubleLine: false,
      );
    }
    Pen.face(c, Offset(r * 0.05, -r * 0.02), r * 0.7);
  }
}
