import 'common.dart';

const _balloonColors = [Ink.coral, Ink.yellow, Ink.blue, Ink.mint, Ink.purple, Ink.pink, Ink.orange];

class _Balloon {
  _Balloon(this.id, this.pos, this.vy, this.color, this.shape, this.phase);
  final String id;
  Offset pos;
  final double vy, phase;
  final int color, shape;
  bool popped = false;
}

class BalloonScene extends GameScene {
  BalloonScene(this.cfg);
  final ScoreConfig cfg;

  final balloons = <_Balloon>[];
  int popped = 0;
  double _spawnIn = 0;

  @override
  void setup() {
    for (var i = 0; i < 3; i++) {
      _spawn(y: rand(300, 560));
    }
  }

  void _spawn({double y = 690}) {
    final xs = balloons.where((b) => b.pos.dy > 450).map((b) => b.pos.dx).toList();
    var x = rand(50, 310);
    for (var i = 0; i < 8 && xs.any((o) => (o - x).abs() < 70); i++) {
      x = rand(50, 310);
    }
    balloons.add(
      _Balloon(
        newId('balloon'),
        Offset(x, y),
        rand(45, 85) * ctx.speed,
        rng.nextInt(_balloonColors.length),
        rng.nextInt(3),
        rand(0, 6),
      ),
    );
  }

  @override
  void tick(double dt) {
    for (final b in balloons) {
      b.pos += Offset(wave(time, 1.3, b.phase) * 14 * dt, -b.vy * dt);
    }
    balloons.removeWhere((b) => b.popped || b.pos.dy < -70);
    if (!ended && balloons.length < (ctx.simple ? 4 : 6)) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(0.4, 0.9);
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final b in balloons.reversed) {
      if (b.popped || (b.pos - p).distance > 34 + ctx.hitPad) continue;
      b.popped = true;
      popped++;
      score(cfg.base, b.id, b.pos);
      ctx.onSfx(Sfx.pop); // a soft pop, never a bang
      fx.confetti(b.pos, colors: [_balloonColors[b.color], Ink.yellow, Ink.blue]);
      fx.ring(b.pos, radius: 34, color: _balloonColors[b.color]);
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    for (final (o, w) in [
      (const Offset(80, 200), 110.0),
      (const Offset(280, 330), 90.0),
      (const Offset(120, 470), 80.0),
    ]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.cloud(c, w, seed: w.round());
      c.restore();
    }
    // Bunting across the top.
    final line = Path()
      ..moveTo(-4, 30)
      ..quadraticBezierTo(180, 80, 364, 30);
    Pen.stroke(c, line, width: 1.8, seed: 2);
    for (var i = 0; i < 9; i++) {
      final x = 20 + i * 40.0;
      final t = x / 360;
      final y = 30 + 4 * 25 * t * (1 - t) * 2;
      Pen.shape(
        c,
        Pen.poly([Offset(x - 12, y - 2), Offset(x + 12, y - 2), Offset(x, y + 22)]),
        fill: _balloonColors[i % _balloonColors.length],
        seed: i,
        width: 1.8,
        doubleLine: false,
      );
    }
    // Streamers.
    for (final x in [30.0, 330.0]) {
      final s = Path()..moveTo(x, 34);
      for (var y = 34.0; y < 160; y += 24) {
        s.quadraticBezierTo(x + (y % 48 == 34 ? 12 : -12), y + 12, x, y + 24);
      }
      Pen.stroke(c, s, ink: x < 100 ? Ink.pink : Ink.mint, width: 4, seed: x.round());
    }
    final r = Random(3);
    for (var i = 0; i < 26; i++) {
      final o = Offset(r.nextDouble() * 360, 120 + r.nextDouble() * 480);
      c.drawRect(
        Rect.fromCenter(center: o, width: 5, height: 3),
        Paint()..color = _balloonColors[i % 7].withValues(alpha: 0.5),
      );
    }
  }

  @override
  void paint(Canvas c) {
    for (final b in balloons) {
      sprite(
        c,
        'balloon-${b.color}-${b.shape}',
        b.pos,
        (c) => Props.balloon(c, _balloonColors[b.color], shape: b.shape, seed: b.color + 1),
        scale: ctx.simple ? 1.25 : 1.05,
        rotation: wave(time, 1.3, b.phase) * 0.08,
      );
    }
  }

  @override
  String get progressText => tr.progBalloons(popped);

  @override
  void paintProgressIcon(Canvas c, Size s) => sprite(
    c,
    'balloon-0-0',
    s.center(const Offset(0, -4)),
    (c) => Props.balloon(c, _balloonColors[0], seed: 1),
    scale: s.width / 90,
  );
}

final balloonParadeGame = GameDefinition(
  gameId: 'balloon_tap_parade',
  name: (l) => l.gameBalloonParadeName,
  objective: (l) => l.gameBalloonParadeGoal,
  instructions: (l) => l.gameBalloonParadeHowTo,
  interactionType: Interaction.tap,
  accent: Ink.coral,
  assetManifest: const ['balloon', 'bunting', 'streamer', 'cloud'],
  create: BalloonScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.25, 0.45, (c) => Props.balloon(c, Ink.coral), scale: 0.75);
    Thumb.put(c, s, 0.52, 0.35, (c) => Props.balloon(c, Ink.blue, shape: 1, seed: 2), scale: 0.75);
    Thumb.put(c, s, 0.78, 0.5, (c) => Props.balloon(c, Ink.yellow, shape: 2, seed: 3), scale: 0.75);
  },
);
