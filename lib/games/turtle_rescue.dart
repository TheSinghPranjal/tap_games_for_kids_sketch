import 'common.dart';

const _shells = [Ink.leaf, Ink.orange, Ink.purple, Ink.blue];

enum _T { waiting, swimming, celebrating, hiding }

class _Turtle {
  _Turtle(this.id, this.pos, this.vx, this.color);
  final String id;
  Offset pos;
  double vx;
  final int color;
  _T state = _T.waiting;
  double t = 0, angle = 0;
  int spot = -1;
  Offset from = Offset.zero, ctrl = Offset.zero;
}

class TurtleScene extends GameScene {
  TurtleScene(this.cfg);
  final ScoreConfig cfg;

  static const _reef = [Offset(50, 170), Offset(120, 150), Offset(190, 165), Offset(255, 148), Offset(320, 168)];

  final turtles = <_Turtle>[];
  final _bubbles = <Offset>[];
  int rescued = 0;
  double _spawnIn = 0;

  @override
  void setup() {
    for (var i = 0; i < 12; i++) {
      _bubbles.add(Offset(rand(0, 360), rand(200, 620)));
    }
    _spawn();
    _spawn();
  }

  void _spawn() {
    final area = const Rect.fromLTRB(50, 330, 310, 520);
    final p = freeSpot(area, turtles.where((t) => t.state == _T.waiting).map((t) => t.pos), 90);
    turtles.add(
      _Turtle(newId('turtle'), p, (rng.nextBool() ? 1 : -1) * rand(14, 24) * ctx.speed, rng.nextInt(_shells.length)),
    );
  }

  @override
  void tick(double dt) {
    for (var i = 0; i < _bubbles.length; i++) {
      var b = _bubbles[i] + Offset(wave(time, 2, i.toDouble()) * 10 * dt, -30 * dt);
      if (b.dy < 190) b = Offset(rand(0, 360), 620);
      _bubbles[i] = b;
    }
    for (final t in turtles) {
      t.t += dt;
      switch (t.state) {
        case _T.waiting:
          t.pos += Offset(t.vx * dt, wave(time, 1.5, t.pos.dx) * 6 * dt);
          if (t.pos.dx < 40 || t.pos.dx > 320) t.vx = -t.vx;
          t.angle = t.vx < 0 ? 3.14159 : 0;
        case _T.swimming:
          final dur = 2.0 / ctx.speed;
          final k = Flight.ease((t.t / dur).clamp(0, 1));
          final to = _reef[t.spot];
          final prev = t.pos;
          t.pos = t.from * ((1 - k) * (1 - k)) + t.ctrl * (2 * k * (1 - k)) + to * (k * k);
          if ((t.pos - prev).distance > 0.1) t.angle = (t.pos - prev).direction;
          if (t.t >= dur) {
            t
              ..state = _T.celebrating
              ..t = 0;
            // Safe at the reef: score once per turtle.
            rescued++;
            score(cfg.base, t.id, t.pos + const Offset(0, -30));
            ctx.onSfx(Sfx.cheer);
            fx.hearts(t.pos + const Offset(0, -20));
          }
        case _T.celebrating:
          t.angle = -1.5708 + wave(t.t, 10) * 0.3;
          if (t.t > 1.0) {
            t
              ..state = _T.hiding
              ..t = 0;
          }
        case _T.hiding:
          break;
      }
    }
    turtles.removeWhere((t) => t.state == _T.hiding && t.t > 0.6);
    if (!ended && turtles.where((t) => t.state == _T.waiting).length < (ctx.simple ? 2 : 3)) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(0.8, 1.5);
      }
    }
  }

  @override
  void onTap(Offset p) {
    final busy = turtles.where((t) => t.state != _T.waiting).map((t) => t.spot).toSet();
    final free = [
      for (var i = 0; i < _reef.length; i++)
        if (!busy.contains(i)) i,
    ];
    if (free.isEmpty) return;
    for (final t in turtles) {
      if (t.state != _T.waiting || (t.pos - p).distance > 36 + ctx.hitPad) continue;
      free.sort((a, b) => (_reef[a] - t.pos).distance.compareTo((_reef[b] - t.pos).distance));
      t
        ..state = _T.swimming
        ..t = 0
        ..spot = free.first
        ..from = t.pos
        ..ctrl = Offset(t.pos.dx + (t.pos.dx < 180 ? 80 : -80), (t.pos.dy + _reef[free.first].dy) / 2);
      ctx.onSfx(Sfx.whoosh);
      fx.burst(t.pos, colors: const [Ink.white, Ink.sky], count: 6, speed: 50);
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    final r = GameScene.worldRect;
    c.drawRect(r, Paint()..color = Ink.tint(Ink.sky, 0.7));
    Paper.gridOverlay(c, r, alpha: 0.3);
    final ink = Pen.inkPaint(Ink.white.withValues(alpha: 0.8), 2);
    final rnd = Random(2);
    for (var i = 0; i < 12; i++) {
      final o = Offset(rnd.nextDouble() * 360, 200 + rnd.nextDouble() * 360);
      c.drawArc(Rect.fromCenter(center: o, width: 30, height: 8), 3.4, 2.6, false, ink);
    }
    // Coral reef across the top: the safe place.
    Pen.shape(
      c,
      Pen.poly(const [Offset(-4, -4), Offset(364, -4), Offset(364, 190), Offset(-4, 200)]),
      fill: Ink.sand,
      seed: 3,
    );
    for (final (x, color, h) in [
      (20.0, Ink.coral, 70.0),
      (88.0, Ink.pink, 54.0),
      (160.0, Ink.orange, 64.0),
      (225.0, Ink.purple, 56.0),
      (290.0, Ink.coral, 68.0),
      (350.0, Ink.yellow, 50.0),
    ]) {
      c.save();
      c.translate(x, 205);
      Nature.coral(c, color, h: h, seed: x.round());
      c.restore();
    }
    for (final o in _reef) {
      Pen.shape(
        c,
        Pen.oval(o + const Offset(0, 8), 26, 10),
        fill: Ink.tint(Ink.coral, 0.6),
        seed: o.dx.round(),
        width: 1.6,
        doubleLine: false,
      );
    }
    // Sea floor.
    groundBand(c, const Rect.fromLTRB(0, 560, 360, 620), Ink.sand, seed: 4);
    for (final x in [30.0, 110.0, 250.0, 330.0]) {
      c.save();
      c.translate(x, 590);
      Nature.seaweed(c, 70 + x % 30, seed: x.round());
      c.restore();
    }
    for (final (o, w) in [(const Offset(180, 592), 34.0), (const Offset(70, 600), 24.0)]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.rock(c, w, seed: w.round());
      c.restore();
    }
  }

  @override
  void paint(Canvas c) {
    final bub = Pen.inkPaint(Ink.white, 1.6);
    for (final (i, b) in _bubbles.indexed) {
      c.drawCircle(b, 3.0 + i % 3, bub);
    }
    for (final t in turtles) {
      final paddle = wave(time, t.state == _T.swimming ? 9 : 4, t.pos.dx) * 0.3;
      final hop = t.state == _T.celebrating ? bump((t.t * 2) % 1) * 12 : 0.0;
      final opacity = t.state == _T.hiding ? (1 - t.t / 0.6).clamp(0.0, 1.0) : 1.0;
      final s = ctx.simple ? 1.4 : 1.2;
      c.save();
      c.translate(t.pos.dx, t.pos.dy - hop);
      c.rotate(t.angle);
      c.scale(s);
      if (opacity < 1) c.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, opacity));
      Critters.turtle(c, _shells[t.color], seed: t.color + 1, paddle: fx.reduced ? 0 : paddle);
      if (opacity < 1) c.restore();
      c.restore();
    }
  }

  @override
  String get progressText => tr.progTurtles(rescued);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'turtle-icon', s.center(Offset.zero), (c) => Critters.turtle(c, _shells[0]), scale: s.width / 70);
}

final turtleRescueGame = GameDefinition(
  gameId: 'tiny_turtle_rescue',
  name: (l) => l.gameTurtleRescueName,
  objective: (l) => l.gameTurtleRescueGoal,
  instructions: (l) => l.gameTurtleRescueHowTo,
  interactionType: Interaction.tap,
  accent: Ink.mint,
  scoreConfig: const ScoreConfig(base: 3, bonus: 3),
  assetManifest: const ['turtle', 'coral', 'seaweed', 'bubble', 'rock'],
  create: TurtleScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, Ink.tint(Ink.sky, 0.7));
    Thumb.put(
      c,
      s,
      0.5,
      0.0,
      (c) => Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-200, -20, 400, 46), 2), fill: Ink.sand),
    );
    Thumb.put(c, s, 0.2, 0.42, (c) => Nature.coral(c, Ink.coral, h: 40));
    Thumb.put(c, s, 0.55, 0.65, (c) => Critters.turtle(c, Ink.leaf), rotation: -0.6);
    Thumb.put(c, s, 0.85, 0.42, (c) => Nature.coral(c, Ink.pink, h: 34, seed: 2));
  },
);
