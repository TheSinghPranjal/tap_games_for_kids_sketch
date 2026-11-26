import 'dart:math' as math;

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

const _boxColors = [Ink.coral, Ink.blue, Ink.mint, Ink.purple, Ink.yellow];
const _rock = Color(0xFF6E6478);

enum _B { crate, colored, broken }

class _Box {
  _Box(this.id, this.at, this.color, this.crateHits, this.colorHits);
  final String id;
  final Offset at;
  final int color;

  /// Taps needed: 2..5 for the wooden crate, 1..2 for the coloured box.
  final int crateHits, colorHits;
  int hits = 0;
  _B state = _B.crate;
  double shake = 0;
  double pop = 0;
}

/// Break wooden crates to find coloured boxes; the box matching the colour
/// on the sign holds the gem. Wrong colours still pay out coins.
class GemMineScene extends GameScene {
  GemMineScene(this.cfg);
  final ScoreConfig cfg;

  static const signAt = Offset(180, 62);

  final _boxes = <_Box>[];
  int target = 0, found = 0;
  double _resetIn = 0;
  bool _won = false;
  Offset _hammerAt = const Offset(-100, -100);
  double _swing = 1;

  @visibleForTesting
  List<(Offset, int, int, int)> get debugBoxes => [
    for (final b in _boxes)
      if (b.state != _B.broken) (b.at, b.color, b.crateHits, b.colorHits),
  ];

  double get _w => ctx.simple ? 86 : 74;

  @override
  void setup() => _newLevel();

  void _newLevel() {
    _won = false;
    _boxes.clear();
    target = rng.nextInt(_boxColors.length);
    final cols = ctx.simple ? 2 : 3, rows = 3;
    final gemAt = rng.nextInt(cols * rows);
    final cellW = 300 / cols, cellH = 128.0;
    for (var i = 0; i < cols * rows; i++) {
      final at = Offset(30 + cellW * (i % cols + 0.5), 196 + cellH * (i ~/ cols));
      var color = target;
      // Exactly one box matches the sign; the rest are other colours.
      if (i != gemAt) color = (target + 1 + rng.nextInt(_boxColors.length - 1)) % _boxColors.length;
      _boxes.add(_Box(newId('box'), at, color, 2 + rng.nextInt(4), 1 + rng.nextInt(2)));
    }
  }

  @override
  void tick(double dt) {
    _swing = (_swing + dt * 6).clamp(0, 1);
    for (final b in _boxes) {
      b.shake = math.max(0, b.shake - dt * 5);
      b.pop = (b.pop + dt * 4).clamp(0, 1);
    }
    if (_won && !ended) {
      _resetIn -= dt;
      if (_resetIn <= 0) _newLevel();
    }
  }

  @override
  void onTap(Offset p) {
    if (_won || ended) return;
    _Box? hit;
    for (final b in _boxes) {
      if (b.state != _B.broken && (b.at - p).distance < _w * 0.62 + ctx.hitPad) hit = b;
    }
    if (hit == null) return;
    final b = hit;
    _hammerAt = b.at + Offset(_w * 0.55, _w * 0.2); // handle end; head swings onto the box
    _swing = 0;
    b
      ..hits += 1
      ..shake = 1;
    if (b.state == _B.crate) {
      ctx.onSfx(Sfx.tap);
      fx.burst(b.at, colors: const [Ink.brown, Ink.sand], count: 5, speed: 70, size: 4);
      if (b.hits >= b.crateHits) {
        b
          ..state = _B.colored
          ..hits = 0
          ..pop = 0;
        ctx.onSfx(Sfx.pop);
        fx.burst(b.at, colors: const [Ink.brown, Ink.sand, Ink.white], count: 12, speed: 120);
      }
      return;
    }
    ctx.onSfx(Sfx.tap);
    if (b.hits < b.colorHits) return;
    b.state = _B.broken;
    if (b.color == target) {
      // 20 points: exactly one gem under the usual points-to-gem rule.
      _won = true;
      _resetIn = 1.6;
      found++;
      score(cfg.bonus, b.id, b.at + const Offset(0, -30));
      ctx.onSfx(Sfx.bonus);
      fx.confetti(b.at, colors: [_boxColors[target], Ink.yellow, Ink.white]);
      final color = _boxColors[target];
      fly(
        b.at,
        signAt + const Offset(70, 0),
        0.9,
        (c, pos, t) => sprite(c, 'mine-gem-$target', pos, (c) => Props.gem(c, 18, color: color), scale: 1.4 - t * 0.5),
        arc: -90,
      );
    } else {
      score(cfg.base, b.id, b.at + const Offset(0, -30));
      ctx.onSfx(Sfx.collect);
      fx.floatText(b.at + const Offset(0, 14), tr.gameNotThisOne);
      fx.burst(b.at, colors: const [Ink.gold, Ink.yellow], count: 10);
    }
  }

  @override
  void paintBackground(Canvas c) {
    c.drawRect(GameScene.worldRect, Pen.fillPaint(_rock));
    Paper.gridOverlay(c, GameScene.worldRect, alpha: 0.06);
    final r = math.Random(8);
    for (var i = 0; i < 26; i++) {
      final o = Offset(r.nextDouble() * 360, 120 + r.nextDouble() * 500);
      final w = 10 + r.nextDouble() * 22;
      Pen.shape(
        c,
        Pen.oval(o, w, w * 0.6),
        fill: Ink.shade(_rock, 0.12),
        solid: true,
        width: 1.4,
        seed: i,
        doubleLine: false,
      );
    }
    // Sparkly gem veins in the rock.
    for (var i = 0; i < 8; i++) {
      final o = Offset(r.nextDouble() * 360, 130 + r.nextDouble() * 470);
      Pen.twinkle(c, o, 4, _boxColors[i % _boxColors.length].withValues(alpha: 0.7));
    }
    // Wooden support beams.
    for (final x in [8.0, 352.0]) {
      Pen.shape(
        c,
        Pen.rrect(Rect.fromCenter(center: Offset(x, 380), width: 22, height: 520), 3),
        fill: Ink.brown,
        solid: true,
        hatch: Ink.shade(Ink.brown, 0.2),
        hatchAngle: 1.5,
        seed: x.round(),
      );
    }
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-6, 112, 372, 22), 3),
      fill: Ink.brown,
      solid: true,
      hatch: Ink.shade(Ink.brown, 0.2),
      hatchAngle: 0,
      seed: 5,
    );
    for (final x in [130.0, 230.0]) {
      c.drawCircle(Offset(x, 150), 26, Pen.fillPaint(Ink.yellow.withValues(alpha: 0.18)));
      Pen.line(c, Offset(x, 134), Offset(x, 140), width: 2);
      Pen.shape(
        c,
        Pen.rrect(Rect.fromCenter(center: Offset(x, 150), width: 14, height: 20), 4),
        fill: Ink.yellow,
        solid: true,
        hatch: Ink.gold,
        seed: 9,
        width: 2,
      );
    }
    // Rail track along the floor.
    Pen.line(c, const Offset(0, 600), const Offset(360, 600), ink: const Color(0xFF9EA3B2), width: 4);
    for (var x = 10.0; x < 360; x += 30) {
      Pen.line(c, Offset(x, 594), Offset(x, 612), ink: Ink.brown, width: 5);
    }
    // Paper sign behind the "find this colour" panel.
    Pen.shape(
      c,
      Pen.rrect(Rect.fromCenter(center: signAt, width: 250, height: 76), 16),
      fill: Ink.paperWarm,
      solid: true,
      seed: 6,
      width: 2.6,
    );
  }

  @override
  void paint(Canvas c) {
    // Sign: "Find" + the target box with its gem.
    Pen.text(c, tr.gameFind, signAt + const Offset(-78, 0), size: 26, maxWidth: 76);
    sprite(c, 'mine-sign-box-$target', signAt + const Offset(-4, 2), (c) => Props.gemBox(c, _boxColors[target], 46));
    sprite(c, 'mine-gem-$target', signAt + const Offset(70, 0), (c) => Props.gem(c, 18, color: _boxColors[target]));

    for (final b in _boxes) {
      if (b.state == _B.broken) continue;
      final jiggle = Offset(math.sin(b.shake * 30) * b.shake * 5, 0);
      final at = b.at + jiggle;
      if (b.state == _B.crate) {
        final dmg = b.hits / b.crateHits;
        final seed = b.at.dx.round() % 5 + 1;
        sprite(
          c,
          'crate-${(dmg * 4).round()}-${_w.round()}-$seed',
          at,
          (c) => Props.crate(c, _w, damage: dmg, seed: seed),
        );
      } else {
        final (sx, sy) = squash(b.pop, 0.2);
        final dmg = b.hits / b.colorHits * 0.75;
        sprite(
          c,
          'gembox-${b.color}-${(dmg * 4).round()}-${_w.round()}',
          at,
          (c) => Props.gemBox(c, _boxColors[b.color], _w * 0.82, damage: dmg, seed: b.color + 1),
          sx: sx,
          sy: sy,
        );
      }
    }
    if (_swing < 1) {
      // Quick hammer bonk at the last tapped box.
      final rot = 0.3 - Flight.ease(_swing) * 1.2;
      sprite(
        c,
        'mine-hammer',
        _hammerAt,
        (c) {
          c.translate(0, -40);
          Props.hammer(c);
        },
        rotation: rot,
        scale: ctx.simple ? 1.2 : 1,
      );
    }
  }

  @override
  String get progressText => tr.progGemsFound(found);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'mine-gem-1', s.center(Offset.zero), (c) => Props.gem(c, 18, color: Ink.blue), scale: s.width / 44);
}

final gemMineGame = GameDefinition(
  gameId: 'find_the_gem',
  name: (l) => l.gameGemMineName,
  objective: (l) => l.gameGemMineGoal,
  instructions: (l) => l.gameGemMineHowTo,
  interactionType: Interaction.tap,
  accent: Ink.blue,
  scoreConfig: const ScoreConfig(base: 10, bonus: 20),
  assetManifest: const ['crate', 'gem-box', 'gem', 'hammer'],
  create: GemMineScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, _rock);
    Thumb.put(c, s, 0.25, 0.6, (c) => Props.crate(c, 60, damage: 0.5));
    Thumb.put(c, s, 0.55, 0.62, (c) => Props.gemBox(c, Ink.coral, 50));
    Thumb.put(c, s, 0.8, 0.38, (c) => Props.gem(c, 18, color: Ink.blue), scale: 1.2);
    Thumb.put(c, s, 0.4, 0.3, (c) => Props.hammer(c), rotation: -0.6, scale: 0.9);
  },
);
