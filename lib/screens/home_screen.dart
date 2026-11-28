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

// Colours measured from the reference illustration ("Hand-Drawn Tap and
// Drag Games Screen"): each fill is the average crayon colour of that area and
// each *Shade is its darker pencil strokes.
const _water = Color(0xFF6BD7FC);
const _waterShade = Color(0xFF5AD2FB);
const _grass = Color(0xFF8BEE37);
const _grassShade = Color(0xFF5FE00F);
const _bushGreen = Color(0xFF7EE849);
const _bushShade = Color(0xFF41CD12);
const _treeGreen = Color(0xFFA2EF3E);
const _treeShade = Color(0xFF78E710);
const _leafGreen = Color(0xFF72DC46);
const _leafShade = Color(0xFF26A42B);
const _padGreen = Color(0xFF8CE53B);
const _padShade = Color(0xFF4DC60E);
const _brown = Color(0xFFEEA853);
const _brownShade = Color(0xFFD37018);
const _signWood = Color(0xFFF4B95E);
const _signShade = Color(0xFFE78D26);
const _wood = Color(0xFFEEB96E);
const _woodShade = Color(0xFFCE8834);
const _rope = Color(0xFFDEB763);
const _ropeShade = Color(0xFFA37730);
const _rockGrey = Color(0xFFB1BCCE);
const _cattailBrown = Color(0xFFDDA962);
const _cattailShade = Color(0xFFCA7016);
const _dash = Color(0xFFFC890A);
const _rayGold = Color(0xFFFCB54A);
const _titlePink = Color(0xFFFA86AA);
const _titleBlue = Color(0xFF3AC1FB);
const _titleGreen = Color(0xFF75F156);
const _titleYellow = Color(0xFFFBE21C);
const _playYellow = Color(0xFFFDE335);
const _rewardsPink = Color(0xFFFDB7DE);
const _sun = Color(0xFFFCE829);
const _sunShade = Color(0xFFF7D93B);
const _lilyLight = Color(0xFFFBBCE0);
const _lily = Color(0xFFEBA7CA);
const _lilyShade = Color(0xFFE36AAF);
const _cloudShade = Color(0xFFB5ECFC);
const _gridLine = Color(0xFFD7F2FD);
const _gearBlue = Color(0xFF2E4CA4);
const _ribbonRed = Color(0xFFF74C5A);
// Small accents (controller buttons, cheeks) from the shared palette.
const _orange = Color(0xFFDD8C45);
const _coral = _ribbonRed;
const _yellow = _playYellow;
const _gold = Color(0xFFF7D93B);
const _mint = Color(0xFF62B27D);
const _blue = Color(0xFF4881E1);
const _pink = _lily;
const _leafInk = _leafShade;

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
      body: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth, h = c.maxHeight;
          final top = MediaQuery.paddingOf(context).top;
          // Everything is placed at the same fractions of the screen as the
          // reference illustration, so the pond art and the widgets line up.
          return Stack(
            children: [
              Positioned.fill(
                child: DuskFilter(child: CustomPaint(painter: PondScenePainter(sun: false))),
              ),
              // The sign and buttons are part of the illustration: always daytime colours.
              Theme(
                data: sketchLightTheme,
                child: Stack(
                  children: [
                    Positioned(
                      top: max(h * 0.19, top + 96),
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SizedBox(
                          width: min(w * 0.8, 440),
                          child: ListenableBuilder(
                            listenable: scope.settings,
                            builder: (context, child) => AnimatedBuilder(
                              animation: _bob,
                              // A gentle swing from the rope tops.
                              builder: (context, child) => Transform.rotate(
                                angle: scope.settings.effectiveReducedMotion ? 0 : sin(_bob.value * 2 * pi) * 0.012,
                                alignment: const Alignment(0, -2.2),
                                child: child,
                              ),
                              child: child,
                            ),
                            child: const TitleSign(hanging: true),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: h * 0.525,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          _MenuButton(
                            label: l.homePlayGames,
                            fill: _playYellow,
                            icon: _Icon.controller,
                            onTap: () =>
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HubScreen())),
                          ),
                          const SizedBox(height: 16),
                          _MenuButton(
                            label: l.homeRewards,
                            fill: _rewardsPink,
                            icon: _Icon.gift,
                            onTap: () => _showRewards(context),
                          ),
                        ],
                      ),
                    ),
                    // Settings tucked against the sun.
                    Positioned(
                      top: max(h * 0.135 - 24, top + 4),
                      right: w * 0.13 - 24,
                      child: SketchButton(
                        semanticLabel: l.settings,
                        fill: Ink.white,
                        radius: 14,
                        padding: const EdgeInsets.all(10),
                        onTap: () => openSettings(context),
                        child: const DoodleIcon(Doodle.gear, color: _gearBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
  const TitleSign({super.key, this.hanging = false});

  /// Hung from two ropes with leafy tops (home). Without it the leaves sprout
  /// from the plank itself (splash, where the mascot stands on top).
  final bool hanging;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final style = Txt.title.copyWith(fontSize: 46, height: 1.05, letterSpacing: 0.5);
    // Each word of the first line gets the next crayon colour.
    const colors = [_titlePink, _titleBlue, _titleGreen, _orange];
    final words = l.homeTitleLine1.split(' ');
    return Semantics(
      header: true,
      label: l.homeTitleSemantics,
      child: ExcludeSemantics(
        child: CustomPaint(
          painter: _SignPainter(hanging: hanging),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(38, 26, 38, 30),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  OutlinedText(
                    [for (final (i, w) in words.indexed) (i < words.length - 1 ? '$w ' : w, colors[i % colors.length])],
                    style: style,
                    rim: Ink.white,
                    // Thick enough to stay bold after the sign scales the title down.
                    stroke: 13,
                  ),
                  OutlinedText([(l.homeTitleLine2, _titleYellow)], style: style, rim: Ink.white, stroke: 13),
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
  _SignPainter({required this.hanging});
  final bool hanging;

  /// Rope lengths above the ties: the left one ends in a leafy knot, the
  /// right one holds up the sun.
  static const leftRope = 48.0, rightRope = 52.0, sunRadius = 30.0;

  /// A twisted rope from [a] up to [b].
  static void _ropeTo(Canvas c, Offset a, Offset b) {
    final d = b - a;
    final n = Offset(-d.dy, d.dx) / d.distance * 3.4;
    final band = Path()
      ..moveTo((a + n).dx, (a + n).dy)
      ..lineTo((b + n).dx, (b + n).dy)
      ..lineTo((b - n).dx, (b - n).dy)
      ..lineTo((a - n).dx, (a - n).dy)
      ..close();
    Pen.shape(c, band, fill: _rope, solid: true, width: 1.8, seed: 41, doubleLine: false, amp: 0.4);
    // Twist marks along the rope.
    final twist = Pen.inkPaint(_ropeShade, 1.3);
    for (var t = 0.08; t < 1; t += 0.11) {
      final o = Offset.lerp(a, b, t)!;
      c.drawLine(o - n * 0.9, o + n * 0.9 + d / d.distance * 3, twist);
    }
  }

  static void _leaf(Canvas c, Offset at, double angle, double len, int seed) {
    c.save();
    c.translate(at.dx, at.dy);
    c.rotate(angle);
    Nature.leaf(c, len, color: _leafGreen, width: 0.45, seed: seed);
    c.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    SpriteCache.draw(canvas, 'home-sign-$hanging-${size.width.round()}x${size.height.round()}', (c) {
      final r = (Offset.zero & size).deflate(6);
      // Ropes go behind the plank; their loops are drawn on top of it.
      final ties = [Offset(r.left + r.width * 0.21, r.top + 14), Offset(r.left + r.width * 0.84, r.top + 14)];
      final leftTop = ties[0] + const Offset(-2, -leftRope);
      final rightTop = ties[1] + const Offset(4, -rightRope);
      if (hanging) {
        _ropeTo(c, ties[0], leftTop);
        _ropeTo(c, ties[1], rightTop);
      }
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
        fill: _signWood,
        solid: true,
        hatch: _signShade.withValues(alpha: 0.6),
        hatchAngle: 0.1,
        seed: 21,
        width: 2.8,
      );
      // Wood grain streaks.
      final grain = Pen.inkPaint(_signShade, 1.6);
      for (final (fx, fy, w) in [
        (0.12, 0.22, 0.18),
        (0.7, 0.16, 0.2),
        (0.2, 0.84, 0.22),
        (0.66, 0.86, 0.16),
        (0.04, 0.55, 0.08),
        (0.88, 0.5, 0.08),
        (0.42, 0.93, 0.14),
      ]) {
        final o = Offset(r.left + r.width * fx, r.top + r.height * fy);
        c.drawPath(
          Path()
            ..moveTo(o.dx, o.dy)
            ..quadraticBezierTo(o.dx + r.width * w / 2, o.dy - 3, o.dx + r.width * w, o.dy),
          grain,
        );
      }
      // Rope loops through the plank, leaves, and the sun on the right rope
      // (home); or leaves sprouting from the top corners (splash).
      if (hanging) {
        for (final t in ties) {
          c.drawCircle(t, 6, Pen.inkPaint(Ink.navy, 6.5));
          c.drawCircle(t, 6, Pen.inkPaint(_rope, 3.6));
          Pen.dot(c, t, 3.2, _signShade);
        }
        _leaf(c, leftTop + const Offset(0, 6), -2.3, 36, 2);
        _leaf(c, leftTop + const Offset(0, 6), -1.05, 34, 5);
        _leaf(c, ties[1] + const Offset(10, -10), -0.85, 30, 8);
        c.save();
        c.translate(rightTop.dx + 4, rightTop.dy - sunRadius + 4);
        happySun(c, sunRadius);
        c.restore();
      }
      for (final (o, a, flip) in [
        if (!hanging) ...[
          (Offset(r.left + 30, r.top + 2), -1.9, false),
          (Offset(r.left + 40, r.top + 2), -1.2, false),
          (Offset(r.right - 30, r.top + 2), -1.25, true),
          (Offset(r.right - 40, r.top + 2), -1.95, true),
        ],
      ]) {
        c.save();
        c.translate(o.dx, o.dy);
        c.rotate(a);
        if (flip) c.scale(1, -1);
        Nature.leaf(c, 30, color: _leafGreen, width: 0.42, seed: o.dx.round());
        c.restore();
      }
      // Little "ta-da" dashes beside "Games".
      for (final side in [-1.0, 1.0]) {
        final base = Offset(side > 0 ? r.right - 22 : r.left + 22, r.top + r.height * 0.68);
        for (final a in [-0.6, -0.2, 0.2, 0.6]) {
          final d = Offset(cos(a) * side, sin(a));
          Pen.line(c, base + d * 4, base + d * 17, ink: _dash, width: 3, seed: (a * 10).round().abs() + 3);
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
          width: min(MediaQuery.sizeOf(context).width * 0.65, 300),
          height: 92,
          child: SketchButton(
            fill: fill,
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
      for (final a in [-0.55, 0.0, 0.55]) {
        final d = Offset(cos(a), sin(a));
        Pen.line(
          c,
          d * 4 - const Offset(8, 0),
          d * 16 - const Offset(8, 0),
          ink: _dash,
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
  Pen.line(c, const Offset(-19, -2), const Offset(-9, -2), ink: _blue, width: 4);
  Pen.line(c, const Offset(-14, -7), const Offset(-14, 3), ink: _blue, width: 4);
  for (final (o, col) in [
    (const Offset(14, -7), _yellow),
    (const Offset(19, -2), _coral),
    (const Offset(14, 3), _mint),
    (const Offset(9, -2), _blue),
  ]) {
    Pen.dot(c, o, 2.6, col);
  }
  Pen.line(c, const Offset(-4, -5), const Offset(-1, -5), ink: Ink.navySoft, width: 1.6);
  Pen.line(c, const Offset(2, -5), const Offset(5, -5), ink: Ink.navySoft, width: 1.6);
}

void _gift(Canvas c) {
  Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-16, -6, 32, 24), 3), fill: _yellow, solid: true, hatch: _gold, seed: 6);
  Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-19, -13, 38, 9), 3), fill: _yellow, solid: true, hatch: _gold, seed: 7);
  c.drawRect(const Rect.fromLTWH(-3.5, -13, 7, 31), Pen.fillPaint(_coral));
  Pen.stroke(c, Pen.rrect(const Rect.fromLTWH(-3.5, -13, 7, 31), 1), width: 1.6, seed: 8);
  for (final s in [-1.0, 1.0]) {
    final loop = Path()
      ..moveTo(0, -13)
      ..cubicTo(s * 4, -26, s * 16, -24, s * 12, -15)
      ..quadraticBezierTo(s * 8, -12, 0, -13)
      ..close();
    Pen.shape(c, loop, fill: _coral, solid: true, seed: s > 0 ? 9 : 10, width: 1.8);
  }
  Pen.dot(c, const Offset(0, -13), 3, Ink.shade(_coral, 0.15));
}

/// The whole sunny pond backdrop (shared with the splash screen), drawn once
/// per screen size. Positions are fractions of the screen, taken from the
/// reference illustration; art sizes scale with the width.
class PondScenePainter extends CustomPainter {
  PondScenePainter({this.sun = true});

  /// The home screen hangs its sun from the sign's rope instead.
  final bool sun;

  @override
  void paint(Canvas canvas, Size size) {
    SpriteCache.draw(
      canvas,
      'home-scene-$sun-${size.width.round()}x${size.height.round()}',
      (c) => _paint(c, size, sun: sun),
    );
  }

  static void _at(Canvas c, Offset o, void Function(Canvas c) draw, {double scale = 1, double rot = 0}) {
    c.save();
    c.translate(o.dx, o.dy);
    if (rot != 0) c.rotate(rot);
    if (scale != 1) c.scale(scale);
    draw(c);
    c.restore();
  }

  /// A crayon cloud: white with blue pencil shading.
  static void _cloud(Canvas c, double w, int seed) =>
      Nature.cloud(c, w, fill: Ink.white, hatch: _cloudShade, seed: seed);

  /// Round leafy tree; its trunk base is at the origin.
  static void _tree(Canvas c, {required bool mirror, int seed = 1}) {
    if (mirror) c.scale(-1, 1);
    final trunk = Path()
      ..moveTo(-8, 0)
      ..quadraticBezierTo(-5, -40, -6, -84)
      ..lineTo(6, -84)
      ..quadraticBezierTo(5, -40, 9, 0)
      ..close();
    Pen.shape(c, trunk, fill: _brown, solid: true, hatch: _brownShade, seed: seed, width: 2.2);
    // Forked branches.
    for (final (a, b) in [
      (const Offset(-2, -44), const Offset(-22, -70)),
      (const Offset(2, -54), const Offset(20, -76)),
    ]) {
      Pen.line(c, a, b, ink: Ink.navy, width: 6.5, seed: seed);
      Pen.line(c, a, b, ink: _brown, width: 3.5, seed: seed);
    }
    for (final (o, r) in [
      (const Offset(-26, -92), 24.0),
      (const Offset(26, -96), 24.0),
      (const Offset(-10, -116), 28.0),
      (const Offset(18, -122), 24.0),
      (const Offset(0, -94), 26.0),
    ]) {
      Pen.shape(
        c,
        Pen.circle(o, r),
        fill: _treeGreen,
        solid: true,
        hatch: _treeShade,
        hatchGap: 4,
        seed: seed + r.round() + o.dx.round(),
        width: 2.2,
      );
    }
  }

  /// Wooden fence post with a pointed top; its base is at the origin.
  static Path _post(double w, double h) => Path()
    ..moveTo(-w / 2, 0)
    ..lineTo(-w / 2, -h + w / 2)
    ..lineTo(0, -h)
    ..lineTo(w / 2, -h + w / 2)
    ..lineTo(w / 2, 0)
    ..close();

  static void _paint(Canvas c, Size s, {required bool sun}) {
    final w = s.width, h = s.height;
    Offset at(double fx, double fy) => Offset(w * fx, h * fy);
    final k = w / 400; // art scale relative to a ~400pt wide phone

    // Sky: plain notebook graph paper.
    Paper.graph(c, Offset.zero & s, base: Ink.white, line: _gridLine, cell: 22, speckles: false);
    _at(c, at(0.155, 0.11), (c) => _cloud(c, 84, 3), scale: k);
    _at(c, at(0.49, 0.125), (c) => _cloud(c, 112, 5), scale: k);
    _at(c, at(0.97, 0.285), (c) => _cloud(c, 86, 7), scale: k);
    if (sun) _at(c, at(0.785, 0.115), (c) => happySun(c, 30), scale: k);

    // Trees on both sides, standing on the far meadow.
    final horizon = h * 0.455;
    _at(c, Offset(w * 0.085, horizon + 4), (c) => _tree(c, mirror: false, seed: 3), scale: k * 1.05);
    _at(c, Offset(w * 0.905, horizon + 4), (c) => _tree(c, mirror: true, seed: 9), scale: k * 0.95);

    // A row of bushes along the horizon.
    for (final (fx, rx, ry) in [
      (0.2, 48.0, 56.0),
      (0.44, 52.0, 62.0),
      (0.68, 52.0, 58.0),
      (0.88, 44.0, 50.0),
      (0.32, 46.0, 46.0),
      (0.56, 48.0, 50.0),
      (0.78, 44.0, 44.0),
    ]) {
      final o = Offset(w * fx, horizon + 4);
      final bush = Path.combine(
        PathOperation.intersect,
        Pen.oval(o, rx * k, ry * k),
        Path()..addRect(Rect.fromLTRB(o.dx - rx * k - 4, o.dy - ry * k - 4, o.dx + rx * k + 4, o.dy)),
      );
      Pen.shape(
        c,
        bush,
        fill: _bushGreen,
        solid: true,
        hatch: _bushShade,
        hatchGap: 4.5,
        seed: (fx * 100).round(),
        width: 2.2,
      );
    }

    // Meadow from the horizon down.
    final meadow = Path()..moveTo(-10, horizon + 2);
    for (var x = -10.0; x < w + 10; x += w / 3) {
      meadow.quadraticBezierTo(x + w / 6, horizon - 6, x + w / 3, horizon + 2);
    }
    meadow
      ..lineTo(w + 10, h + 10)
      ..lineTo(-10, h + 10)
      ..close();
    Pen.shape(c, meadow, fill: _grass, solid: true, hatch: _grassShade, hatchAngle: -0.9, hatchGap: 4, seed: 12);

    // Fences on both sides.
    for (final (x0, x1) in [(0.02, 0.28), (0.7, 0.98)]) {
      final base = h * 0.472;
      final ph = 34 * k;
      for (final dy in [0.32, 0.7]) {
        final y = base - ph * dy;
        Pen.shape(
          c,
          Pen.rrect(Rect.fromLTRB(w * x0 - 4, y - 3 * k, w * x1 + 4, y + 3 * k), 2),
          fill: _wood,
          solid: true,
          width: 1.8,
          seed: (dy * 10).round(),
          doubleLine: false,
        );
      }
      const posts = 6;
      for (var i = 0; i <= posts; i++) {
        final x = w * (x0 + (x1 - x0) * i / posts);
        _at(
          c,
          Offset(x, base),
          (c) => Pen.shape(
            c,
            _post(9, 34),
            fill: _wood,
            solid: true,
            hatch: _woodShade,
            seed: i + 1,
            width: 1.8,
            doubleLine: false,
          ),
          scale: k,
        );
      }
    }

    // The pond.
    final pond = Path()
      ..moveTo(-20, h * 0.505)
      ..cubicTo(w * 0.25, h * 0.48, w * 0.75, h * 0.48, w + 20, h * 0.51)
      ..lineTo(w + 20, h * 0.83)
      ..cubicTo(w * 0.78, h * 0.86, w * 0.6, h * 0.885, w * 0.4, h * 0.885)
      ..cubicTo(w * 0.2, h * 0.885, w * 0.05, h * 0.86, -20, h * 0.84)
      ..close();
    Pen.shape(
      c,
      pond,
      fill: _water,
      solid: true,
      hatch: _waterShade,
      hatchAngle: 0.6,
      hatchGap: 3.6,
      seed: 4,
      width: 2.6,
    );
    final ripples = Pen.inkPaint(Ink.white.withValues(alpha: 0.85), 1.8);
    final rnd = Random(5);
    c.save();
    c.clipPath(pond);
    for (var i = 0; i < 34; i++) {
      final o = Offset(rnd.nextDouble() * w, h * (0.5 + rnd.nextDouble() * 0.37));
      final rw = (10 + rnd.nextDouble() * 14) * k;
      c.drawPath(
        Path()
          ..moveTo(o.dx - rw / 2, o.dy)
          ..quadraticBezierTo(o.dx - rw / 4, o.dy - 2.5, o.dx, o.dy)
          ..quadraticBezierTo(o.dx + rw / 4, o.dy + 2.5, o.dx + rw / 2, o.dy),
        ripples,
      );
    }
    c.restore();

    // Rocks on the far bank.
    for (final (fx, fy, rw) in [(0.1, 0.515, 50.0), (0.19, 0.507, 34.0), (0.8, 0.51, 42.0), (0.9, 0.527, 46.0)]) {
      _at(
        c,
        at(fx, fy),
        (c) => Nature.rock(c, rw, seed: rw.round(), color: _rockGrey),
        scale: k,
      );
    }
    for (final (fx, fy) in [(0.45, 0.47), (0.93, 0.493)]) {
      _at(
        c,
        at(fx, fy),
        (c) => Nature.grass(c, 20, seed: (fx * 100).round(), color: _leafInk),
        scale: k,
      );
    }

    // Lily pads, most with a water lily.
    for (final (fx, fy, r, lily) in [
      (0.1, 0.61, 22.0, true),
      (0.885, 0.64, 25.0, true),
      (0.37, 0.835, 36.0, true),
      (0.73, 0.82, 26.0, false),
    ]) {
      _at(c, at(fx, fy), (c) {
        _lilyPad(c, r, seed: (fx * 100).round());
        if (lily) _waterLily(c, r * 0.8, seed: (fx * 100).round());
      }, scale: k);
    }

    // Front bank.
    final front = Path()
      ..moveTo(-10, h * 0.8)
      ..cubicTo(w * 0.1, h * 0.84, w * 0.15, h * 0.875, w * 0.35, h * 0.885)
      ..cubicTo(w * 0.55, h * 0.895, w * 0.72, h * 0.875, w * 0.82, h * 0.85)
      ..cubicTo(w * 0.9, h * 0.83, w * 0.95, h * 0.8, w + 10, h * 0.79)
      ..lineTo(w + 10, h + 10)
      ..lineTo(-10, h + 10)
      ..close();
    Pen.shape(c, front, fill: _grass, solid: true, hatch: _grassShade, hatchAngle: -0.9, hatchGap: 4, seed: 14);
    for (final (fx, fy, rw) in [(0.21, 0.9, 54.0), (0.32, 0.94, 40.0)]) {
      _at(
        c,
        at(fx, fy),
        (c) => Nature.rock(c, rw, seed: rw.round() + 1, color: _rockGrey),
        scale: k,
      );
    }
    for (final (fx, fy) in [(0.25, 0.975), (0.47, 0.955), (0.68, 0.92), (0.83, 0.975), (0.55, 0.99)]) {
      _at(
        c,
        at(fx, fy),
        (c) => Nature.grass(c, 22, seed: (fx * 100).round(), color: _leafInk),
        scale: k,
      );
    }
    for (final (fx, fy) in [(0.115, 0.945), (0.6, 0.965), (0.89, 0.925)]) {
      _at(c, at(fx, fy), (c) => Nature.flower(c, Ink.white, r: 12, face: false, seed: (fx * 100).round()), scale: k);
    }

    // Cattails with long grass blades in the front corners.
    for (final (fx, mirror) in [(0.09, false), (0.9, true)]) {
      _at(c, at(fx, 0.895), (c) {
        if (mirror) c.scale(-1, 1);
        for (final (x, rh) in [(-10.0, 120.0), (12.0, 100.0)]) {
          c.save();
          c.translate(x, 0);
          _cattail(c, rh, seed: rh.round());
          c.restore();
        }
        for (final (ang, len) in [(-1.95, 70.0), (-1.75, 86.0), (-1.4, 78.0), (-1.15, 62.0), (-2.2, 54.0)]) {
          c.save();
          c.rotate(ang);
          Pen.shape(
            c,
            Nature.leafPath(len, 7),
            fill: _leafGreen,
            solid: true,
            hatch: _leafShade,
            seed: len.round(),
            width: 1.8,
            doubleLine: false,
          );
          c.restore();
        }
      }, scale: k);
    }
  }

  @override
  bool shouldRepaint(covariant PondScenePainter oldDelegate) => oldDelegate.sun != sun;
}

/// A beaming yellow sun with orange rays and a big open smile.
void happySun(Canvas c, double r) {
  for (var i = 0; i < 12; i++) {
    final a = i * pi / 6 + 0.12;
    final d = Offset(cos(a), sin(a));
    Pen.line(c, d * (r * 1.3), d * (r * (i.isEven ? 1.7 : 1.55)), ink: i.isEven ? _rayGold : _dash, width: 3);
  }
  Pen.shape(
    c,
    Pen.circle(Offset.zero, r),
    fill: _sun,
    solid: true,
    hatch: _sunShade,
    hatchGap: 4,
    ink: _dash,
    width: 2.4,
    seed: 4,
  );
  // Eyes with a sparkle, rosy cheeks, open smile.
  for (final dx in [-r * 0.32, r * 0.32]) {
    c.drawOval(
      Rect.fromCenter(center: Offset(dx, -r * 0.18), width: r * 0.17, height: r * 0.24),
      Pen.fillPaint(Ink.navy),
    );
    Pen.dot(c, Offset(dx - r * 0.03, -r * 0.24), r * 0.035, Ink.white);
    c.drawOval(
      Rect.fromCenter(center: Offset(dx * 1.6, r * 0.18), width: r * 0.3, height: r * 0.17),
      Pen.fillPaint(_coral.withValues(alpha: 0.6)),
    );
  }
  final mouth = Path()
    ..moveTo(-r * 0.36, r * 0.12)
    ..quadraticBezierTo(0, r * 0.22, r * 0.36, r * 0.12)
    ..quadraticBezierTo(r * 0.3, r * 0.58, 0, r * 0.58)
    ..quadraticBezierTo(-r * 0.3, r * 0.58, -r * 0.36, r * 0.12)
    ..close();
  c.drawPath(mouth, Pen.fillPaint(Ink.shade(_coral, 0.1)));
  c.save();
  c.clipPath(mouth);
  c.drawCircle(Offset(0, r * 0.62), r * 0.2, Pen.fillPaint(_pink));
  c.restore();
  c.drawPath(mouth, Pen.inkPaint(Ink.navy, 2));
}

/// A pink water lily: pointed petals fanned upwards around a yellow heart.
void _waterLily(Canvas c, double r, {int seed = 1}) {
  c.save();
  c.translate(-r * 0.3, -r * 0.15);
  // Back row then front row, so the front petals overlap.
  for (final (angles, len, color) in [
    (const [-2.5, -1.95, -1.57, -1.19, -0.64], r * 1.35, _lilyLight),
    (const [-2.2, -1.57, -0.94], r * 1.05, _lily),
  ]) {
    for (final (i, a) in angles.indexed) {
      c.save();
      c.rotate(a);
      Pen.shape(
        c,
        Nature.leafPath(len, len * 0.42),
        fill: color,
        solid: true,
        hatch: _lilyShade,
        width: 1.7,
        seed: seed + i,
        doubleLine: false,
      );
      c.restore();
    }
  }
  Pen.shape(c, Pen.oval(const Offset(0, -2), r * 0.3, r * 0.2), fill: _yellow, solid: true, width: 1.4, seed: seed);
  c.restore();
}

/// A bright lily pad with a notch.
void _lilyPad(Canvas c, double r, {int seed = 1}) {
  final p = Path.combine(
    PathOperation.difference,
    Pen.oval(Offset.zero, r, r * 0.62),
    Path()
      ..moveTo(0, 0)
      ..lineTo(r * 1.2, -r * 0.25)
      ..lineTo(r * 1.2, r * 0.15)
      ..close(),
  );
  Pen.shape(c, p, fill: _padGreen, solid: true, hatch: _padShade, hatchGap: 4, seed: seed, width: 2);
}

/// A cattail: a curved green stem with a fat brown head.
void _cattail(Canvas c, double h, {int seed = 1}) {
  Pen.stroke(
    c,
    Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-3, -h * 0.6, 2, -h),
    ink: Ink.navy,
    width: 5,
    seed: seed,
  );
  Pen.stroke(
    c,
    Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-3, -h * 0.6, 2, -h),
    ink: _leafGreen,
    width: 2.6,
    seed: seed,
  );
  Pen.shape(
    c,
    Pen.rrect(Rect.fromCenter(center: Offset(2, -h + 14), width: 13, height: 32), 6.5),
    fill: _cattailBrown,
    solid: true,
    hatch: _cattailShade,
    hatchGap: 3.5,
    seed: seed,
    width: 2,
  );
  Pen.line(c, Offset(2, -h - 2), Offset(2, -h - 10), ink: Ink.navy, width: 1.8);
}
