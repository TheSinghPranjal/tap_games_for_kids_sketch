import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';

/// Friendly doodle animals and characters, drawn around the origin.
class Critters {
  Critters._();

  /// Fish facing right, ~60x32.
  static void fish(Canvas c, Color color, {int seed = 1}) {
    final tail = Path()
      ..moveTo(-16, 0)
      ..lineTo(-32, -12)
      ..quadraticBezierTo(-27, 0, -32, 12)
      ..close();
    Pen.shape(c, tail, fill: color, seed: seed + 2, width: 2);
    final fin = Path()
      ..moveTo(-6, -12)
      ..quadraticBezierTo(2, -24, 10, -12)
      ..close();
    Pen.shape(c, fin, fill: color, seed: seed + 4, width: 2, doubleLine: false);
    Pen.shape(c, Pen.oval(Offset.zero, 23, 14), fill: color, seed: seed, hatchAngle: 1.0);
    c.drawArc(
      const Rect.fromLTWH(-8, -9, 10, 18),
      -1.2,
      2.4,
      false,
      Pen.inkPaint(Ink.navy.withValues(alpha: 0.6), 1.5),
    );
    Pen.dot(c, const Offset(12, -3), 3.2, Ink.pencil);
    Pen.dot(c, const Offset(11, -4.2), 1.1, Ink.white);
    c.drawArc(const Rect.fromLTWH(12, 1, 7, 5), 0.2, 2.4, false, Pen.inkPaint(Ink.pencil, 1.6));
    c.drawOval(
      Rect.fromCenter(center: const Offset(8, 4), width: 6, height: 3.5),
      Pen.fillPaint(Ink.pink.withValues(alpha: 0.7)),
    );
  }

  /// Baby penguin, ~70 tall, standing with feet at y=36.
  static void penguin(Canvas c, {Mood mood = Mood.happy}) {
    for (final dx in [-10.0, 10.0]) {
      Pen.shape(c, Pen.oval(Offset(dx, 34), 9, 4), fill: Ink.orange, solid: true, seed: 3, width: 1.8);
    }
    for (final s in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(s * 20, -6)
        ..quadraticBezierTo(s * 34, 8, s * 26, 22)
        ..quadraticBezierTo(s * 20, 14, s * 20, -6)
        ..close();
      Pen.shape(c, wing, fill: Ink.navySoft, seed: 5, width: 2);
    }
    Pen.shape(c, Pen.oval(const Offset(0, 4), 24, 32), fill: Ink.navySoft, cross: true, seed: 1);
    Pen.shape(
      c,
      Pen.oval(const Offset(0, 10), 16, 22),
      fill: Ink.white,
      solid: true,
      hatch: Ink.sky.withValues(alpha: 0.4),
      seed: 2,
    );
    Pen.shape(c, Pen.oval(const Offset(0, -12), 14, 11), fill: Ink.white, solid: true, width: 0);
    Pen.face(c, const Offset(0, -12), 26, mood: mood == Mood.chomp ? Mood.happy : mood);
    final beak = mood == Mood.chomp
        ? (Path()
            ..moveTo(-5, -7)
            ..lineTo(0, -1)
            ..lineTo(5, -7)
            ..lineTo(0, -4)
            ..close())
        : (Path()
            ..moveTo(-4, -8)
            ..lineTo(4, -8)
            ..lineTo(0, -3)
            ..close());
    Pen.shape(c, beak, fill: Ink.orange, solid: true, width: 1.6, seed: 4);
  }

  /// Bee body (wings drawn separately so they can flap), ~40 wide.
  static void bee(Canvas c) {
    final body = Pen.oval(Offset.zero, 18, 13);
    final rb = Pen.rough(body, seed: 3);
    c.drawPath(rb, Pen.fillPaint(Ink.yellow));
    c.save();
    c.clipPath(rb);
    final stripe = Pen.inkPaint(Ink.pencil, 4.5);
    for (final x in [-8.0, 0.0]) {
      c.drawLine(Offset(x, -14), Offset(x + 2, 14), stripe);
    }
    c.restore();
    c.drawPath(rb, Pen.inkPaint(Ink.navy, 2.2));
    Pen.line(c, const Offset(-18, 0), const Offset(-24, 1), width: 2);
    Pen.face(c, const Offset(9, -1), 15);
    for (final dx in [8.0, 13.0]) {
      Pen.line(c, Offset(dx, -11), Offset(dx + 3, -18), width: 1.4);
      Pen.dot(c, Offset(dx + 3, -18), 1.8, Ink.navy);
    }
  }

  static void beeWings(Canvas c, double flap) {
    final p = Paint()..color = Ink.white.withValues(alpha: 0.85);
    final ink = Pen.inkPaint(Ink.navy.withValues(alpha: 0.7), 1.4);
    for (final dx in [-6.0, 2.0]) {
      final r = Rect.fromCenter(center: Offset(dx, -15), width: 13, height: 18 * flap);
      c.drawOval(r, p);
      c.drawOval(r, ink);
    }
  }

  /// Ladybug viewed from above, head pointing up (-y), ~34 wide.
  static void ladybug(Canvas c, {bool golden = false, double open = 0}) {
    final shell = golden ? Ink.gold : Ink.coral;
    Pen.shape(c, Pen.oval(const Offset(0, -15), 9, 7), fill: Ink.pencil, solid: true, seed: 2, width: 1.8);
    for (final s in [-1.0, 1.0]) {
      for (final y in [-6.0, 2.0, 10.0]) {
        Pen.line(c, Offset(s * 12, y), Offset(s * 19, y + 2), ink: Ink.pencil, width: 1.6);
      }
    }
    if (open > 0) {
      for (final s in [-1.0, 1.0]) {
        c.drawOval(
          Rect.fromCenter(center: Offset(s * 9, 2), width: 12, height: 26),
          Pen.fillPaint(Ink.white.withValues(alpha: 0.7)),
        );
      }
    }
    for (final s in [-1.0, 1.0]) {
      c.save();
      c.translate(0, -8);
      c.rotate(s * open * 0.7);
      final half = Path()
        ..moveTo(0, 0)
        ..arcTo(Rect.fromCenter(center: const Offset(0, 9), width: 30, height: 30), -math.pi / 2, s * math.pi, false)
        ..close();
      Pen.shape(c, half, fill: shell, solid: true, hatch: Ink.shade(shell, 0.2), seed: s > 0 ? 3 : 4, width: 2);
      for (final o in [Offset(s * 6, 4), Offset(s * 9, 14), Offset(s * 4, 19)]) {
        Pen.dot(c, o, 2.8, golden ? Ink.white : Ink.pencil);
      }
      c.restore();
    }
    Pen.dot(c, const Offset(-3, -17), 1.6, Ink.white);
    Pen.dot(c, const Offset(3, -17), 1.6, Ink.white);
  }

  /// One right-hand butterfly wing pair; mirror with scale(-1, 1).
  static void butterflyWing(Canvas c, Color color, {int seed = 1}) {
    final upper = Path()
      ..moveTo(0, -2)
      ..cubicTo(10, -26, 30, -24, 26, -8)
      ..quadraticBezierTo(22, 0, 0, 2)
      ..close();
    final lower = Path()
      ..moveTo(0, 2)
      ..cubicTo(18, 2, 24, 18, 12, 20)
      ..quadraticBezierTo(4, 20, 0, 4)
      ..close();
    Pen.shape(c, upper, fill: color, seed: seed, width: 2);
    Pen.shape(c, lower, fill: Ink.shade(color, 0.05), seed: seed + 2, width: 2);
    Pen.dot(c, const Offset(16, -11), 3.5, Ink.white.withValues(alpha: 0.9));
    Pen.dot(c, const Offset(10, 11), 2.5, Ink.white.withValues(alpha: 0.9));
  }

  static void butterflyBody(Canvas c) {
    Pen.shape(c, Pen.oval(Offset.zero, 4, 14), fill: Ink.pencil, solid: true, width: 1.6, seed: 2);
    Pen.stroke(
      c,
      Path()
        ..moveTo(-1, -12)
        ..quadraticBezierTo(-5, -20, -8, -22),
      width: 1.4,
    );
    Pen.stroke(
      c,
      Path()
        ..moveTo(1, -12)
        ..quadraticBezierTo(5, -20, 8, -22),
      width: 1.4,
    );
  }

  static void butterfly(Canvas c, Color color, double flap, {int seed = 1}) {
    for (final s in [-1.0, 1.0]) {
      c.save();
      c.scale(s * flap, 1);
      butterflyWing(c, color, seed: seed);
      c.restore();
    }
    butterflyBody(c);
  }

  /// Owl perched with feet at y=30, ~60 tall.
  static void owl(Canvas c, Color color, {bool awake = false, int seed = 1}) {
    final body = Path()
      ..moveTo(-22, -16)
      ..lineTo(-18, -32)
      ..lineTo(-8, -22)
      ..quadraticBezierTo(0, -25, 8, -22)
      ..lineTo(18, -32)
      ..lineTo(22, -16)
      ..quadraticBezierTo(30, 14, 0, 28)
      ..quadraticBezierTo(-30, 14, -22, -16)
      ..close();
    Pen.shape(c, body, fill: color, cross: true, seed: seed);
    Pen.shape(
      c,
      Pen.oval(const Offset(0, 10), 13, 15),
      fill: Ink.cream,
      solid: true,
      hatch: Ink.tint(color, 0.6),
      seed: seed + 1,
      width: 1.6,
    );
    for (var i = 0; i < 3; i++) {
      c.drawArc(
        Rect.fromCenter(center: Offset(-5 + i * 5.0, 6 + (i % 2) * 6.0), width: 6, height: 5),
        0.2,
        2.6,
        false,
        Pen.inkPaint(Ink.navy.withValues(alpha: 0.6), 1.2),
      );
    }
    for (final dx in [-9.0, 9.0]) {
      final eye = Offset(dx, -10);
      Pen.shape(c, Pen.circle(eye, 8), fill: Ink.white, solid: true, width: 1.8, seed: seed + 3, doubleLine: false);
      if (awake) {
        Pen.dot(c, eye, 4.2, Ink.pencil);
        Pen.dot(c, eye.translate(-1.4, -1.6), 1.5, Ink.white);
      } else {
        c.drawArc(
          Rect.fromCenter(center: eye.translate(0, -1), width: 10, height: 7),
          0.2,
          math.pi - 0.4,
          false,
          Pen.inkPaint(Ink.pencil, 2),
        );
      }
    }
    Pen.shape(
      c,
      Pen.poly(const [Offset(-3, -4), Offset(3, -4), Offset(0, 2)]),
      fill: Ink.orange,
      solid: true,
      width: 1.4,
      seed: 4,
    );
    for (final dx in [-7.0, 7.0]) {
      Pen.line(c, Offset(dx - 3, 28), Offset(dx - 3, 32), ink: Ink.orange, width: 2.4);
      Pen.line(c, Offset(dx + 3, 28), Offset(dx + 3, 32), ink: Ink.orange, width: 2.4);
    }
  }

  static void owlWing(Canvas c, Color color) {
    final p = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(16, 6, 12, 26)
      ..quadraticBezierTo(2, 18, 0, 0)
      ..close();
    Pen.shape(c, p, fill: Ink.shade(color, 0.1), seed: 7, width: 1.8);
  }

  /// Turtle viewed from above, head pointing right, ~56 wide.
  static void turtle(Canvas c, Color shell, {int seed = 1, double paddle = 0}) {
    for (final (o, a) in [
      (const Offset(12, -15), -0.6),
      (const Offset(12, 15), 0.6),
      (const Offset(-14, -13), -2.4),
      (const Offset(-14, 13), 2.4),
    ]) {
      c.save();
      c.translate(o.dx, o.dy);
      c.rotate(a + paddle * (o.dx > 0 ? 1 : -1));
      Pen.shape(c, Pen.oval(const Offset(6, 0), 9, 5), fill: Ink.mint, seed: seed + 1, width: 1.8, doubleLine: false);
      c.restore();
    }
    Pen.shape(c, Pen.circle(const Offset(27, 0), 10), fill: Ink.mint, seed: seed + 2, width: 2);
    Pen.face(c, const Offset(29, 0), 16);
    Pen.shape(c, Pen.oval(Offset.zero, 22, 18), fill: shell, seed: seed);
    final pat = Pen.inkPaint(Ink.shade(shell, 0.45), 1.6);
    final hex = Pen.poly([
      for (var i = 0; i < 6; i++) Offset(math.cos(i * math.pi / 3), math.sin(i * math.pi / 3)) * 8,
    ]);
    c.drawPath(Pen.rough(hex, seed: 3), pat);
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      c.drawLine(Offset(math.cos(a), math.sin(a)) * 8, Offset(math.cos(a), math.sin(a)) * 16, pat);
    }
  }

  /// Chick, ~34 tall.
  static void chick(Canvas c, {Mood mood = Mood.happy}) {
    for (final dx in [-5.0, 5.0]) {
      Pen.line(c, Offset(dx, 14), Offset(dx, 20), ink: Ink.orange, width: 2.4);
    }
    Pen.shape(c, Pen.circle(Offset.zero, 16), fill: Ink.yellow, solid: true, hatch: Ink.orange, seed: 2);
    Pen.shape(
      c,
      Pen.oval(const Offset(-12, 4), 6, 8),
      fill: Ink.gold,
      solid: true,
      seed: 3,
      width: 1.6,
      doubleLine: false,
    );
    Pen.stroke(
      c,
      Path()
        ..moveTo(-2, -16)
        ..quadraticBezierTo(0, -24, 4, -20),
      width: 1.8,
    );
    Pen.face(c, const Offset(1, -2), 22, mood: mood);
    Pen.shape(
      c,
      Pen.poly(const [Offset(-3, 1), Offset(3, 1), Offset(0, 5)]),
      fill: Ink.orange,
      solid: true,
      width: 1.2,
    );
  }

  static void crab(Canvas c, {int seed = 1}) {
    for (final s in [-1.0, 1.0]) {
      for (var i = 0; i < 3; i++) {
        Pen.line(c, Offset(s * 10, 2.0 + i * 4), Offset(s * 20, 6.0 + i * 5), ink: Ink.coral, width: 2.2);
      }
      Pen.line(c, Offset(s * 12, -4), Offset(s * 20, -12), ink: Ink.coral, width: 2.4);
      final claw = Path.combine(
        PathOperation.difference,
        Pen.circle(Offset(s * 22, -15), 6),
        Pen.poly([Offset(s * 22, -15), Offset(s * 30, -24), Offset(s * 30, -14)]),
      );
      Pen.shape(c, claw, fill: Ink.coral, solid: true, width: 1.8, seed: seed + 2);
    }
    Pen.shape(
      c,
      Pen.oval(Offset.zero, 15, 10),
      fill: Ink.coral,
      solid: true,
      hatch: Ink.shade(Ink.coral, 0.2),
      seed: seed,
    );
    Pen.face(c, const Offset(0, 0), 18, mood: Mood.wow);
  }

  /// Friendly seabird floating on the water, ~60 wide.
  static void seabird(Canvas c, {bool happy = true}) {
    Pen.shape(
      c,
      Pen.oval(const Offset(0, 4), 24, 13),
      fill: Ink.white,
      solid: true,
      hatch: Ink.sky.withValues(alpha: 0.5),
      seed: 1,
    );
    final wing = Path()
      ..moveTo(-16, 0)
      ..quadraticBezierTo(0, -10, 12, 2)
      ..quadraticBezierTo(0, 10, -16, 0)
      ..close();
    Pen.shape(c, wing, fill: const Color(0xFFB8C2D6), seed: 2, width: 1.8);
    Pen.shape(c, Pen.circle(const Offset(18, -12), 11), fill: Ink.white, solid: true, seed: 3);
    Pen.face(c, const Offset(19, -13), 17, mood: happy ? Mood.happy : Mood.wow);
    Pen.shape(
      c,
      Pen.poly(const [Offset(27, -12), Offset(38, -9), Offset(27, -6)]),
      fill: Ink.orange,
      solid: true,
      width: 1.6,
      seed: 4,
    );
  }

  static void firefly(Canvas c) {
    Pen.shape(c, Pen.oval(const Offset(0, 4), 6, 8), fill: Ink.yellow, solid: true, width: 1.6, seed: 2);
    Pen.shape(c, Pen.circle(const Offset(0, -6), 5), fill: Ink.pencil, solid: true, width: 1.4, seed: 3);
    for (final s in [-1.0, 1.0]) {
      c.drawOval(
        Rect.fromCenter(center: Offset(s * 7, -2), width: 9, height: 12),
        Pen.fillPaint(Ink.white.withValues(alpha: 0.7)),
      );
      c.drawOval(Rect.fromCenter(center: Offset(s * 7, -2), width: 9, height: 12), Pen.inkPaint(Ink.white, 1));
    }
    Pen.dot(c, const Offset(-2, -7), 1.2, Ink.white);
    Pen.dot(c, const Offset(2, -7), 1.2, Ink.white);
  }

  /// A child, ~90 tall, feet at y=45.
  static void kid(Canvas c, {Mood mood = Mood.happy}) {
    for (final dx in [-8.0, 8.0]) {
      Pen.line(c, Offset(dx, 22), Offset(dx, 42), ink: Ink.pencil, width: 3);
      Pen.shape(c, Pen.oval(Offset(dx + 2, 44), 7, 3.5), fill: Ink.coral, solid: true, width: 1.6);
    }
    final dress = Path()
      ..moveTo(-12, -8)
      ..lineTo(12, -8)
      ..lineTo(20, 26)
      ..lineTo(-20, 26)
      ..close();
    Pen.shape(c, dress, fill: Ink.purple, seed: 4);
    for (final s in [-1.0, 1.0]) {
      Pen.line(c, Offset(s * 12, -4), Offset(s * 24, 10), ink: Ink.pencil, width: 3);
    }
    Pen.shape(c, Pen.circle(const Offset(0, -24), 17), fill: const Color(0xFFFFE2C8), solid: true, seed: 2);
    final hair = Path()
      ..moveTo(-18, -24)
      ..quadraticBezierTo(-18, -44, 0, -42)
      ..quadraticBezierTo(18, -44, 18, -24)
      ..quadraticBezierTo(8, -34, -2, -30)
      ..quadraticBezierTo(-10, -34, -18, -24)
      ..close();
    Pen.shape(c, hair, fill: Ink.brown, cross: true, seed: 6);
    Pen.face(c, const Offset(0, -21), 26, mood: mood);
  }
}
