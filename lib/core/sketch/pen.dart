import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'ink.dart';

enum Mood { happy, sleepy, wow, chomp }

/// Hand-drawn drawing primitives: wobbly outlines, colored-pencil hatching,
/// doodle faces and sparkles. Everything is deterministic for a given seed
/// so cached pictures never "boil".
class Pen {
  Pen._();

  static double _wave(double theta, int seed) {
    final p1 = seed * 1.7, p2 = seed * 2.9, p3 = seed * 0.61;
    return 0.6 * math.sin(theta + p1) + 0.3 * math.sin(2 * theta + p2) + 0.12 * math.sin(5 * theta + p3);
  }

  /// Returns [src] with a gentle, periodic hand-drawn wobble along its normal.
  static Path rough(Path src, {double amp = 1.0, double step = 5, int seed = 1}) {
    final out = Path();
    for (final m in src.computeMetrics()) {
      final len = m.length;
      if (len < 0.5) continue;
      final n = math.max(4, (len / step).ceil());
      final cycles = math.max(1, (len / 38).round()).toDouble();
      final pts = <Offset>[];
      for (var i = 0; i <= n; i++) {
        final d = len * i / n;
        final t = m.getTangentForOffset(d);
        if (t == null) continue;
        final normal = Offset(-t.vector.dy, t.vector.dx);
        final theta = cycles * 2 * math.pi * i / n;
        pts.add(t.position + normal * (_wave(theta, seed) * amp));
      }
      if (pts.length < 2) continue;
      out.moveTo(pts[0].dx, pts[0].dy);
      for (var i = 1; i < pts.length - 1; i++) {
        final mid = (pts[i] + pts[i + 1]) / 2;
        out.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
      }
      out.lineTo(pts.last.dx, pts.last.dy);
      if (m.isClosed) out.close();
    }
    return out;
  }

  static Paint inkPaint(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static Paint fillPaint(Color c) => Paint()..color = c;

  /// Colored-pencil hatching clipped to [p].
  static void hatchIn(
    Canvas c,
    Path p,
    Color color, {
    double angle = -0.75,
    double gap = 4.2,
    double width = 1.2,
    bool cross = false,
    double alpha = 0.75,
  }) {
    final b = p.getBounds();
    final r = b.longestSide * 0.75 + 4;
    final paint = inkPaint(color.withValues(alpha: alpha), width);
    c.save();
    c.clipPath(p);
    c.translate(b.center.dx, b.center.dy);
    void lines(double a) {
      c.save();
      c.rotate(a);
      for (var y = -r; y <= r; y += gap) {
        c.drawLine(Offset(-r, y), Offset(r, y + 0.8), paint);
      }
      c.restore();
    }

    lines(angle);
    if (cross) lines(angle + 1.35);
    c.restore();
  }

  /// Fill + hatch + double hand-drawn outline.
  static void shape(
    Canvas c,
    Path p, {
    Color? fill,
    Color? hatch,
    bool solid = false,
    double hatchAngle = -0.75,
    double hatchGap = 4.2,
    bool cross = false,
    Color ink = Ink.navy,
    double width = 2.2,
    int seed = 1,
    bool doubleLine = true,
    double amp = 0.9,
  }) {
    final rp = rough(p, amp: amp, seed: seed);
    if (fill != null) {
      c.drawPath(rp, fillPaint(solid ? fill : Ink.tint(fill, 0.42)));
      hatchIn(c, rp, hatch ?? Ink.shade(fill, 0.12), angle: hatchAngle, gap: hatchGap, cross: cross);
    } else if (hatch != null) {
      hatchIn(c, rp, hatch, angle: hatchAngle, gap: hatchGap, cross: cross);
    }
    if (width > 0) {
      c.drawPath(rp, inkPaint(ink, width));
      if (doubleLine) {
        final rp2 = rough(p.shift(const Offset(0.6, 0.4)), amp: amp * 1.2, seed: seed + 7);
        c.drawPath(rp2, inkPaint(ink.withValues(alpha: 0.45), width * 0.5));
      }
    }
  }

  static void stroke(Canvas c, Path p, {Color ink = Ink.navy, double width = 2.2, int seed = 1, double amp = 0.9}) {
    c.drawPath(rough(p, amp: amp, seed: seed), inkPaint(ink, width));
  }

  static void line(Canvas c, Offset a, Offset b, {Color ink = Ink.navy, double width = 2.2, int seed = 1}) {
    stroke(
      c,
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy),
      ink: ink,
      width: width,
      seed: seed,
      amp: 0.7,
    );
  }

  static Path oval(Offset center, double rx, double ry) =>
      Path()..addOval(Rect.fromCenter(center: center, width: rx * 2, height: ry * 2));

  static Path circle(Offset center, double r) => oval(center, r, r);

  static Path rrect(Rect r, double radius) => Path()..addRRect(RRect.fromRectAndRadius(r, Radius.circular(radius)));

  static Path poly(List<Offset> pts, {bool close = true}) {
    final p = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final o in pts.skip(1)) {
      p.lineTo(o.dx, o.dy);
    }
    if (close) p.close();
    return p;
  }

  static Path star(Offset c, double outer, double inner, {int points = 5, double rot = -math.pi / 2}) {
    final pts = <Offset>[];
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final a = rot + i * math.pi / points;
      pts.add(c + Offset(math.cos(a), math.sin(a)) * r);
    }
    return poly(pts);
  }

  static Path heartPath(Offset c, double s) {
    return Path()
      ..moveTo(c.dx, c.dy + s * 0.9)
      ..cubicTo(c.dx - s * 1.4, c.dy - s * 0.1, c.dx - s * 0.6, c.dy - s * 1.2, c.dx, c.dy - s * 0.4)
      ..cubicTo(c.dx + s * 0.6, c.dy - s * 1.2, c.dx + s * 1.4, c.dy - s * 0.1, c.dx, c.dy + s * 0.9)
      ..close();
  }

  static void heart(Canvas c, Offset p, double s, {Color color = Ink.coral, int seed = 3}) {
    shape(c, heartPath(p, s), fill: color, width: math.max(1.2, s * 0.22), seed: seed, doubleLine: false);
  }

  /// Small "+" sparkle like a pencil doodle.
  static void plus(Canvas c, Offset p, double s, Color color, {double width = 2}) {
    final paint = inkPaint(color, width);
    c.drawLine(p + Offset(-s, 0), p + Offset(s, 0.3), paint);
    c.drawLine(p + Offset(0, -s), p + Offset(0.3, s), paint);
  }

  /// Four-point twinkle.
  static void twinkle(Canvas c, Offset p, double s, Color color) {
    final path = Path()
      ..moveTo(p.dx, p.dy - s)
      ..quadraticBezierTo(p.dx, p.dy, p.dx + s, p.dy)
      ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + s)
      ..quadraticBezierTo(p.dx, p.dy, p.dx - s, p.dy)
      ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - s)
      ..close();
    c.drawPath(path, fillPaint(color));
  }

  static void dot(Canvas c, Offset p, double r, Color color) => c.drawCircle(p, r, fillPaint(color));

  /// Cute doodle face centred on [o]; [s] is roughly the face width.
  static void face(Canvas c, Offset o, double s, {Mood mood = Mood.happy, Color ink = Ink.pencil, bool blush = true}) {
    final eyeDx = s * 0.22, eyeY = o.dy - s * 0.05;
    final w = math.max(1.2, s * 0.06);
    final p = inkPaint(ink, w);
    switch (mood) {
      case Mood.sleepy:
        for (final dx in [-eyeDx, eyeDx]) {
          final e = Offset(o.dx + dx, eyeY);
          c.drawArc(Rect.fromCenter(center: e, width: s * 0.2, height: s * 0.14), 0.2, math.pi - 0.4, false, p);
        }
      case Mood.happy || Mood.chomp:
        for (final dx in [-eyeDx, eyeDx]) {
          final e = Offset(o.dx + dx, eyeY);
          c.drawArc(
            Rect.fromCenter(center: e.translate(0, s * 0.04), width: s * 0.2, height: s * 0.18),
            math.pi + 0.3,
            math.pi - 0.6,
            false,
            p,
          );
        }
      case Mood.wow:
        for (final dx in [-eyeDx, eyeDx]) {
          final e = Offset(o.dx + dx, eyeY);
          dot(c, e, s * 0.085, ink);
          dot(c, e.translate(-s * 0.03, -s * 0.03), s * 0.03, Ink.white);
        }
    }
    if (blush) {
      for (final dx in [-eyeDx * 1.65, eyeDx * 1.65]) {
        final r = Rect.fromCenter(center: Offset(o.dx + dx, o.dy + s * 0.12), width: s * 0.2, height: s * 0.11);
        c.drawOval(r, fillPaint(Ink.pink.withValues(alpha: 0.55)));
      }
    }
    final m = Offset(o.dx, o.dy + s * 0.14);
    if (mood == Mood.chomp || mood == Mood.wow) {
      final mouth = Pen.oval(m.translate(0, s * 0.02), s * 0.08, s * 0.07);
      c.drawPath(mouth, fillPaint(Ink.coral));
      c.drawPath(mouth, inkPaint(ink, w));
    } else {
      c.drawArc(Rect.fromCenter(center: m, width: s * 0.2, height: s * 0.14), 0.25, math.pi - 0.5, false, p);
    }
  }

  /// Draws [text] in the notebook headline style.
  static void text(
    Canvas c,
    String text,
    Offset center, {
    double size = 18,
    Color color = Ink.navy,
    FontWeight weight = FontWeight.w900,
    bool italic = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }
}

/// Caches recorded [ui.Picture]s for static sprites. Sprites are drawn in
/// local coordinates around the origin and positioned with canvas transforms.
class SpriteCache {
  SpriteCache._();
  static final _cache = <String, ui.Picture>{};

  static void draw(Canvas canvas, String key, void Function(Canvas c) build) {
    var pic = _cache[key];
    if (pic == null) {
      final rec = ui.PictureRecorder();
      build(Canvas(rec));
      pic = rec.endRecording();
      if (_cache.length > 400) _cache.clear();
      _cache[key] = pic;
    }
    canvas.drawPicture(pic);
  }

  /// Draws a cached sprite translated to [at], scaled and rotated.
  static void place(
    Canvas canvas,
    String key,
    Offset at,
    void Function(Canvas c) build, {
    double scale = 1,
    double sx = 1,
    double sy = 1,
    double rotation = 0,
    double opacity = 1,
  }) {
    canvas.save();
    canvas.translate(at.dx, at.dy);
    if (rotation != 0) canvas.rotate(rotation);
    if (scale != 1 || sx != 1 || sy != 1) canvas.scale(scale * sx, scale * sy);
    if (opacity < 1) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, opacity.clamp(0, 1)));
      draw(canvas, key, build);
      canvas.restore();
    } else {
      draw(canvas, key, build);
    }
    canvas.restore();
  }
}
