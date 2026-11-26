import 'common.dart';

const _beeFlowerColors = [Ink.pink, Ink.purple, Ink.coral, Ink.orange, Ink.blue, Ink.yellow];

class _Spot {
  _Spot(this.base, this.color);
  final Offset base;
  final int color;
  bool bloomed = false;
  double bloomT = 0;
  Offset get head => base + const Offset(0, -70);
}

enum _B { flying, hovering, pollinating, resting }

class _Bee {
  _Bee(this.pos);
  Offset pos;
  Offset from = Offset.zero, to = Offset.zero;
  _B state = _B.resting;
  double t = 0;
  _Spot? target;
  int visits = 0;
}

class BusyBeeScene extends GameScene {
  BusyBeeScene(this.cfg);
  final ScoreConfig cfg;

  static const rest = [Offset(90, 120), Offset(270, 140)];

  late final spots = [
    for (final (i, (x, y)) in [
      (60.0, 330.0),
      (180.0, 300.0),
      (300.0, 330.0),
      (60.0, 520.0),
      (180.0, 500.0),
      (300.0, 520.0),
    ].indexed)
      _Spot(Offset(x, y), i),
  ];
  late final bees = [_Bee(rest[0]), _Bee(rest[1])];
  int blooms = 0, cycles = 0;
  double _newCycleIn = 0;

  @override
  void setup() {
    for (final b in bees) {
      _sendToFlower(b);
    }
  }

  /// A bee always goes to an unbloomed flower nobody else is visiting —
  /// it never stays stuck on a bloomed one.
  void _sendToFlower(_Bee b) {
    final taken = bees.where((o) => o != b).map((o) => o.target).toSet();
    final free = spots.where((s) => !s.bloomed && !taken.contains(s)).toList();
    b
      ..from = b.pos
      ..t = 0;
    if (free.isEmpty) {
      b
        ..target = null
        ..to = rest[bees.indexOf(b)]
        ..state = _B.flying;
      return;
    }
    free.sort((x, y) => (x.head - b.pos).distance.compareTo((y.head - b.pos).distance));
    final pickOne = free[rng.nextInt(free.length.clamp(1, 2))];
    b
      ..target = pickOne
      ..to = pickOne.head + const Offset(0, -26)
      ..state = _B.flying;
  }

  @override
  void tick(double dt) {
    for (final s in spots) {
      if (s.bloomed) s.bloomT = (s.bloomT + dt * 2.5).clamp(0, 1);
    }
    for (final b in bees) {
      b.t += dt;
      switch (b.state) {
        case _B.flying:
          final dur = 1.3 / ctx.speed;
          final k = Flight.ease((b.t / dur).clamp(0, 1));
          final mid = Offset((b.from.dx + b.to.dx) / 2, (b.from.dy + b.to.dy) / 2 - 60);
          b.pos = b.from * ((1 - k) * (1 - k)) + mid * (2 * k * (1 - k)) + b.to * (k * k);
          if (b.t >= dur) {
            b.t = 0;
            b.state = b.target == null ? _B.resting : _B.hovering;
          }
        case _B.hovering:
          b.pos = b.to + Offset(wave(time, 3, b.to.dx) * 6, wave(time, 5, b.to.dy) * 4);
          if (b.target?.bloomed ?? true) _sendToFlower(b); // safety: never linger on a bloom
        case _B.pollinating:
          if (b.t >= 0.6) {
            final s = b.target!;
            s
              ..bloomed = true
              ..bloomT = 0;
            ctx.onSfx(Sfx.chirp);
            fx.burst(s.head, colors: [_beeFlowerColors[s.color], Ink.yellow]);
            _sendToFlower(b);
          }
        case _B.resting:
          b.pos = b.to + Offset(wave(time, 2) * 8, wave(time, 3) * 5);
      }
    }
    if (spots.every((s) => s.bloomed)) {
      if (_newCycleIn <= 0) {
        _newCycleIn = 2.0;
        cycles++;
        score(cfg.bonus, 'garden-$cycles', const Offset(180, 220));
        ctx.onSfx(Sfx.cheer);
        fx.confetti(const Offset(180, 260));
      }
      _newCycleIn -= dt;
      if (_newCycleIn <= 0) {
        // New garden cycle: fresh buds, bees head back out.
        for (final s in spots) {
          s.bloomed = false;
        }
        for (final b in bees) {
          _sendToFlower(b);
        }
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final b in bees) {
      if ((b.pos - p).distance > 34 + ctx.hitPad) continue;
      if (b.state == _B.hovering && b.target != null && !b.target!.bloomed) {
        b
          ..state = _B.pollinating
          ..t = 0
          ..visits += 1;
        blooms++;
        score(cfg.base, 'bee-${bees.indexOf(b)}-${b.visits}', b.pos);
        fx.burst(b.pos + const Offset(0, 20), colors: const [Ink.yellow, Ink.gold], count: 10, speed: 50);
        ctx.onSfx(Sfx.collect);
      }
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    c.save();
    c.translate(60, 60);
    Nature.sun(c, 28);
    c.restore();
    c.save();
    c.translate(260, 60);
    Nature.cloud(c, 110);
    c.restore();
    groundBand(c, const Rect.fromLTRB(0, 545, 360, 620), Ink.mint, seed: 8);
    for (final s in spots) {
      c.save();
      c.translate(s.base.dx, s.base.dy);
      Nature.stem(c, 56, seed: s.color + 3);
      Nature.grass(c, 44, seed: s.color);
      c.restore();
    }
  }

  @override
  void paint(Canvas c) {
    for (final s in spots) {
      final sway = wave(time, 1.2, s.base.dx) * 0.05;
      if (s.bloomed) {
        final pop = 0.6 + 0.4 * s.bloomT + bump(s.bloomT) * 0.25;
        sprite(
          c,
          'bee-bloom-${s.color}',
          s.head,
          (c) => Nature.flower(c, _beeFlowerColors[s.color], r: 24, seed: s.color),
          scale: pop,
          rotation: sway,
        );
      } else {
        sprite(
          c,
          'bee-bud-${s.color}',
          s.head,
          (c) => Nature.bud(c, _beeFlowerColors[s.color], r: 15, seed: s.color),
          rotation: sway,
        );
      }
    }
    for (final b in bees) {
      final left = b.state == _B.flying && b.to.dx < b.from.dx;
      final flap = 0.55 + 0.45 * wave(time, 40).abs();
      c.save();
      c.translate(b.pos.dx, b.pos.dy);
      final s = ctx.simple ? 1.6 : 1.35;
      c.scale(left ? -s : s, s);
      if (b.state == _B.pollinating) c.rotate(wave(b.t, 30) * 0.15);
      Critters.beeWings(c, fx.reduced ? 1 : flap);
      SpriteCache.draw(c, 'bee', Critters.bee);
      c.restore();
      if (b.state == _B.hovering && ((time * 2 + b.pos.dx) % 2) < 1) {
        Pen.plus(c, b.pos + const Offset(28, -24), 4, Ink.gold);
      }
    }
  }

  @override
  String get progressText => tr.progBlooms(blooms);

  @override
  void paintProgressIcon(Canvas c, Size s) {
    c.save();
    c.translate(s.width / 2, s.height / 2 + 3);
    c.scale(s.width / 46);
    Critters.beeWings(c, 1);
    SpriteCache.draw(c, 'bee', Critters.bee);
    c.restore();
  }
}

final busyBeeGame = GameDefinition(
  gameId: 'busy_bee_garden',
  name: (l) => l.gameBusyBeeName,
  objective: (l) => l.gameBusyBeeGoal,
  instructions: (l) => l.gameBusyBeeHowTo,
  interactionType: Interaction.tap,
  accent: Ink.yellow,
  scoreConfig: const ScoreConfig(base: 3, bonus: 6),
  assetManifest: const ['bee', 'bud', 'flower', 'sun'],
  create: BusyBeeScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.3, 0.7, (c) => Nature.flower(c, Ink.pink, r: 20));
    Thumb.put(c, s, 0.7, 0.75, (c) => Nature.bud(c, Ink.purple));
    Thumb.put(c, s, 0.62, 0.38, (c) {
      Critters.beeWings(c, 1);
      Critters.bee(c);
    }, scale: 1.1);
    Thumb.put(c, s, 0.12, 0.22, (c) => Nature.sun(c, 16, face: false));
  },
);
