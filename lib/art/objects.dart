import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';
import 'nature.dart';

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

  /// Cartoon rocket pointing up, ~40x64 centred on the body. [flame] 0..1
  /// sets the exhaust length (0 = parked).
  static void rocket(Canvas c, {Color color = Ink.coral, double flame = 0, int seed = 1}) {
    if (flame > 0) {
      final f = 14 + flame * 18;
      Pen.shape(
        c,
        Path()
          ..moveTo(-8, 22)
          ..quadraticBezierTo(-6, 22 + f * 0.7, 0, 22 + f)
          ..quadraticBezierTo(6, 22 + f * 0.7, 8, 22)
          ..close(),
        fill: Ink.orange,
        solid: true,
        hatch: Ink.coral,
        width: 1.8,
        seed: seed,
        doubleLine: false,
      );
      Pen.shape(
        c,
        Path()
          ..moveTo(-4, 22)
          ..quadraticBezierTo(-3, 22 + f * 0.45, 0, 22 + f * 0.62)
          ..quadraticBezierTo(3, 22 + f * 0.45, 4, 22)
          ..close(),
        fill: Ink.yellow,
        solid: true,
        width: 0,
      );
    }
    for (final s in [-1.0, 1.0]) {
      Pen.shape(
        c,
        Pen.poly([Offset(s * 10, 2), Offset(s * 20, 20), Offset(s * 20, 26), Offset(s * 9, 18)]),
        fill: color,
        solid: true,
        hatch: Ink.shade(color, 0.15),
        width: 2,
        seed: seed + 2,
      );
    }
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-7, 16, 14, 8), 2), fill: Ink.navySoft, solid: true, width: 1.8);
    final body = Path()
      ..moveTo(0, -32)
      ..cubicTo(10, -24, 13, -8, 12, 18)
      ..lineTo(-12, 18)
      ..cubicTo(-13, -8, -10, -24, 0, -32)
      ..close();
    Pen.shape(c, body, fill: Ink.white, solid: true, hatch: Ink.grid, seed: seed);
    c.save();
    c.clipPath(body);
    c.drawRect(const Rect.fromLTWH(-14, -34, 28, 14), Pen.fillPaint(color));
    c.restore();
    Pen.stroke(c, body, width: 2.2, seed: seed);
    Pen.shape(
      c,
      Pen.circle(const Offset(0, -4), 6.5),
      fill: Ink.sky,
      solid: true,
      hatch: Ink.blue,
      width: 2,
      seed: seed + 4,
    );
    Pen.dot(c, const Offset(-2, -6), 1.6, Ink.white);
  }

  /// Waffle cone, origin at the centre of its rim, ~48x62.
  static void cone(Canvas c, {int seed = 1}) {
    final body = Pen.poly(const [Offset(-21, 2), Offset(21, 2), Offset(0, 58)]);
    Pen.shape(
      c,
      body,
      fill: Ink.sand,
      solid: true,
      hatch: Ink.brown.withValues(alpha: 0.6),
      cross: true,
      hatchGap: 7,
      seed: seed,
    );
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-25, -6, 50, 12), 6),
      fill: Ink.sand,
      solid: true,
      hatch: Ink.brown.withValues(alpha: 0.4),
      seed: seed + 2,
    );
  }

  /// Round ice-cream scoop with a drippy bottom and a smile, radius ~22.
  static void scoop(Canvas c, Color color, {bool sprinkles = false, int seed = 1}) {
    var p = Pen.circle(Offset.zero, 22);
    for (final (x, y) in [(-15.0, 14.0), (-4.0, 18.0), (8.0, 17.0), (17.0, 12.0)]) {
      p = Path.combine(PathOperation.union, p, Pen.circle(Offset(x, y), 7));
    }
    Pen.shape(c, p, fill: color, solid: true, hatch: Ink.shade(color, 0.12), seed: seed);
    c.drawPath(
      Path()..addArc(Rect.fromCircle(center: Offset.zero, radius: 15), 3.6, 1.0),
      Pen.inkPaint(Ink.white.withValues(alpha: 0.8), 3),
    );
    if (sprinkles) {
      final r = math.Random(seed);
      for (var i = 0; i < 9; i++) {
        final o = Offset(r.nextDouble() * 32 - 16, r.nextDouble() * 18 - 18);
        final a = r.nextDouble() * math.pi;
        final d = Offset(math.cos(a), math.sin(a)) * 3;
        c.drawLine(o - d, o + d, Pen.inkPaint(Ink.bright[i % Ink.bright.length], 2.4));
      }
    }
    Pen.face(c, const Offset(0, 4), 20);
  }

  /// Zig-zag crack lines; more appear as [amount] goes from 0 to 1.
  static void _cracks(Canvas c, double half, double amount, int seed) {
    if (amount <= 0) return;
    final r = math.Random(seed);
    final n = (amount * 4).ceil();
    for (var i = 0; i < n; i++) {
      final a = r.nextDouble() * math.pi * 2;
      var p = Offset(math.cos(a), math.sin(a)) * half * 0.15;
      final crack = Path()..moveTo(p.dx, p.dy);
      for (var k = 0; k < 3; k++) {
        p += Offset(math.cos(a + (k.isEven ? 0.6 : -0.6)), math.sin(a + (k.isEven ? 0.6 : -0.6))) * half * 0.28;
        crack.lineTo(p.dx, p.dy);
      }
      c.drawPath(crack, Pen.inkPaint(Ink.navy, 2.2));
    }
  }

  /// Wooden mine crate, [w] wide, centred. [damage] 0..1 adds cracks.
  static void crate(Canvas c, double w, {double damage = 0, int seed = 1}) {
    final h = w / 2;
    final box = Pen.rrect(Rect.fromCenter(center: Offset.zero, width: w, height: w), 6);
    Pen.shape(
      c,
      box,
      fill: const Color(0xFFD9A066),
      solid: true,
      hatch: Ink.brown.withValues(alpha: 0.45),
      hatchAngle: 0,
      seed: seed,
    );
    final edge = Pen.inkPaint(Ink.shade(Ink.brown, 0.25), 3);
    c.drawRect(
      Rect.fromCenter(center: Offset.zero, width: w - 16, height: w - 16),
      Pen.inkPaint(Ink.shade(Ink.brown, 0.25), 2),
    );
    c.drawLine(Offset(-h + 8, -h + 8), Offset(h - 8, h - 8), edge);
    c.drawLine(Offset(h - 8, -h + 8), Offset(-h + 8, h - 8), edge);
    for (final o in [Offset(-h + 5, -h + 5), Offset(h - 5, -h + 5), Offset(-h + 5, h - 5), Offset(h - 5, h - 5)]) {
      Pen.dot(c, o, 2.2, Ink.pencil);
    }
    _cracks(c, h, damage, seed + 11);
  }

  /// Shiny coloured box with a "?" on it, [w] wide, centred.
  static void gemBox(Canvas c, Color color, double w, {double damage = 0, int seed = 1}) {
    final h = w / 2;
    Pen.shape(
      c,
      Pen.rrect(Rect.fromCenter(center: const Offset(0, 4), width: w, height: w - 8), 10),
      fill: color,
      solid: true,
      hatch: Ink.shade(color, 0.15),
      seed: seed,
    );
    Pen.shape(
      c,
      Pen.rrect(Rect.fromLTWH(-h - 3, -h, w + 6, w * 0.26), 6),
      fill: Ink.tint(color, 0.7),
      solid: true,
      hatch: color,
      seed: seed + 1,
    );
    c.drawPath(
      Path()
        ..moveTo(-h + 10, -h * 0.2)
        ..lineTo(-h + 10, h * 0.5),
      Pen.inkPaint(Ink.white.withValues(alpha: 0.7), 3),
    );
    Pen.text(c, '?', Offset(0, h * 0.25), size: w * 0.42, color: Ink.white);
    _cracks(c, h, damage, seed + 5);
  }

  /// Little hammer, head at the origin pointing left, handle going down-right.
  static void hammer(Canvas c) {
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-4, -2, 8, 44), 3),
      fill: Ink.brown,
      solid: true,
      hatch: Ink.shade(Ink.brown, 0.2),
      seed: 2,
      width: 2,
    );
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-18, -12, 36, 16), 4),
      fill: const Color(0xFFB8BCC8),
      solid: true,
      hatch: Ink.navySoft.withValues(alpha: 0.4),
      seed: 3,
      width: 2.2,
    );
  }

  // ---- fruit (each ~40 across, centred) ----------------------------------

  static void apple(Canvas c) {
    Pen.line(c, const Offset(0, -14), const Offset(3, -24), ink: Ink.brown, width: 3);
    c.save();
    c.translate(4, -20);
    c.rotate(-0.5);
    Nature.leaf(c, 14, color: Ink.mint, width: 0.45);
    c.restore();
    final body = Path()
      ..moveTo(0, -12)
      ..cubicTo(10, -20, 22, -12, 20, 2)
      ..cubicTo(18, 16, 8, 20, 0, 16)
      ..cubicTo(-8, 20, -18, 16, -20, 2)
      ..cubicTo(-22, -12, -10, -20, 0, -12)
      ..close();
    Pen.shape(c, body, fill: Ink.coral, solid: true, hatch: Ink.shade(Ink.coral, 0.15), seed: 11);
    Pen.twinkle(c, const Offset(-9, -5), 4, Ink.white);
    Pen.face(c, const Offset(0, 3), 16);
  }

  static void banana(Canvas c) {
    final body = Path()
      ..moveTo(-22, -10)
      ..quadraticBezierTo(-12, 18, 22, 6)
      ..quadraticBezierTo(24, 10, 20, 12)
      ..quadraticBezierTo(-18, 26, -26, -8)
      ..close();
    Pen.shape(c, body, fill: Ink.yellow, solid: true, hatch: Ink.gold, seed: 12);
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-28, -14, 6, 8), 2),
      fill: Ink.brown,
      solid: true,
      width: 1.6,
      doubleLine: false,
    );
    Pen.face(c, const Offset(-2, 8), 13);
  }

  static void orange(Canvas c) {
    Pen.shape(
      c,
      Pen.circle(const Offset(0, 2), 19),
      fill: Ink.orange,
      solid: true,
      hatch: Ink.shade(Ink.orange, 0.12),
      cross: true,
      hatchGap: 6,
      seed: 13,
    );
    c.save();
    c.translate(1, -16);
    c.rotate(-0.4);
    Nature.leaf(c, 14, color: Ink.mint, width: 0.45);
    c.restore();
    Pen.twinkle(c, const Offset(-8, -4), 4, Ink.white);
    Pen.face(c, const Offset(0, 5), 16);
  }

  static void grapes(Canvas c) {
    Pen.line(c, const Offset(0, -20), const Offset(2, -26), ink: Ink.brown, width: 3);
    for (final o in const [
      Offset(-10, -12),
      Offset(0, -14),
      Offset(10, -12),
      Offset(-5, -2),
      Offset(5, -2),
      Offset(-12, -2),
      Offset(12, -2),
      Offset(-6, 8),
      Offset(6, 8),
      Offset(0, 17),
    ]) {
      Pen.shape(
        c,
        Pen.circle(o, 6.5),
        fill: Ink.purple,
        solid: true,
        hatch: Ink.shade(Ink.purple, 0.15),
        width: 1.6,
        seed: o.dx.round() + 20,
        doubleLine: false,
      );
    }
    Pen.face(c, const Offset(0, 0), 13);
  }

  /// TinyThink's pencil mascot. [cheer] raises both arms in a hooray.
  static void mascot(Canvas c, {Mood mood = Mood.happy, bool cheer = false}) {
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
      if (cheer) {
        final hand = Offset(s * 30, -22);
        Pen.stroke(
          c,
          Path()
            ..moveTo(s * 16, -4)
            ..quadraticBezierTo(s * 26, -6, hand.dx, hand.dy),
          width: 2.4,
        );
        // Tiny three-finger wave.
        for (final a in [-0.5, 0.0, 0.5]) {
          final d = Offset(s * math.sin(a + 0.4), -math.cos(a + 0.4));
          Pen.line(c, hand, hand + d * 5, width: 2);
        }
      } else {
        Pen.line(c, Offset(s * 16, 0), Offset(s * 26, s > 0 ? -12 : 8), width: 2.4);
      }
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
