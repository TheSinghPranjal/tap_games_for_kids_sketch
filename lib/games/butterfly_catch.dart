import 'common.dart';

const _wingColors = [Ink.purple, Ink.coral, Ink.blue, Ink.yellow, Ink.pink, Ink.orange];

class _Fly {
  _Fly(this.id, this.anchor, this.drift, this.color, this.phase, this.life);
  final String id;
  Offset anchor;
  Offset drift;
  final int color;
  final double phase, life;
  double t = 0;
  bool taken = false;
  Offset pos = Offset.zero;
}

class ButterflyScene extends GameScene {
  ButterflyScene(this.cfg);
  final ScoreConfig cfg;

  static const play = Rect.fromLTRB(50, 120, 310, 420);
  static const garden = Offset(280, 545);
  static const _gardenSpots = [
    Offset(240, 520),
    Offset(270, 505),
    Offset(300, 518),
    Offset(330, 505),
    Offset(255, 560),
    Offset(315, 560),
  ];

  final flies = <_Fly>[];
  final resting = <int>[]; // colors of butterflies in the garden
  int caught = 0;
  double _spawnIn = 0;

  void _spawn() {
    final a = freeSpot(play, flies.map((f) => f.anchor), 90);
    flies.add(
      _Fly(
        newId('bfly'),
        a,
        Offset(rand(-14, 14), rand(-10, 10)) * ctx.speed,
        rng.nextInt(_wingColors.length),
        rand(0, 6),
        rand(9, 12) * ctx.patience,
      ),
    );
  }

  @override
  void setup() {
    for (var i = 0; i < 3; i++) {
      _spawn();
    }
  }

  @override
  void tick(double dt) {
    for (final f in flies) {
      f.t += dt;
      if (f.t > f.life) {
        f.anchor += Offset(f.drift.dx.sign * 90, -40) * dt; // flutters off gently
      } else {
        f.anchor += f.drift * dt;
        if (f.anchor.dx < play.left || f.anchor.dx > play.right) f.drift = Offset(-f.drift.dx, f.drift.dy);
        if (f.anchor.dy < play.top || f.anchor.dy > play.bottom) f.drift = Offset(f.drift.dx, -f.drift.dy);
      }
      // Smooth curved flutter around a slowly drifting anchor.
      f.pos = f.anchor + Offset(wave(f.t, 1.3 * ctx.speed, f.phase) * 38, wave(f.t, 2.1 * ctx.speed, f.phase) * 22);
    }
    flies.removeWhere((f) => f.taken || f.pos.dx < -40 || f.pos.dx > 400 || f.pos.dy < -40);
    if (!ended && flies.length < (ctx.simple ? 3 : 4)) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(0.8, 1.4);
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final f in flies) {
      if (f.taken || (f.pos - p).distance > 34 + ctx.hitPad) continue;
      f.taken = true;
      caught++;
      score(cfg.base, f.id, f.pos);
      ctx.onSfx(Sfx.collect);
      fx.ring(f.pos, radius: 34, color: Ink.yellow);
      fx.burst(f.pos, colors: [_wingColors[f.color], Ink.yellow]);
      final color = f.color;
      final spot = _gardenSpots[resting.length % _gardenSpots.length];
      fly(
        f.pos,
        spot,
        1.0,
        (c, at, t) {
          c.drawCircle(at, 22 * (1 - t), Paint()..color = Ink.yellow.withValues(alpha: 0.35 * (1 - t)));
          _draw(c, at, color, 0.5 + wave(t * 40).abs() * 0.5, 1.1 - t * 0.4);
        },
        arc: -70,
        onArrive: () {
          if (resting.length >= _gardenSpots.length) resting.removeAt(0);
          resting.add(color);
        },
      );
      return;
    }
  }

  void _draw(Canvas c, Offset at, int color, double flap, double scale) {
    c.save();
    c.translate(at.dx, at.dy);
    c.scale(scale);
    for (final s in [-1.0, 1.0]) {
      c.save();
      c.scale(s * flap, 1);
      SpriteCache.draw(c, 'bwing-$color', (c) => Critters.butterflyWing(c, _wingColors[color], seed: color + 1));
      c.restore();
    }
    SpriteCache.draw(c, 'bbody', Critters.butterflyBody);
    c.restore();
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    c.save();
    c.translate(70, 60);
    Nature.sun(c, 22);
    c.restore();
    c.save();
    c.translate(260, 70);
    Nature.cloud(c, 100);
    c.restore();
    groundBand(c, const Rect.fromLTRB(0, 440, 360, 620), Ink.mint, seed: 3);
    // Little fence.
    for (var x = 10.0; x < 210; x += 28) {
      Pen.shape(
        c,
        Pen.poly([Offset(x, 480), Offset(x + 7, 470), Offset(x + 14, 480), Offset(x + 14, 520), Offset(x, 520)]),
        fill: Ink.white,
        solid: true,
        hatch: Ink.brown.withValues(alpha: 0.4),
        seed: x.round(),
        width: 1.8,
      );
    }
    Pen.line(c, const Offset(0, 492), const Offset(214, 492), width: 2.4);
    for (final (o, color) in [
      (const Offset(40, 580), Ink.pink),
      (const Offset(110, 590), Ink.yellow),
      (const Offset(170, 575), Ink.purple),
    ]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.flower(c, color, r: 14, face: false, seed: o.dx.round());
      c.restore();
    }
    // Butterfly garden: flower bed with an arch.
    Pen.shape(c, Pen.oval(garden + const Offset(0, 20), 82, 34), fill: Ink.brown, seed: 5);
    Pen.stroke(
      c,
      Path()..addArc(Rect.fromCenter(center: garden + const Offset(0, -10), width: 150, height: 150), 3.3, 2.8),
      ink: Ink.leaf,
      width: 5,
      seed: 6,
    );
    for (var i = 0; i < 5; i++) {
      c.save();
      c.translate(garden.dx - 60 + i * 30.0, garden.dy + 22 + (i % 2) * 8);
      Nature.flower(c, Ink.bright[i], r: 11, face: false, seed: i);
      c.restore();
    }
  }

  @override
  void paint(Canvas c) {
    for (final (i, color) in resting.indexed) {
      _draw(c, _gardenSpots[i], color, fx.reduced ? 0.8 : 0.55 + wave(time, 2, i.toDouble()).abs() * 0.45, 0.75);
    }
    for (final f in flies) {
      _draw(c, f.pos, f.color, fx.reduced ? 0.8 : 0.3 + wave(f.t, 12, f.phase).abs() * 0.7, ctx.simple ? 1.4 : 1.2);
    }
    // Collection row.
    final n = caught.clamp(0, 8);
    for (var i = 0; i < n; i++) {
      _draw(c, Offset(28 + i * 26.0, 24), resting.isEmpty ? 0 : resting[i % resting.length], 0.9, 0.45);
    }
  }

  @override
  String get progressText => tr.progButterflies(caught);

  @override
  void paintProgressIcon(Canvas c, Size s) => _draw(c, s.center(Offset.zero), 0, 1, s.width / 56);
}

final butterflyGame = GameDefinition(
  gameId: 'butterfly_catch',
  name: (l) => l.gameButterflyName,
  objective: (l) => l.gameButterflyGoal,
  instructions: (l) => l.gameButterflyHowTo,
  interactionType: Interaction.tap,
  accent: Ink.purple,
  assetManifest: const ['butterfly', 'fence', 'flower', 'garden'],
  create: ButterflyScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.5, 1.05, (c) => groundBand(c, const Rect.fromLTRB(-200, -30, 200, 10), Ink.mint));
    Thumb.put(c, s, 0.35, 0.4, (c) => Critters.butterfly(c, Ink.purple, 1));
    Thumb.put(c, s, 0.7, 0.55, (c) => Critters.butterfly(c, Ink.coral, 0.7, seed: 2), scale: 0.8);
    Thumb.put(c, s, 0.15, 0.85, (c) => Nature.flower(c, Ink.yellow, r: 12, face: false));
  },
);
