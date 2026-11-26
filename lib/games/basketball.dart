import 'dart:math' as math;

import 'common.dart';

enum _Ball { aiming, flying, returning }

class BasketballScene extends GameScene {
  BasketballScene(this.cfg);
  final ScoreConfig cfg;

  static const home = Offset(180, 500);
  static const hoops = [Offset(72, 210), Offset(180, 160), Offset(288, 210)];
  static const _hoopColors = [Ink.coral, Ink.blue, Ink.mint];
  static const shootButton = Rect.fromLTWH(105, 548, 150, 56);
  static const maxAngle = 0.72;

  var _state = _Ball.aiming;
  double aim = 0, _sweepT = 0, _t = 0;
  int shots = 0, baskets = 0;
  int? _target;
  Offset ball = home, _from = home, _ctrl = home, _to = home;
  double _flightDur = 1;
  final _swish = [0.0, 0.0, 0.0];
  double _press = 0;

  double get _tolerance => ctx.simple ? 0.2 : 0.13;

  static double angleTo(Offset hoop) => math.atan2(hoop.dx - home.dx, home.dy - hoop.dy);

  @override
  void setup() {}

  @override
  void tick(double dt) {
    _press = (_press - dt * 4).clamp(0, 1);
    for (var i = 0; i < 3; i++) {
      _swish[i] = (_swish[i] - dt * 1.6).clamp(0, 1);
    }
    switch (_state) {
      case _Ball.aiming:
        _sweepT += dt * ctx.speed;
        aim = math.sin(_sweepT * 1.7) * maxAngle; // bounded, smooth sweep
      case _Ball.flying:
        _t += dt;
        final k = (_t / _flightDur).clamp(0.0, 1.0);
        ball = _bez(k);
        if (k >= 1) _land();
      case _Ball.returning:
        _t += dt;
        final k = Flight.ease((_t / 0.6).clamp(0, 1));
        ball = Offset.lerp(_from, home, k)! - Offset(0, bump(k) * 30);
        if (k >= 1) {
          ball = home;
          _state = _Ball.aiming;
        }
    }
  }

  Offset _bez(double k) {
    final u = 1 - k;
    return _from * (u * u) + _ctrl * (2 * u * k) + _to * (k * k);
  }

  void _land() {
    final i = _target;
    if (i != null) {
      _swish[i] = 1;
      baskets++;
      score(cfg.base, 'shot-$shots', hoops[i] + const Offset(0, -30));
      ctx.onSfx(Sfx.cheer);
      fx.confetti(hoops[i] + const Offset(0, 20), colors: [_hoopColors[i], Ink.yellow]);
    } else {
      // A miss just gets a cheerful "try again" sparkle.
      fx.floatText(ball, tr.gameSoClose);
      ctx.onSfx(Sfx.soft);
    }
    _state = _Ball.returning;
    _from = ball;
    _t = 0;
  }

  @override
  void onTap(Offset p) {
    if (_state != _Ball.aiming || !shootButton.inflate(10).contains(p)) return;
    // The indicator freezes on the exact angle shown at the moment of the tap.
    final locked = aim;
    _press = 1;
    shots++;
    ctx.onSfx(Sfx.whoosh);
    int? best;
    var bestDiff = _tolerance;
    for (var i = 0; i < hoops.length; i++) {
      final d = (angleTo(hoops[i]) - locked).abs();
      if (d < bestDiff) {
        bestDiff = d;
        best = i;
      }
    }
    _target = best;
    _from = home;
    if (best != null) {
      _to = hoops[best] + const Offset(0, 18); // through the net
      _ctrl = Offset((home.dx + _to.dx) / 2, _to.dy - 170);
    } else {
      final dist = home.dy - 200;
      _to = home + Offset(math.tan(locked) * dist, -dist) + const Offset(0, 60);
      _ctrl = Offset((home.dx + _to.dx) / 2, 40);
    }
    _flightDur = 1.0;
    _t = 0;
    _state = _Ball.flying;
    aim = locked;
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    // Court floor with hand-drawn markings.
    Pen.shape(
      c,
      Pen.poly(const [Offset(-4, 330), Offset(364, 330), Offset(364, 624), Offset(-4, 624)]),
      fill: Ink.tint(Ink.orange, 0.5),
      seed: 3,
      hatchGap: 6,
    );
    Pen.stroke(
      c,
      Path()..addArc(Rect.fromCircle(center: home, radius: 90), math.pi, math.pi),
      ink: Ink.white,
      width: 4,
      seed: 2,
    );
    Pen.line(c, const Offset(0, 420), const Offset(360, 420), ink: Ink.white, width: 3);
    for (var i = 0; i < 3; i++) {
      final h = hoops[i];
      Pen.line(c, h + const Offset(0, -8), Offset(h.dx, 330), ink: Ink.navySoft, width: 5, seed: i);
      c.save();
      c.translate(h.dx, h.dy);
      Props.hoop(c, color: _hoopColors[i]);
      c.restore();
    }
    for (final (o, w) in [(const Offset(60, 60), 90.0), (const Offset(290, 80), 80.0)]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.cloud(c, w);
      c.restore();
    }
  }

  @override
  void paint(Canvas c) {
    for (var i = 0; i < 3; i++) {
      final h = hoops[i];
      c.save();
      c.translate(h.dx, h.dy);
      Props.net(c, bump(_swish[i]));
      c.restore();
    }
    final ballGoingDown = _state == _Ball.flying && _target != null && _t / _flightDur > 0.75;
    void drawBall() => sprite(
      c,
      'basketball',
      ball,
      (c) => Props.basketball(c, 16),
      scale: ctx.simple ? 1.35 : 1.2,
      rotation: _state == _Ball.aiming ? 0 : _t * 8,
    );
    if (ballGoingDown) drawBall(); // behind the rim while it drops through
    for (var i = 0; i < 3; i++) {
      sprite(c, 'rim-$i', hoops[i], (c) => Props.rim(c, color: _hoopColors[i]));
    }
    if (!ballGoingDown) drawBall();
    if (_state == _Ball.aiming) {
      // Dashed direction indicator.
      final dir = Offset(math.sin(aim), -math.cos(aim));
      final dash = Pen.inkPaint(Ink.coral, 4);
      for (var d = 30.0; d < 120; d += 18) {
        c.drawLine(home + dir * d, home + dir * (d + 10), dash);
      }
      final tip = home + dir * 128;
      final n = Offset(-dir.dy, dir.dx);
      c.drawPath(Pen.poly([tip + dir * 10, tip + n * 9, tip - n * 9]), Pen.fillPaint(Ink.coral));
    }
    final s = 1 - _press * 0.08;
    final ready = _state == _Ball.aiming;
    sprite(c, 'shoot-btn-$ready', shootButton.center, (c) {
      final r = Rect.fromCenter(center: Offset.zero, width: shootButton.width, height: shootButton.height);
      Pen.shape(c, Pen.rrect(r, 18), fill: ready ? Ink.blushPink : Ink.white, solid: true, seed: 5, width: 2.6);
      Pen.text(
        c,
        tr.gameShoot,
        Offset.zero,
        size: 24,
        color: ready ? Ink.navy : Ink.navySoft,
        maxWidth: shootButton.width - 16,
      );
    }, scale: s);
  }

  @override
  String get progressText => tr.progBaskets(baskets);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'basketball', s.center(Offset.zero), (c) => Props.basketball(c, 16), scale: s.width / 36);
}

final basketballGame = GameDefinition(
  gameId: 'basketball_hoop_challenge',
  name: (l) => l.gameBasketballName,
  objective: (l) => l.gameBasketballGoal,
  instructions: (l) => l.gameBasketballHowTo,
  interactionType: Interaction.tap,
  accent: Ink.orange,
  scoreConfig: const ScoreConfig(base: 5, bonus: 5),
  assetManifest: const ['basketball', 'hoop', 'net', 'court'],
  create: BasketballScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(
      c,
      s,
      0.5,
      1.0,
      (c) => Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-200, -30, 400, 40), 2), fill: Ink.tint(Ink.orange, 0.5)),
    );
    Thumb.put(c, s, 0.3, 0.5, (c) {
      Props.hoop(c);
      Props.net(c, 0);
      Props.rim(c);
    }, scale: 0.8);
    Thumb.put(c, s, 0.72, 0.45, (c) => Props.basketball(c, 16));
  },
);
