import 'common.dart';

const _owlColors = [Ink.brown, Ink.purple, Ink.orange, Ink.blue];

const _perches = [
  Offset(70, 210),
  Offset(290, 180),
  Offset(95, 340),
  Offset(275, 320),
  Offset(60, 470),
  Offset(300, 455),
  Offset(180, 120),
];

enum _O { sleeping, waking, stretching, flying, settling, dozing }

class _Owl {
  _Owl(this.perch, this.color);
  int perch;
  final int color;
  _O state = _O.sleeping;
  double t = 0;
  int wakes = 0;
  Offset pos = Offset.zero, from = Offset.zero, to = Offset.zero;
}

class WakeOwlsScene extends GameScene {
  WakeOwlsScene(this.cfg);
  final ScoreConfig cfg;

  final owls = <_Owl>[];
  int woken = 0;

  static const _dur = {_O.waking: 0.45, _O.stretching: 0.6, _O.flying: 1.1, _O.settling: 0.45, _O.dozing: 1.0};

  @override
  void setup() {
    final order = [0, 1, 2, 3, 4, 5, 6]..shuffle(rng);
    for (var i = 0; i < 4; i++) {
      owls.add(_Owl(order[i], i)..pos = _perches[order[i]]);
    }
  }

  @override
  void tick(double dt) {
    for (final o in owls) {
      o.t += dt;
      final d = _dur[o.state];
      if (o.state == _O.flying) {
        final k = Flight.ease((o.t / (d! / ctx.speed)).clamp(0, 1));
        final mid = Offset((o.from.dx + o.to.dx) / 2, (o.from.dy + o.to.dy) / 2 - 80);
        o.pos = o.from * ((1 - k) * (1 - k)) + mid * (2 * k * (1 - k)) + o.to * (k * k);
      }
      if (d == null || o.t < d / (o.state == _O.flying ? ctx.speed : 1)) continue;
      o.t = 0;
      switch (o.state) {
        case _O.waking:
          o.state = _O.stretching;
        case _O.stretching:
          final used = owls.map((x) => x.perch).toSet();
          final free = [
            for (var i = 0; i < _perches.length; i++)
              if (!used.contains(i)) i,
          ];
          o
            ..from = o.pos
            ..perch = pick(free)
            ..to = _perches[o.perch]
            ..state = _O.flying;
          ctx.onSfx(Sfx.whoosh);
        case _O.flying:
          o
            ..pos = o.to
            ..state = _O.settling;
          // One award per completed wake-up.
          woken++;
          score(cfg.base, 'owl-${o.color}-${o.wakes}', o.pos + const Offset(0, -40));
          ctx.onSfx(Sfx.chirp);
        case _O.settling:
          o.state = _O.dozing;
        case _O.dozing:
          o.state = _O.sleeping;
        case _O.sleeping:
          break;
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final o in owls) {
      if (o.state != _O.sleeping || (o.pos - p).distance > 40 + ctx.hitPad) continue;
      o
        ..state = _O.waking
        ..t = 0
        ..wakes += 1;
      ctx.onSfx(Sfx.tap);
      fx.burst(o.pos + const Offset(0, -30), count: 5, speed: 50);
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    c.save();
    c.translate(300, 60);
    Nature.sun(c, 26);
    c.restore();
    for (final (o, w) in [(const Offset(70, 70), 100.0), (const Offset(220, 260), 70.0)]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.cloud(c, w, seed: w.round());
      c.restore();
    }
    groundBand(c, const Rect.fromLTRB(0, 570, 360, 620), Ink.mint, seed: 6);
    // Trunk and branches.
    Pen.shape(
      c,
      Pen.poly(const [Offset(150, 600), Offset(160, 150), Offset(200, 150), Offset(212, 600)]),
      fill: Ink.brown,
      seed: 2,
      cross: true,
    );
    for (final p in _perches) {
      // Each branch runs from the trunk out past its perch.
      final side = p.dx < 180 ? -1.0 : 1.0;
      final toTrunk = Offset(180 - side * 15, p.dy + 32);
      final tip = Offset(p.dx + side * 40, p.dy + 32);
      Pen.line(c, tip, toTrunk, ink: Ink.shade(Ink.brown, 0.3), width: 9, seed: p.dx.round());
      Pen.line(c, tip, toTrunk, ink: Ink.brown, width: 5, seed: p.dx.round() + 1);
      c.save();
      c.translate(tip.dx - side * 6, tip.dy - 2);
      c.rotate(side < 0 ? -2.6 : -0.5);
      Nature.leaf(c, 26, seed: p.dy.round());
      c.restore();
    }
    c.save();
    c.translate(180, 140);
    Nature.bush(c, 220, color: Ink.mint, seed: 4);
    c.restore();
  }

  @override
  void paint(Canvas c) {
    for (final o in owls) {
      final awake = o.state != _O.sleeping && o.state != _O.dozing;
      final color = _owlColors[o.color];
      final flap = switch (o.state) {
        _O.stretching => 0.5 + bump(o.t / 0.6) * 1.2,
        _O.flying => 0.6 + wave(o.t, 18).abs() * 1.0,
        _ => 0.0,
      };
      final scale = ctx.simple ? 1.25 : 1.1;
      final (sx, sy) = o.state == _O.stretching ? squash(o.t / 0.6, -0.15) : (1.0, 1.0);
      final breath = o.state == _O.sleeping ? 1 + wave(time, 2, o.color.toDouble()) * 0.025 : 1.0;
      c.save();
      c.translate(o.pos.dx, o.pos.dy);
      c.scale(scale * sx, scale * sy * breath);
      for (final side in [-1.0, 1.0]) {
        c.save();
        c.translate(side * 20, -8);
        c.scale(side, 1);
        c.rotate(-flap);
        SpriteCache.draw(c, 'owl-wing-${o.color}', (c) => Critters.owlWing(c, color));
        c.restore();
      }
      SpriteCache.draw(c, 'owl-${o.color}-$awake', (c) => Critters.owl(c, color, awake: awake, seed: o.color + 1));
      c.restore();
      if (o.state == _O.sleeping && !fx.reduced) {
        final k = (time * 0.5 + o.color * 0.25) % 1;
        Pen.text(
          c,
          'z',
          o.pos + Offset(26 + k * 10, -40 - k * 26),
          size: 14 + k * 6,
          color: Ink.navySoft.withValues(alpha: 1 - k),
        );
      }
    }
  }

  @override
  String get progressText => tr.progWakeUps(woken);

  @override
  void paintProgressIcon(Canvas c, Size s) => sprite(
    c,
    'owl-0-true',
    s.center(const Offset(0, 2)),
    (c) => Critters.owl(c, _owlColors[0], awake: true, seed: 1),
    scale: s.width / 62,
  );
}

final wakeOwlsGame = GameDefinition(
  gameId: 'wake_up_little_owls',
  name: (l) => l.gameWakeOwlsName,
  objective: (l) => l.gameWakeOwlsGoal,
  instructions: (l) => l.gameWakeOwlsHowTo,
  interactionType: Interaction.tap,
  accent: Ink.brown,
  scoreConfig: const ScoreConfig(base: 3, bonus: 3),
  assetManifest: const ['owl', 'owl-wing', 'tree', 'sun'],
  create: WakeOwlsScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.5, 0.75, (c) => Pen.line(c, const Offset(-90, 0), const Offset(90, 0), ink: Ink.brown, width: 7));
    Thumb.put(c, s, 0.32, 0.45, (c) => Critters.owl(c, Ink.brown));
    Thumb.put(c, s, 0.68, 0.45, (c) => Critters.owl(c, Ink.purple, awake: true, seed: 2));
  },
);
