import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';

/// Props, containers and collectables, drawn around the origin.
class Props {
  Props._();

  /// Woven basket, top rim at y=-h/2.
  static void basket(Canvas c, {double w = 74, double h = 46, Color color = Ink.brown}) {
    Pen.stroke(
      c,
      Path()..addArc(Rect.fromLTWH(-w * 0.35, -h * 1.2, w * 0.7, h * 1.4), math.pi, math.pi),
      ink: Ink.shade(color, 0.3),
      width: 3.2,
      seed: 6,
    );
    final body = Path()
      ..moveTo(-w / 2, -h / 2)
      ..lineTo(w / 2, -h / 2)
      ..lineTo(w * 0.38, h / 2)
      ..lineTo(-w * 0.38, h / 2)
      ..close();
    Pen.shape(c, body, fill: color, cross: true, hatchGap: 5, seed: 2);
    final rim = Pen.rrect(Rect.fromCenter(center: Offset(0, -h / 2), width: w + 8, height: 10), 5);
    Pen.shape(c, rim, fill: Ink.shade(color, 0.05), seed: 3, width: 2);
  }

  static void gem(Canvas c, double r, {Color color = Ink.blue}) {
    final p = Pen.poly([
      Offset(-r, -r * 0.35),
      Offset(-r * 0.5, -r * 0.85),
      Offset(r * 0.5, -r * 0.85),
      Offset(r, -r * 0.35),
      Offset(0, r),
    ]);
    Pen.shape(
      c,
      p,
      fill: Ink.tint(color, 0.7),
      solid: true,
      hatch: color,
      seed: 3,
      width: math.max(1.4, r * 0.16),
      doubleLine: false,
    );
    final ink = Pen.inkPaint(Ink.navy.withValues(alpha: 0.7), math.max(1, r * 0.09));
    c.drawLine(Offset(-r, -r * 0.35), Offset(r, -r * 0.35), ink);
    c.drawLine(Offset(-r * 0.35, -r * 0.35), Offset(0, r), ink);
    c.drawLine(Offset(r * 0.35, -r * 0.35), Offset(0, r), ink);
    Pen.twinkle(c, Offset(-r * 0.4, -r * 0.55), r * 0.22, Ink.white);
  }

  static void raindrop(Canvas c, double r, {Color color = Ink.blue}) {
    final p = Path()
      ..moveTo(0, -r * 1.6)
      ..quadraticBezierTo(r * 1.1, -r * 0.1, r * 0.9, r * 0.35)
      ..arcToPoint(Offset(-r * 0.9, r * 0.35), radius: Radius.circular(r * 0.95))
      ..quadraticBezierTo(-r * 1.1, -r * 0.1, 0, -r * 1.6)
      ..close();
    Pen.shape(c, p, fill: color, seed: 2, width: 2);
    Pen.face(c, Offset(0, r * 0.1), r * 1.3);
    c.drawArc(
      Rect.fromCircle(center: Offset(-r * 0.3, -r * 0.2), radius: r * 0.4),
      3.4,
      1.0,
      false,
      Pen.inkPaint(Ink.white, 2),
    );
  }

  static void balloon(Canvas c, Color color, {int shape = 0, int seed = 1}) {
    Pen.stroke(
      c,
      Path()
        ..moveTo(0, 30)
        ..cubicTo(-6, 40, 6, 50, 0, 62),
      ink: Ink.pencil,
      width: 1.4,
      seed: seed,
    );
    Path body;
    switch (shape) {
      case 1:
        body = Pen.heartPath(const Offset(0, 4), 26);
      case 2:
        body = Pen.oval(Offset.zero, 18, 32);
      default:
        body = Pen.oval(Offset.zero, 26, 30);
    }
    Pen.shape(c, body, fill: color, seed: seed);
    Pen.shape(
      c,
      Pen.poly(const [Offset(-4, 34), Offset(4, 34), Offset(0, 28)]),
      fill: color,
      solid: true,
      width: 1.6,
      seed: seed + 1,
    );
    c.drawArc(const Rect.fromLTWH(-16, -20, 14, 18), 3.3, 1.2, false, Pen.inkPaint(Ink.white, 3));
  }

  static void seashell(Canvas c, Color color, {int seed = 1}) {
    final p = Path()
      ..moveTo(0, 16)
      ..lineTo(-18, -2)
      ..quadraticBezierTo(-16, -18, 0, -18)
      ..quadraticBezierTo(16, -18, 18, -2)
      ..close();
    Pen.shape(c, p, fill: color, seed: seed);
    final ink = Pen.inkPaint(Ink.navy.withValues(alpha: 0.6), 1.3);
    for (final x in [-10.0, -4.0, 4.0, 10.0]) {
      c.drawLine(const Offset(0, 14), Offset(x, -15), ink);
    }
    Pen.shape(
      c,
      Pen.rrect(Rect.fromCenter(center: const Offset(0, 16), width: 10, height: 6), 2),
      fill: color,
      solid: true,
      width: 1.6,
    );
  }

  static void starfish(Canvas c, Color color, {int seed = 1}) {
    Pen.shape(c, Pen.star(Offset.zero, 20, 9), fill: color, solid: true, hatch: Ink.shade(color, 0.2), seed: seed);
    for (var i = 0; i < 5; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / 5;
      Pen.dot(c, Offset(math.cos(a), math.sin(a)) * 11, 1.6, Ink.cream);
    }
    Pen.face(c, const Offset(0, 1), 14, blush: false);
  }

  static void clamBottom(Canvas c, Color color) {
    final p = Path()
      ..moveTo(-24, 0)
      ..quadraticBezierTo(-22, 16, 0, 16)
      ..quadraticBezierTo(22, 16, 24, 0)
      ..close();
    Pen.shape(c, p, fill: color, seed: 4);
  }

  static void clamTop(Canvas c, Color color) {
    final p = Path()
      ..moveTo(-24, 0)
      ..quadraticBezierTo(-24, -20, 0, -20)
      ..quadraticBezierTo(24, -20, 24, 0)
      ..close();
    Pen.shape(c, p, fill: color, seed: 5);
    final ink = Pen.inkPaint(Ink.navy.withValues(alpha: 0.55), 1.3);
    for (final x in [-14.0, -6.0, 2.0, 10.0]) {
      c.drawLine(const Offset(0, -1), Offset(x + 2, -18), ink);
    }
  }

  static void pearl(Canvas c, double r, {Color color = Ink.white}) {
    Pen.shape(
      c,
      Pen.circle(Offset.zero, r),
      fill: color,
      solid: true,
      hatch: Ink.purple.withValues(alpha: 0.35),
      seed: 2,
      width: 1.8,
      doubleLine: false,
    );
    Pen.dot(c, Offset(-r * 0.35, -r * 0.35), r * 0.25, Ink.white);
  }

  static void egg(Canvas c, Color color, {int cracks = 0, int seed = 1}) {
    final p = Path()
      ..moveTo(0, -30)
      ..cubicTo(20, -30, 24, 6, 22, 12)
      ..cubicTo(18, 28, -18, 28, -22, 12)
      ..cubicTo(-24, 6, -20, -30, 0, -30)
      ..close();
    Pen.shape(c, p, fill: color, solid: true, hatch: Ink.shade(color, 0.12), seed: seed);
    final spots = math.Random(seed);
    for (var i = 0; i < 5; i++) {
      Pen.dot(
        c,
        Offset(spots.nextDouble() * 26 - 13, spots.nextDouble() * 34 - 18),
        2 + spots.nextDouble() * 1.5,
        Ink.shade(color, 0.25).withValues(alpha: 0.5),
      );
    }
    final cr = Pen.inkPaint(Ink.navy, 2);
    const zig = [
      [Offset(-16, -8), Offset(-9, -3), Offset(-4, -10), Offset(2, -4)],
      [Offset(2, -4), Offset(8, -11), Offset(13, -5), Offset(18, -9)],
      [Offset(-6, 8), Offset(0, 3), Offset(5, 10), Offset(10, 4)],
    ];
    for (var i = 0; i < math.min(cracks, zig.length); i++) {
      c.drawPath(Pen.poly(zig[i], close: false), cr);
    }
  }

  static void nest(Canvas c, {double w = 120}) {
    final p = Path()
      ..moveTo(-w / 2, -6)
      ..quadraticBezierTo(-w / 2, 26, 0, 26)
      ..quadraticBezierTo(w / 2, 26, w / 2, -6)
      ..quadraticBezierTo(0, 6, -w / 2, -6)
      ..close();
    Pen.shape(c, p, fill: Ink.brown, cross: true, seed: 3);
    final straw = Pen.inkPaint(Ink.gold, 2);
    final r = math.Random(4);
    for (var i = 0; i < 14; i++) {
      final x = -w / 2 + r.nextDouble() * w;
      c.drawLine(
        Offset(x, -2 + r.nextDouble() * 6),
        Offset(x + r.nextDouble() * 20 - 10, -8 + r.nextDouble() * 6),
        straw,
      );
    }
  }

  static void basketball(Canvas c, double r) {
    Pen.shape(c, Pen.circle(Offset.zero, r), fill: Ink.orange, solid: true, hatch: Ink.shade(Ink.orange, 0.2), seed: 2);
    final ink = Pen.inkPaint(Ink.navy, 1.8);
    c.drawLine(Offset(-r, 0), Offset(r, 0), ink);
    c.drawLine(Offset(0, -r), Offset(0, r), ink);
    c.drawArc(Rect.fromCircle(center: Offset(-r * 1.2, 0), radius: r * 0.9), -0.9, 1.8, false, ink);
    c.drawArc(Rect.fromCircle(center: Offset(r * 1.2, 0), radius: r * 0.9), math.pi - 0.9, 1.8, false, ink);
  }

  /// Backboard + rim. The rim centre is the origin; net hangs below.
  static void hoop(Canvas c, {Color color = Ink.coral}) {
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-34, -52, 68, 44), 6),
      fill: Ink.white,
      solid: true,
      hatch: Ink.sky.withValues(alpha: 0.4),
      seed: 1,
    );
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-14, -36, 28, 22), 3), width: 2, seed: 2, ink: color);
  }

  static void rim(Canvas c, {Color color = Ink.coral}) {
    Pen.stroke(c, Pen.oval(Offset.zero, 24, 6), ink: color, width: 4, seed: 3);
  }

  static void net(Canvas c, double swish) {
    final ink = Pen.inkPaint(Ink.navy.withValues(alpha: 0.75), 1.4);
    final bottom = 26 + swish * 8;
    final narrow = 12 - swish * 4;
    for (var i = 0; i <= 4; i++) {
      final x0 = -22 + i * 11.0;
      final x1 = -narrow + i * narrow / 2;
      c.drawLine(Offset(x0, 2), Offset(x1, bottom), ink);
    }
    for (var j = 1; j <= 3; j++) {
      final t = j / 3.5;
      final y = 2 + (bottom - 2) * t;
      final half = 22 + (narrow - 22) * t;
      c.drawLine(Offset(-half, y), Offset(half, y), ink);
    }
  }

  static void chest({required Canvas c, bool open = false, double lift = 0}) {
    final body = Pen.rrect(const Rect.fromLTWH(-34, -6, 68, 36), 5);
    Pen.shape(c, body, fill: Ink.brown, seed: 1);
    for (final x in [-20.0, 20.0]) {
      Pen.line(c, Offset(x, -6), Offset(x, 30), ink: Ink.gold, width: 3.4);
    }
    c.save();
    c.translate(-34, -6);
    c.rotate(open ? -0.9 - lift : -lift);
    final lid = Path()
      ..moveTo(0, 0)
      ..lineTo(0, -10)
      ..quadraticBezierTo(34, -30, 68, -10)
      ..lineTo(68, 0)
      ..close();
    Pen.shape(c, lid, fill: Ink.shade(Ink.brown, 0.05), seed: 2);
    c.restore();
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-6, -4, 12, 12), 2), fill: Ink.gold, solid: true, width: 1.6, seed: 3);
  }

  static void hand(Canvas c) {
    final p = Path()
      ..moveTo(-4, -26)
      ..quadraticBezierTo(0, -32, 4, -26)
      ..lineTo(4, -8)
      ..quadraticBezierTo(10, -12, 13, -6)
      ..quadraticBezierTo(18, -9, 20, -2)
      ..lineTo(20, 10)
      ..quadraticBezierTo(18, 22, 6, 24)
      ..lineTo(-6, 24)
      ..quadraticBezierTo(-14, 18, -16, 6)
      ..lineTo(-18, -4)
      ..quadraticBezierTo(-14, -8, -10, -2)
      ..lineTo(-4, 2)
      ..close();
    Pen.shape(c, p, fill: const Color(0xFFFFE2C8), solid: true, hatch: Ink.coral.withValues(alpha: 0.35), seed: 2);
  }

  /// TinyThink's pencil mascot.
  static void mascot(Canvas c, {Mood mood = Mood.happy}) {
    final body = Pen.rrect(const Rect.fromLTWH(-16, -26, 32, 46), 6);
    Pen.shape(c, body, fill: Ink.yellow, solid: true, hatch: Ink.gold, seed: 1);
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-16, -36, 32, 12), 4), fill: Ink.pink, solid: true, seed: 2);
    final tip = Pen.poly(const [Offset(-16, 20), Offset(16, 20), Offset(0, 42)]);
    Pen.shape(c, tip, fill: Ink.sand, solid: true, seed: 3);
    Pen.shape(
      c,
      Pen.poly(const [Offset(-5, 34), Offset(5, 34), Offset(0, 42)]),
      fill: Ink.pencil,
      solid: true,
      width: 1.4,
    );
    Pen.face(c, const Offset(0, -4), 26, mood: mood);
    for (final s in [-1.0, 1.0]) {
      Pen.line(c, Offset(s * 16, 0), Offset(s * 26, s > 0 ? -12 : 8), width: 2.4);
    }
  }

  // ---- bedroom items -------------------------------------------------------

  static void teddy(Canvas c) {
    for (final dx in [-12.0, 12.0]) {
      Pen.shape(c, Pen.circle(Offset(dx, -24), 7), fill: Ink.brown, seed: 3, width: 1.8);
    }
    Pen.shape(c, Pen.oval(const Offset(0, 10), 15, 14), fill: Ink.brown, seed: 2);
    Pen.shape(c, Pen.circle(const Offset(0, -14), 14), fill: Ink.brown, seed: 1);
    Pen.shape(c, Pen.oval(const Offset(0, -9), 6, 4.5), fill: Ink.cream, solid: true, width: 1.4);
    Pen.face(c, const Offset(0, -15), 20);
  }

  static void toyBall(Canvas c) {
    Pen.shape(c, Pen.circle(Offset.zero, 15), fill: Ink.white, solid: true, seed: 1);
    c.save();
    c.clipPath(Pen.circle(Offset.zero, 15));
    c.drawRect(const Rect.fromLTWH(-16, -16, 32, 10), Pen.fillPaint(Ink.coral));
    c.drawRect(const Rect.fromLTWH(-16, 6, 32, 10), Pen.fillPaint(Ink.blue));
    c.restore();
    Pen.stroke(c, Pen.circle(Offset.zero, 15), width: 2.2, seed: 1);
  }

  static void block(Canvas c, Color color, String letter) {
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-15, -15, 30, 30), 3), fill: color, seed: 4);
    Pen.text(c, letter, Offset.zero, size: 18, color: Ink.navy);
  }

  static void toyCar(Canvas c) {
    final body = Path()
      ..moveTo(-24, 6)
      ..lineTo(-24, -4)
      ..lineTo(-12, -6)
      ..lineTo(-6, -16)
      ..lineTo(10, -16)
      ..lineTo(16, -6)
      ..lineTo(24, -4)
      ..lineTo(24, 6)
      ..close();
    Pen.shape(c, body, fill: Ink.blue, seed: 2);
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-4, -13, 10, 7), 1), fill: Ink.sky, solid: true, width: 1.4);
    for (final dx in [-13.0, 13.0]) {
      Pen.shape(c, Pen.circle(Offset(dx, 7), 6), fill: Ink.pencil, solid: true, width: 1.6, seed: 3);
      Pen.dot(c, Offset(dx, 7), 2, Ink.white);
    }
  }

  static void book(Canvas c, Color color) {
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-14, -18, 28, 36), 2), fill: color, seed: 3);
    Pen.line(c, const Offset(-9, -18), const Offset(-9, 18), width: 1.6);
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-4, -10, 13, 8), 1), fill: Ink.white, solid: true, width: 1.2);
  }

  static void sock(Canvas c, Color color) {
    final p = Path()
      ..moveTo(-8, -20)
      ..lineTo(8, -20)
      ..lineTo(8, 4)
      ..quadraticBezierTo(22, 6, 20, 16)
      ..quadraticBezierTo(10, 22, -8, 14)
      ..close();
    Pen.shape(c, p, fill: color, seed: 4);
    for (final y in [-15.0, -10.0]) {
      Pen.line(c, Offset(-8, y), Offset(8, y), ink: Ink.white, width: 2.2);
    }
  }

  static void shirt(Canvas c, Color color) {
    final p = Pen.poly(const [
      Offset(-8, -18),
      Offset(-22, -10),
      Offset(-16, 0),
      Offset(-12, -4),
      Offset(-12, 18),
      Offset(12, 18),
      Offset(12, -4),
      Offset(16, 0),
      Offset(22, -10),
      Offset(8, -18),
      Offset(0, -13),
    ]);
    Pen.shape(c, p, fill: color, seed: 5);
    _shirtStar(c);
  }

  // Tiny doodle star printed on the shirt.
  static void _shirtStar(Canvas c) {
    c.drawPath(Pen.star(const Offset(0, 3), 6, 3), Pen.fillPaint(Ink.yellow));
  }

  static void pants(Canvas c, Color color) {
    final p = Pen.poly(const [
      Offset(-14, -18),
      Offset(14, -18),
      Offset(16, 20),
      Offset(4, 20),
      Offset(0, -2),
      Offset(-4, 20),
      Offset(-16, 20),
    ]);
    Pen.shape(c, p, fill: color, seed: 6);
  }
}
