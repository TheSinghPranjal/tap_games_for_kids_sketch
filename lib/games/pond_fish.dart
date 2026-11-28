import 'dart:math';

import 'common.dart';

const _fishColors = Critters.fishColors;
const _water = Color(0xFF4DB3EC);
const _grass = Color(0xFF8BD866);

void _fish(Canvas c, int color, Offset at, {double scale = 1, bool left = false, double rotation = 0}) => sprite(
  c,
  'fish-$color',
  at,
  (c) => Critters.fish(c, _fishColors[color], seed: color + 1),
  scale: scale,
  sx: left ? -1 : 1,
  rotation: rotation,
);

enum _S { swim, caught }

class _Fish {
  _Fish(this.id, this.pos, this.vx, this.color, this.phase);
  final String id;
  Offset pos;
  double vx;
  final int color;
  final double phase;
  _S state = _S.swim;
  double t = 0;
  double turnCd = 0;
}

class PondFishScene extends GameScene {
  PondFishScene(this.cfg);
  final ScoreConfig cfg;

  static const center = Offset(182, 300);
  static const rx = 166.0, ry = 212.0;
  static const basketAt = Offset(298, 562);
  static const frame = Rect.fromLTRB(6, 4, 354, 614);

  final fish = <_Fish>[];
  int caught = 0;
  double _spawnIn = 0;
  double _basketBounce = 1;

  int get _target => ctx.simple ? 3 : 4;
  double get _size => ctx.simple ? 1.25 : 1.05;

  bool _inPond(Offset p, [double margin = 34]) {
    final dx = (p.dx - center.dx) / (rx - margin), dy = (p.dy - center.dy) / (ry - margin);
    return dx * dx + dy * dy <= 1;
  }

  @override
  void setup() {
    for (var i = 0; i < _target; i++) {
      _spawn();
    }
  }

  void _spawn() {
    final area = Rect.fromCenter(center: center, width: rx * 1.5, height: ry * 1.6);
    var p = freeSpot(area, fish.map((f) => f.pos), 90);
    if (!_inPond(p, 44)) p = center + Offset(rand(-60, 60), rand(-120, 120));
    final speed = rand(38, 62) * ctx.speed;
    fish.add(_Fish(newId('fish'), p, rng.nextBool() ? speed : -speed, rng.nextInt(_fishColors.length), rand(0, 6)));
  }

  @override
  void tick(double dt) {
    _basketBounce = (_basketBounce + dt * 3).clamp(0, 1);
    for (final f in fish) {
      f.t += dt;
      f.turnCd -= dt;
      if (f.state != _S.swim) continue;
      // A fish that ended up outside the swim zone drifts back towards the middle.
      if (!_inPond(f.pos, 44)) {
        f.pos += (center - f.pos) * min(1.0, dt * 2);
        continue;
      }
      // Move horizontally and vertically separately so the bobbing drift can
      // never pin a fish against the shore while it keeps flipping direction.
      final nx = f.pos + Offset(f.vx * dt, 0);
      if (_inPond(nx, 44)) {
        f.pos = nx;
      } else {
        f.vx = -f.vx;
        f.turnCd = 0.4;
      }
      final ny = f.pos + Offset(0, wave(time, 1.6, f.phase) * 12 * dt);
      if (_inPond(ny, 44)) f.pos = ny;
    }
    // Keep targets apart: a fish heading into another one turns around (with a
    // short cooldown so a fish squeezed between two others doesn't flip every
    // frame), and close fish gently push apart.
    for (final a in fish) {
      for (final b in fish) {
        if (identical(a, b) || a.state != _S.swim || b.state != _S.swim) continue;
        final d = b.pos - a.pos;
        if (d.distance >= 74) continue;
        if (a.turnCd <= 0 && d.dx.sign == a.vx.sign && d.dx.abs() > 1) {
          a.vx = -a.vx;
          a.turnCd = 0.6;
        }
        final away = d.distance > 0.1 ? -d / d.distance : const Offset(0, 1);
        final pushed = a.pos + away * 30 * dt;
        if (_inPond(pushed, 44)) a.pos = pushed;
      }
    }
    fish.removeWhere((f) => f.state == _S.caught && f.t > 0.3);
    final swimming = fish.where((f) => f.state == _S.swim).length;
    if (!ended && swimming < _target) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = 0.7;
      }
    }
  }

  @override
  void onTap(Offset p) {
    _Fish? best;
    var bestD = 34 * _size + ctx.hitPad;
    for (final f in fish) {
      if (f.state != _S.swim) continue;
      final d = (f.pos - p).distance;
      if (d < bestD) {
        bestD = d;
        best = f;
      }
    }
    final f = best;
    if (f == null) return; // missed taps are never punished
    f
      ..state = _S.caught
      ..t = 0;
    caught++;
    fx.splash(f.pos);
    ctx.onSfx(Sfx.splash);
    score(cfg.base, f.id, f.pos);
    final from = f.pos, left = f.vx < 0, color = f.color;
    // Wiggle briefly, then arc into the basket.
    fly(
      from,
      basketAt + const Offset(0, -24),
      0.75,
      (c, pos, t) {
        final wig = t < 0.25 ? wave(t * 60) * 0.35 : t * 4;
        _fish(c, color, pos, scale: _size * (1 - t * 0.45), left: left, rotation: wig);
      },
      arc: -140,
      onArrive: () {
        _basketBounce = 0;
        fx.burst(basketAt + const Offset(0, -30), count: 6);
        ctx.onSfx(Sfx.collect);
      },
    );
  }

  /// Slightly egg-shaped pond, wider towards the bottom like a real puddle.
  static Path _pondPath() {
    final l = center.dx - rx, r = center.dx + rx, t = center.dy - ry, b = center.dy + ry;
    return Path()
      ..moveTo(center.dx, t)
      ..cubicTo(center.dx + rx * 0.62, t, r - 4, center.dy - ry * 0.55, r, center.dy + 6)
      ..cubicTo(r + 2, center.dy + ry * 0.62, center.dx + rx * 0.6, b, center.dx - 6, b)
      ..cubicTo(center.dx - rx * 0.62, b, l - 2, center.dy + ry * 0.6, l, center.dy + 4)
      ..cubicTo(l + 4, center.dy - ry * 0.58, center.dx - rx * 0.6, t, center.dx, t)
      ..close();
  }

  static void _at(Canvas c, Offset o, void Function(Canvas c) draw, {double scale = 1}) {
    c.save();
    c.translate(o.dx, o.dy);
    if (scale != 1) c.scale(scale);
    draw(c);
    c.restore();
  }

  /// Grass tuft: a fan of curved blades rooted at the origin.
  static void _tuft(Canvas c, double h, {int seed = 1}) {
    final r = Random(seed);
    final blades = Path();
    for (var i = 0; i < 5; i++) {
      final a = -0.9 + i * 0.45 + (r.nextDouble() - 0.5) * 0.2;
      final len = h * (i == 2 ? 1 : 0.6 + r.nextDouble() * 0.3);
      blades
        ..moveTo(i * 2.0 - 4, 0)
        ..quadraticBezierTo(a * h * 0.3, -len * 0.6, a * h * 0.6, -len);
    }
    Pen.stroke(c, blades, ink: Ink.leaf, width: 2, seed: seed, amp: 0.4);
  }

  /// Cattail cluster: tall leaves plus two or three brown heads.
  static void _cattails(Canvas c, {bool mirror = false, int seed = 1}) {
    if (mirror) c.scale(-1, 1);
    final leaves = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-4, -40, -18, -62)
      ..moveTo(4, 0)
      ..quadraticBezierTo(10, -36, 24, -54)
      ..moveTo(2, 0)
      ..quadraticBezierTo(2, -30, 10, -46)
      ..moveTo(-2, 0)
      ..quadraticBezierTo(-12, -20, -22, -30);
    Pen.stroke(c, leaves, ink: Ink.leaf, width: 2.4, seed: seed, amp: 0.5);
    for (final (x, h) in [(-6.0, 88.0), (8.0, 76.0), (18.0, 60.0)]) {
      _at(c, Offset(x, 0), (c) => Nature.reed(c, h, seed: seed + h.round()));
    }
  }

  static void _daisy(Canvas c, {int seed = 1}) {
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * pi / 5 - pi / 2;
      Pen.shape(
        c,
        Pen.circle(Offset(cos(a), sin(a)) * 5.5, 4.2),
        fill: Ink.white,
        solid: true,
        hatch: Ink.grid,
        width: 1.2,
        seed: seed + i,
        doubleLine: false,
      );
    }
    Pen.dot(c, Offset.zero, 3, Ink.gold);
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    // Notebook frame around the whole scene.
    Pen.shape(c, Pen.rrect(frame, 14), seed: 11, width: 2.4);

    // Top meadow: a rounded panel with a sandy lower lip.
    final top = Path()
      ..moveTo(frame.left, frame.top + 14)
      ..quadraticBezierTo(frame.left, frame.top, frame.left + 14, frame.top)
      ..lineTo(frame.right - 14, frame.top)
      ..quadraticBezierTo(frame.right, frame.top, frame.right, frame.top + 14)
      ..lineTo(frame.right, 104)
      ..lineTo(frame.left, 104)
      ..close();
    Pen.shape(c, top, fill: _grass, solid: true, hatch: Ink.leaf, hatchAngle: -0.8, hatchGap: 4.5, seed: 12);
    Pen.stroke(
      c,
      Path()
        ..moveTo(frame.left + 4, 108)
        ..lineTo(frame.right - 4, 108),
      ink: Ink.sand,
      width: 3,
      seed: 13,
    );

    // Bottom meadow with a wavy top edge.
    final bottom = Path()..moveTo(frame.left, 504);
    for (var x = frame.left; x < frame.right; x += 58) {
      bottom.quadraticBezierTo(x + 29, 494 + (x % 3) * 3, min(x + 58, frame.right), 502);
    }
    bottom
      ..lineTo(frame.right, frame.bottom - 14)
      ..quadraticBezierTo(frame.right, frame.bottom, frame.right - 14, frame.bottom)
      ..lineTo(frame.left + 14, frame.bottom)
      ..quadraticBezierTo(frame.left, frame.bottom, frame.left, frame.bottom - 14)
      ..close();
    Pen.shape(c, bottom, fill: _grass, solid: true, hatch: Ink.leaf, hatchAngle: -0.8, hatchGap: 4.5, seed: 14);

    // Top meadow decorations.
    _at(c, const Offset(30, 100), (c) => _cattails(c, seed: 3));
    _at(c, const Offset(330, 104), (c) => _cattails(c, mirror: true, seed: 7));
    for (final (o, w) in [(const Offset(52, 98), 30.0), (const Offset(318, 100), 24.0)]) {
      _at(c, o, (c) => Nature.rock(c, w, seed: w.round()));
    }
    for (final (o, h) in [
      (const Offset(82, 34), 18.0),
      (const Offset(140, 78), 22.0),
      (const Offset(200, 36), 14.0),
      (const Offset(250, 80), 20.0),
      (const Offset(300, 40), 14.0),
      (const Offset(108, 96), 14.0),
    ]) {
      _at(c, o, (c) => _tuft(c, h, seed: o.dx.round()));
    }
    for (final o in [const Offset(100, 52), const Offset(298, 66)]) {
      _at(c, o, (c) => _daisy(c, seed: o.dx.round()));
    }

    // The pond itself.
    final pond = _pondPath();
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
    final waves = Pen.inkPaint(Ink.white.withValues(alpha: 0.75), 1.8);
    final r = Random(9);
    c.save();
    c.clipPath(pond);
    for (var i = 0; i < 22; i++) {
      final o = Offset(center.dx + (r.nextDouble() * 2 - 1) * rx, center.dy + (r.nextDouble() * 2 - 1) * ry);
      final w = 14 + r.nextDouble() * 14;
      c.drawPath(
        Path()
          ..moveTo(o.dx - w / 2, o.dy)
          ..quadraticBezierTo(o.dx - w / 4, o.dy - 3, o.dx, o.dy)
          ..quadraticBezierTo(o.dx + w / 4, o.dy + 3, o.dx + w / 2, o.dy),
        waves,
      );
    }
    c.restore();
    for (final (o, rad, fl, rot) in [
      (const Offset(68, 170), 30.0, true, 0.0),
      (const Offset(282, 186), 25.0, false, 0.0),
      (const Offset(98, 444), 30.0, false, 0.0),
      (const Offset(282, 456), 27.0, true, 0.0),
    ]) {
      _at(c, o, (c) {
        c.rotate(rot);
        Nature.lilyPad(c, rad, seed: o.dx.round(), flower: fl);
      });
    }

    // Bottom meadow decorations.
    for (final (o, w) in [
      (const Offset(40, 548), 38.0),
      (const Offset(86, 566), 28.0),
      (const Offset(170, 590), 36.0),
    ]) {
      _at(c, o, (c) => Nature.rock(c, w, seed: w.round()));
    }
    for (final (o, h) in [
      (const Offset(36, 526), 14.0),
      (const Offset(140, 538), 16.0),
      (const Offset(238, 530), 18.0),
      (const Offset(52, 604), 14.0),
      (const Offset(220, 606), 16.0),
      (const Offset(340, 520), 16.0),
      (const Offset(118, 600), 12.0),
    ]) {
      _at(c, o, (c) => _tuft(c, h, seed: o.dx.round() + 5));
    }
    for (final o in [const Offset(28, 590), const Offset(240, 580)]) {
      _at(c, o, (c) => _daisy(c, seed: o.dx.round()));
    }
  }

  @override
  void paint(Canvas c) {
    final ripple = Pen.inkPaint(Ink.white.withValues(alpha: 0.85), 1.6);
    for (final f in fish) {
      if (f.state != _S.swim) continue;
      // Little water rings around each swimming fish.
      final k = (time * 0.6 + f.phase) % 1;
      final s = _size * (1 + k * 0.15);
      final rect = Rect.fromCenter(center: f.pos + Offset(0, 14 * _size), width: 78 * s, height: 22 * s);
      c.drawArc(rect, 0.15, pi - 0.3, false, Pen.inkPaint(Ink.white.withValues(alpha: 0.85 - k * 0.4), 1.6));
      final back = f.vx < 0 ? 1.0 : -1.0;
      for (final d in [0.0, 6.0]) {
        c.drawArc(
          Rect.fromCenter(center: f.pos + Offset(back * (42 + d) * _size, 0), width: 14, height: 30 * _size),
          back > 0 ? -0.9 : pi - 0.9,
          1.8,
          false,
          ripple,
        );
      }
    }
    for (final f in fish) {
      if (f.state != _S.swim) continue;
      _fish(c, f.color, f.pos, scale: _size, left: f.vx < 0, rotation: wave(time, 8, f.phase) * 0.06);
    }
    final (sx, sy) = squash(_basketBounce);
    sprite(c, 'pond-basket', basketAt, (c) => Props.basket(c, w: 90, h: 56), sx: sx, sy: sy);
  }

  @override
  String get progressText => tr.progFish(caught);

  @override
  void paintProgressIcon(Canvas c, Size s) => _fish(c, 3, s.center(Offset.zero), scale: s.width / 72);
}

final pondFishGame = GameDefinition(
  gameId: 'pond_fish_catch',
  name: (l) => l.gamePondFishName,
  objective: (l) => l.gamePondFishGoal,
  instructions: (l) => l.gamePondFishHowTo,
  interactionType: Interaction.tap,
  accent: Ink.sky,
  assetManifest: const ['fish', 'basket', 'lily-pad', 'reed', 'rock'],
  create: PondFishScene.new,
  thumbnail: (c, s) {
    // The pond fills the whole card, like the game itself.
    waterBody(c, Path()..addRect((Offset.zero & s).inflate(4)), color: _water, seed: 3);
    Thumb.put(c, s, 0.08, 1.0, (c) => Nature.grass(c, 40, seed: 2));
    Thumb.put(c, s, 0.22, 0.26, (c) => Nature.lilyPad(c, 18, flower: true));
    for (final (fx, fy, r) in [(0.58, 0.2, 4.5), (0.64, 0.1, 3.0), (0.53, 0.32, 2.5)]) {
      Thumb.put(
        c,
        s,
        fx,
        fy,
        (c) => Pen.shape(c, Pen.circle(Offset.zero, r), fill: Ink.white, solid: true, width: 1.4),
      );
    }
    _fishThumb(c, s, 0.42, 0.5, 0);
    _fishThumb(c, s, 0.66, 0.68, 2);
    Thumb.put(c, s, 0.86, 0.8, (c) => Props.basket(c, w: 40, h: 26));
  },
);

void _fishThumb(Canvas c, Size s, double fx, double fy, int color) =>
    Thumb.put(c, s, fx, fy, (c) => Critters.fish(c, _fishColors[color], seed: color + 1), scale: 0.8);
