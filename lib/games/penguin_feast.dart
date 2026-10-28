import 'common.dart';

const _colors = [Ink.orange, Ink.coral, Ink.yellow, Ink.blue];

class _Jumper {
  _Jumper(this.id, this.start, this.vx, this.vy, this.g, this.color);
  final String id;
  final Offset start;
  final double vx, vy, g;
  final int color;
  double t = 0;
  bool taken = false;

  Offset get pos => start + Offset(vx * t, -vy * t + 0.5 * g * t * t);
  double get angle => -(vy - g * t) / 220 * (vx >= 0 ? 1 : -1);
}

class PenguinFeastScene extends GameScene {
  PenguinFeastScene(this.cfg);
  final ScoreConfig cfg;

  static const waterY = 330.0;
  static const penguinAt = Offset(84, 500);

  final fish = <_Jumper>[];
  final flakes = <Offset>[];
  int eaten = 0;
  double _spawnIn = 0.4, _chomp = 0, _hop = 1;

  @override
  void setup() {
    for (var i = 0; i < 22; i++) {
      flakes.add(Offset(rand(0, 360), rand(0, 620)));
    }
  }

  void _spawn() {
    final x = rand(150, 320);
    final apexY = rand(120, 230); // never under the HUD
    final start = Offset(x, waterY + 30);
    final h = start.dy - apexY;
    final dur = rand(2.2, 2.7) / ctx.speed * (ctx.simple ? 1.1 : 1);
    fish.add(
      _Jumper(newId('jump'), start, rand(-26, 26), 4 * h / dur, 8 * h / (dur * dur), rng.nextInt(_colors.length)),
    );
    fx.splash(Offset(x, waterY), color: Ink.white);
  }

  @override
  void tick(double dt) {
    _chomp = (_chomp - dt).clamp(0, 1);
    _hop = (_hop + dt * 2.4).clamp(0, 1);
    for (final f in fish) {
      f.t += dt;
      if (!f.taken && f.pos.dy > waterY + 40 && f.t > 0.5) f.taken = true; // dived back in
    }
    fish.removeWhere((f) => f.taken);
    for (var i = 0; i < flakes.length; i++) {
      var p = flakes[i] + Offset(wave(time, 1, i.toDouble()) * 8 * dt, 22 * dt);
      if (p.dy > 620) p = Offset(rand(0, 360), -5);
      flakes[i] = p;
    }
    if (!ended) {
      _spawnIn -= dt;
      if (_spawnIn <= 0 && fish.length < (ctx.simple ? 2 : 3)) {
        _spawn();
        _spawnIn = rand(0.9, 1.5) / ctx.speed;
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final f in fish) {
      final pos = f.pos;
      if (f.taken || pos.dy > waterY + 6 || (pos - p).distance > 34 + ctx.hitPad) continue;
      f.taken = true;
      eaten++;
      score(cfg.base, f.id, pos);
      ctx.onSfx(Sfx.whoosh);
      final color = f.color;
      fly(
        pos,
        penguinAt + const Offset(0, -8),
        0.7,
        (c, at, t) {
          sprite(
            c,
            'pfish-$color',
            at,
            (c) => Critters.fish(c, _colors[color], seed: color + 1),
            scale: 0.9 - t * 0.5,
            sx: -1,
            rotation: t * 2,
          );
        },
        arc: -60,
        onArrive: () {
          _chomp = 0.6;
          _hop = 0;
          ctx.onSfx(Sfx.collect);
          fx.hearts(penguinAt + const Offset(0, -50));
        },
      );
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect, base: const Color(0xFFF3F8FD));
    for (final (x, w, h) in [(80.0, 220.0, 50.0), (260.0, 260.0, 64.0)]) {
      c.save();
      c.translate(x, waterY);
      Nature.hill(c, w, h, seed: x.round());
      c.restore();
    }
    c.save();
    c.translate(290, 70);
    Nature.sun(c, 22);
    c.restore();
    final sea = Path()..addRect(const Rect.fromLTRB(-4, waterY, 364, 624));
    waterBody(c, sea, color: Ink.tint(Ink.blue, 0.7), seed: 8);
    for (final (o, w) in [
      (const Offset(250, 430), 70.0),
      (const Offset(170, 560), 60.0),
      (const Offset(310, 600), 50.0),
    ]) {
      c.save();
      c.translate(o.dx, o.dy);
      Pen.shape(
        c,
        Pen.poly([
          Offset(-w / 2, 0),
          Offset(-w * 0.35, -10),
          Offset(w * 0.4, -12),
          Offset(w / 2, 0),
          Offset(w * 0.2, 6),
        ]),
        fill: Ink.white,
        solid: true,
        hatch: Ink.sky,
        seed: w.round(),
        width: 2,
      );
      c.restore();
    }
    // Ice platform for the penguin.
    Pen.shape(
      c,
      Pen.poly(const [
        Offset(14, 540),
        Offset(30, 520),
        Offset(150, 518),
        Offset(166, 540),
        Offset(140, 560),
        Offset(30, 560),
      ]),
      fill: Ink.white,
      solid: true,
      hatch: Ink.sky,
      seed: 3,
    );
  }

  @override
  void paint(Canvas c) {
    final snow = Paint()..color = Ink.sky;
    for (final f in flakes) {
      c.drawCircle(f, 2, snow);
    }
    for (final f in fish) {
      final pos = f.pos;
      if (pos.dy > waterY + 12) continue;
      sprite(
        c,
        'pfish-${f.color}',
        pos,
        (c) => Critters.fish(c, _colors[f.color], seed: f.color + 1),
        scale: ctx.simple ? 1.15 : 1,
        sx: f.vx >= 0 ? 1 : -1,
        rotation: f.angle.clamp(-1.2, 1.2),
      );
    }
    final (sx, sy) = squash(_hop, 0.15);
    final y = penguinAt.dy - bump(_hop) * 26;
    final mood = _chomp > 0 ? (_chomp > 0.3 ? Mood.chomp : Mood.happy) : Mood.wow;
    sprite(
      c,
      'penguin-${mood.name}',
      Offset(penguinAt.dx, y),
      (c) => Critters.penguin(c, mood: mood),
      sx: sx,
      sy: sy,
    );
  }

  @override
  String get progressText => '$eaten yummy fish';

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'penguin-happy', s.center(Offset.zero), (c) => Critters.penguin(c), scale: s.width / 78);
}

final penguinFeastGame = GameDefinition(
  gameId: 'penguin_fish_feast',
  name: 'Penguin Fish Feast',
  objective: 'Feed the hungry baby penguin!',
  instructions: 'Tap a jumping fish to send it to the penguin.',
  interactionType: Interaction.tap,
  accent: Ink.blue,
  assetManifest: const ['penguin', 'fish', 'ice-floe', 'hill', 'snow'],
  create: PenguinFeastScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(
      c,
      s,
      0.5,
      0.75,
      (c) => waterBody(c, Path()..addRect(const Rect.fromLTRB(-200, -10, 200, 60)), color: Ink.tint(Ink.blue, 0.7)),
    );
    Thumb.put(c, s, 0.25, 0.58, (c) => Critters.penguin(c), scale: 0.95);
    Thumb.put(c, s, 0.68, 0.32, (c) => Critters.fish(c, Ink.orange), rotation: -0.5);
  },
);
