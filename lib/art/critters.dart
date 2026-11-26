import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';

/// Friendly doodle animals and characters, drawn around the origin.
class Critters {
  Critters._();

  /// The one fish palette every game uses, so fish look the same app-wide.
  static const fishColors = [Ink.yellow, Ink.purple, Ink.pink, Ink.orange];

  static Color fishFin(Color body) => body == Ink.yellow ? Ink.orange : Ink.shade(body, 0.08);

  /// Round striped fish facing right, ~68x50.
  static void fish(Canvas c, Color color, {int seed = 1}) {
    final fin = fishFin(color);
    final rays = Pen.inkPaint(Ink.shade(fin, 0.3).withValues(alpha: 0.7), 1.1);
    final tail = Path()
      ..moveTo(-17, 0)
      ..quadraticBezierTo(-26, -6, -35, -16)
      ..quadraticBezierTo(-28, 0, -35, 16)
      ..quadraticBezierTo(-26, 6, -17, 0)
      ..close();
    Pen.shape(c, tail, fill: fin, solid: true, seed: seed + 2, width: 2, doubleLine: false);
    for (final dy in [-8.0, 0.0, 8.0]) {
      c.drawLine(const Offset(-21, 0), Offset(-31, dy * 1.2), rays);
    }
    final dorsal = Path()
      ..moveTo(-11, -13)
      ..cubicTo(-8, -27, 6, -28, 11, -14)
      ..close();
    Pen.shape(c, dorsal, fill: fin, solid: true, seed: seed + 4, width: 2, doubleLine: false);
    for (final x in [-4.0, 2.0]) {
      c.drawLine(Offset(x, -15), Offset(x - 1, -23), rays);
    }
    final belly = Path()
      ..moveTo(-6, 14)
      ..quadraticBezierTo(-10, 23, -2, 23)
      ..quadraticBezierTo(2, 20, 3, 15)
      ..close();
    Pen.shape(c, belly, fill: fin, solid: true, seed: seed + 5, width: 1.8, doubleLine: false);

    final body = Pen.oval(const Offset(2, 0), 22, 17);
    final rough = Pen.rough(body, amp: 0.8, seed: seed);
    c.drawPath(rough, Pen.fillPaint(Ink.tint(color, 0.62)));
    c.save();
    c.clipPath(rough);
    final stripe = Pen.inkPaint(color, 5);
    for (final x in [-11.0, -2.0, 7.0]) {
      c.drawPath(
        Path()
          ..moveTo(x, -18)
          ..quadraticBezierTo(x - 3, 0, x, 18),
        stripe,
      );
    }
    c.restore();
    Pen.hatchIn(c, rough, Ink.shade(color, 0.12), angle: 1.0, gap: 4.4, alpha: 0.35);
    // Belly highlight keeps the body round.
    c.drawOval(
      Rect.fromCenter(center: const Offset(4, 8), width: 26, height: 8),
      Pen.fillPaint(Ink.white.withValues(alpha: 0.25)),
    );
    Pen.shape(c, body, seed: seed, amp: 0.8);

    Pen.dot(c, const Offset(13, -4), 3.6, Ink.pencil);
    Pen.dot(c, const Offset(12, -5.4), 1.3, Ink.white);
    c.drawArc(const Rect.fromLTWH(11, 1.5, 9, 6), 0.3, 2.3, false, Pen.inkPaint(Ink.pencil, 1.6));
    c.drawOval(
      Rect.fromCenter(center: const Offset(8, 6), width: 7, height: 4),
      Pen.fillPaint(Ink.coral.withValues(alpha: 0.55)),
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

  /// Glowing jellyfish, dome centred at the origin, ~44 wide.
  static void jellyfish(Canvas c, Color color, {int seed = 1}) {
    final r = math.Random(seed);
    for (var i = 0; i < 4; i++) {
      final x = -12.0 + i * 8;
      final len = 22 + r.nextDouble() * 10;
      Pen.stroke(
        c,
        Path()
          ..moveTo(x, 6)
          ..quadraticBezierTo(x - 6, 6 + len * 0.35, x, 6 + len * 0.65)
          ..quadraticBezierTo(x + 6, 6 + len * 0.85, x - 1, 6 + len),
        ink: Ink.shade(color, 0.2),
        width: 2.2,
        seed: seed + i,
        amp: 0.5,
      );
    }
    final dome = Path()
      ..moveTo(-22, 6)
      ..cubicTo(-24, -26, 24, -26, 22, 6);
    for (var i = 0; i < 4; i++) {
      final x = 22 - i * 11.0;
      dome.quadraticBezierTo(x - 5.5, 12, x - 11, 6);
    }
    dome.close();
    Pen.shape(c, dome, fill: Ink.tint(color, 0.7), solid: true, hatch: color, seed: seed);
    c.drawPath(
      Path()..addArc(Rect.fromCircle(center: const Offset(-4, -4), radius: 13), 3.5, 1.1),
      Pen.inkPaint(Ink.white.withValues(alpha: 0.85), 3),
    );
    Pen.face(c, const Offset(0, -2), 20);
  }

  /// Little diver in a round glass helmet, ~60x84 centred on the helmet.
  static void babyDiver(Canvas c, {Mood mood = Mood.happy}) {
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(14, 4, 12, 28), 5), fill: const Color(0xFFB8BCC8), solid: true, seed: 6);
    for (final s in [-1.0, 1.0]) {
      Pen.shape(
        c,
        Pen.oval(Offset(s * 11, 58), 10, 5),
        fill: Ink.blue,
        solid: true,
        hatch: Ink.shade(Ink.blue, 0.15),
        seed: 7,
        width: 2,
      );
      Pen.line(c, Offset(s * 8, 40), Offset(s * 11, 54), width: 6, ink: Ink.navy);
      Pen.line(c, Offset(s * 8, 40), Offset(s * 11, 54), width: 3.4, ink: Ink.yellow);
      Pen.line(c, Offset(s * 15, 18), Offset(s * 30, 8), width: 6, ink: Ink.navy);
      Pen.line(c, Offset(s * 15, 18), Offset(s * 30, 8), width: 3.4, ink: Ink.yellow);
    }
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-17, 8, 34, 36), 12),
      fill: Ink.yellow,
      solid: true,
      hatch: Ink.gold,
      seed: 3,
    );
    Pen.shape(
      c,
      Pen.circle(const Offset(0, -12), 26),
      fill: Ink.tint(Ink.sky, 0.55),
      solid: true,
      hatch: Ink.sky,
      seed: 4,
    );
    Pen.shape(
      c,
      Pen.circle(const Offset(0, -10), 15),
      fill: const Color(0xFFFFE2C8),
      solid: true,
      width: 1.8,
      seed: 5,
      doubleLine: false,
    );
    Pen.face(c, const Offset(0, -9), 22, mood: mood);
    c.drawPath(
      Path()..addArc(Rect.fromCircle(center: const Offset(0, -12), radius: 20), 3.6, 1.0),
      Pen.inkPaint(Ink.white.withValues(alpha: 0.9), 3.2),
    );
    Pen.stroke(c, Pen.rrect(const Rect.fromLTWH(-18, 10, 36, 7), 3), width: 2.4, seed: 8);
  }

  /// Round green frog sitting down, ~56x46 centred on its body.
  static void frog(Canvas c, {Mood mood = Mood.happy}) {
    for (final s in [-1.0, 1.0]) {
      Pen.shape(
        c,
        Pen.oval(Offset(s * 20, 14), 13, 8),
        fill: Ink.leaf,
        solid: true,
        hatch: Ink.shade(Ink.leaf, 0.15),
        seed: 3,
        width: 2,
      );
    }
    Pen.shape(c, Pen.oval(const Offset(0, 4), 24, 18), fill: Ink.mint, solid: true, hatch: Ink.leaf, seed: 1);
    Pen.shape(
      c,
      Pen.oval(const Offset(0, 10), 14, 9),
      fill: Ink.tint(Ink.yellow, 0.5),
      solid: true,
      width: 1.6,
      seed: 2,
      doubleLine: false,
    );
    for (final s in [-1.0, 1.0]) {
      Pen.shape(c, Pen.circle(Offset(s * 11, -12), 9), fill: Ink.mint, solid: true, hatch: Ink.leaf, seed: 4, width: 2);
      Pen.shape(c, Pen.circle(Offset(s * 11, -12), 5.5), fill: Ink.white, solid: true, width: 1.4, doubleLine: false);
      Pen.dot(c, Offset(s * 11, -11), 2.8, Ink.pencil);
    }
    final mouth = Path()
      ..moveTo(-10, 0)
      ..quadraticBezierTo(0, mood == Mood.wow ? 10 : 7, 10, 0);
    Pen.stroke(c, mouth, ink: Ink.pencil, width: 2);
    Pen.dot(c, const Offset(-15, 2), 3, Ink.pink.withValues(alpha: 0.7));
    Pen.dot(c, const Offset(15, 2), 3, Ink.pink.withValues(alpha: 0.7));
  }

  /// Scalloped oval outline that reads as fur.
  static Path fuzz(Offset c, double rx, double ry, {int tufts = 18, double depth = 5}) {
    final p = Path();
    for (var i = 0; i <= tufts; i++) {
      final a = i / tufts * 2 * math.pi;
      final pt = c + Offset(math.cos(a) * rx, math.sin(a) * ry);
      if (i == 0) {
        p.moveTo(pt.dx, pt.dy);
        continue;
      }
      final m = (i - 0.5) / tufts * 2 * math.pi;
      final ctrl = c + Offset(math.cos(m) * (rx + depth), math.sin(m) * (ry + depth));
      p.quadraticBezierTo(ctrl.dx, ctrl.dy, pt.dx, pt.dy);
    }
    return p..close();
  }

  /// Big fluffy monster in a nightcap, ~150x140, sitting with feet at y=62.
  /// [wake]: 0 fast asleep, 1 peeking with one eye, 2 wide awake.
  static void monster(Canvas c, {int wake = 0}) {
    const fur = Ink.purple;
    for (final s in [-1.0, 1.0]) {
      Pen.shape(c, Pen.oval(Offset(s * 36, 56), 22, 11), fill: Ink.shade(fur, 0.08), solid: true, seed: 3);
      for (var k = -1; k <= 1; k++) {
        Pen.line(c, Offset(s * 36 + k * 8, 60), Offset(s * 36 + k * 8, 66), width: 1.6, seed: k + 4);
      }
    }
    // Little curly horns.
    for (final s in [-1.0, 1.0]) {
      final horn = Path()
        ..moveTo(s * 22, -48)
        ..quadraticBezierTo(s * 30, -78, s * 48, -82)
        ..quadraticBezierTo(s * 40, -66, s * 42, -46)
        ..close();
      Pen.shape(c, horn, fill: Ink.cream, solid: true, hatch: Ink.sand, seed: 6, width: 2);
    }
    Pen.shape(c, fuzz(Offset.zero, 70, 60, tufts: 22, depth: 6), fill: fur, cross: true, seed: 1, width: 2.6);
    Pen.shape(
      c,
      fuzz(const Offset(0, 32), 38, 24, tufts: 14, depth: 3),
      fill: Ink.tint(Ink.pink, 0.55),
      solid: true,
      hatch: Ink.pink.withValues(alpha: 0.5),
      seed: 2,
      width: 1.8,
    );
    // Stubby arms: folded on the tummy asleep, thrown up when awake.
    for (final s in [-1.0, 1.0]) {
      final arm = wake == 2 ? Pen.oval(Offset(s * 72, -18), 12, 18) : Pen.oval(Offset(s * 40, 30), 15, 10);
      Pen.shape(c, arm, fill: Ink.shade(fur, 0.05), solid: true, hatch: Ink.shade(fur, 0.2), seed: 7, width: 2);
    }
    const eyeY = -28.0;
    final ink = Pen.inkPaint(Ink.pencil, 3);
    void closedEye(double x) =>
        c.drawArc(Rect.fromCenter(center: Offset(x, eyeY), width: 26, height: 16), 0.2, math.pi - 0.4, false, ink);
    void openEye(double x, double r) {
      Pen.shape(c, Pen.circle(Offset(x, eyeY), r), fill: Ink.white, solid: true, width: 2.2, doubleLine: false);
      Pen.dot(c, Offset(x, eyeY + 1), r * 0.5, Ink.pencil);
      Pen.dot(c, Offset(x - r * 0.2, eyeY - r * 0.2), r * 0.18, Ink.white);
    }

    switch (wake) {
      case 0:
        closedEye(-24);
        closedEye(24);
      case 1:
        closedEye(-24);
        openEye(24, 9);
        // Half-closed lid over the peeking eye.
        c.drawArc(
          Rect.fromCenter(center: Offset(24, eyeY), width: 22, height: 22),
          math.pi,
          math.pi,
          true,
          Pen.fillPaint(fur),
        );
        Pen.line(c, const Offset(13, eyeY), const Offset(35, eyeY), ink: Ink.pencil, width: 2.6);
      default:
        openEye(-24, 13);
        openEye(24, 13);
    }
    for (final s in [-1.0, 1.0]) {
      c.drawOval(
        Rect.fromCenter(center: Offset(s * 44, -12), width: 18, height: 10),
        Pen.fillPaint(Ink.pink.withValues(alpha: 0.6)),
      );
    }
    if (wake == 2) {
      // Big surprised yawn.
      final mouth = Pen.oval(const Offset(0, -6), 13, 11);
      c.drawPath(mouth, Pen.fillPaint(Ink.coral));
      c.drawPath(mouth, Pen.inkPaint(Ink.pencil, 2.4));
    } else {
      // Sleepy smile with one tooth poking out.
      c.drawArc(Rect.fromCenter(center: const Offset(0, -10), width: 30, height: 18), 0.25, math.pi - 0.5, false, ink);
      Pen.shape(
        c,
        Pen.poly(const [Offset(5, -2), Offset(13, -3), Offset(9, 5)]),
        fill: Ink.white,
        solid: true,
        width: 1.6,
        doubleLine: false,
      );
    }
    // Floppy striped nightcap with a pompom.
    final cap = Path()
      ..moveTo(-46, -46)
      ..quadraticBezierTo(-10, -96, 34, -70)
      ..quadraticBezierTo(62, -56, 76, -24)
      ..quadraticBezierTo(46, -44, 30, -40)
      ..quadraticBezierTo(-6, -50, -46, -46)
      ..close();
    Pen.shape(c, cap, fill: Ink.sky, solid: true, hatch: Ink.blue, seed: 8);
    c.save();
    c.clipPath(cap);
    final stripe = Pen.inkPaint(Ink.white.withValues(alpha: 0.85), 7);
    for (var x = -40.0; x < 80; x += 20) {
      c.drawLine(Offset(x, -100), Offset(x + 24, -20), stripe);
    }
    c.restore();
    Pen.stroke(c, cap, width: 2.2, seed: 8);
    Pen.shape(
      c,
      fuzz(const Offset(78, -20), 9, 9, tufts: 8, depth: 2),
      fill: Ink.white,
      solid: true,
      seed: 9,
      width: 2,
    );
  }

  /// Mischievous baby monster, ~50 wide. [kind] 0 one eye, 1 two eyes with
  /// horns, 2 antenna. [golden] babies wear a crown.
  static void babyMonster(Canvas c, Color color, {int kind = 0, bool golden = false, Mood mood = Mood.happy}) {
    for (final s in [-1.0, 1.0]) {
      Pen.shape(c, Pen.oval(Offset(s * 10, 20), 8, 5), fill: Ink.shade(color, 0.1), solid: true, seed: 3, width: 1.8);
      // Little arms reaching out.
      Pen.shape(
        c,
        Pen.oval(Offset(s * 22, 2), 6, 9),
        fill: color,
        solid: true,
        hatch: Ink.shade(color, 0.15),
        seed: 4,
        width: 1.8,
      );
    }
    if (kind == 1) {
      for (final s in [-1.0, 1.0]) {
        Pen.shape(
          c,
          Pen.poly([Offset(s * 6, -16), Offset(s * 16, -30), Offset(s * 16, -12)]),
          fill: Ink.cream,
          solid: true,
          width: 1.6,
          seed: 5,
          doubleLine: false,
        );
      }
    } else if (kind == 2) {
      Pen.line(c, const Offset(0, -16), const Offset(4, -32), width: 2);
      Pen.shape(c, Pen.circle(const Offset(4, -34), 4.5), fill: Ink.yellow, solid: true, width: 1.6, doubleLine: false);
    }
    Pen.shape(
      c,
      fuzz(Offset.zero, 20, 19, tufts: 12, depth: 3),
      fill: color,
      solid: true,
      hatch: Ink.shade(color, 0.15),
      seed: 1,
    );
    final surprised = mood == Mood.wow;
    void eye(Offset o, double r) {
      Pen.shape(c, Pen.circle(o, r), fill: Ink.white, solid: true, width: 1.6, doubleLine: false);
      Pen.dot(c, o + Offset(surprised ? 0 : 1, surprised ? 0 : 1), r * (surprised ? 0.35 : 0.55), Ink.pencil);
    }

    if (kind == 0) {
      eye(const Offset(0, -5), 8);
    } else {
      eye(const Offset(-7, -5), 5);
      eye(const Offset(7, -5), 5);
    }
    for (final s in [-1.0, 1.0]) {
      c.drawOval(
        Rect.fromCenter(center: Offset(s * 12, 5), width: 7, height: 4),
        Pen.fillPaint(Ink.pink.withValues(alpha: 0.7)),
      );
    }
    final ink = Pen.inkPaint(Ink.pencil, 1.8);
    if (surprised) {
      final o = Pen.oval(const Offset(0, 9), 4, 4);
      c.drawPath(o, Pen.fillPaint(Ink.coral));
      c.drawPath(o, ink);
    } else {
      // Cheeky grin with a tooth.
      c.drawArc(Rect.fromCenter(center: const Offset(0, 6), width: 14, height: 9), 0.2, math.pi - 0.4, false, ink);
      c.drawRect(const Rect.fromLTWH(-3, 9.5, 3, 3), Pen.fillPaint(Ink.white));
    }
    if (golden) {
      Pen.shape(
        c,
        Pen.poly(const [
          Offset(-10, -18),
          Offset(-10, -28),
          Offset(-5, -22),
          Offset(0, -30),
          Offset(5, -22),
          Offset(10, -28),
          Offset(10, -18),
        ]),
        fill: Ink.yellow,
        solid: true,
        hatch: Ink.gold,
        width: 1.8,
        seed: 6,
      );
    }
  }
}
