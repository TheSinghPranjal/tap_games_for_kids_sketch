import 'common.dart';

const _eggColors = [Ink.cream, Color(0xFFDDEBFB), Color(0xFFFDE3EA), Color(0xFFE7F5E4)];

enum _E { dropping, waiting, hatching, leaving }

class HatchChickScene extends GameScene {
  HatchChickScene(this.cfg);
  final ScoreConfig cfg;

  static const nestAt = Offset(180, 430);

  var _state = _E.dropping;
  double t = 0, _knock = 0;
  int taps = 0, hatched = 0, egg = 0, color = 0;
  final _walkers = <(double, int)>[]; // chicks wandering off: (age, color)

  int get threshold => ctx.simple ? 3 : 4;

  @override
  void setup() => _newEgg();

  void _newEgg() {
    _state = _E.dropping;
    t = 0;
    taps = 0;
    egg++;
    color = rng.nextInt(_eggColors.length);
  }

  @override
  void tick(double dt) {
    t += dt;
    _knock = (_knock - dt * 3).clamp(0, 1);
    switch (_state) {
      case _E.dropping:
        if (t > 0.55) {
          _state = _E.waiting;
          t = 0;
        }
      case _E.waiting:
        break;
      case _E.hatching:
        if (t > 1.5) {
          _state = _E.leaving;
          t = 0;
          _walkers.add((0, color));
        }
      case _E.leaving:
        if (t > 0.5 && !ended) _newEgg();
    }
    for (var i = 0; i < _walkers.length; i++) {
      _walkers[i] = (_walkers[i].$1 + dt, _walkers[i].$2);
    }
    _walkers.removeWhere((w) => w.$1 > 2.6);
  }

  @override
  void onTap(Offset p) {
    if (_state != _E.waiting) return; // completed eggs never score again
    if ((p - (nestAt + const Offset(0, -46))).distance > 70 + ctx.hitPad) return;
    taps++;
    _knock = 1;
    ctx.onSfx(Sfx.tap);
    fx.burst(nestAt + Offset(rand(-20, 20), -60), count: 4, speed: 50, colors: const [Ink.yellow, Ink.white]);
    if (taps >= threshold) {
      _state = _E.hatching;
      t = 0;
      hatched++;
      score(cfg.base, 'egg-$egg', nestAt + const Offset(0, -90));
      ctx.onSfx(Sfx.chirp);
      fx.hearts(nestAt + const Offset(0, -100));
      fx.burst(nestAt + const Offset(0, -50), count: 12, colors: const [Ink.yellow, Ink.coral, Ink.mint]);
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect, base: Ink.paperWarm);
    c.save();
    c.translate(290, 70);
    Nature.sun(c, 26);
    c.restore();
    c.save();
    c.translate(80, 80);
    Nature.cloud(c, 100);
    c.restore();
    // Little barn.
    Pen.shape(
      c,
      Pen.poly(const [Offset(30, 260), Offset(80, 210), Offset(130, 260), Offset(130, 330), Offset(30, 330)]),
      fill: Ink.coral,
      seed: 4,
    );
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(64, 280, 32, 50), 2),
      fill: Ink.white,
      solid: true,
      hatch: Ink.coral,
      seed: 5,
    );
    // Fence.
    for (var x = 160.0; x < 360; x += 32) {
      Pen.shape(
        c,
        Pen.rrect(Rect.fromLTWH(x, 280, 12, 52), 3),
        fill: Ink.white,
        solid: true,
        hatch: Ink.brown.withValues(alpha: 0.4),
        seed: x.round(),
      );
    }
    Pen.line(c, const Offset(150, 296), const Offset(360, 296), width: 3);
    Pen.line(c, const Offset(150, 318), const Offset(360, 318), width: 3);
    groundBand(c, const Rect.fromLTRB(0, 330, 360, 620), Ink.tint(Ink.yellow, 0.6), seed: 3);
    final hay = Random(6);
    for (var i = 0; i < 40; i++) {
      final o = Offset(hay.nextDouble() * 360, 350 + hay.nextDouble() * 260);
      Pen.line(c, o, o + Offset(hay.nextDouble() * 16 - 8, -6), ink: Ink.gold, width: 1.6, seed: i);
    }
    for (final x in [40.0, 320.0]) {
      c.save();
      c.translate(x, 560);
      Nature.flower(c, x < 100 ? Ink.pink : Ink.purple, r: 14, face: false);
      c.restore();
    }
  }

  @override
  void paint(Canvas c) {
    sprite(
      c,
      'nest-back',
      nestAt + const Offset(0, -6),
      (c) => Pen.shape(c, Pen.oval(Offset.zero, 62, 16), fill: Ink.brown, seed: 2),
    );
    final eggAt = nestAt + const Offset(0, -42);
    switch (_state) {
      case _E.dropping:
        final k = (t / 0.55).clamp(0.0, 1.0);
        final y = eggAt.dy - (1 - k * k) * 320;
        sprite(c, 'egg-$color-0', Offset(eggAt.dx, y), (c) => Props.egg(c, _eggColors[color], seed: color + 1));
      case _E.waiting:
        final idle = fx.reduced ? 0.0 : wave(time, 4) * (0.05 + taps * 0.03);
        final knock = wave(_knock * 20) * _knock * 0.3;
        sprite(c, 'egg-$color-$taps', eggAt + const Offset(0, 26), (c) {
          c.translate(0, -26);
          Props.egg(c, _eggColors[color], cracks: taps, seed: color + 1);
        }, rotation: idle + knock);
      case _E.hatching:
        final k = (t / 0.4).clamp(0.0, 1.0);
        // Bottom shell stays, top half lifts off; the chick pops up.
        c.save();
        c.clipRect(Rect.fromLTRB(0, eggAt.dy + 2, 360, 620));
        sprite(c, 'egg-$color-3', eggAt, (c) => Props.egg(c, _eggColors[color], cracks: 3, seed: color + 1));
        c.restore();
        final chickY = eggAt.dy - 12 - k * 28 - bump(((t - 0.4) * 2).clamp(0, 1)) * 12;
        sprite(c, 'chick-happy', Offset(eggAt.dx, chickY), (c) => Critters.chick(c), scale: 1.4 * (0.6 + 0.4 * k));
        c.save();
        c.translate(eggAt.dx + k * 40, eggAt.dy - k * 60);
        c.rotate(k * 0.9);
        c.clipRect(const Rect.fromLTRB(-40, -40, 40, 2));
        SpriteCache.draw(c, 'egg-$color-3', (c) => Props.egg(c, _eggColors[color], cracks: 3, seed: color + 1));
        c.restore();
      case _E.leaving:
        break;
    }
    sprite(c, 'nest', nestAt, (c) => Props.nest(c, w: 132));
    for (final (age, _) in _walkers) {
      final x = nestAt.dx + 30 + age * 90;
      final hop = bump((age * 3) % 1) * 14;
      sprite(
        c,
        'chick-happy',
        Offset(x, nestAt.dy + 60 - hop),
        (c) => Critters.chick(c),
        scale: 1.1,
        opacity: (1 - (age - 2).clamp(0, 0.6) / 0.6),
      );
    }
    // Hatch progress: dots under the nest.
    for (var i = 0; i < threshold; i++) {
      final filled = _state != _E.waiting || i < taps;
      final o = Offset(nestAt.dx - (threshold - 1) * 15 + i * 30.0, nestAt.dy + 46);
      sprite(
        c,
        'hatch-dot-$filled-$i',
        o,
        (c) => Pen.shape(
          c,
          Pen.circle(Offset.zero, 9),
          fill: filled ? Ink.yellow : Ink.white,
          solid: true,
          seed: i + 1,
          width: 2,
        ),
      );
    }
  }

  @override
  String get progressText => tr.progChicks(hatched);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'chick-happy', s.center(Offset.zero), (c) => Critters.chick(c), scale: s.width / 40);
}

final hatchChickGame = GameDefinition(
  gameId: 'hatch_a_chick',
  name: (l) => l.gameHatchChickName,
  objective: (l) => l.gameHatchChickGoal,
  instructions: (l) => l.gameHatchChickHowTo,
  interactionType: Interaction.tap,
  accent: Ink.yellow,
  scoreConfig: const ScoreConfig(base: 5, bonus: 5),
  assetManifest: const ['egg', 'nest', 'chick', 'barn', 'fence'],
  create: HatchChickScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, Ink.tint(Ink.yellow, 0.25));
    Thumb.put(c, s, 0.38, 0.55, (c) => Props.egg(c, Ink.cream, cracks: 2));
    Thumb.put(c, s, 0.66, 0.6, (c) => Critters.chick(c), scale: 1.2);
    Thumb.put(c, s, 0.5, 0.9, (c) => Props.nest(c, w: 130));
  },
);
