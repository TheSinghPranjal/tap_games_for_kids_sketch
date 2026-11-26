import 'common.dart';

const _petals = [Ink.pink, Ink.coral, Ink.purple, Ink.orange, Ink.blue, Ink.yellow];

enum _F { bud, opening, bloomed, wilting, empty }

class _Slot {
  _Slot(this.base);
  final Offset base;
  _F state = _F.empty;
  double t = 0;
  double window = 4;
  int color = 0;
  int gen = 0;
  double wobble = 0;
  Offset get head => base + const Offset(0, -86);
}

class FlowerBasketScene extends GameScene {
  FlowerBasketScene(this.cfg);
  final ScoreConfig cfg;

  static const basketAt = Offset(180, 570);
  static const _budTime = 0.8, _openTime = 1.6, _wiltTime = 1.1, _emptyTime = 0.7;

  final slots = [
    for (final (x, y) in [(70.0, 270.0), (180.0, 250.0), (290.0, 270.0), (70.0, 460.0), (180.0, 440.0), (290.0, 460.0)])
      _Slot(Offset(x, y)),
  ];
  int collected = 0;
  double _basket = 1;

  @override
  void setup() {
    for (final (i, s) in slots.indexed) {
      s.t = -i * 0.6; // stagger so flowers bloom one after another
      s.state = _F.empty;
    }
  }

  void _next(_Slot s) {
    s.t = 0;
    switch (s.state) {
      case _F.empty:
        if (ended) return;
        s
          ..state = _F.bud
          ..color = rng.nextInt(_petals.length)
          ..gen += 1
          ..window = rand(3.6, 4.8) * ctx.patience;
      case _F.bud:
        s.state = _F.opening;
      case _F.opening:
        s.state = _F.bloomed;
      case _F.bloomed:
        s.state = _F.wilting;
      case _F.wilting:
        s.state = _F.empty;
    }
  }

  double _duration(_Slot s) => switch (s.state) {
    _F.bud => _budTime / ctx.speed,
    _F.opening => _openTime / ctx.speed,
    _F.bloomed => s.window,
    _F.wilting => _wiltTime,
    _F.empty => _emptyTime,
  };

  @override
  void tick(double dt) {
    _basket = (_basket + dt * 3).clamp(0, 1);
    for (final s in slots) {
      s.t += dt;
      s.wobble = (s.wobble - dt * 2).clamp(0, 1);
      if (s.t >= _duration(s)) _next(s);
    }
  }

  @override
  void onTap(Offset p) {
    for (final s in slots) {
      if ((s.head - p).distance > 34 + ctx.hitPad) continue;
      if (s.state == _F.bloomed || (s.state == _F.opening && s.t > _duration(s) * 0.85)) {
        final color = s.color, from = s.head;
        score(cfg.base, 'flower-${slots.indexOf(s)}-${s.gen}', from);
        collected++;
        ctx.onSfx(Sfx.collect);
        fx.burst(from, colors: [_petals[color], Ink.yellow]);
        s
          ..state = _F.empty
          ..t = 0;
        // Gentle bounce off the stem, then into the basket.
        fly(
          from,
          basketAt + const Offset(0, -30),
          0.85,
          (c, pos, t) {
            final k = 1 - t * 0.4 + bump(t * 3) * 0.15;
            sprite(
              c,
              'bloom-$color',
              pos,
              (c) => Nature.flower(c, _petals[color], r: 22, seed: color + 1),
              scale: k,
              rotation: t * 3,
            );
          },
          arc: -90,
          onArrive: () => _basket = 0,
        );
      } else if (s.state == _F.bud || s.state == _F.opening) {
        s.wobble = 1; // not ready yet: a friendly wiggle, no penalty
        ctx.onSfx(Sfx.soft);
      }
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    c.save();
    c.translate(300, 70);
    Nature.sun(c, 26);
    c.restore();
    c.save();
    c.translate(90, 70);
    Nature.cloud(c, 100);
    c.restore();
    groundBand(c, const Rect.fromLTRB(0, 500, 360, 620), Ink.mint, seed: 4);
    for (final s in slots) {
      c.save();
      c.translate(s.base.dx, s.base.dy);
      Nature.stem(c, 70, seed: s.base.dx.round());
      Nature.grass(c, 40, seed: s.base.dy.round());
      c.restore();
    }
    // Little doodle insects.
    for (final o in [const Offset(130, 150), const Offset(250, 360)]) {
      c.save();
      c.translate(o.dx, o.dy);
      c.scale(0.5);
      Critters.ladybug(c);
      c.restore();
    }
    Pen.plus(c, const Offset(40, 160), 5, Ink.coral);
    Pen.plus(c, const Offset(330, 380), 5, Ink.gold);
  }

  @override
  void paint(Canvas c) {
    for (final s in slots) {
      final k = (s.t / _duration(s)).clamp(0.0, 1.0);
      final sway = wave(time, 1.4, s.base.dx) * 0.06 + wave(s.wobble * 20) * s.wobble * 0.25;
      final head = s.head;
      final colorKey = 'bud-${s.color}', bloomKey = 'bloom-${s.color}';
      void bud(double scale) => sprite(
        c,
        colorKey,
        head,
        (c) => Nature.bud(c, _petals[s.color], seed: s.color + 2),
        scale: scale,
        rotation: sway,
      );
      void bloom(double scale, {double rot = 0, double opacity = 1}) => sprite(
        c,
        bloomKey,
        head,
        (c) => Nature.flower(c, _petals[s.color], r: 22, seed: s.color + 1),
        scale: scale,
        rotation: sway + rot,
        opacity: opacity,
      );
      switch (s.state) {
        case _F.empty:
          break;
        case _F.bud:
          bud(0.3 + 0.9 * k);
        case _F.opening:
          if (k < 0.5) {
            bud(1.2 + k * 0.4);
          } else {
            bloom(0.5 + (k - 0.5) * 1.0);
          }
        case _F.bloomed:
          bloom(1.0 + wave(time, 3, s.base.dx) * 0.04);
          if (!fx.reduced) {
            Pen.twinkle(c, head + Offset(26, -24 + wave(time, 2) * 4), 5, Ink.gold.withValues(alpha: 0.8));
          }
        case _F.wilting:
          // Closes gently and lets a few petals drift down.
          bloom(1.0 - k * 0.5, rot: k * 0.6, opacity: 1 - k);
          for (var i = 0; i < 3; i++) {
            final p = head + Offset(-14.0 + i * 14 + wave(k * 6 + i) * 6, 10 + k * 70);
            c.save();
            c.translate(p.dx, p.dy);
            c.rotate(k * 3 + i);
            c.drawOval(
              Rect.fromCenter(center: Offset.zero, width: 9, height: 13),
              Pen.fillPaint(_petals[s.color].withValues(alpha: 1 - k)),
            );
            c.restore();
          }
      }
    }
    final (sx, sy) = squash(_basket);
    sprite(c, 'flower-basket', basketAt, (c) => Props.basket(c, w: 86, h: 48), sx: sx, sy: sy);
  }

  @override
  String get progressText => tr.progFlowers(collected);

  @override
  void paintProgressIcon(Canvas c, Size s) => sprite(
    c,
    'bloom-0',
    s.center(Offset.zero),
    (c) => Nature.flower(c, _petals[0], r: 22, seed: 1),
    scale: s.width / 52,
  );
}

final flowerBasketGame = GameDefinition(
  gameId: 'blooming_flower_basket',
  name: (l) => l.gameFlowerBasketName,
  objective: (l) => l.gameFlowerBasketGoal,
  instructions: (l) => l.gameFlowerBasketHowTo,
  interactionType: Interaction.tap,
  accent: Ink.pink,
  assetManifest: const ['bud', 'flower', 'stem', 'basket'],
  create: FlowerBasketScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.5, 1.0, (c) => groundBand(c, const Rect.fromLTRB(-200, -26, 200, 10), Ink.mint));
    Thumb.put(c, s, 0.25, 0.85, (c) => Nature.stem(c, 50, leaves: false));
    Thumb.put(c, s, 0.25, 0.35, (c) => Nature.flower(c, Ink.pink, r: 20));
    Thumb.put(c, s, 0.5, 0.85, (c) => Nature.stem(c, 40, leaves: false));
    Thumb.put(c, s, 0.5, 0.45, (c) => Nature.bud(c, Ink.purple));
    Thumb.put(c, s, 0.8, 0.72, (c) => Props.basket(c, w: 54, h: 32));
  },
);
