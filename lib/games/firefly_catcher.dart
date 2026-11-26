import 'common.dart';

class _Fly {
  _Fly(this.id, this.pos, this.heading, this.life, this.phase);
  final String id;
  Offset pos;
  double heading;
  final double life, phase;
  double t = 0;
  bool taken = false;
  bool get leaving => t > life;
}

class FireflyScene extends GameScene {
  FireflyScene(this.cfg);
  final ScoreConfig cfg;

  static const play = Rect.fromLTRB(30, 70, 330, 470);
  static const _flowers = [
    (Offset(40, 540), Ink.pink),
    (Offset(110, 520), Ink.purple),
    (Offset(185, 548), Ink.coral),
    (Offset(255, 522), Ink.yellow),
    (Offset(325, 545), Ink.blue),
  ];

  final flies = <_Fly>[];
  final _glow = List<double>.filled(_flowers.length, 0);
  int caught = 0;
  double _spawnIn = 0;

  double get brightness => (caught / 30).clamp(0.0, 1.0);

  void _spawn() {
    final p = freeSpot(play.deflate(30), flies.map((f) => f.pos), 70);
    flies.add(_Fly(newId('fly'), p, rand(0, 6.28), rand(5.5, 7.5) * ctx.patience, rand(0, 6)));
  }

  @override
  void setup() {
    for (var i = 0; i < 3; i++) {
      _spawn();
    }
  }

  @override
  void tick(double dt) {
    for (var i = 0; i < _glow.length; i++) {
      _glow[i] = (_glow[i] - dt * 0.8).clamp(0, 1);
    }
    for (final f in flies) {
      f.t += dt;
      if (f.leaving) {
        f.pos += Offset(wave(f.t, 3) * 30, -70) * dt;
        continue;
      }
      // Short curved paths: heading drifts smoothly, steered back from edges.
      f.heading += wave(f.t, 1.3, f.phase) * 1.6 * dt;
      final toCenter = play.center - f.pos;
      if (!play.deflate(20).contains(f.pos)) {
        final want = toCenter.direction;
        f.heading += ((want - f.heading + 3.14159) % 6.28318 - 3.14159) * 2.5 * dt;
      }
      f.pos += Offset.fromDirection(f.heading, 34 * ctx.speed * dt);
    }
    flies.removeWhere((f) => f.taken || f.pos.dy < -20); // escapes cost nothing
    if (!ended && flies.where((f) => !f.leaving).length < (ctx.simple ? 3 : 4)) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(0.6, 1.2);
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final f in flies) {
      if (f.taken || (f.pos - p).distance > 30 + ctx.hitPad) continue;
      f.taken = true;
      caught++;
      score(cfg.base, f.id, f.pos);
      ctx.onSfx(Sfx.collect);
      fx.burst(f.pos, colors: const [Ink.yellow, Ink.white, Ink.gold], count: 10);
      for (var i = 0; i < _flowers.length; i++) {
        if ((_flowers[i].$1 - f.pos).distance < 260) _glow[i] = 1;
      }
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    final r = GameScene.worldRect;
    c.drawRect(r, Paint()..color = Ink.nightDeep);
    Paper.gridOverlay(c, r, alpha: 0.07);
    final rnd = Random(9);
    for (var i = 0; i < 30; i++) {
      Pen.dot(
        c,
        Offset(rnd.nextDouble() * 360, rnd.nextDouble() * 300),
        1 + rnd.nextDouble() * 0.8,
        Ink.white.withValues(alpha: 0.5),
      );
    }
    c.save();
    c.translate(70, 70);
    Nature.moon(c, 26);
    c.restore();
    for (final (o, w) in [(const Offset(60, 500), 110.0), (const Offset(300, 490), 120.0)]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.bush(c, w, color: Ink.shade(Ink.leaf, 0.35));
      c.restore();
    }
    groundBand(c, const Rect.fromLTRB(0, 560, 360, 620), Ink.shade(Ink.leaf, 0.4), seed: 5);
  }

  @override
  void paint(Canvas c) {
    if (brightness > 0) {
      c.drawRect(GameScene.worldRect, Paint()..color = Ink.yellow.withValues(alpha: brightness * 0.14));
    }
    for (var i = 0; i < _flowers.length; i++) {
      final (o, color) = _flowers[i];
      final g = (_glow[i] + brightness * 0.4).clamp(0.0, 1.0);
      if (g > 0) c.drawCircle(o + const Offset(0, -48), 34, Paint()..color = Ink.yellow.withValues(alpha: g * 0.3));
      sprite(c, 'night-stem-$i', o, (c) {
        Nature.stem(c, 46, seed: i, leaves: false);
        Nature.grass(c, 34, seed: i, color: Ink.mint);
      });
      sprite(
        c,
        'night-flower-$i',
        o + const Offset(0, -48),
        (c) => Nature.flower(c, color, r: 17, seed: i),
        scale: 1 + g * 0.08,
      );
    }
    for (final f in flies) {
      final pulse = 0.65 + 0.35 * wave(time, 2.6, f.phase); // slow, gentle glow: no flashing
      c.drawCircle(f.pos + const Offset(0, 4), 24, Paint()..color = Ink.yellow.withValues(alpha: 0.16 * pulse));
      c.drawCircle(f.pos + const Offset(0, 4), 13, Paint()..color = Ink.yellow.withValues(alpha: 0.3 * pulse));
      sprite(c, 'firefly', f.pos, Critters.firefly, scale: ctx.simple ? 1.6 : 1.35, rotation: f.heading + 1.57);
    }
  }

  @override
  String get progressText => tr.progFireflies(caught);

  @override
  void paintProgressIcon(Canvas c, Size s) {
    c.drawCircle(s.center(Offset.zero), s.width * 0.45, Paint()..color = Ink.yellow.withValues(alpha: 0.4));
    sprite(c, 'firefly', s.center(Offset.zero), Critters.firefly, scale: s.width / 26);
  }
}

final fireflyGame = GameDefinition(
  gameId: 'firefly_catcher',
  name: (l) => l.gameFireflyName,
  objective: (l) => l.gameFireflyGoal,
  instructions: (l) => l.gameFireflyHowTo,
  interactionType: Interaction.tap,
  accent: Ink.yellow,
  assetManifest: const ['firefly', 'moon', 'flower', 'bush'],
  create: FireflyScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, Ink.nightDeep);
    Thumb.put(c, s, 0.18, 0.25, (c) => Nature.moon(c, 16));
    for (final (x, y) in [(0.45, 0.4), (0.72, 0.28), (0.62, 0.68)]) {
      Thumb.put(c, s, x, y, (c) {
        c.drawCircle(Offset.zero, 18, Paint()..color = Ink.yellow.withValues(alpha: 0.3));
        Critters.firefly(c);
      });
    }
    Thumb.put(c, s, 0.2, 0.95, (c) => Nature.flower(c, Ink.pink, r: 16));
  },
);
