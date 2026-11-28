import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

enum _P { show, cover, shuffle, choose, reveal }

const _cloth = Color(0xFFE8F4E0);

/// A ball hides under one of three identical cups; the cups swap places
/// slowly, then the child taps the cup they think hides the ball.
class CupShuffleScene extends GameScene {
  CupShuffleScene(this.cfg);
  final ScoreConfig cfg;

  static const slots = [Offset(76, 400), Offset(180, 400), Offset(284, 400)];
  static const _liftH = 78.0;

  /// slotOf[cup] = which slot that cup is standing on.
  final slotOf = [0, 1, 2];
  final _lift = [0.0, 0.0, 0.0];
  int ballCup = 1;
  int wins = 0, _round = 0;

  _P _phase = _P.show;
  double _t = 0;
  int _swapsLeft = 0, _a = 0, _b = 1;
  int? _picked;
  bool _revealedBall = false;

  /// Slow, gentle swaps (even slower in little-kid mode).
  double get _swapDur => ctx.simple ? 1.35 : 1.05;

  @visibleForTesting
  String get debugPhase => _phase.name;
  @visibleForTesting
  Offset get debugBallCupAt => cupAt(ballCup);
  @visibleForTesting
  List<Offset> get debugCupPositions => [for (var i = 0; i < 3; i++) cupAt(i)];

  @override
  void setup() => _startRound();

  void _startRound() {
    _round++;
    _phase = _P.show;
    _t = 0;
    _picked = null;
    _revealedBall = false;
  }

  /// Where cup [i] is right now (mid-swap cups travel along arcs).
  Offset cupAt(int i) {
    final home = slots[slotOf[i]];
    if (_phase != _P.shuffle || (i != _a && i != _b)) return home;
    final k = Flight.ease((_t / _swapDur).clamp(0.0, 1.0));
    final other = slots[slotOf[i == _a ? _b : _a]];
    final p = Offset.lerp(home, other, k)!;
    // One cup passes behind (up), the other in front (down).
    return p + Offset(0, (i == _a ? -46 : 22) * bump(k));
  }

  @override
  void tick(double dt) {
    _t += dt;
    final up = dt / 0.4;
    switch (_phase) {
      case _P.show:
        _lift[ballCup] = (_lift[ballCup] + up).clamp(0, 1);
        if (_t > 1.7) _go(_P.cover);
      case _P.cover:
        for (var i = 0; i < 3; i++) {
          _lift[i] = (_lift[i] - up).clamp(0, 1);
        }
        if (_t > 0.6) {
          _swapsLeft = (ctx.simple ? 2 : 3) + (_round ~/ 2).clamp(0, ctx.simple ? 2 : 4);
          _nextSwap();
        }
      case _P.shuffle:
        if (_t >= _swapDur + 0.18) {
          final s = slotOf[_a];
          slotOf[_a] = slotOf[_b];
          slotOf[_b] = s;
          _swapsLeft--;
          _swapsLeft > 0 ? _nextSwap() : _go(_P.choose);
        }
      case _P.choose:
        break;
      case _P.reveal:
        final picked = _picked!;
        _lift[picked] = (_lift[picked] + up).clamp(0, 1);
        // After a wrong guess, gently show where the ball really was.
        if (picked != ballCup && _t > 0.8) {
          if (!_revealedBall) {
            _revealedBall = true;
            ctx.onSfx(Sfx.soft);
          }
          _lift[ballCup] = (_lift[ballCup] + up).clamp(0, 1);
        }
        if (_t > (picked == ballCup ? 1.5 : 2.2) && !ended) {
          for (var i = 0; i < 3; i++) {
            _lift[i] = 0;
          }
          _startRound();
        }
    }
  }

  void _go(_P p) {
    _phase = p;
    _t = 0;
  }

  void _nextSwap() {
    _a = rng.nextInt(3);
    _b = (_a + 1 + rng.nextInt(2)) % 3;
    ctx.onSfx(Sfx.whoosh);
    _go(_P.shuffle);
  }

  @override
  void onTap(Offset p) {
    if (_phase != _P.choose || ended) return;
    for (var i = 0; i < 3; i++) {
      final at = cupAt(i);
      final r = Rect.fromCenter(center: at, width: 96, height: 112).inflate(ctx.hitPad);
      if (!r.contains(p)) continue;
      _picked = i;
      _go(_P.reveal);
      if (i == ballCup) {
        wins++;
        score(cfg.base, 'cup-$_round', at + const Offset(0, -70));
        ctx.onSfx(Sfx.cheer);
        fx.confetti(at + const Offset(0, -20));
      } else {
        fx.floatText(at + const Offset(0, -70), tr.gameNotHere);
        ctx.onSfx(Sfx.pop);
      }
      return;
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    // Striped wallpaper band and a table with a cloth.
    for (var x = 0.0; x < 360; x += 40) {
      c.drawRect(Rect.fromLTWH(x, 0, 20, 300), Pen.fillPaint(Ink.blushPink.withValues(alpha: 0.6)));
    }
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-10, 300, 380, 200), 18),
      fill: _cloth,
      solid: true,
      hatch: Ink.mint,
      seed: 3,
    );
    final scallops = Path()..moveTo(-10, 480);
    for (var x = -10.0; x < 370; x += 38) {
      scallops.quadraticBezierTo(x + 19, 512, x + 38, 480);
    }
    scallops
      ..lineTo(370, 470)
      ..lineTo(-10, 470)
      ..close();
    Pen.shape(c, scallops, fill: Ink.tint(Ink.mint, 0.5), solid: true, hatch: Ink.mint, seed: 5, width: 2);
    for (final x in [40.0, 320.0]) {
      Pen.shape(
        c,
        Pen.rrect(Rect.fromLTWH(x - 9, 500, 18, 120), 4),
        fill: Ink.brown,
        solid: true,
        hatch: Ink.shade(Ink.brown, 0.2),
        seed: x.round(),
      );
    }
    // Sign board for the hint text.
    Pen.shape(
      c,
      Pen.rrect(Rect.fromCenter(center: const Offset(180, 110), width: 280, height: 74), 18),
      fill: Ink.paperWarm,
      solid: true,
      seed: 7,
      width: 2.6,
    );
  }

  static void _cup(Canvas c) {
    final body = Path()
      ..moveTo(-28, -44)
      ..quadraticBezierTo(0, -52, 28, -44)
      ..lineTo(42, 40)
      ..quadraticBezierTo(0, 50, -42, 40)
      ..close();
    Pen.shape(c, body, fill: Ink.coral, solid: true, hatch: Ink.shade(Ink.coral, 0.12), seed: 4, width: 2.6);
    final band = Path()
      ..moveTo(-36, 4)
      ..quadraticBezierTo(0, 10, 36, 4)
      ..lineTo(38, 18)
      ..quadraticBezierTo(0, 25, -38, 18)
      ..close();
    Pen.shape(c, band, fill: Ink.yellow, solid: true, hatch: Ink.gold, seed: 6, width: 2);
    for (final x in [-18.0, 0.0, 18.0]) {
      Pen.dot(c, Offset(x, 13), 3, Ink.white);
    }
    c.drawLine(const Offset(-18, -34), const Offset(-26, 0), Pen.inkPaint(Ink.white.withValues(alpha: 0.7), 4));
  }

  static void _ball(Canvas c) {
    Pen.shape(c, Pen.circle(Offset.zero, 18), fill: Ink.blue, solid: true, hatch: Ink.shade(Ink.blue, 0.15), seed: 2);
    Pen.twinkle(c, const Offset(-6, -6), 5, Ink.white);
    Pen.face(c, const Offset(0, 3), 16);
  }

  @override
  void paint(Canvas c) {
    final hint = switch (_phase) {
      _P.show => tr.gameWatchBall,
      _P.cover || _P.shuffle => tr.gameKeepWatching,
      _P.choose => tr.gameWhereBall,
      _P.reveal => _picked == ballCup ? tr.gameFoundIt : tr.gameItWasHere,
    };
    Pen.text(c, hint, const Offset(180, 110), size: 26, maxWidth: 300);

    // Shadows, then the ball, then the cups on top so a lowered cup hides it.
    for (var i = 0; i < 3; i++) {
      final at = cupAt(i);
      c.drawOval(
        Rect.fromCenter(center: Offset(at.dx, slots[0].dy + 46), width: 92 - _lift[i] * 20, height: 16),
        Pen.fillPaint(Ink.navy.withValues(alpha: 0.12)),
      );
    }
    sprite(c, 'cup-ball', cupAt(ballCup) + const Offset(0, 26), _ball, scale: ctx.simple ? 1.15 : 1);
    // The front-passing cup is drawn last during a swap.
    final order = [0, 1, 2]..sort((x, y) => cupAt(x).dy.compareTo(cupAt(y).dy));
    for (final i in order) {
      final lift = Flight.ease(_lift[i]) * _liftH;
      sprite(c, 'cup', cupAt(i) - Offset(0, lift), _cup, scale: ctx.simple ? 1.1 : 1);
    }
    if (_phase == _P.choose) {
      // Gentle bouncing arrows invite a tap.
      for (var i = 0; i < 3; i++) {
        final at = cupAt(i) + Offset(0, -78 + wave(time, 4, i.toDouble()) * 5);
        c.drawPath(
          Pen.poly([at + const Offset(-9, -8), at + const Offset(9, -8), at + const Offset(0, 4)]),
          Pen.fillPaint(Ink.navySoft.withValues(alpha: 0.6)),
        );
      }
    }
  }

  @override
  String get progressText => tr.progFound(wins);

  @override
  void paintProgressIcon(Canvas c, Size s) => sprite(c, 'cup', s.center(Offset.zero), _cup, scale: s.width / 100);
}

final cupShuffleGame = GameDefinition(
  gameId: 'cup_shuffle',
  name: (l) => l.gameCupShuffleName,
  objective: (l) => l.gameCupShuffleGoal,
  instructions: (l) => l.gameCupShuffleHowTo,
  interactionType: Interaction.tap,
  accent: Ink.coral,
  scoreConfig: const ScoreConfig(base: 6, bonus: 6),
  assetManifest: const ['cup', 'ball', 'table'],
  create: CupShuffleScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s, wash: Ink.sand);
    Thumb.put(
      c,
      s,
      0.5,
      1.0,
      (c) => Pen.shape(
        c,
        Pen.rrect(const Rect.fromLTWH(-200, -34, 400, 44), 8),
        fill: _cloth,
        solid: true,
        hatch: Ink.mint,
      ),
    );
    for (final (x, lift) in [(0.22, 0.0), (0.5, 26.0), (0.78, 0.0)]) {
      if (lift > 0) Thumb.put(c, s, x, 0.72, CupShuffleScene._ball, scale: 0.75);
      Thumb.put(c, s, x, 0.55 - lift / 112, CupShuffleScene._cup, scale: 0.62);
    }
  },
);
