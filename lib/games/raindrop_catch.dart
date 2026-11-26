import 'common.dart';

class _Drop {
  _Drop(this.id, this.pos, this.vy, this.phase);
  final String id;
  Offset pos;
  final double vy, phase;
  bool taken = false;
}

class RaindropScene extends GameScene {
  RaindropScene(this.cfg);
  final ScoreConfig cfg;

  static const jarAt = Offset(220, 520);
  static const jarW = 96.0, jarH = 110.0;
  static const kidAt = Offset(90, 545);
  static const _clouds = [Offset(70, 70), Offset(185, 52), Offset(295, 74)];
  static const dropsToFill = 8;

  final drops = <_Drop>[];
  int collected = 0, fills = 0;
  double level = 0, _spawnIn = 0, _drinking = 0;

  @override
  void setup() {}

  void _spawn() {
    final cloud = pick(_clouds);
    drops.add(_Drop(newId('drop'), cloud + Offset(rand(-36, 36), 30), rand(62, 95) * ctx.speed, rand(0, 6)));
  }

  @override
  void tick(double dt) {
    if (_drinking > 0) {
      _drinking -= dt;
      level = (level - dt / 1.8).clamp(0, 1);
      if (_drinking <= 0) level = 0;
    }
    for (final d in drops) {
      d.pos += Offset(wave(time, 2, d.phase) * 10 * dt, d.vy * dt);
      if (!d.taken && d.pos.dy > 600) {
        d.taken = true; // missed drops just splash on the grass
        fx.splash(Offset(d.pos.dx, 604));
      }
    }
    drops.removeWhere((d) => d.taken);
    if (!ended) {
      _spawnIn -= dt;
      if (_spawnIn <= 0 && drops.length < 5) {
        _spawn();
        _spawnIn = rand(0.55, 1.0) / ctx.speed;
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final d in drops) {
      if (d.taken || (d.pos - p).distance > 28 + ctx.hitPad) continue;
      d.taken = true;
      collected++;
      score(cfg.base, d.id, d.pos);
      ctx.onSfx(Sfx.pop);
      fly(
        d.pos,
        jarAt + const Offset(0, -jarH / 2 - 6),
        0.7,
        (c, at, t) {
          sprite(c, 'raindrop', at, (c) => Props.raindrop(c, 12), scale: 1 - t * 0.4);
        },
        arc: -70,
        onArrive: () {
          fx.splash(jarAt + const Offset(0, -jarH / 2 + 8));
          if (_drinking > 0) return;
          level = (level + 1 / dropsToFill).clamp(0, 1);
          if (level >= 0.999) {
            fills++;
            _drinking = 1.9;
            score(cfg.bonus, 'jar-full-$fills', kidAt + const Offset(0, -70));
            ctx.onSfx(Sfx.cheer);
            fx.hearts(kidAt + const Offset(0, -80));
          }
        },
      );
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect, base: const Color(0xFFEFF6FD));
    c.save();
    c.translate(180, 380);
    Nature.rainbow(c, 170);
    c.restore();
    for (final o in _clouds) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.cloud(c, 120, fill: Ink.white, hatch: Ink.sky, seed: o.dx.round());
      c.restore();
    }
    groundBand(c, const Rect.fromLTRB(0, 580, 360, 620), Ink.mint, seed: 2);
  }

  @override
  void paint(Canvas c) {
    // Slanted rain doodles for atmosphere.
    final rain = Pen.inkPaint(Ink.sky.withValues(alpha: 0.6), 1.4);
    for (var i = 0; i < 14; i++) {
      final x = (i * 29.0 + time * 40) % 380 - 10;
      final y = 110 + ((i * 53.0 + time * 160) % 440);
      c.drawLine(Offset(x, y), Offset(x - 4, y + 12), rain);
    }
    for (final d in drops) {
      sprite(c, 'raindrop', d.pos, (c) => Props.raindrop(c, 12), scale: ctx.simple ? 1.5 : 1.3);
    }
    // Jar: water level clipped inside the glass.
    final jar = Pen.rrect(Rect.fromCenter(center: jarAt, width: jarW, height: jarH), 22);
    c.drawPath(jar, Paint()..color = Ink.white.withValues(alpha: 0.7));
    if (level > 0) {
      c.save();
      c.clipPath(jar);
      final top = jarAt.dy + jarH / 2 - jarH * 0.92 * level;
      final water = Path()
        ..moveTo(jarAt.dx - jarW, top + wave(time, 4) * 3)
        ..quadraticBezierTo(jarAt.dx, top - 6 + wave(time, 3) * 4, jarAt.dx + jarW, top)
        ..lineTo(jarAt.dx + jarW, jarAt.dy + jarH)
        ..lineTo(jarAt.dx - jarW, jarAt.dy + jarH)
        ..close();
      c.drawPath(water, Paint()..color = Ink.tint(Ink.blue, 0.55));
      Pen.hatchIn(c, water, Ink.blue, gap: 5);
      c.restore();
    }
    sprite(c, 'jar-outline', jarAt, (c) {
      Pen.stroke(
        c,
        Pen.rrect(Rect.fromCenter(center: Offset.zero, width: jarW, height: jarH), 22),
        width: 2.6,
        seed: 4,
      );
      Pen.shape(
        c,
        Pen.rrect(const Rect.fromLTWH(-jarW / 2 - 4, -jarH / 2 - 10, jarW + 8, 14), 5),
        fill: Ink.sky,
        seed: 5,
      );
      for (var i = 1; i < 4; i++) {
        Pen.line(
          c,
          Offset(jarW / 2 - 14, -jarH / 2 + i * 24.0),
          Offset(jarW / 2 - 4, -jarH / 2 + i * 24.0),
          width: 1.6,
          seed: i,
        );
      }
      c.drawArc(Rect.fromLTWH(-jarW / 2 + 8, -jarH / 2 + 12, 20, 60), 2.6, 1.0, false, Pen.inkPaint(Ink.white, 4));
    });
    final drinking = _drinking > 0;
    final hop = drinking ? bump((_drinking * 2) % 1) * 6 : 0.0;
    sprite(
      c,
      drinking ? 'kid-happy' : 'kid-thirsty',
      kidAt - Offset(0, hop),
      (c) => Critters.kid(c, mood: drinking ? Mood.happy : Mood.wow),
    );
    if (drinking) {
      // The kid sips from a cup of the collected rain.
      sprite(c, 'kid-cup', kidAt + const Offset(26, -12), (c) {
        Pen.shape(
          c,
          Pen.poly(const [Offset(-9, -12), Offset(9, -12), Offset(6, 10), Offset(-6, 10)]),
          fill: Ink.sky,
          seed: 3,
          width: 2,
        );
      }, rotation: -0.4);
    }
    // Jar progress: little drops above the jar.
    for (var i = 0; i < dropsToFill; i++) {
      final filled = i < (level * dropsToFill).round();
      c.drawCircle(
        Offset(jarAt.dx - 42 + i * 12.0, jarAt.dy - jarH / 2 - 26),
        4.5,
        filled ? Pen.fillPaint(Ink.blue) : Pen.inkPaint(Ink.navySoft, 1.4),
      );
    }
  }

  @override
  String get progressText => tr.progDrops(collected);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'raindrop', s.center(const Offset(0, 4)), (c) => Props.raindrop(c, 12), scale: s.width / 34);
}

final raindropGame = GameDefinition(
  gameId: 'rainbow_raindrop_catch',
  name: (l) => l.gameRaindropName,
  objective: (l) => l.gameRaindropGoal,
  instructions: (l) => l.gameRaindropHowTo,
  interactionType: Interaction.tap,
  accent: Ink.blue,
  scoreConfig: const ScoreConfig(base: 2, bonus: 5),
  assetManifest: const ['raindrop', 'cloud', 'rainbow', 'jar', 'kid'],
  create: RaindropScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.5, 0.95, (c) => Nature.rainbow(c, 90));
    Thumb.put(c, s, 0.3, 0.2, (c) => Nature.cloud(c, 80));
    Thumb.put(c, s, 0.4, 0.55, (c) => Props.raindrop(c, 12));
    Thumb.put(c, s, 0.7, 0.4, (c) => Props.raindrop(c, 10));
    Thumb.put(
      c,
      s,
      0.82,
      0.78,
      (c) => Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-20, -26, 40, 50), 10), fill: Ink.sky, seed: 3),
    );
  },
);
