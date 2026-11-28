import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../art/critters.dart';
import '../art/objects.dart';
import '../core/sketch/ink.dart';
import '../core/sketch/pen.dart';
import '../l10n/l10n.dart';
import '../ui/sketch_widgets.dart';
import 'home_screen.dart';

/// Opening splash: the pond scene, cheering mascot on the title sign, a few
/// fish bobbing about and the studio credit. Moves on by itself (or on tap).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  Timer? _timer;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2800), _next);
  }

  void _next() {
    if (_left || !mounted) return;
    _left = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = AppScope.of(context).settings.effectiveReducedMotion;
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth, h = c.maxHeight;
            // Expand: the Scaffold body is only loosely constrained, so without it
            // the Stack shrinks to the sign column and the scene stops short.
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: DuskFilter(
                    child: Stack(
                      children: [
                        Positioned.fill(child: CustomPaint(painter: PondScenePainter())),
                        // Fish swimming in the pond.
                        AnimatedBuilder(
                          animation: _anim,
                          builder: (context, _) {
                            final t = still ? 0.0 : _anim.value * 2 * pi;
                            return CustomPaint(size: Size(w, h), painter: _FishPainter(t, w / 400));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Sign and credit belong to the illustration: daytime colours always.
                Theme(
                  data: sketchLightTheme,
                  child: SafeArea(
                    child: Column(
                      children: [
                        SizedBox(height: h * 0.06),
                        AnimatedBuilder(
                          animation: _anim,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, still ? 0 : sin(_anim.value * 2 * pi) * 4),
                            child: child,
                          ),
                          child: Column(
                            children: [
                              SpriteView(
                                size: const Size(180, 120),
                                painter: (c, s) =>
                                    SpriteCache.place(c, 'splash-mascot', s.center(const Offset(0, 6)), (c) {
                                      for (var i = 0; i < 7; i++) {
                                        final a = -pi * 0.92 + i * pi * 0.84 / 6;
                                        final d = Offset(cos(a), sin(a));
                                        Pen.line(c, d * 56, d * 70, ink: Ink.gold, width: 3, seed: i + 1);
                                      }
                                      c.scale(1.45);
                                      Props.mascot(c, mood: Mood.wow, cheer: true);
                                    }),
                              ),
                              Transform.translate(offset: const Offset(0, -14), child: const TitleSign()),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const _Credit(),
                        SizedBox(height: h * 0.025),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FishPainter extends CustomPainter {
  _FishPainter(this.t, this.k);
  final double t;
  final double k;

  @override
  void paint(Canvas canvas, Size size) {
    // Same fish (and colours) as every game: yellow, purple, pink, orange.
    for (final (fx, fy, color, left, phase) in [
      (0.42, 0.6, 3, false, 0.0),
      (0.24, 0.71, 2, false, 2.0),
      (0.76, 0.71, 1, true, 4.0),
    ]) {
      final o = Offset(size.width * fx + sin(t + phase) * 6 * k, size.height * fy + cos(t * 2 + phase) * 3 * k);
      SpriteCache.place(
        canvas,
        'fish-$color',
        o,
        (c) => Critters.fish(c, Critters.fishColors[color], seed: color + 1),
        scale: k * 1.15,
        sx: left ? -1 : 1,
        rotation: sin(t * 3 + phase) * 0.06,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FishPainter o) => o.t != t || o.k != k;
}

/// "by The lazy bear developer" badge with a little bear face.
class _Credit extends StatelessWidget {
  const _Credit();

  @override
  Widget build(BuildContext context) => SketchBox(
    fill: Ink.white,
    radius: 30,
    seed: 17,
    padding: const EdgeInsets.fromLTRB(14, 8, 24, 10),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpriteView(
          size: const Size(60, 56),
          painter: (c, s) => SpriteCache.place(c, 'splash-bear', s.center(Offset.zero), _bear),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.creditBy, style: Txt.small.copyWith(color: Ink.pencil)),
            Text('The lazy bear', style: Txt.heading.copyWith(color: Ink.pencil)),
            Text('developer', style: Txt.small.copyWith(color: Ink.pencil, letterSpacing: 3)),
          ],
        ),
      ],
    ),
  );
}

void _bear(Canvas c) {
  for (final dx in [-16.0, 16.0]) {
    Pen.shape(c, Pen.circle(Offset(dx, -15), 8), fill: Ink.brown, solid: true, seed: 3, width: 2);
    Pen.dot(c, Offset(dx, -15), 4, Ink.tint(Ink.brown, 0.4));
  }
  Pen.shape(c, Pen.oval(Offset.zero, 22, 19), fill: Ink.brown, solid: true, hatch: Ink.shade(Ink.brown, 0.1), seed: 2);
  Pen.shape(c, Pen.oval(const Offset(0, 7), 9, 7), fill: Ink.sand, solid: true, width: 1.6, seed: 4, doubleLine: false);
  Pen.dot(c, const Offset(0, 4), 2.6, Ink.pencil);
  Pen.face(c, const Offset(0, -1), 24);
}
