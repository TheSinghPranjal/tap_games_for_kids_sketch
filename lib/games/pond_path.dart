import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

const _water = Color(0xFF4DB3EC);
const _stone = Color(0xFFC9CDD6);
const _shapeNames = ['circle', 'square', 'rectangle', 'rhombus', 'triangle'];

/// Stone outline for each shape, centred, about 60 across.
Path _shape(int shape) => switch (shape) {
  0 => Pen.circle(Offset.zero, 28),
  1 => Pen.rrect(Rect.fromCenter(center: Offset.zero, width: 52, height: 52), 6),
  2 => Pen.rrect(Rect.fromCenter(center: Offset.zero, width: 72, height: 38), 6),
  3 => Pen.poly(const [Offset(0, -32), Offset(34, 0), Offset(0, 32), Offset(-34, 0)]),
  _ => Pen.poly(const [Offset(0, -30), Offset(34, 26), Offset(-34, 26)]),
};

class _Stone {
  _Stone(this.shape, this.rest) : pos = rest;
  final int shape;
  final Offset rest;
  Offset pos;
  bool placed = false, returning = false;
}

/// Drag the right stepping stone into each shaped gap so the frog can hop
/// across the pond.
class PondPathScene extends GameScene {
  PondPathScene(this.cfg);
  final ScoreConfig cfg;

  static const start = Offset(60, 486);
  static const goal = Offset(180, 46);

  /// Two roomy rows on the near bank, clear of the frog's start.
  static const _bankSpots = [
    Offset(150, 528),
    Offset(240, 528),
    Offset(326, 528),
    Offset(104, 590),
    Offset(204, 590),
    Offset(300, 590),
  ];
  static const _spots = [Offset(120, 386), Offset(238, 306), Offset(128, 226), Offset(244, 146)];

  /// Shape wanted in each gap, and whether it has been filled.
  List<int> gaps = [];
  List<bool> _filled = [];
  final _stones = <_Stone>[];
  _Stone? _held;
  Offset _grab = Offset.zero;

  /// Index of the spot the frog sits on (-1 = start bank).
  int _frogAt = -1;
  double _hop = 1;
  Offset _hopFrom = start;
  int crossings = 0, matched = 0;
  double _nextIn = 0;

  int get _gapCount => ctx.simple ? 3 : 4;

  @visibleForTesting
  List<(Offset, int)> get debugStones => [
    for (final s in _stones)
      if (!s.placed && !s.returning) (s.pos, s.shape),
  ];
  @visibleForTesting
  Offset gapAt(int i) => _spots[i];
  @visibleForTesting
  int get frogStep => _frogAt;

  @override
  void setup() => _newPond();

  void _newPond() {
    final shapes = List.generate(_shapeNames.length, (i) => i)..shuffle(rng);
    gaps = shapes.take(_gapCount).toList();
    _filled = List.filled(_gapCount, false);
    _frogAt = -1;
    _hop = 1;
    // One stone per gap plus a decoy shape, laid out on the near bank.
    final pile = [...gaps, if (!ctx.simple) shapes[_gapCount]]..shuffle(rng);
    _stones
      ..clear()
      ..addAll([for (var i = 0; i < pile.length; i++) _Stone(pile[i], _bankSpots[i])]);
  }

  Offset _frogPos() {
    final to = _frogAt < 0 ? start : (_frogAt >= _gapCount ? goal : _spots[_frogAt]);
    if (_hop >= 1) return to;
    final k = Flight.ease(_hop);
    return Offset.lerp(_hopFrom, to, k)! - Offset(0, bump(k) * 60);
  }

  void _jump() {
    _hopFrom = _frogPos();
    _frogAt++;
    _hop = 0;
    ctx.onSfx(Sfx.whoosh);
  }

  @override
  void tick(double dt) {
    final wasHopping = _hop < 1;
    _hop = (_hop + dt / 0.55).clamp(0, 1);
    if (wasHopping && _hop >= 1) {
      fx.splash(_frogPos() + const Offset(0, 20), color: Ink.white);
      if (_frogAt >= _gapCount) {
        crossings++;
        score(cfg.bonus, 'cross-$crossings', goal + const Offset(0, 40));
        ctx.onSfx(Sfx.cheer);
        fx.confetti(goal + const Offset(0, 30));
        _nextIn = 1.6;
      }
    }
    // Hop forward one stone at a time while the next gap is filled.
    if (_hop >= 1 && _frogAt < _gapCount) {
      final next = _frogAt + 1;
      if (next == _gapCount || _filled[next]) _jump();
    }
    if (_frogAt >= _gapCount && _hop >= 1 && !ended) {
      _nextIn -= dt;
      if (_nextIn <= 0) _newPond();
    }
  }

  @override
  bool onDragStart(Offset p) {
    if (ended) return false;
    for (final s in _stones.reversed) {
      if (s.placed || s.returning || (s.pos - p).distance > 40 + ctx.hitPad) continue;
      _held = s;
      _grab = s.pos - p;
      ctx.onSfx(Sfx.tap);
      return true;
    }
    return false;
  }

  @override
  void onDragMove(Offset p) => _held?.pos = p + _grab;

  @override
  void onDragEnd(Offset p) {
    final s = _held;
    _held = null;
    if (s == null) return;
    for (var i = 0; i < _gapCount; i++) {
      if (_filled[i] || (s.pos - _spots[i]).distance > 46 + ctx.hitPad) continue;
      if (gaps[i] != s.shape || ended) {
        fx.floatText(_spots[i] + const Offset(0, -44), tr.gameWrongShape);
        ctx.onSfx(Sfx.soft);
        break;
      }
      _filled[i] = true;
      s
        ..placed = true
        ..pos = _spots[i];
      matched++;
      score(cfg.base, 'stone-$crossings-$i', _spots[i] + const Offset(0, -40));
      ctx.onSfx(Sfx.splash);
      fx.splash(_spots[i]);
      return;
    }
    _sendBack(s);
  }

  @override
  void cancelDrag() {
    final s = _held;
    _held = null;
    if (s != null) _sendBack(s);
  }

  void _sendBack(_Stone s) {
    s.returning = true;
    final shape = s.shape;
    fly(
      s.pos,
      s.rest,
      0.35,
      (c, pos, t) => _drawStone(c, shape, pos),
      arc: -20,
      trail: false,
      onArrive: () {
        s
          ..pos = s.rest
          ..returning = false;
      },
    );
  }

  void _drawStone(Canvas c, int shape, Offset at, [double scale = 1]) => sprite(c, 'path-stone-$shape', at, (c) {
    final p = _shape(shape);
    Pen.shape(c, p, fill: _stone, solid: true, hatch: Ink.navySoft.withValues(alpha: 0.35), seed: shape + 3);
    // A tuft of moss so it reads as a stone.
    Pen.shape(c, Pen.oval(const Offset(-8, -8), 8, 4), fill: Ink.mint, solid: true, width: 1.2, doubleLine: false);
  }, scale: scale);

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    // Far bank (the frog's goal), the pond and the near bank with stones.
    groundBand(c, const Rect.fromLTRB(-10, -20, 370, 80), _grass, seed: 2);
    waterBody(
      c,
      Path()
        ..moveTo(-10, 80)
        ..quadraticBezierTo(180, 60, 370, 84)
        ..lineTo(370, 470)
        ..quadraticBezierTo(180, 450, -10, 468)
        ..close(),
      color: _water,
      seed: 6,
    );
    groundBand(c, const Rect.fromLTRB(-10, 460, 370, 620), _grass, seed: 4);
    for (final (o, r, fl) in [
      (const Offset(310, 400), 22.0, true),
      (const Offset(40, 250), 20.0, false),
      (const Offset(320, 230), 18.0, false),
    ]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.lilyPad(c, r, flower: fl, seed: o.dx.round());
      c.restore();
    }
    for (final x in [24.0, 336.0]) {
      c.save();
      c.translate(x, 76);
      Nature.reed(c, 60, seed: x.round());
      c.restore();
    }
    // Home sweet home: a big lily pad on the far bank.
    c.save();
    c.translate(goal.dx, goal.dy + 8);
    Nature.lilyPad(c, 34, flower: true, seed: 9);
    c.restore();
  }

  static const _grass = Color(0xFF8BD866);

  @override
  void paint(Canvas c) {
    // Gaps: shaped shadows on the water until their stone arrives.
    for (var i = 0; i < _gapCount; i++) {
      if (_filled[i]) {
        _drawStone(c, gaps[i], _spots[i]);
        continue;
      }
      final glow = _held != null && _held!.shape == gaps[i];
      if (glow) c.drawCircle(_spots[i], 44, Pen.fillPaint(Ink.yellow.withValues(alpha: 0.3)));
      sprite(c, 'path-gap-${gaps[i]}', _spots[i], (c) {
        Pen.shape(
          c,
          _shape(gaps[i]),
          fill: Ink.navy.withValues(alpha: 0.28),
          solid: true,
          ink: Ink.white,
          width: 2,
          seed: 5,
          doubleLine: false,
        );
      });
    }
    for (final s in _stones) {
      if (s.placed || s.returning || identical(s, _held)) continue;
      _drawStone(c, s.shape, s.pos);
    }
    final hopping = _hop < 1;
    sprite(
      c,
      'path-frog-$hopping',
      _frogPos(),
      (c) => Critters.frog(c, mood: hopping ? Mood.wow : Mood.happy),
      scale: ctx.simple ? 1.15 : 1,
    );
    final held = _held;
    if (held != null) _drawStone(c, held.shape, held.pos, 1.1);
  }

  @override
  String get progressText => tr.progCrossed(crossings);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'path-frog-false', s.center(Offset.zero), Critters.frog, scale: s.width / 60);
}

final pondPathGame = GameDefinition(
  gameId: 'pond_path',
  name: (l) => l.gamePondPathName,
  objective: (l) => l.gamePondPathGoal,
  instructions: (l) => l.gamePondPathHowTo,
  interactionType: Interaction.drag,
  accent: Ink.leaf,
  scoreConfig: const ScoreConfig(base: 3, bonus: 8),
  assetManifest: const ['frog', 'stone', 'lily-pad'],
  create: PondPathScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(c, s, 0.5, 0.6, (c) => waterBody(c, Pen.oval(Offset.zero, 120, 40), color: _water, seed: 3));
    Thumb.put(
      c,
      s,
      0.34,
      0.62,
      (c) => Pen.shape(c, _shape(3), fill: Ink.navy.withValues(alpha: 0.28), solid: true, ink: Ink.white),
      scale: 0.6,
    );
    Thumb.put(c, s, 0.6, 0.55, (c) => Pen.shape(c, _shape(0), fill: _stone, solid: true), scale: 0.6);
    Thumb.put(c, s, 0.6, 0.38, Critters.frog, scale: 0.8);
    Thumb.put(c, s, 0.16, 0.86, (c) => Pen.shape(c, _shape(4), fill: _stone, solid: true), scale: 0.5);
  },
);
