import 'common.dart';

const _fishColors = [Ink.orange, Ink.coral, Ink.yellow, Ink.purple, Ink.blue];

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
}

class PondFishScene extends GameScene {
  PondFishScene(this.cfg);
  final ScoreConfig cfg;

  static const center = Offset(180, 300);
  static const rx = 160.0, ry = 205.0;
  static const basketAt = Offset(292, 566);

  final fish = <_Fish>[];
  int caught = 0;
  double _spawnIn = 0;
  double _basketBounce = 1;

  int get _target => ctx.simple ? 3 : 4;
  double get _size => ctx.simple ? 1.3 : 1.1;

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
    var p = freeSpot(area, fish.map((f) => f.pos), 80);
    if (!_inPond(p)) p = center + Offset(rand(-60, 60), rand(-120, 120));
    final speed = rand(38, 62) * ctx.speed;
    fish.add(_Fish(newId('fish'), p, rng.nextBool() ? speed : -speed, rng.nextInt(_fishColors.length), rand(0, 6)));
  }

  @override
  void tick(double dt) {
    _basketBounce = (_basketBounce + dt * 3).clamp(0, 1);
    for (final f in fish) {
      f.t += dt;
      if (f.state != _S.swim) continue;
      final next = Offset(f.pos.dx + f.vx * dt, f.pos.dy + wave(time, 1.6, f.phase) * 12 * dt);
      if (!_inPond(next)) {
        f.vx = -f.vx;
      } else {
        f.pos = next;
      }
    }
    // Keep targets apart: a fish heading into another one turns around.
    for (final a in fish) {
      for (final b in fish) {
        if (identical(a, b) || a.state != _S.swim || b.state != _S.swim) continue;
        final d = b.pos - a.pos;
        if (d.distance < 62 && d.dx.sign == a.vx.sign && d.dx.abs() > 1) a.vx = -a.vx;
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
    var bestD = 30 * _size + ctx.hitPad;
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

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    groundBand(c, const Rect.fromLTRB(0, 0, 360, 110), Ink.mint, seed: 2);
    groundBand(c, const Rect.fromLTRB(0, 500, 360, 620), Ink.mint, seed: 3);
    waterBody(c, Pen.oval(center, rx, ry), seed: 4);
    for (final (o, r, fl) in [
      (const Offset(70, 170), 26.0, true),
      (const Offset(290, 240), 22.0, false),
      (const Offset(95, 420), 24.0, false),
      (const Offset(270, 430), 20.0, true),
    ]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.lilyPad(c, r, seed: o.dx.round(), flower: fl);
      c.restore();
    }
    for (final x in [24.0, 40.0, 330.0, 344.0]) {
      c.save();
      c.translate(x, 120 + (x % 3) * 6);
      Nature.reed(c, 60 + x % 20, seed: x.round());
      c.restore();
    }
    for (final (o, w) in [
      (const Offset(40, 540), 34.0),
      (const Offset(80, 560), 24.0),
      (const Offset(190, 585), 28.0),
    ]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.rock(c, w, seed: w.round());
      c.restore();
    }
    for (final x in [130.0, 230.0]) {
      c.save();
      c.translate(x, 70);
      Nature.grass(c, 50, seed: x.round());
      c.restore();
    }
    Pen.plus(c, const Offset(320, 40), 6, Ink.gold);
    Pen.plus(c, const Offset(36, 60), 5, Ink.coral);
  }

  @override
  void paint(Canvas c) {
    for (var i = 0; i < 3; i++) {
      final k = ((time * 0.4 + i / 3) % 1);
      final o = Offset(110 + i * 70.0, 220 + i * 90.0);
      c.drawOval(
        Rect.fromCenter(center: o, width: 30 + k * 50, height: 10 + k * 16),
        Pen.inkPaint(Ink.white.withValues(alpha: (1 - k) * 0.8), 1.6),
      );
    }
    for (final f in fish) {
      if (f.state != _S.swim) continue;
      _fish(c, f.color, f.pos, scale: _size, left: f.vx < 0, rotation: wave(time, 8, f.phase) * 0.06);
    }
    final (sx, sy) = squash(_basketBounce);
    sprite(c, 'pond-basket', basketAt, (c) => Props.basket(c), sx: sx, sy: sy);
  }

  @override
  String get progressText => '$caught fish';

  @override
  void paintProgressIcon(Canvas c, Size s) => _fish(c, 0, s.center(Offset.zero), scale: s.width / 64);
}

final pondFishGame = GameDefinition(
  gameId: 'pond_fish_catch',
  name: 'Pond Fish Catch',
  objective: 'Tap the fish to catch them!',
  instructions: 'Tap a swimming fish to pop it into the basket.',
  interactionType: Interaction.tap,
  accent: Ink.sky,
  assetManifest: const ['fish', 'basket', 'lily-pad', 'reed', 'rock'],
  create: PondFishScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.5, 0.55, (c) => waterBody(c, Pen.oval(Offset.zero, 70, 42), seed: 3));
    Thumb.put(c, s, 0.22, 0.3, (c) => Nature.lilyPad(c, 16, flower: true));
    _fishThumb(c, s, 0.42, 0.5, 0);
    _fishThumb(c, s, 0.66, 0.68, 1);
    Thumb.put(c, s, 0.86, 0.8, (c) => Props.basket(c, w: 40, h: 26));
  },
);

void _fishThumb(Canvas c, Size s, double fx, double fy, int color) =>
    Thumb.put(c, s, fx, fy, (c) => Critters.fish(c, _fishColors[color], seed: color + 1), scale: 0.8);
