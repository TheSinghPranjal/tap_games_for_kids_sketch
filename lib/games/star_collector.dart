import 'common.dart';

class _Star {
  _Star(this.id, this.pos, this.vel, this.golden, this.life);
  final String id;
  Offset pos;
  final Offset vel;
  final bool golden;
  final double life;
  double t = 0;
  bool taken = false;
}

class StarCollectorScene extends GameScene {
  StarCollectorScene(this.cfg);
  final ScoreConfig cfg;

  static const basketAt = Offset(180, 572);
  static const area = Rect.fromLTRB(40, 110, 320, 480);

  final stars = <_Star>[];
  int collected = 0;
  double _spawnIn = 0, _basket = 1;

  int get _max => ctx.simple ? 4 : 5;

  @override
  void setup() {
    for (var i = 0; i < 3; i++) {
      _spawn();
    }
  }

  void _spawn() {
    final golden = rng.nextDouble() < 0.14;
    final p = freeSpot(area, stars.map((s) => s.pos), 80);
    final v = Offset(rand(-8, 8), rand(-6, 6)) * ctx.speed;
    stars.add(_Star(newId('star'), p, v, golden, rand(5, 7) * ctx.patience));
  }

  double _radius(_Star s) => (s.golden ? 30.0 : 21.0) * (ctx.simple ? 1.2 : 1);

  @override
  void tick(double dt) {
    _basket = (_basket + dt * 3).clamp(0, 1);
    for (final s in stars) {
      s.t += dt;
      s.pos += s.vel * dt;
    }
    stars.removeWhere((s) => s.taken || s.t > s.life);
    if (!ended && stars.length < _max) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(0.5, 1.1);
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final s in stars.reversed) {
      if (s.taken || (s.pos - p).distance > _radius(s) + 10 + ctx.hitPad) continue;
      s.taken = true;
      collected++;
      score(s.golden ? cfg.bonus : cfg.base, s.id, s.pos);
      ctx.onSfx(s.golden ? Sfx.bonus : Sfx.collect);
      fx.burst(
        s.pos,
        colors: s.golden ? const [Ink.gold, Ink.yellow, Ink.white] : const [Ink.yellow, Ink.white],
        count: s.golden ? 12 : 8,
      );
      final golden = s.golden, r = _radius(s);
      fly(
        s.pos,
        basketAt + const Offset(0, -26),
        0.8,
        (c, pos, t) {
          _drawStar(c, pos, golden, r * (1 - t * 0.5), t * 6);
        },
        arc: -60,
        onArrive: () => _basket = 0,
      );
      return;
    }
  }

  void _drawStar(Canvas c, Offset at, bool golden, double r, double rot) {
    sprite(
      c,
      golden ? 'star-gold' : 'star',
      at,
      (c) {
        Nature.starShape(c, 20, color: golden ? Ink.gold : Ink.yellow, seed: golden ? 3 : 1);
        if (golden) Pen.stroke(c, Pen.circle(Offset.zero, 26), ink: Ink.gold, width: 2, seed: 4);
      },
      scale: r / 20,
      rotation: rot,
    );
  }

  @override
  void paintBackground(Canvas c) {
    final r = GameScene.worldRect;
    c.drawRect(r, Paint()..color = Ink.night);
    Paper.gridOverlay(c, r, alpha: 0.08);
    final rnd = Random(5);
    for (var i = 0; i < 40; i++) {
      Pen.dot(
        c,
        Offset(rnd.nextDouble() * 360, rnd.nextDouble() * 500),
        1 + rnd.nextDouble(),
        Ink.white.withValues(alpha: 0.6),
      );
    }
    // A little constellation.
    const pts = [Offset(60, 70), Offset(95, 50), Offset(130, 72), Offset(160, 48)];
    for (var i = 0; i < pts.length - 1; i++) {
      Pen.line(c, pts[i], pts[i + 1], ink: Ink.white.withValues(alpha: 0.5), width: 1.2, seed: i);
    }
    for (final p in pts) {
      Pen.twinkle(c, p, 5, Ink.white);
    }
    c.save();
    c.translate(300, 70);
    Nature.moon(c, 30);
    Pen.face(c, const Offset(-12, 6), 22, mood: Mood.sleepy);
    c.restore();
    for (final (o, w) in [(const Offset(70, 520), 110.0), (const Offset(300, 500), 90.0)]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.cloud(c, w, fill: Ink.tint(Ink.purple, 0.35), hatch: Ink.purple.withValues(alpha: 0.5));
      c.restore();
    }
    groundBand(c, const Rect.fromLTRB(0, 560, 360, 620), Ink.tint(Ink.purple, 0.8), seed: 7);
  }

  @override
  void paint(Canvas c) {
    for (final s in stars) {
      final fadeIn = (s.t / 0.35).clamp(0.0, 1.0);
      final fadeOut = ((s.life - s.t) / 0.7).clamp(0.0, 1.0);
      final tw = 1 + wave(time, 4, s.pos.dx) * 0.08;
      if (s.golden && !fx.reduced) {
        c.drawCircle(s.pos, _radius(s) * 1.6, Paint()..color = Ink.gold.withValues(alpha: 0.18 * fadeOut));
      }
      sprite(
        c,
        s.golden ? 'star-gold' : 'star',
        s.pos,
        (c) {
          Nature.starShape(c, 20, color: s.golden ? Ink.gold : Ink.yellow, seed: s.golden ? 3 : 1);
          if (s.golden) Pen.stroke(c, Pen.circle(Offset.zero, 26), ink: Ink.gold, width: 2, seed: 4);
        },
        scale: _radius(s) / 20 * tw * (0.4 + 0.6 * fadeIn),
        opacity: fadeOut,
        rotation: wave(time, 1.2, s.pos.dy) * 0.12,
      );
    }
    final (sx, sy) = squash(_basket);
    sprite(
      c,
      'star-basket',
      basketAt,
      (c) => Props.basket(c, w: 80, h: 46, color: Ink.purple),
      sx: sx,
      sy: sy,
    );
  }

  @override
  String get progressText => tr.progStars(collected);

  @override
  void paintProgressIcon(Canvas c, Size s) => _drawStar(c, s.center(Offset.zero), false, s.width * 0.45, 0);
}

final starCollectorGame = GameDefinition(
  gameId: 'star_collector',
  name: (l) => l.gameStarCollectorName,
  objective: (l) => l.gameStarCollectorGoal,
  instructions: (l) => l.gameStarCollectorHowTo,
  interactionType: Interaction.tap,
  accent: Ink.purple,
  scoreConfig: const ScoreConfig(base: 2, bonus: 6),
  assetManifest: const ['star', 'star-gold', 'moon', 'cloud', 'basket'],
  create: StarCollectorScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, Ink.night);
    Thumb.put(c, s, 0.82, 0.25, (c) => Nature.moon(c, 18));
    Thumb.put(c, s, 0.3, 0.4, (c) => Nature.starShape(c, 20));
    Thumb.put(c, s, 0.58, 0.62, (c) => Nature.starShape(c, 26, color: Ink.gold, seed: 3));
    Thumb.put(c, s, 0.15, 0.78, (c) => Nature.starShape(c, 14, face: false));
  },
);
