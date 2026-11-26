import 'dart:math' as math;

import 'common.dart';

enum _R { flying, landing, landed, lost }

class _Rocket {
  _Rocket(this.id, this.color, this.dir, this.aim);
  final String id;
  final int color;
  final Offset dir;
  final double aim;
  Offset pos = RocketLaunchScene.pad;
  _R state = _R.flying;
  double t = 0;

  /// Where it sits on the planet, as an angle from the planet's centre.
  double spot = 0;
  Offset landFrom = Offset.zero;
}

class RocketLaunchScene extends GameScene {
  RocketLaunchScene(this.cfg);
  final ScoreConfig cfg;

  static const pad = Offset(180, 512);
  static const planetY = 124.0;
  static const maxAngle = 0.62;
  static const _colors = [Ink.coral, Ink.blue, Ink.mint, Ink.purple];

  final rockets = <_Rocket>[];
  double aim = 0, _sweepT = 0;

  /// 0..1 while the next rocket rises onto the pad; 1 = ready to launch.
  double _reload = 1;
  int _next = 0, landed = 0;
  double _planetBounce = 1;

  double get _r => ctx.simple ? 56 : 46;
  Offset get planet => Offset(180 + math.sin(time * 0.55 * ctx.speed) * 100, planetY);

  @override
  void setup() {}

  @override
  void tick(double dt) {
    _planetBounce = (_planetBounce + dt * 2.5).clamp(0, 1);
    _reload = (_reload + dt / 0.45).clamp(0, 1);
    _sweepT += dt * ctx.speed;
    aim = math.sin(_sweepT * 1.5) * maxAngle; // bounded, smooth sweep
    final p = planet;
    for (final r in rockets) {
      r.t += dt;
      switch (r.state) {
        case _R.flying:
          r.pos += r.dir * 430 * ctx.speed * dt;
          if ((r.pos - p).distance < _r + 16) {
            _touchDown(r, p);
          } else if (r.pos.dy < -60 || r.pos.dx < -60 || r.pos.dx > 420) {
            r.state = _R.lost;
          }
        case _R.landing:
          if (r.t >= 0.35) r.state = _R.landed;
        case _R.landed || _R.lost:
          break;
      }
    }
    // Only a handful of rockets stay parked on the planet.
    final parked = rockets.where((r) => r.state == _R.landed).toList();
    if (parked.length > 5) rockets.remove(parked.first);
    rockets.removeWhere((r) => r.state == _R.lost);
  }

  void _touchDown(_Rocket r, Offset p) {
    final off = r.pos - p;
    // Lateral distance of the flight line from the planet's centre.
    final miss = (r.dir.dx * (p.dy - pad.dy) - r.dir.dy * (p.dx - pad.dx)).abs();
    final perfect = miss < _r * 0.4;
    r
      ..state = _R.landing
      ..t = 0
      ..landFrom = r.pos
      ..spot = math.atan2(off.dy, off.dx);
    landed++;
    _planetBounce = 0;
    final at = p + Offset(math.cos(r.spot), math.sin(r.spot)) * (_r + 18);
    score(perfect ? cfg.bonus : cfg.base, r.id, at + const Offset(0, -10));
    if (perfect) {
      fx.floatText(at + const Offset(0, 26), tr.gamePerfect, color: Ink.gold);
      ctx.onSfx(Sfx.bonus);
    } else {
      ctx.onSfx(Sfx.cheer);
    }
    fx.confetti(at, colors: [_colors[r.color], Ink.yellow, Ink.white]);
  }

  @override
  void onTap(Offset p) {
    if (_reload < 1 || ended) return;
    // The rocket flies along the exact angle the arrow showed at the tap.
    final locked = aim;
    final dir = Offset(math.sin(locked), -math.cos(locked));
    rockets.add(_Rocket(newId('rocket'), _next, dir, locked));
    _next = (_next + 1) % _colors.length;
    _reload = 0;
    ctx.onSfx(Sfx.whoosh);
    fx.burst(pad + const Offset(0, 30), colors: const [Ink.orange, Ink.yellow, Ink.white], count: 10);
  }

  void _drawRocket(Canvas c, int color, Offset at, double rotation, {double flame = 0, double scale = 1}) => sprite(
    c,
    'rocket-$color-${(flame * 4).round()}',
    at,
    (c) => Props.rocket(c, color: _colors[color], flame: (flame * 4).round() / 4, seed: color + 1),
    scale: scale * (ctx.simple ? 1.15 : 1),
    rotation: rotation,
  );

  @override
  void paintBackground(Canvas c) {
    c.drawRect(GameScene.worldRect, Pen.fillPaint(Ink.night));
    Paper.gridOverlay(c, GameScene.worldRect, alpha: 0.08);
    final r = math.Random(7);
    for (var i = 0; i < 40; i++) {
      final o = Offset(r.nextDouble() * 360, r.nextDouble() * 520);
      if (i % 5 == 0) {
        Pen.twinkle(c, o, 4 + r.nextDouble() * 3, Ink.yellow.withValues(alpha: 0.9));
      } else {
        Pen.dot(c, o, 1 + r.nextDouble() * 1.4, Ink.white.withValues(alpha: 0.75));
      }
    }
    c.save();
    c.translate(306, 300);
    Nature.moon(c, 16);
    c.restore();
    c.save();
    c.translate(48, 372);
    Nature.planet(c, 16, color: Ink.orange, seed: 4);
    c.restore();

    // Moon-rock ground with a launch pad.
    final ground = Path()..moveTo(-4, 556);
    for (var x = -4.0; x < 364; x += 60) {
      ground.quadraticBezierTo(x + 30, 544 + (x % 120 == 0 ? -6 : 4), x + 60, 552);
    }
    ground
      ..lineTo(364, 624)
      ..lineTo(-4, 624)
      ..close();
    Pen.shape(
      c,
      ground,
      fill: const Color(0xFFB8BCC8),
      solid: true,
      hatch: Ink.navySoft.withValues(alpha: 0.4),
      seed: 9,
    );
    for (final (o, cr) in [
      (const Offset(52, 584), 14.0),
      (const Offset(300, 590), 18.0),
      (const Offset(236, 606), 9.0),
    ]) {
      Pen.shape(
        c,
        Pen.oval(o, cr, cr * 0.45),
        fill: const Color(0xFF9EA3B2),
        solid: true,
        width: 1.6,
        seed: cr.round(),
      );
    }
    Pen.shape(
      c,
      Pen.rrect(Rect.fromCenter(center: pad + const Offset(0, 34), width: 96, height: 16), 6),
      fill: Ink.yellow,
      solid: true,
      hatch: Ink.gold,
      seed: 3,
    );
    for (final dx in [-34.0, 34.0]) {
      Pen.line(c, pad + Offset(dx, 42), pad + Offset(dx * 1.2, 56), width: 3);
    }
  }

  @override
  void paint(Canvas c) {
    final p = planet;
    // Parked rockets sit on the planet with their noses pointing outwards.
    for (final r in rockets) {
      if (r.state != _R.landed && r.state != _R.landing) continue;
      final rest = p + Offset(math.cos(r.spot), math.sin(r.spot)) * (_r + 22);
      final restRot = r.spot + math.pi / 2;
      if (r.state == _R.landing) {
        final k = Flight.ease((r.t / 0.35).clamp(0, 1));
        // Flip round and settle feet-first onto the surface.
        final turn = math.atan2(math.sin(restRot - r.aim), math.cos(restRot - r.aim));
        final rot = r.aim + turn * k;
        _drawRocket(c, r.color, Offset.lerp(r.landFrom, rest, k)!, rot, flame: 1 - k, scale: 0.85);
      } else {
        _drawRocket(c, r.color, rest, restRot, scale: 0.85);
      }
    }
    final (sx, sy) = squash(_planetBounce, 0.1);
    sprite(c, 'rocket-planet-${_r.round()}', p, (c) => Nature.planet(c, _r, seed: 2), sx: sx, sy: sy);

    for (final r in rockets) {
      if (r.state == _R.flying) _drawRocket(c, r.color, r.pos, r.aim, flame: 0.75 + math.sin(r.t * 30) * 0.25);
    }

    // The waiting rocket rises up onto the pad, then the arrow appears.
    final rise = Flight.ease(_reload);
    _drawRocket(c, _next, pad + Offset(0, (1 - rise) * 40), _reload >= 1 ? aim : 0);
    if (_reload >= 1 && !ended) {
      final dir = Offset(math.sin(aim), -math.cos(aim));
      final dash = Pen.inkPaint(Ink.coral, 4);
      for (var d = 46.0; d < 150; d += 18) {
        c.drawLine(pad + dir * d, pad + dir * (d + 10), dash);
      }
      final tip = pad + dir * 158;
      final n = Offset(-dir.dy, dir.dx);
      c.drawPath(Pen.poly([tip + dir * 10, tip + n * 9, tip - n * 9]), Pen.fillPaint(Ink.coral));
    }
  }

  @override
  String get progressText => tr.progLanded(landed);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'rocket-icon', s.center(Offset.zero), (c) => Props.rocket(c), scale: s.width / 64, rotation: 0.5);
}

final rocketLaunchGame = GameDefinition(
  gameId: 'rocket_launch',
  name: (l) => l.gameRocketLaunchName,
  objective: (l) => l.gameRocketLaunchGoal,
  instructions: (l) => l.gameRocketLaunchHowTo,
  interactionType: Interaction.tap,
  accent: Ink.purple,
  scoreConfig: const ScoreConfig(base: 5, bonus: 8),
  assetManifest: const ['rocket', 'planet', 'moon', 'launch-pad'],
  create: RocketLaunchScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, Ink.night);
    for (final (x, y) in [(0.1, 0.2), (0.4, 0.12), (0.55, 0.5), (0.9, 0.7), (0.2, 0.62)]) {
      Pen.dot(c, Offset(s.width * x, s.height * y), 1.8, Ink.white);
    }
    Thumb.put(c, s, 0.74, 0.3, (c) => Nature.planet(c, 24, seed: 2));
    Thumb.put(c, s, 0.34, 0.6, (c) => Props.rocket(c, flame: 1), rotation: 0.55, scale: 0.9);
  },
);
