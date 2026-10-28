import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../core/sketch/ink.dart';
import '../core/sketch/paper.dart';
import '../core/sketch/pen.dart';

export 'dart:math' show Random;
export 'package:flutter/painting.dart';

export '../art/critters.dart';
export '../art/nature.dart';
export '../art/objects.dart';
export '../core/engine/audio_manager.dart' show Sfx;
export '../core/engine/game_definition.dart';
export '../core/engine/game_scene.dart';
export '../core/sketch/ink.dart';
export '../core/sketch/paper.dart';
export '../core/sketch/pen.dart';

/// Short alias for drawing a cached sprite at a position.
void sprite(
  Canvas c,
  String key,
  Offset at,
  void Function(Canvas c) build, {
  double scale = 1,
  double sx = 1,
  double sy = 1,
  double rotation = 0,
  double opacity = 1,
}) => SpriteCache.place(c, key, at, build, scale: scale, sx: sx, sy: sy, rotation: rotation, opacity: opacity);

double wave(double t, [double speed = 1, double phase = 0]) => math.sin(t * speed + phase);

/// Bounce curve 0..1..0 over [t] in 0..1.
double bump(double t) => t <= 0 || t >= 1 ? 0 : math.sin(t * math.pi);

/// Squash-and-stretch pair for a jelly bounce at progress [t].
(double, double) squash(double t, [double amount = 0.18]) {
  final b = bump(t) * amount;
  return (1 + b, 1 - b);
}

/// Helpers for drawing hub thumbnails into an arbitrary card size.
class Thumb {
  Thumb._();

  static void paper(Canvas c, Size s, {Color? tint}) {
    Paper.graph(c, Offset.zero & s, cell: 14, speckles: false);
    if (tint != null) c.drawRect(Offset.zero & s, Paint()..color = tint);
  }

  static void scene(Canvas c, Size s, Color color, {double alpha = 1}) {
    c.drawRect(Offset.zero & s, Paint()..color = color.withValues(alpha: alpha));
    Paper.gridOverlay(c, Offset.zero & s, cell: 14, alpha: 0.16);
  }

  /// Places a sprite at a fractional position of the card, scaled with it.
  static void put(
    Canvas c,
    Size s,
    double fx,
    double fy,
    void Function(Canvas c) build, {
    double scale = 1,
    double rotation = 0,
  }) {
    final k = s.height / 112;
    c.save();
    c.translate(s.width * fx, s.height * fy);
    c.rotate(rotation);
    c.scale(k * scale);
    build(c);
    c.restore();
  }
}

/// Ground band filled with hatching (grass, sand, floor...).
void groundBand(Canvas c, Rect r, Color color, {int seed = 1, double wobble = 8}) {
  final p = Path()..moveTo(r.left, r.top + wobble);
  for (var x = r.left; x <= r.right; x += 40) {
    p.quadraticBezierTo(x + 20, r.top - wobble * (x / 40 % 2 == 0 ? 1 : -0.4), x + 40, r.top + wobble * 0.5);
  }
  p
    ..lineTo(r.right, r.bottom + 4)
    ..lineTo(r.left, r.bottom + 4)
    ..close();
  Pen.shape(c, p, fill: color, seed: seed, hatchGap: 5, width: 2.2);
}

/// Water body with hand-drawn ripple strokes.
void waterBody(Canvas c, Path area, {Color color = Ink.sky, int seed = 1}) {
  Pen.shape(c, area, fill: color, seed: seed, hatchAngle: 0.15, hatchGap: 7, width: 2.4);
  final b = area.getBounds();
  final r = math.Random(seed);
  final ink = Pen.inkPaint(Ink.white.withValues(alpha: 0.85), 2);
  c.save();
  c.clipPath(area);
  for (var i = 0; i < 14; i++) {
    final o = Offset(b.left + r.nextDouble() * b.width, b.top + r.nextDouble() * b.height);
    c.drawArc(
      Rect.fromCenter(center: o, width: 26 + r.nextDouble() * 20, height: 8),
      math.pi + 0.3,
      math.pi - 0.6,
      false,
      ink,
    );
  }
  Paper.gridOverlay(c, b, alpha: 0.2);
  c.restore();
}
