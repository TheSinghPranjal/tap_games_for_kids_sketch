import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'ink.dart';
import 'pen.dart';

class Paper {
  Paper._();

  /// Light-blue graph grid with a few pencil speckles.
  static void graph(
    Canvas c,
    Rect r, {
    Color base = Ink.paper,
    Color line = Ink.grid,
    double cell = 20,
    bool speckles = true,
    double lineAlpha = 1,
    Color? speckle,
  }) {
    c.drawRect(r, Paint()..color = base);
    final p = Paint()
      ..color = line.withValues(alpha: line.a * lineAlpha)
      ..strokeWidth = 1;
    for (var x = r.left + (cell - r.left % cell); x < r.right; x += cell) {
      c.drawLine(Offset(x, r.top), Offset(x, r.bottom), p);
    }
    for (var y = r.top + (cell - r.top % cell); y < r.bottom; y += cell) {
      c.drawLine(Offset(r.left, y), Offset(r.right, y), p);
    }
    if (speckles) {
      final rng = math.Random(7);
      final sp = Paint()..color = speckle ?? Ink.pencil.withValues(alpha: 0.12);
      final n = (r.width * r.height / 9000).round();
      for (var i = 0; i < n; i++) {
        c.drawCircle(
          Offset(r.left + rng.nextDouble() * r.width, r.top + rng.nextDouble() * r.height),
          0.5 + rng.nextDouble() * 0.7,
          sp,
        );
      }
    }
  }

  /// Ruled notebook lines with a red margin.
  static void ruled(Canvas c, Rect r, {double gap = 26}) {
    final p = Paint()
      ..color = Ink.grid
      ..strokeWidth = 1.2;
    for (var y = r.top + gap; y < r.bottom; y += gap) {
      c.drawLine(Offset(r.left, y), Offset(r.right, y), p);
    }
    c.drawLine(
      Offset(r.left + 34, r.top),
      Offset(r.left + 34, r.bottom),
      Paint()
        ..color = Ink.coral.withValues(alpha: 0.45)
        ..strokeWidth = 1.4,
    );
  }

  /// Faint grid overlay so coloured scenes keep the notebook texture.
  static void gridOverlay(Canvas c, Rect r, {double alpha = 0.18, Color color = Ink.white, double cell = 20}) {
    final p = Paint()
      ..color = color.withValues(alpha: alpha)
      ..strokeWidth = 1;
    for (var x = r.left + cell; x < r.right; x += cell) {
      c.drawLine(Offset(x, r.top), Offset(x, r.bottom), p);
    }
    for (var y = r.top + cell; y < r.bottom; y += cell) {
      c.drawLine(Offset(r.left, y), Offset(r.right, y), p);
    }
  }
}

class GraphPaperBackground extends StatelessWidget {
  const GraphPaperBackground({
    super.key,
    required this.child,
    this.base = Ink.paper,
    this.line = Ink.grid,
    this.speckle,
  });
  final Widget child;
  final Color base;
  final Color line;
  final Color? speckle;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GraphPainter(base, line, speckle), child: child);
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter(this.base, this.line, this.speckle);
  final Color base;
  final Color line;
  final Color? speckle;

  @override
  void paint(Canvas canvas, Size size) =>
      Paper.graph(canvas, Offset.zero & size, base: base, line: line, speckle: speckle);

  @override
  bool shouldRepaint(covariant _GraphPainter o) => o.base != base || o.line != line || o.speckle != speckle;
}

/// Wavy coral underline, like a highlighter scribble under a title.
class ScribbleUnderline extends CustomPainter {
  ScribbleUnderline({this.color = Ink.coral});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height / 2;
    final p1 = Path()
      ..moveTo(2, y + 1)
      ..quadraticBezierTo(size.width * 0.5, y - 3, size.width - 2, y - 1);
    final p2 = Path()
      ..moveTo(size.width * 0.08, y + 3)
      ..quadraticBezierTo(size.width * 0.55, y + 1, size.width * 0.9, y - 2);
    Pen.stroke(canvas, p1, ink: color.withValues(alpha: 0.85), width: 4, seed: 3);
    Pen.stroke(canvas, p2, ink: color.withValues(alpha: 0.6), width: 3, seed: 9);
  }

  @override
  bool shouldRepaint(covariant ScribbleUnderline old) => old.color != color;
}
