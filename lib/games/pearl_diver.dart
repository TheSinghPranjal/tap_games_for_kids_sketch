import 'common.dart';

const _clamColors = [Ink.purple, Ink.pink, Ink.blue, Ink.coral, Ink.mint];

enum _C { closed, wobble, ajar, opened, closing }

class _Clam {
  _Clam(this.pos, this.color);
  final Offset pos;
  final int color;
  _C state = _C.closed;
  double t = 0, wait = 1;
  bool pink = false;
  int gen = 0;

  double get lid => switch (state) {
    _C.closed || _C.wobble => 0.0,
    _C.ajar => (t / 0.3).clamp(0.0, 1.0) * 0.5,
    _C.opened => 0.5 + (t / 0.25).clamp(0.0, 1.0) * 0.5,
    _C.closing => (1 - (t / 0.4).clamp(0.0, 1.0)) * 0.5,
  };
}

class PearlDiverScene extends GameScene {
  PearlDiverScene(this.cfg);
  final ScoreConfig cfg;

  static const surface = 92.0;
  static const jarAt = Offset(42, 150);

  late final clams = [
    for (final (i, x) in [50.0, 120.0, 190.0, 260.0, 325.0].indexed) _Clam(Offset(x, 530 - (i % 2) * 22.0), i),
  ];
  int pearls = 0;
  double _birdX = 250, _birdDir = 1, _birdHappy = 0;

  @override
  void setup() {
    for (final c in clams) {
      c.wait = rand(0.4, 3.5);
    }
  }

  @override
  void tick(double dt) {
    _birdHappy = (_birdHappy - dt).clamp(0, 2);
    _birdX += _birdDir * 18 * dt;
    if (_birdX < 130 || _birdX > 310) _birdDir = -_birdDir;
    for (final c in clams) {
      c.t += dt;
      switch (c.state) {
        case _C.closed:
          if (!ended && c.t > c.wait) _set(c, _C.wobble);
        case _C.wobble:
          if (c.t > 0.7) {
            _set(c, _C.ajar);
            c
              ..gen += 1
              ..pink = rng.nextDouble() < 0.12;
          }
        case _C.ajar:
          if (c.t > 3.2 * ctx.patience) {
            // Not collected: the pearl drifts up as a bubble to the friendly bird.
            final from = c.pos + const Offset(0, -10);
            final pink = c.pink;
            fly(
              from,
              Offset(_birdX + 20, surface - 4),
              1.6,
              (cv, at, t) {
                sprite(
                  cv,
                  'pearl-$pink',
                  at,
                  (cv) => Props.pearl(cv, 9, color: pink ? Ink.pink : Ink.white),
                  scale: 1 - t * 0.3,
                );
                cv.drawCircle(at, 14, Pen.inkPaint(Ink.white.withValues(alpha: 0.8), 1.6));
              },
              arc: -20,
              trail: false,
              onArrive: () => _birdHappy = 1.2,
            );
            _set(c, _C.closing);
          }
        case _C.opened:
          if (c.t > 0.6) _set(c, _C.closing);
        case _C.closing:
          if (c.t > 0.4) {
            _set(c, _C.closed);
            c.wait = rand(1.2, 3.2);
          }
      }
    }
  }

  void _set(_Clam c, _C s) {
    c
      ..state = s
      ..t = 0;
  }

  @override
  void onTap(Offset p) {
    for (final c in clams) {
      // The whole shell (and the pearl above it) stays tappable while open.
      final hit = Rect.fromCenter(center: c.pos + const Offset(0, -12), width: 70, height: 64).inflate(ctx.hitPad);
      if (c.state != _C.ajar || !hit.contains(p)) continue;
      _set(c, _C.opened);
      pearls++;
      final from = c.pos + const Offset(0, -12), pink = c.pink;
      score(pink ? cfg.bonus : cfg.base, 'pearl-${c.color}-${c.gen}', from);
      ctx.onSfx(pink ? Sfx.bonus : Sfx.collect);
      fx.burst(from, colors: const [Ink.white, Ink.pink, Ink.yellow]);
      fly(
        from,
        jarAt + const Offset(0, 10),
        1.1,
        (cv, at, t) {
          sprite(
            cv,
            'pearl-$pink',
            at,
            (cv) => Props.pearl(cv, 9, color: pink ? Ink.pink : Ink.white),
            scale: 1.4 - t * 0.5,
          );
          if (!fx.reduced && t < 0.9) Pen.twinkle(cv, at + const Offset(12, -10), 5, Ink.yellow);
        },
        arc: -40,
        onArrive: () => fx.burst(jarAt, count: 5, speed: 40),
      );
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, const Rect.fromLTRB(0, 0, 360, surface));
    final water = Path()..addRect(const Rect.fromLTRB(-4, surface, 364, 624));
    waterBody(c, water, color: Ink.tint(Ink.blue, 0.55), seed: 7);
    final wavePath = Path()..moveTo(-4, surface);
    for (var x = -4.0; x < 364; x += 30) {
      wavePath.quadraticBezierTo(x + 15, surface - 8, x + 30, surface);
    }
    Pen.stroke(c, wavePath, width: 2.4, seed: 2);
    c.save();
    c.translate(60, 46);
    Nature.cloud(c, 80);
    c.restore();
    groundBand(c, const Rect.fromLTRB(0, 540, 360, 620), Ink.sand, seed: 9);
    for (final x in [20.0, 90.0, 155.0, 225.0, 345.0]) {
      c.save();
      c.translate(x, 575);
      Nature.seaweed(c, 60 + (x % 40), seed: x.round());
      c.restore();
    }
    for (final (o, w) in [(const Offset(290, 590), 40.0), (const Offset(130, 600), 26.0)]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.rock(c, w, seed: w.round());
      c.restore();
    }
    // Pearl jar.
    Pen.shape(
      c,
      Pen.rrect(Rect.fromCenter(center: jarAt, width: 54, height: 60), 14),
      fill: Ink.white,
      solid: true,
      hatch: Ink.sky.withValues(alpha: 0.4),
      seed: 3,
    );
    Pen.shape(
      c,
      Pen.rrect(Rect.fromCenter(center: jarAt + const Offset(0, -32), width: 58, height: 12), 4),
      fill: Ink.coral,
      seed: 4,
    );
  }

  @override
  void paint(Canvas c) {
    // Bubbles.
    final bub = Pen.inkPaint(Ink.white.withValues(alpha: 0.8), 1.4);
    for (var i = 0; i < 8; i++) {
      final y = 520 - ((time * 30 + i * 60) % 420);
      c.drawCircle(Offset(30 + i * 44.0 + wave(time, 2, i.toDouble()) * 6, y), 3 + i % 3.0, bub);
    }
    // Friendly seabird bobbing on the surface.
    final bob = wave(time, 2) * 3 + (_birdHappy > 0 ? bump(_birdHappy / 1.2) * -10 : 0);
    sprite(
      c,
      'seabird-${_birdHappy > 0}',
      Offset(_birdX, surface - 12 + bob),
      (c) => Critters.seabird(c, happy: true),
      sx: _birdDir > 0 ? 1 : -1,
    );
    // Pearls collected, shown inside the jar.
    for (var i = 0; i < pearls.clamp(0, 9); i++) {
      Pen.dot(c, jarAt + Offset(-14 + (i % 3) * 14.0, 18 - (i ~/ 3) * 12.0), 5, i.isEven ? Ink.white : Ink.pink);
    }
    for (final cl in clams) {
      final wob = cl.state == _C.wobble ? wave(cl.t, 30) * 0.12 : 0.0;
      final s = ctx.simple ? 1.2 : 1.05;
      c.save();
      c.translate(cl.pos.dx, cl.pos.dy);
      c.rotate(wob);
      c.scale(s);
      SpriteCache.draw(c, 'clam-bottom-${cl.color}', (c) => Props.clamBottom(c, _clamColors[cl.color]));
      if (cl.state == _C.ajar) {
        if (!fx.reduced) {
          c.drawCircle(const Offset(0, -6), 14 + wave(time, 4) * 2, Paint()..color = Ink.white.withValues(alpha: 0.35));
        }
        SpriteCache.draw(c, 'pearl-in-${cl.pink}', (c) {
          c.translate(0, -6);
          Props.pearl(c, 9, color: cl.pink ? Ink.pink : Ink.white);
        });
      }
      c.save();
      c.translate(-22, 0);
      c.rotate(-cl.lid * 1.4);
      c.translate(22, 0);
      SpriteCache.draw(c, 'clam-top-${cl.color}', (c) => Props.clamTop(c, _clamColors[cl.color]));
      c.restore();
      if (cl.state == _C.closed || cl.state == _C.wobble) Pen.face(c, const Offset(0, -6), 22, mood: Mood.sleepy);
      c.restore();
    }
  }

  @override
  String get progressText => '$pearls pearls';

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'pearl-false', s.center(Offset.zero), (c) => Props.pearl(c, 9), scale: s.width / 24);
}

final pearlDiverGame = GameDefinition(
  gameId: 'pearl_diver',
  name: 'Pearl Diver',
  objective: 'Collect pearls from the shells!',
  instructions: 'When a shell opens and shows its pearl, tap it!',
  interactionType: Interaction.tap,
  accent: Ink.blue,
  assetManifest: const ['clam', 'pearl', 'seabird', 'seaweed', 'jar'],
  create: PearlDiverScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, Ink.tint(Ink.blue, 0.55));
    Thumb.put(c, s, 0.75, 0.2, (c) => Critters.seabird(c), scale: 0.7);
    Thumb.put(c, s, 0.35, 0.72, (c) {
      Props.clamBottom(c, Ink.purple);
      Props.pearl(c, 9);
      c.translate(-22, 0);
      c.rotate(-0.8);
      c.translate(22, 0);
      Props.clamTop(c, Ink.purple);
    }, scale: 1.2);
  },
);
