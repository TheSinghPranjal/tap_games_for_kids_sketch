import 'dart:math';

import 'package:flutter/material.dart' hide Ink;

import '../app_scope.dart';
import '../art/nature.dart';
import '../core/rewards/reward_models.dart';
import '../core/sketch/ink.dart';
import '../core/sketch/paper.dart';
import '../core/sketch/pen.dart';
import '../l10n/l10n.dart';
import '../ui/sketch_widgets.dart';
import 'hub_screen.dart';
import 'settings_screen.dart';

const _water = Color(0xFF4DB3EC);
const _grass = Color(0xFF8BD866);
const _wood = Color(0xFFE2A866);

/// First screen: a sunny pond with the wooden title sign and two big buttons.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final _bob = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l = context.l10n;
    return Scaffold(
      backgroundColor: _grass,
      body: Stack(
        children: [
          Positioned.fill(
            child: DuskFilter(child: CustomPaint(painter: PondScenePainter())),
          ),
          // The sign and buttons are part of the illustration: always daytime colours.
          Theme(
            data: sketchLightTheme,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, c) => Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: c.maxHeight * 0.1),
                        ListenableBuilder(
                          listenable: scope.settings,
                          builder: (context, child) => AnimatedBuilder(
                            animation: _bob,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(
                                0,
                                scope.settings.effectiveReducedMotion ? 0 : sin(_bob.value * 2 * pi) * 4,
                              ),
                              child: child,
                            ),
                            child: child,
                          ),
                          child: const TitleSign(),
                        ),
                        const Spacer(flex: 3),
                        _MenuButton(
                          label: l.homePlayGames,
                          fill: Ink.yellow,
                          icon: _Icon.controller,
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HubScreen())),
                        ),
                        const SizedBox(height: 22),
                        _MenuButton(
                          label: l.homeRewards,
                          fill: Ink.pink,
                          icon: _Icon.gift,
                          onTap: () => _showRewards(context),
                        ),
                        const Spacer(flex: 4),
                      ],
                    ),
                    Positioned(
                      top: 10,
                      right: 14,
                      child: SketchButton(
                        semanticLabel: l.settings,
                        padding: const EdgeInsets.all(10),
                        onTap: () => openSettings(context),
                        child: const DoodleIcon(Doodle.gear),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showRewards(BuildContext context) {
  final rewards = AppScope.of(context).rewards;
  return showSketchDialog(
    context,
    builder: (ctx) => ListenableBuilder(
      listenable: rewards,
      builder: (ctx, _) {
        final l = ctx.l10n;
        final today = rewards.getDailyPlayStats().values;
        final stars = today.fold(0, (sum, s) => sum + s.totalScore);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpriteView(
              size: const Size(90, 80),
              painter: (c, s) => SpriteCache.place(c, 'rewards-gift', s.center(Offset.zero), (c) {
                c.scale(1.5);
                _gift(c);
                Pen.twinkle(c, const Offset(-30, -18), 6, Ink.gold);
                Pen.twinkle(c, const Offset(28, -22), 5, Ink.gold);
              }),
            ),
            ScribbleTitle(l.rewardsTitle),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GemIcon(size: 44),
                const SizedBox(width: 8),
                Text('${rewards.getGemBalance()}', style: Txt.title.copyWith(fontSize: 42)),
              ],
            ),
            Text(l.rewardsGemsSaved, style: Txt.note.soft(ctx)),
            const SizedBox(height: 14),
            SketchBox(
              fill: ctx.palette.tint(Ink.sky, 0.3),
              radius: 18,
              seed: 4,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RewardLine(icon: const DoodleIcon(Doodle.star, size: 24), text: l.rewardsStarsToday(stars)),
                  _RewardLine(icon: const GemIcon(size: 24), text: l.rewardsStarsPerGem(RewardRules.pointsPerGem)),
                  _RewardLine(
                    icon: const DoodleIcon(Doodle.play, size: 22),
                    text: l.rewardsFreePlaysPerDay(RewardRules.freePlaysPerDay),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SketchButton(
              fill: ctx.palette.tint(Ink.pink, 0.45),
              onTap: () => Navigator.of(ctx).pop(),
              child: Text(l.rewardsYay, style: Txt.heading),
            ),
          ],
        );
      },
    ),
  );
}

class _RewardLine extends StatelessWidget {
  const _RewardLine({required this.icon, required this.text});
  final Widget icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 30, child: Center(child: icon)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Txt.body.copyWith(fontSize: 15))),
      ],
    ),
  );
}

/// Wooden plank sign with leaves and the colourful bubbly title.
class TitleSign extends StatelessWidget {
  const TitleSign({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final style = Txt.title.copyWith(fontSize: 46, height: 1.05, letterSpacing: 0.5);
    // Each word of the first line gets the next crayon colour.
    const colors = [Ink.coral, Ink.blue, Ink.mint, Ink.orange];
    final words = l.homeTitleLine1.split(' ');
    return Semantics(
      header: true,
      label: l.homeTitleSemantics,
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: _SignPainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(38, 26, 38, 30),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  OutlinedText([
                    for (final (i, w) in words.indexed) (i < words.length - 1 ? '$w ' : w, colors[i % colors.length]),
                  ], style: style),
                  OutlinedText([(l.homeTitleLine2, Ink.yellow)], style: style),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    SpriteCache.draw(canvas, 'home-sign-${size.width.round()}x${size.height.round()}', (c) {
      final r = (Offset.zero & size).deflate(6);
      final plank = Path()
        ..moveTo(r.left + 18, r.top + 6)
        ..quadraticBezierTo(r.center.dx, r.top - 6, r.right - 18, r.top + 6)
        ..quadraticBezierTo(r.right, r.top + 8, r.right, r.top + 26)
        ..lineTo(r.right - 4, r.bottom - 22)
        ..quadraticBezierTo(r.right - 6, r.bottom, r.right - 26, r.bottom)
        ..quadraticBezierTo(r.center.dx, r.bottom + 8, r.left + 26, r.bottom)
        ..quadraticBezierTo(r.left + 4, r.bottom, r.left + 4, r.bottom - 22)
        ..lineTo(r.left, r.top + 26)
        ..quadraticBezierTo(r.left, r.top + 8, r.left + 18, r.top + 6)
        ..close();
      Pen.shape(
        c,
        plank,
        fill: _wood,
        solid: true,
        hatch: Ink.brown.withValues(alpha: 0.35),
        hatchAngle: 0.1,
        seed: 21,
        width: 2.8,
      );
      // Wood grain streaks.
      final grain = Pen.inkPaint(Ink.shade(Ink.brown, 0.1).withValues(alpha: 0.55), 1.6);
      for (final (fx, fy, w) in [(0.12, 0.22, 0.18), (0.7, 0.16, 0.2), (0.2, 0.84, 0.22), (0.66, 0.86, 0.16)]) {
        final o = Offset(r.left + r.width * fx, r.top + r.height * fy);
        c.drawPath(
          Path()
            ..moveTo(o.dx, o.dy)
            ..quadraticBezierTo(o.dx + r.width * w / 2, o.dy - 3, o.dx + r.width * w, o.dy),
          grain,
        );
      }
      // Leaves sprouting from the top corners.
      for (final (o, a, flip) in [
        (Offset(r.left + 30, r.top + 2), -1.9, false),
        (Offset(r.left + 40, r.top + 2), -1.2, false),
        (Offset(r.right - 30, r.top + 2), -1.25, true),
        (Offset(r.right - 40, r.top + 2), -1.95, true),
      ]) {
        c.save();
        c.translate(o.dx, o.dy);
        c.rotate(a);
        if (flip) c.scale(1, -1);
        Nature.leaf(c, 30, color: Ink.leaf, width: 0.42, seed: o.dx.round());
        c.restore();
      }
      // Little "ta-da" dashes beside "Games".
      for (final side in [-1.0, 1.0]) {
        final base = Offset(side > 0 ? r.right - 22 : r.left + 22, r.top + r.height * 0.68);
        for (final (a, col) in [(-0.5, Ink.yellow), (0.0, Ink.coral), (0.5, Ink.yellow)]) {
          final d = Offset(cos(a) * side, sin(a));
          Pen.line(c, base + d * 2, base + d * 11, ink: col, width: 2.6, seed: (a * 10).round().abs() + 3);
        }
      }
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum _Icon { controller, gift }

/// Big chunky pill button with a doodle icon and "ta-da" dashes either side.
class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.label, required this.fill, required this.icon, required this.onTap});
  final String label;
  final Color fill;
  final _Icon icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _Dashes(left: true),
        SizedBox(
          width: min(MediaQuery.sizeOf(context).width - 120, 300),
          height: 108,
          child: SketchButton(
            fill: Ink.tint(fill, 0.85),
            radius: 46,
            seed: icon.index + 31,
            semanticLabel: label.replaceAll('\n', ' '),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SpriteView(
                  size: const Size(80, 64),
                  painter: (c, s) => SpriteCache.place(c, 'home-icon-${icon.name}', s.center(Offset.zero), (c) {
                    c.scale(1.45);
                    icon == _Icon.controller ? _controller(c) : _gift(c);
                  }),
                ),
                const SizedBox(width: 14),
                Text(label, style: Txt.title.copyWith(fontSize: 30, height: 1.05, color: Ink.navy)),
              ],
            ),
          ),
        ),
        const _Dashes(left: false),
      ],
    );
  }
}

class _Dashes extends StatelessWidget {
  const _Dashes({required this.left});
  final bool left;

  @override
  Widget build(BuildContext context) => SpriteView(
    size: const Size(34, 60),
    painter: (c, s) => SpriteCache.place(c, 'home-dashes-$left', s.center(Offset.zero), (c) {
      if (left) c.scale(-1, 1);
      for (final (a, col) in [(-0.55, Ink.coral), (0.0, Ink.yellow), (0.55, Ink.coral)]) {
        final d = Offset(cos(a), sin(a));
        Pen.line(
          c,
          d * 4 - const Offset(8, 0),
          d * 16 - const Offset(8, 0),
          ink: col,
          width: 3,
          seed: (a * 10).round().abs() + 1,
        );
      }
    }),
  );
}

void _controller(Canvas c) {
  final body = Path.combine(
    PathOperation.union,
    Pen.rrect(const Rect.fromLTWH(-22, -12, 44, 20), 9),
    Path.combine(PathOperation.union, Pen.circle(const Offset(-14, 6), 9), Pen.circle(const Offset(14, 6), 9)),
  );
  Pen.shape(c, body, fill: Ink.white, solid: true, hatch: Ink.grid, seed: 5, width: 2.2);
  // D-pad.
  Pen.line(c, const Offset(-19, -2), const Offset(-9, -2), ink: Ink.blue, width: 4);
  Pen.line(c, const Offset(-14, -7), const Offset(-14, 3), ink: Ink.blue, width: 4);
  for (final (o, col) in [
    (const Offset(14, -7), Ink.yellow),
    (const Offset(19, -2), Ink.coral),
    (const Offset(14, 3), Ink.mint),
    (const Offset(9, -2), Ink.blue),
  ]) {
    Pen.dot(c, o, 2.6, col);
  }
  Pen.line(c, const Offset(-4, -5), const Offset(-1, -5), ink: Ink.navySoft, width: 1.6);
  Pen.line(c, const Offset(2, -5), const Offset(5, -5), ink: Ink.navySoft, width: 1.6);
}

void _gift(Canvas c) {
  Pen.shape(
    c,
    Pen.rrect(const Rect.fromLTWH(-16, -6, 32, 24), 3),
    fill: Ink.yellow,
    solid: true,
    hatch: Ink.gold,
    seed: 6,
  );
  Pen.shape(
    c,
    Pen.rrect(const Rect.fromLTWH(-19, -13, 38, 9), 3),
    fill: Ink.yellow,
    solid: true,
    hatch: Ink.gold,
    seed: 7,
  );
  c.drawRect(const Rect.fromLTWH(-3.5, -13, 7, 31), Pen.fillPaint(Ink.coral));
  Pen.stroke(c, Pen.rrect(const Rect.fromLTWH(-3.5, -13, 7, 31), 1), width: 1.6, seed: 8);
  for (final s in [-1.0, 1.0]) {
    final loop = Path()
      ..moveTo(0, -13)
      ..cubicTo(s * 4, -26, s * 16, -24, s * 12, -15)
      ..quadraticBezierTo(s * 8, -12, 0, -13)
      ..close();
    Pen.shape(c, loop, fill: Ink.coral, solid: true, seed: s > 0 ? 9 : 10, width: 1.8);
  }
  Pen.dot(c, const Offset(0, -13), 3, Ink.shade(Ink.coral, 0.15));
}

/// The whole sunny pond backdrop (shared with the splash screen), drawn once per screen size.
class PondScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    SpriteCache.draw(canvas, 'home-scene-${size.width.round()}x${size.height.round()}', (c) => _paint(c, size));
  }

  static void _at(Canvas c, Offset o, void Function(Canvas c) draw, {double scale = 1, double rot = 0}) {
    c.save();
    c.translate(o.dx, o.dy);
    if (rot != 0) c.rotate(rot);
    if (scale != 1) c.scale(scale);
    draw(c);
    c.restore();
  }

  static void _paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    Offset at(double fx, double fy) => Offset(w * fx, h * fy);
    final k = w / 400; // art scale relative to a ~400pt wide phone

    // Sky.
    c.drawRect(Offset.zero & s, Pen.fillPaint(Ink.tint(Ink.sky, 0.8)));
    Paper.gridOverlay(c, Rect.fromLTWH(0, 0, w, h * 0.5), alpha: 0.22, cell: 22);
    _at(c, at(0.86, 0.085), (c) => Nature.sun(c, 26), scale: k * 1.25);
    for (final (fx, fy, cw) in [(0.5, 0.1, 110.0), (0.22, 0.2, 90.0), (0.92, 0.27, 80.0), (0.08, 0.31, 70.0)]) {
      _at(c, at(fx, fy), (c) => Nature.cloud(c, cw, seed: cw.round()), scale: k);
    }

    // Far trees and bushes along the horizon.
    final horizon = h * 0.43;
    for (var i = 0; i < 9; i++) {
      final x = w * (i / 8);
      _at(
        c,
        Offset(x, horizon - 6),
        (c) => Nature.bush(c, 120, color: i.isEven ? Ink.leaf : Ink.mint, seed: i + 40),
        scale: k * (0.9 + (i % 3) * 0.12),
      );
    }
    // Round trees on both sides.
    for (final (fx, fy, sc) in [(0.04, 0.37, 1.1), (0.97, 0.38, 1.0)]) {
      _at(c, at(fx, fy), (c) {
        Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-6, -10, 12, 46), 4), fill: Ink.brown, seed: 3, width: 2);
        for (final (o, r) in [
          (const Offset(-18, -22), 24.0),
          (const Offset(16, -26), 24.0),
          (const Offset(0, -46), 28.0),
        ]) {
          Pen.shape(c, Pen.circle(o, r), fill: Ink.leaf, cross: true, seed: r.round() + o.dx.round(), width: 2);
        }
      }, scale: k * sc);
    }

    // Meadow behind the pond.
    final meadow = Path()..moveTo(0, horizon + 10);
    for (var x = 0.0; x < w; x += w / 4) {
      meadow.quadraticBezierTo(x + w / 8, horizon - 4, x + w / 4, horizon + 8);
    }
    meadow
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    Pen.shape(c, meadow, fill: _grass, solid: true, hatch: Ink.leaf, hatchAngle: -0.8, hatchGap: 5, seed: 12);

    // Fences on the far banks.
    for (final (x0, x1) in [(0.0, 0.24), (0.8, 1.0)]) {
      final y = horizon + 14;
      for (var x = w * x0 + 6; x <= w * x1; x += 16 * k) {
        Pen.shape(
          c,
          Pen.rrect(Rect.fromLTWH(x - 3, y - 20 * k, 6, 24 * k), 2),
          fill: _wood,
          solid: true,
          seed: x.round(),
          width: 1.6,
          doubleLine: false,
        );
      }
      for (final dy in [-14.0, -5.0]) {
        Pen.line(
          c,
          Offset(w * x0, y + dy * k),
          Offset(w * x1, y + dy * k),
          ink: Ink.brown,
          width: 3,
          seed: dy.round().abs(),
        );
      }
    }

    // The pond.
    final pond = Path()
      ..moveTo(-20, h * 0.5)
      ..cubicTo(w * 0.25, h * 0.44, w * 0.75, h * 0.44, w + 20, h * 0.5)
      ..lineTo(w + 20, h * 0.8)
      ..cubicTo(w * 0.8, h * 0.9, w * 0.3, h * 0.92, -20, h * 0.84)
      ..close();
    Pen.shape(
      c,
      pond,
      fill: _water,
      solid: true,
      hatch: Ink.shade(_water, 0.12),
      hatchAngle: 0.6,
      hatchGap: 3.6,
      seed: 4,
      width: 2.6,
    );
    final ripples = Pen.inkPaint(Ink.white.withValues(alpha: 0.75), 1.8);
    final rnd = Random(5);
    c.save();
    c.clipPath(pond);
    for (var i = 0; i < 26; i++) {
      final o = Offset(rnd.nextDouble() * w, h * (0.47 + rnd.nextDouble() * 0.42));
      final rw = (14 + rnd.nextDouble() * 16) * k;
      c.drawPath(
        Path()
          ..moveTo(o.dx - rw / 2, o.dy)
          ..quadraticBezierTo(o.dx - rw / 4, o.dy - 3, o.dx, o.dy)
          ..quadraticBezierTo(o.dx + rw / 4, o.dy + 3, o.dx + rw / 2, o.dy),
        ripples,
      );
    }
    c.restore();

    // Rocks on the shore.
    for (final (fx, fy, rw) in [(0.05, 0.49, 46.0), (0.15, 0.48, 30.0), (0.86, 0.485, 34.0), (0.95, 0.5, 40.0)]) {
      _at(c, at(fx, fy), (c) => Nature.rock(c, rw, seed: rw.round()), scale: k);
    }

    // Lily pads drifting on the water.
    for (final (fx, fy, r, fl) in [
      (0.07, 0.57, 26.0, true),
      (0.18, 0.66, 18.0, false),
      (0.92, 0.6, 24.0, true),
      (0.88, 0.69, 18.0, false),
      (0.36, 0.83, 30.0, true),
      (0.78, 0.82, 26.0, false),
    ]) {
      _at(
        c,
        at(fx, fy),
        (c) => Nature.lilyPad(c, r, seed: (fx * 100).round(), flower: fl),
        scale: k,
      );
    }

    // Front bank with rocks, flowers and cattails.
    final front = Path()..moveTo(0, h * 0.86);
    for (var x = 0.0; x < w; x += w / 5) {
      front.quadraticBezierTo(x + w / 10, h * (x / w < 0.5 ? 0.9 : 0.86), x + w / 5, h * (0.88 + (x / w) * 0.02));
    }
    front
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    Pen.shape(c, front, fill: _grass, solid: true, hatch: Ink.leaf, hatchAngle: -0.8, hatchGap: 5, seed: 14);
    for (final (fx, fy, rw) in [(0.2, 0.91, 52.0), (0.34, 0.94, 36.0)]) {
      _at(c, at(fx, fy), (c) => Nature.rock(c, rw, seed: rw.round() + 1), scale: k);
    }
    for (final (fx, fy) in [(0.12, 0.83), (0.15, 0.95), (0.62, 0.97), (0.85, 0.95), (0.94, 0.92), (0.06, 0.5)]) {
      _at(c, at(fx, fy), (c) => Nature.flower(c, Ink.white, r: 10, face: false, seed: (fx * 100).round()), scale: k);
    }
    for (final (fx, fy) in [(0.48, 0.96), (0.7, 0.93), (0.28, 0.99), (0.55, 0.47), (0.4, 0.46)]) {
      _at(c, at(fx, fy), (c) => Nature.grass(c, 30, seed: (fx * 100).round()), scale: k);
    }
    for (final (fx, mirror) in [(0.06, false), (0.94, true)]) {
      _at(c, at(fx, 0.93), (c) {
        if (mirror) c.scale(-1, 1);
        for (final (x, rh) in [(-6.0, 110.0), (8.0, 92.0), (20.0, 72.0)]) {
          c.save();
          c.translate(x, 0);
          Nature.reed(c, rh, seed: rh.round());
          c.restore();
        }
        Pen.stroke(
          c,
          Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(-6, -40, -24, -70)
            ..moveTo(6, 0)
            ..quadraticBezierTo(14, -36, 32, -56),
          ink: Ink.leaf,
          width: 2.6,
          seed: 3,
        );
      }, scale: k);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
