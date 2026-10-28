import 'common.dart';

/// Big leaves: base point, angle and length. Ladybugs crawl base -> tip.
const _leaves = [
  (Offset(30, 560), -0.95, 300.0, Ink.mint),
  (Offset(340, 470), -2.35, 270.0, Ink.leaf),
  (Offset(20, 250), -0.35, 250.0, Ink.leaf),
  (Offset(350, 210), 3.6, 250.0, Ink.mint),
];

enum _L { crawling, flyaway, leaving }

class _Bug {
  _Bug(this.id, this.leaf, this.golden, this.speed);
  final String id;
  final int leaf;
  final bool golden;
  final double speed;
  double along = 0.12; // fraction of the leaf
  _L state = _L.crawling;
  double t = 0;
  Offset pos = Offset.zero;
  double angle = 0;
}

class LadybugScene extends GameScene {
  LadybugScene(this.cfg);
  final ScoreConfig cfg;

  final bugs = <_Bug>[];
  int helped = 0;
  double _spawnIn = 0;

  static Offset _point(int leaf, double f) {
    final (base, a, len, _) = _leaves[leaf];
    // Slight curve along the leaf's midrib.
    return base + Offset.fromDirection(a, len * f) + Offset.fromDirection(a + 1.57, bump(f) * 14);
  }

  void _spawn() {
    final used = bugs.map((b) => b.leaf).toSet();
    final free = [
      for (var i = 0; i < _leaves.length; i++)
        if (!used.contains(i)) i,
    ];
    if (free.isEmpty) return;
    bugs.add(_Bug(newId('bug'), pick(free), rng.nextDouble() < 0.12, rand(0.085, 0.12) * ctx.speed));
  }

  @override
  void setup() {
    _spawn();
    _spawn();
  }

  @override
  void tick(double dt) {
    for (final b in bugs) {
      b.t += dt;
      switch (b.state) {
        case _L.crawling:
          b.along += b.speed * dt / ctx.patience;
          b.pos = _point(b.leaf, b.along);
          final ahead = _point(b.leaf, b.along + 0.02);
          b.angle = (ahead - b.pos).direction + 1.5708;
          if (b.along >= 0.93) {
            // Journey finished: it simply flies off, no penalty.
            b
              ..state = _L.leaving
              ..t = 0;
          }
        case _L.flyaway || _L.leaving:
          if (b.t > 0.3 || b.state == _L.leaving) {
            b.pos += Offset(wave(b.t, 6) * 60, -190) * dt;
            b.angle = wave(b.t, 5) * 0.3;
          }
      }
    }
    bugs.removeWhere((b) => b.pos.dy < -40);
    if (!ended && bugs.where((b) => b.state == _L.crawling).length < (ctx.simple ? 2 : 3)) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(0.8, 1.6);
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final b in bugs) {
      if (b.state != _L.crawling || (b.pos - p).distance > 32 + ctx.hitPad) continue;
      b
        ..state = _L.flyaway
        ..t = 0;
      helped++;
      score(b.golden ? cfg.bonus : cfg.base, b.id, b.pos);
      ctx.onSfx(b.golden ? Sfx.bonus : Sfx.chirp);
      fx.burst(b.pos, colors: b.golden ? const [Ink.gold, Ink.yellow] : const [Ink.coral, Ink.yellow, Ink.white]);
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    groundBand(c, const Rect.fromLTRB(0, 580, 360, 620), Ink.mint, seed: 9);
    for (final (base, a, len, color) in _leaves) {
      c.save();
      c.translate(base.dx, base.dy);
      c.rotate(a);
      Pen.line(c, const Offset(-30, 0), Offset.zero, ink: Ink.leaf, width: 5);
      Nature.leaf(c, len, color: color, width: 0.28, seed: len.round());
      c.restore();
    }
    for (final o in [const Offset(200, 90), const Offset(110, 420)]) {
      Pen.heart(c, o, 7, color: Ink.pink);
    }
    Pen.plus(c, const Offset(300, 60), 6, Ink.gold);
  }

  @override
  void paint(Canvas c) {
    for (final b in bugs) {
      final open = switch (b.state) {
        _L.crawling => 0.0,
        _L.flyaway => (b.t / 0.25).clamp(0.0, 1.0),
        _L.leaving => 1.0,
      };
      final wig = b.state == _L.flyaway && b.t < 0.3 ? wave(b.t, 50) * 0.2 : 0.0;
      final key = 'ladybug-${b.golden}-${(open * 4).round()}';
      if (b.golden && b.state == _L.crawling) {
        c.drawCircle(b.pos, 30, Paint()..color = Ink.gold.withValues(alpha: 0.25));
      }
      sprite(
        c,
        key,
        b.pos,
        (c) => Critters.ladybug(c, golden: b.golden, open: (open * 4).round() / 4),
        scale: ctx.simple ? 1.45 : 1.25,
        rotation: b.angle + wig,
      );
      if (b.state != _L.crawling && !fx.reduced && ((b.t * 10) % 2) < 1) {
        Pen.twinkle(c, b.pos + const Offset(0, 22), 4, Ink.gold);
      }
    }
  }

  @override
  String get progressText => '$helped ladybugs';

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'ladybug-false-0', s.center(const Offset(0, 2)), (c) => Critters.ladybug(c), scale: s.width / 40);
}

final ladybugGame = GameDefinition(
  gameId: 'ladybug_leaf_tap',
  name: 'Ladybug Leaf Tap',
  objective: 'Help ladybugs fly off the leaves!',
  instructions: 'Tap a crawling ladybug to help it fly. Golden ones are extra special!',
  interactionType: Interaction.tap,
  accent: Ink.coral,
  assetManifest: const ['ladybug', 'ladybug-gold', 'leaf'],
  create: LadybugScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.05, 0.9, (c) => Nature.leaf(c, 150, width: 0.3), rotation: -0.4);
    Thumb.put(c, s, 0.42, 0.62, (c) => Critters.ladybug(c), rotation: 1.1);
    Thumb.put(c, s, 0.76, 0.3, (c) => Critters.ladybug(c, golden: true, open: 0.8));
  },
);
