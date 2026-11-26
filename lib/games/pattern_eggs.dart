import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

const _eggColors = [Ink.coral, Ink.blue, Ink.yellow, Ink.mint, Ink.purple];

enum _Deco { stripes, dots, zigzag }

/// One egg look: a colour plus a decoration. Matches need both to agree.
typedef _Look = (int color, _Deco deco);

class _Choice {
  _Choice(this.look, this.at);
  final _Look look;
  final Offset at;
  double shake = 0;
  bool used = false;
}

/// A row of eggs makes a pattern (red, blue, red, blue, ?). Tap the one of
/// six eggs that comes next.
class PatternEggScene extends GameScene {
  PatternEggScene(this.cfg);
  final ScoreConfig cfg;

  static const rowY = 214.0;
  static const _choiceSpots = [
    Offset(76, 400),
    Offset(180, 400),
    Offset(284, 400),
    Offset(76, 520),
    Offset(180, 520),
    Offset(284, 520),
  ];

  List<_Look> _sequence = [];
  late _Look _answer;
  final _choices = <_Choice>[];
  int solved = 0, _puzzle = 0, _misses = 0;
  bool _done = false;
  double _nextIn = 0;

  @visibleForTesting
  Offset get debugAnswerAt => _choices.firstWhere((c) => c.look == _answer).at;
  @visibleForTesting
  List<Offset> get debugWrongAt => [
    for (final c in _choices)
      if (c.look != _answer) c.at,
  ];
  @visibleForTesting
  int get debugChoiceCount => _choices.map((c) => c.look).toSet().length;

  @override
  void setup() => _newPuzzle();

  void _newPuzzle() {
    _puzzle++;
    _done = false;
    _misses = 0;
    // Little-kid mode sticks to simple two-colour patterns.
    final kinds = ctx.simple ? ['AB'] : ['AB', 'AAB', 'ABB', 'ABC'];
    final kind = pick(kinds);
    final colors = List.of(List.generate(_eggColors.length, (i) => i))..shuffle(rng);
    final decos = List.of(_Deco.values)..shuffle(rng);
    final sameDeco = ctx.simple || rng.nextBool();
    final looks = {for (var i = 0; i < 3; i++) 'ABC'[i]: (colors[i], sameDeco ? decos[0] : decos[i])};
    final shown = kind.length == 2 ? 4 : 5;
    final full = [for (var i = 0; i <= shown; i++) looks[kind[i % kind.length]]!];
    _sequence = full.sublist(0, shown);
    _answer = full.last;

    // Six eggs: the answer, the other pattern eggs, and near-miss decoys
    // (same colour with another decoration, same decoration in another colour).
    final options = <_Look>{_answer, for (final k in kind.split('')) looks[k]!};
    final (ac, ad) = _answer;
    options.add((ac, _Deco.values[(ad.index + 1) % 3]));
    options.add((colors[3], ad));
    while (options.length < 6) {
      options.add((rng.nextInt(_eggColors.length), pick(_Deco.values)));
    }
    final list = options.take(6).toList()..shuffle(rng);
    _choices
      ..clear()
      ..addAll([for (var i = 0; i < 6; i++) _Choice(list[i], _choiceSpots[i])]);
  }

  @override
  void tick(double dt) {
    for (final c in _choices) {
      c.shake = (c.shake - dt * 3).clamp(0, 1);
    }
    if (_done && !ended) {
      _nextIn -= dt;
      if (_nextIn <= 0) _newPuzzle();
    }
  }

  @override
  void onTap(Offset p) {
    if (_done || ended) return;
    for (final c in _choices) {
      if (c.used || (c.at - p).distance > 44 + ctx.hitPad) continue;
      if (c.look == _answer) {
        _done = true;
        _nextIn = 1.6;
        c.used = true;
        solved++;
        // Full stars for a first-try answer, a smaller reward after a retry.
        score(_misses == 0 ? cfg.bonus : cfg.base, 'pattern-$_puzzle', c.at + const Offset(0, -50));
        ctx.onSfx(Sfx.cheer);
        final look = _answer;
        final slot = _slot(_sequence.length);
        fly(
          c.at,
          slot,
          0.6,
          (cv, pos, t) => _drawEgg(cv, pos, look, 1 - t * 0.3),
          arc: -80,
          trail: false,
          onArrive: () {
            fx.confetti(slot);
          },
        );
      } else {
        _misses++;
        c.shake = 1;
        fx.floatText(c.at + const Offset(0, -50), tr.gameTryAgain);
        ctx.onSfx(Sfx.soft);
      }
      return;
    }
  }

  Offset _slot(int i) {
    final n = _sequence.length + 1;
    const gap = 56.0;
    return Offset(180 - (n - 1) * gap / 2 + i * gap, rowY);
  }

  static void _drawEgg(Canvas c, Offset at, _Look look, double scale, {double rotation = 0}) {
    final (color, deco) = look;
    sprite(
      c,
      'pattern-egg-$color-${deco.name}',
      at,
      (c) => _egg(c, _eggColors[color], deco),
      scale: scale,
      rotation: rotation,
    );
  }

  /// Egg ~56x72 centred, with a white decoration painted on.
  static void _egg(Canvas c, Color color, _Deco deco) {
    final shape = Path()
      ..moveTo(0, -36)
      ..cubicTo(24, -36, 30, 4, 28, 14)
      ..cubicTo(26, 30, 14, 36, 0, 36)
      ..cubicTo(-14, 36, -26, 30, -28, 14)
      ..cubicTo(-30, 4, -24, -36, 0, -36)
      ..close();
    Pen.shape(c, shape, fill: color, solid: true, hatch: Ink.shade(color, 0.12), seed: color.toARGB32() % 7);
    c.save();
    c.clipPath(shape);
    final white = Pen.inkPaint(Ink.white, 4.5);
    switch (deco) {
      case _Deco.stripes:
        for (final y in [-10.0, 10.0]) {
          c.drawLine(Offset(-30, y), Offset(30, y), white);
        }
      case _Deco.dots:
        for (final o in const [
          Offset(-11, -14),
          Offset(10, -8),
          Offset(-8, 8),
          Offset(12, 14),
          Offset(0, 24),
          Offset(1, -24),
        ]) {
          Pen.dot(c, o, 4.2, Ink.white);
        }
      case _Deco.zigzag:
        final z = Path()..moveTo(-30, 2);
        for (var i = 0; i < 6; i++) {
          z.lineTo(-25 + i * 10.0, i.isEven ? -8 : 6);
        }
        c.drawPath(z, white);
    }
    c.restore();
    Pen.stroke(c, shape, width: 2.4, seed: 3);
    c.drawLine(const Offset(-14, -22), const Offset(-19, -6), Pen.inkPaint(Ink.white.withValues(alpha: 0.6), 3));
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    // Sign for the question, a strip for the pattern, and grassy nests below.
    Pen.shape(
      c,
      Pen.rrect(Rect.fromCenter(center: const Offset(180, 92), width: 270, height: 64), 18),
      fill: Ink.paperWarm,
      solid: true,
      seed: 7,
      width: 2.6,
    );
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(14, 160, 332, 108), 20),
      fill: Ink.white,
      solid: true,
      hatch: Ink.grid,
      seed: 8,
    );
    groundBand(c, const Rect.fromLTRB(-10, 320, 370, 620), Ink.mint, seed: 5);
    for (final o in _choiceSpots) {
      c.save();
      c.translate(o.dx, o.dy + 40);
      Props.nest(c, w: 92);
      c.restore();
    }
  }

  @override
  void paint(Canvas c) {
    Pen.text(c, _done ? tr.gameGreatPattern : tr.gameWhatNext, const Offset(180, 92), size: 24, maxWidth: 320);
    for (var i = 0; i < _sequence.length; i++) {
      _drawEgg(c, _slot(i), _sequence[i], 0.7);
    }
    final q = _slot(_sequence.length);
    if (!_done) {
      final pulse = 1 + wave(time, 4) * 0.05;
      sprite(c, 'pattern-q', q, (c) {
        final ring = Pen.oval(Offset.zero, 21, 27);
        Pen.shape(c, ring, fill: Ink.blushPink, solid: true, seed: 2, width: 2.2);
        Pen.text(c, '?', const Offset(0, 1), size: 28, color: Ink.coral);
      }, scale: pulse);
    } else if (flights.isEmpty) {
      _drawEgg(c, q, _answer, 0.7);
    }
    for (final ch in _choices) {
      if (ch.used) continue;
      final rot = wave(ch.shake * 40) * ch.shake * 0.25 + wave(time, 1.5, ch.at.dx) * 0.03;
      _drawEgg(c, ch.at, ch.look, ctx.simple ? 1.1 : 1, rotation: rot);
    }
  }

  @override
  String get progressText => tr.progPatterns(solved);

  @override
  void paintProgressIcon(Canvas c, Size s) => _drawEgg(c, s.center(Offset.zero), (0, _Deco.stripes), s.width / 80);
}

final patternEggGame = GameDefinition(
  gameId: 'pattern_egg_hunt',
  name: (l) => l.gamePatternEggsName,
  objective: (l) => l.gamePatternEggsGoal,
  instructions: (l) => l.gamePatternEggsHowTo,
  interactionType: Interaction.tap,
  accent: Ink.yellow,
  scoreConfig: const ScoreConfig(base: 3, bonus: 6),
  assetManifest: const ['pattern-egg', 'nest'],
  create: PatternEggScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    for (final (x, look) in [
      (0.14, (0, _Deco.stripes)),
      (0.32, (1, _Deco.dots)),
      (0.5, (0, _Deco.stripes)),
      (0.68, (1, _Deco.dots)),
    ]) {
      final (col, deco) = look;
      Thumb.put(c, s, x, 0.42, (c) => PatternEggScene._egg(c, _eggColors[col], deco), scale: 0.55);
    }
    Thumb.put(c, s, 0.86, 0.42, (c) {
      Pen.shape(c, Pen.oval(Offset.zero, 18, 24), fill: Ink.blushPink, solid: true);
      Pen.text(c, '?', Offset.zero, size: 26, color: Ink.coral);
    });
    Thumb.put(c, s, 0.5, 1.0, (c) => groundBand(c, const Rect.fromLTRB(-200, -20, 200, 10), Ink.mint));
  },
);
