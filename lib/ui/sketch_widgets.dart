import 'dart:math' as math;

import 'package:flutter/material.dart' hide Ink;

import '../art/objects.dart';
import '../core/sketch/ink.dart';
import '../core/sketch/paper.dart';
import '../core/sketch/pen.dart';

class Txt {
  Txt._();
  static const title = TextStyle(color: Ink.navy, fontSize: 28, fontWeight: FontWeight.w900, height: 1.1);
  static const heading = TextStyle(color: Ink.navy, fontSize: 20, fontWeight: FontWeight.w900);
  static const body = TextStyle(color: Ink.navy, fontSize: 16, fontWeight: FontWeight.w700);
  static const small = TextStyle(color: Ink.navySoft, fontSize: 13, fontWeight: FontWeight.w700);
  static const note = TextStyle(
    color: Ink.navySoft,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
  );
}

/// Rounded hand-drawn box with a slightly irregular double outline.
class SketchBoxPainter extends CustomPainter {
  SketchBoxPainter({this.fill = Ink.cream, this.radius = 16, this.seed = 1, this.ink = Ink.navy, this.hatch});
  final Color fill;
  final double radius;
  final int seed;
  final Color ink;
  final Color? hatch;

  @override
  void paint(Canvas canvas, Size size) {
    final key =
        'box-${size.width.round()}x${size.height.round()}-${fill.toARGB32()}-$radius-$seed-${ink.toARGB32()}-${hatch?.toARGB32()}';
    SpriteCache.draw(canvas, key, (c) {
      final r = Pen.rrect((Offset.zero & size).deflate(3), radius);
      Pen.shape(c, r, fill: fill, solid: true, hatch: hatch, hatchGap: 7, seed: seed, ink: ink, width: 2.4, amp: 0.8);
      // Offset second stroke for the doubled pencil look.
      Pen.stroke(
        c,
        Pen.rrect((Offset.zero & size).deflate(3).shift(const Offset(1.6, 1.8)), radius),
        ink: ink.withValues(alpha: 0.35),
        width: 1.4,
        seed: seed + 5,
      );
    });
  }

  @override
  bool shouldRepaint(covariant SketchBoxPainter o) =>
      o.fill != fill || o.radius != radius || o.seed != seed || o.ink != ink || o.hatch != hatch;
}

class SketchBox extends StatelessWidget {
  const SketchBox({
    super.key,
    required this.child,
    this.fill = Ink.cream,
    this.padding = const EdgeInsets.all(12),
    this.radius = 16,
    this.seed = 1,
    this.hatch,
  });
  final Widget child;
  final Color fill;
  final EdgeInsets padding;
  final double radius;
  final int seed;
  final Color? hatch;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: SketchBoxPainter(fill: fill, radius: radius, seed: seed, hatch: hatch),
    child: Padding(padding: padding, child: child),
  );
}

/// Big, squashy hand-drawn button. Minimum 56x56 touch target.
class SketchButton extends StatefulWidget {
  const SketchButton({
    super.key,
    required this.child,
    required this.onTap,
    this.fill = Ink.cream,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.radius = 18,
    this.seed = 2,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color fill;
  final EdgeInsets padding;
  final double radius;
  final int seed;
  final String? semanticLabel;

  @override
  State<SketchButton> createState() => _SketchButtonState();
}

class _SketchButtonState extends State<SketchButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _down ? 0.93 : 1,
          duration: const Duration(milliseconds: 90),
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
              child: CustomPaint(
                painter: SketchBoxPainter(fill: widget.fill, radius: widget.radius, seed: widget.seed),
                child: Padding(
                  padding: widget.padding,
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    // Labels shrink rather than overflow on narrow phones.
                    child: FittedBox(fit: BoxFit.scaleDown, child: widget.child),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Doodle { back, pause, play, gear, heart, heartFilled, soundOn, soundOff, replay, home, star, check, close, lock }

class DoodleIcon extends StatelessWidget {
  const DoodleIcon(this.kind, {super.key, this.size = 28, this.color = Ink.navy});
  final Doodle kind;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _DoodlePainter(kind, color));
}

class _DoodlePainter extends CustomPainter {
  _DoodlePainter(this.kind, this.color);
  final Doodle kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    SpriteCache.draw(canvas, 'icon-${kind.name}-${size.width}-${color.toARGB32()}', (c) {
      final s = size.width / 24;
      c.scale(s);
      final w = 2.6;
      switch (kind) {
        case Doodle.back:
          Pen.stroke(
            c,
            Path()
              ..moveTo(20, 12)
              ..lineTo(5, 12),
            ink: color,
            width: w,
          );
          Pen.stroke(
            c,
            Pen.poly(const [Offset(11, 5), Offset(4, 12), Offset(11, 19)], close: false),
            ink: color,
            width: w,
          );
        case Doodle.pause:
          Pen.shape(
            c,
            Pen.rrect(const Rect.fromLTWH(6, 5, 4, 14), 1.5),
            fill: color,
            solid: true,
            ink: color,
            width: 1.6,
          );
          Pen.shape(
            c,
            Pen.rrect(const Rect.fromLTWH(14, 5, 4, 14), 1.5),
            fill: color,
            solid: true,
            ink: color,
            width: 1.6,
          );
        case Doodle.play:
          Pen.shape(
            c,
            Pen.poly(const [Offset(7, 4), Offset(20, 12), Offset(7, 20)]),
            fill: color,
            solid: true,
            ink: color,
            width: 2,
          );
        case Doodle.gear:
          Pen.shape(
            c,
            Pen.star(const Offset(12, 12), 10, 7.5, points: 8),
            fill: color,
            solid: true,
            ink: color,
            width: 1.6,
          );
          Pen.dot(c, const Offset(12, 12), 3.5, Ink.cream);
        case Doodle.heart:
          Pen.stroke(c, Pen.heartPath(const Offset(12, 12), 8), ink: color, width: w);
        case Doodle.heartFilled:
          Pen.shape(
            c,
            Pen.heartPath(const Offset(12, 12), 8),
            fill: Ink.coral,
            solid: true,
            hatch: Ink.shade(Ink.coral, 0.2),
            ink: color,
            width: 2.2,
          );
        case Doodle.soundOn || Doodle.soundOff:
          Pen.shape(
            c,
            Pen.poly(const [Offset(3, 9), Offset(8, 9), Offset(13, 4), Offset(13, 20), Offset(8, 15), Offset(3, 15)]),
            fill: color,
            solid: true,
            ink: color,
            width: 1.8,
          );
          if (kind == Doodle.soundOn) {
            Pen.stroke(c, Path()..addArc(const Rect.fromLTWH(10, 7, 8, 10), -1, 2), ink: color, width: 2);
            Pen.stroke(c, Path()..addArc(const Rect.fromLTWH(10, 3, 12, 18), -1, 2), ink: color, width: 2);
          } else {
            Pen.line(c, const Offset(16, 8), const Offset(22, 16), ink: Ink.coral, width: w);
            Pen.line(c, const Offset(22, 8), const Offset(16, 16), ink: Ink.coral, width: w);
          }
        case Doodle.replay:
          Pen.stroke(c, Path()..addArc(const Rect.fromLTWH(4, 4, 16, 16), -0.6, 5.0), ink: color, width: w);
          Pen.stroke(
            c,
            Pen.poly(const [Offset(14, 2), Offset(19, 5.5), Offset(14, 9)], close: false),
            ink: color,
            width: w,
          );
        case Doodle.home:
          Pen.shape(
            c,
            Pen.poly(const [
              Offset(3, 12),
              Offset(12, 4),
              Offset(21, 12),
              Offset(18, 12),
              Offset(18, 20),
              Offset(6, 20),
              Offset(6, 12),
            ]),
            fill: Ink.sky,
            ink: color,
            width: 2.2,
          );
        case Doodle.star:
          Pen.shape(
            c,
            Pen.star(const Offset(12, 12.5), 10, 4.6),
            fill: Ink.yellow,
            solid: true,
            hatch: Ink.orange,
            ink: color,
            width: 2,
          );
        case Doodle.check:
          Pen.stroke(
            c,
            Pen.poly(const [Offset(4, 12), Offset(10, 18), Offset(20, 5)], close: false),
            ink: color,
            width: 3,
          );
        case Doodle.close:
          Pen.line(c, const Offset(5, 5), const Offset(19, 19), ink: color, width: 3);
          Pen.line(c, const Offset(19, 5), const Offset(5, 19), ink: color, width: 3);
        case Doodle.lock:
          Pen.stroke(c, Path()..addArc(const Rect.fromLTWH(7, 3, 10, 12), math.pi, math.pi), ink: color, width: 2.4);
          Pen.shape(
            c,
            Pen.rrect(const Rect.fromLTWH(5, 10, 14, 11), 2),
            fill: Ink.yellow,
            solid: true,
            ink: color,
            width: 2,
          );
      }
    });
  }

  @override
  bool shouldRepaint(covariant _DoodlePainter o) => o.kind != kind || o.color != color;
}

class GemIcon extends StatelessWidget {
  const GemIcon({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _GemPainter());
}

class _GemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    SpriteCache.place(
      canvas,
      'gem-icon-${size.width}',
      size.center(Offset.zero),
      (c) => Props.gem(c, size.width * 0.44),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gem balance chip that bounces when [bump] changes.
class GemChip extends StatefulWidget {
  const GemChip({super.key, required this.count, this.bump = 0, this.compact = false});
  final int count;
  final int bump;
  final bool compact;

  @override
  State<GemChip> createState() => _GemChipState();
}

class _GemChipState extends State<GemChip> with SingleTickerProviderStateMixin {
  late final _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));

  @override
  void didUpdateWidget(covariant GemChip old) {
    super.didUpdateWidget(old);
    if (old.bump != widget.bump || old.count < widget.count) _ctl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${widget.count} gems',
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (context, child) {
          final t = _ctl.value;
          final s = 1 + math.sin(t * math.pi) * 0.25;
          return Transform.scale(scale: s, child: child);
        },
        child: SketchBox(
          fill: Ink.white,
          radius: 22,
          seed: 4,
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 10 : 14, vertical: widget.compact ? 6 : 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GemIcon(size: widget.compact ? 22 : 26),
              const SizedBox(width: 6),
              Text('${widget.count}', style: Txt.heading.copyWith(fontSize: widget.compact ? 18 : 20)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three little circles showing free plays left today.
class FreePlayDots extends StatelessWidget {
  const FreePlayDots({super.key, required this.remaining, this.total = 3, this.size = 16});
  final int remaining;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(total * (size + 6), size + 4), painter: _DotsPainter(remaining, total, size));
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(this.remaining, this.total, this.dot);
  final int remaining, total;
  final double dot;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < total; i++) {
      final filled = i < remaining;
      final o = Offset(dot / 2 + 3 + i * (dot + 6), size.height / 2);
      SpriteCache.place(canvas, 'dot-$filled-$dot-$i', o, (c) {
        Pen.shape(
          c,
          Pen.circle(Offset.zero, dot / 2),
          fill: filled ? Ink.coral : Ink.white,
          solid: true,
          width: 2,
          seed: i + 1,
          doubleLine: false,
        );
      });
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter o) => o.remaining != remaining || o.total != total;
}

/// Hand-drawn progress bar.
class SketchProgress extends StatelessWidget {
  const SketchProgress({super.key, required this.value, this.color = Ink.mint, this.height = 16, this.width = 120});
  final double value;
  final Color color;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size(width, height), painter: _ProgressPainter(value.clamp(0, 1), color));
}

class _ProgressPainter extends CustomPainter {
  _ProgressPainter(this.value, this.color);
  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(2);
    final outline = Pen.rrect(r, r.height / 2);
    canvas.drawPath(outline, Paint()..color = Ink.white);
    if (value > 0) {
      canvas.save();
      canvas.clipPath(outline);
      final fillR = Rect.fromLTWH(r.left, r.top, r.width * value, r.height);
      canvas.drawRect(fillR, Paint()..color = Ink.tint(color, 0.55));
      Pen.hatchIn(canvas, Path()..addRect(fillR), color, gap: 4.5, width: 1.6);
      canvas.restore();
    }
    SpriteCache.draw(
      canvas,
      'progress-outline-${size.width}-${size.height}',
      (c) => Pen.stroke(c, outline, width: 2.2, seed: 6, amp: 0.6),
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter o) => o.value != value || o.color != color;
}

/// Title with a coral scribble underline, like the notebook headings.
class ScribbleTitle extends StatelessWidget {
  const ScribbleTitle(this.text, {super.key, this.style = Txt.title, this.textAlign = TextAlign.center});
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(text, style: style, textAlign: textAlign),
          SizedBox(height: 10, child: CustomPaint(painter: ScribbleUnderline())),
        ],
      ),
    );
  }
}

/// Paints any sprite callback into a widget.
class SpriteView extends StatelessWidget {
  const SpriteView({super.key, required this.size, required this.painter});
  final Size size;
  final void Function(Canvas c, Size s) painter;

  @override
  Widget build(BuildContext context) => CustomPaint(size: size, painter: _FnPainter(painter));
}

class _FnPainter extends CustomPainter {
  _FnPainter(this.fn);
  final void Function(Canvas c, Size s) fn;
  @override
  void paint(Canvas canvas, Size size) => fn(canvas, size);
  @override
  bool shouldRepaint(covariant _FnPainter o) => o.fn != fn;
}

/// Friendly sketch-style dialog.
Future<T?> showSketchDialog<T>(BuildContext context, {required Widget Function(BuildContext) builder}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: false,
    barrierColor: Ink.navy.withValues(alpha: 0.25),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, _, _) => SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Material(
              type: MaterialType.transparency,
              child: SketchBox(
                fill: Ink.paperWarm,
                radius: 24,
                seed: 8,
                padding: const EdgeInsets.all(22),
                child: builder(ctx),
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (ctx, a, _, child) => ScaleTransition(
      scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
      child: FadeTransition(opacity: a, child: child),
    ),
  );
}

class NotebookPage extends StatelessWidget {
  const NotebookPage({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Ink.paper,
    body: GraphPaperBackground(child: child),
  );
}
