import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

const _ballColors = [Ink.coral, Ink.blue, Ink.yellow];

class _Ball {
  _Ball(this.id, this.pos, this.vel, this.color);
  final String id;
  Offset pos;
  Offset vel;
  final int color;
  bool held = false;
}

/// Coloured balls bounce around the playroom; drag each one into the
/// bucket of the same colour.
class BouncyBallScene extends GameScene {
  BouncyBallScene(this.cfg);
  final ScoreConfig cfg;

  static const floorY = 450.0;
  static const bucketY = 548.0;
  static const _gravity = 620.0;

  final _balls = <_Ball>[];
  _Ball? _held;
  Offset _grab = Offset.zero;
  double _spawnIn = 0.4;
  int sorted = 0;
  late final List<double> _bucketBounce;

  int get _bucketCount => ctx.simple ? 2 : 3;
  double get _r => ctx.simple ? 28 : 24;
  int get _max => ctx.simple ? 2 : 3;

  Offset bucketAt(int i) => Offset(360 / (_bucketCount + 1) * (i + 1), bucketY);

  @visibleForTesting
  List<(Offset, int)> get debugBalls => [for (final b in _balls) (b.pos, b.color)];

  @override
  void setup() => _bucketBounce = List.filled(_bucketCount, 1);

  void _spawn() {
    final x = rand(60, 300);
    _balls.add(
      _Ball(
        newId('ball'),
        Offset(x, -_r),
        Offset((x < 180 ? 1 : -1) * rand(50, 110), 60) * ctx.speed,
        rng.nextInt(_bucketCount),
      ),
    );
  }

  @override
  void tick(double dt) {
    for (var i = 0; i < _bucketBounce.length; i++) {
      _bucketBounce[i] = (_bucketBounce[i] + dt * 3).clamp(0, 1);
    }
    for (final b in _balls) {
      if (b.held) continue;
      b.vel += Offset(0, _gravity * ctx.speed * ctx.speed * dt);
      b.pos += b.vel * dt;
      // Bounce on the floor line above the buckets, always back up to a
      // comfy height so balls stay easy to grab.
      if (b.pos.dy > floorY - _r && b.vel.dy > 0) {
        b.pos = Offset(b.pos.dx, floorY - _r);
        b.vel = Offset(b.vel.dx, -rand(470, 560) * ctx.speed);
      }
      if ((b.pos.dx < _r && b.vel.dx < 0) || (b.pos.dx > 360 - _r && b.vel.dx > 0)) {
        b.vel = Offset(-b.vel.dx, b.vel.dy);
      }
    }
    if (!ended && _balls.length < _max) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(1.4, 2.2) / ctx.speed;
      }
    }
  }

  int? _bucketUnder(Offset p) {
    for (var i = 0; i < _bucketCount; i++) {
      if (Rect.fromCenter(center: bucketAt(i), width: 100, height: 110).inflate(ctx.hitPad).contains(p)) return i;
    }
    return null;
  }

  @override
  bool onDragStart(Offset p) {
    if (ended) return false;
    _Ball? best;
    var bestD = _r + 16 + ctx.hitPad;
    for (final b in _balls) {
      final d = (b.pos - p).distance;
      if (d < bestD) {
        bestD = d;
        best = b;
      }
    }
    if (best == null) return false;
    best.held = true;
    _held = best;
    _grab = best.pos - p;
    ctx.onSfx(Sfx.tap);
    return true;
  }

  @override
  void onDragMove(Offset p) => _held?.pos = p + _grab;

  @override
  void onDragEnd(Offset p) {
    final b = _held;
    _held = null;
    if (b == null) return;
    b.held = false;
    final i = _bucketUnder(b.pos);
    if (i == null || ended) {
      b.vel = Offset.zero; // let go in the air: it just carries on bouncing
      return;
    }
    if (i == b.color) {
      _balls.remove(b);
      sorted++;
      score(cfg.base, b.id, bucketAt(i) + const Offset(0, -60));
      ctx.onSfx(Sfx.collect);
      final color = b.color, r = _r;
      fly(
        b.pos,
        bucketAt(i) + const Offset(0, -6),
        0.3,
        (c, pos, t) => _drawBall(c, pos, color, r * (1 - t * 0.3)),
        arc: -20,
        trail: false,
        onArrive: () {
          _bucketBounce[i] = 0;
          fx.burst(bucketAt(i) + const Offset(0, -30), colors: [_ballColors[i], Ink.yellow], count: 8);
        },
      );
    } else {
      // Wrong colour: the ball hops back out to try again.
      fx.floatText(bucketAt(i) + const Offset(0, -60), tr.gameOtherBucket);
      ctx.onSfx(Sfx.soft);
      b
        ..pos = Offset(b.pos.dx, floorY - _r - 10)
        ..vel = Offset((180 - b.pos.dx).sign * 80, -480) * ctx.speed;
    }
  }

  @override
  void cancelDrag() {
    _held?.held = false;
    _held = null;
  }

  static void _drawBall(Canvas c, Offset at, int color, double r) => sprite(c, 'bouncy-$color', at, (c) {
    Pen.shape(
      c,
      Pen.circle(Offset.zero, 24),
      fill: _ballColors[color],
      solid: true,
      hatch: Ink.shade(_ballColors[color], 0.15),
      seed: color + 2,
    );
    c.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: 24),
      -0.4,
      2.2,
      false,
      Pen.inkPaint(Ink.white.withValues(alpha: 0.6), 3),
    );
    Pen.twinkle(c, const Offset(-9, -9), 6, Ink.white);
    Pen.face(c, const Offset(0, 3), 22);
  }, scale: r / 24);

  static void _bucket(Canvas c, Color color) {
    Pen.stroke(
      c,
      Path()..addArc(Rect.fromCenter(center: const Offset(0, -28), width: 76, height: 60), 3.3, 2.8),
      width: 3,
      seed: 4,
    );
    final body = Pen.poly(const [Offset(-42, -28), Offset(42, -28), Offset(32, 40), Offset(-32, 40)]);
    Pen.shape(c, body, fill: color, solid: true, hatch: Ink.shade(color, 0.15), seed: 3);
    Pen.shape(c, Pen.oval(const Offset(0, -28), 42, 9), fill: Ink.shade(color, 0.35), solid: true, seed: 5, width: 2.2);
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-36, 0, 72, 12), 4), fill: Ink.white, solid: true, width: 1.8, seed: 6);
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    // Playroom: wall stripes, a rug floor and a shelf for the buckets.
    for (var x = 0.0; x < 360; x += 36) {
      c.drawRect(Rect.fromLTWH(x, 0, 18, floorY), Pen.fillPaint(Ink.tint(Ink.sky, 0.18)));
    }
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-10, floorY, 380, 190), 4),
      fill: Ink.sand,
      solid: true,
      hatch: Ink.brown.withValues(alpha: 0.3),
      seed: 4,
    );
    Pen.line(c, const Offset(0, floorY), const Offset(360, floorY), width: 3);
    for (final (o, w) in [(const Offset(70, 90), 80.0), (const Offset(280, 140), 70.0)]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.cloud(c, w, seed: w.round());
      c.restore();
    }
  }

  @override
  void paint(Canvas c) {
    // Shadows on the floor line help show how high each ball is.
    for (final b in _balls) {
      final k = ((floorY - b.pos.dy) / 300).clamp(0.0, 1.0);
      c.drawOval(
        Rect.fromCenter(center: Offset(b.pos.dx, floorY + 4), width: _r * 2 * (1 - k * 0.5), height: 8),
        Pen.fillPaint(Ink.navy.withValues(alpha: 0.16 - k * 0.08)),
      );
    }
    for (var i = 0; i < _bucketCount; i++) {
      final (sx, sy) = squash(_bucketBounce[i]);
      final glow = _held != null && _held!.color == i;
      if (glow) c.drawCircle(bucketAt(i), 60, Pen.fillPaint(_ballColors[i].withValues(alpha: 0.25)));
      sprite(
        c,
        'bouncy-bucket-$i',
        bucketAt(i),
        (c) => _bucket(c, _ballColors[i]),
        sx: sx,
        sy: sy,
        scale: ctx.simple ? 1.1 : 1,
      );
    }
    for (final b in _balls) {
      // Squash a little when touching the floor.
      final squish = b.held ? 1.1 : 1.0;
      _drawBall(c, b.pos, b.color, _r * squish);
    }
  }

  @override
  String get progressText => tr.progBalls(sorted);

  @override
  void paintProgressIcon(Canvas c, Size s) => _drawBall(c, s.center(Offset.zero), 0, s.width * 0.4);
}

final bouncyBallGame = GameDefinition(
  gameId: 'bouncy_ball_catch',
  name: (l) => l.gameBouncyBallsName,
  objective: (l) => l.gameBouncyBallsGoal,
  instructions: (l) => l.gameBouncyBallsHowTo,
  interactionType: Interaction.drag,
  accent: Ink.coral,
  scoreConfig: const ScoreConfig(base: 4, bonus: 8),
  assetManifest: const ['bouncy-ball', 'bucket'],
  create: BouncyBallScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.3, 0.84, (c) => BouncyBallScene._bucket(c, Ink.coral), scale: 0.5);
    Thumb.put(c, s, 0.7, 0.84, (c) => BouncyBallScene._bucket(c, Ink.blue), scale: 0.5);
    for (final (x, y, col) in [(0.22, 0.3, 1), (0.55, 0.42, 0), (0.85, 0.22, 2)]) {
      Thumb.put(c, s, x, y, (c) {
        Pen.shape(c, Pen.circle(Offset.zero, 24), fill: _ballColors[col], solid: true);
        Pen.face(c, const Offset(0, 3), 22);
      }, scale: 0.7);
    }
  },
);
