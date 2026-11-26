import 'dart:math' as math;

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

const _bloomColors = [Ink.pink, Ink.purple, Ink.coral];

enum _Pl { thirsty, growing, bloom, shrinking }

class _Plant {
  _Plant(this.x, this.color);
  final double x;
  final int color;
  _Pl state = _Pl.thirsty;

  /// 0 = seedling, 1 = fully open flower.
  double stage = 0;
  double water = 0, t = 0;
  int drinks = 0;
}

/// Drag the watering can over thirsty plants; each one grows into a flower,
/// then shrinks back to a seedling and asks for water again.
class WaterPlantsScene extends GameScene {
  WaterPlantsScene(this.cfg);
  final ScoreConfig cfg;

  static const potY = 500.0;
  static const _canRest = Offset(286, 150);

  final _plants = <_Plant>[];
  Offset can = _canRest;
  Offset _grab = Offset.zero;
  bool _holding = false;
  _Plant? _pouring;
  int watered = 0;

  double get _growTime => 2.6;
  double get _bloomTime => 2.4;
  double get _shrinkTime => 1.6;

  /// Seconds of pouring a thirsty plant needs.
  double get _drinkTime => ctx.simple ? 0.6 : 0.9;

  @visibleForTesting
  List<(double, String)> get debugPlants => [for (final p in _plants) (p.x, p.state.name)];

  @override
  void setup() {
    final n = ctx.simple ? 2 : 3;
    for (var i = 0; i < n; i++) {
      _plants.add(_Plant(360 / (n + 1) * (i + 1), i % _bloomColors.length));
    }
    // Stagger them so they don't all get thirsty at the same moment.
    for (var i = 1; i < _plants.length; i++) {
      _plants[i]
        ..state = _Pl.growing
        ..stage = i / _plants.length;
    }
  }

  /// The can pours on a plant when its spout is above it.
  _Plant? _under() {
    final spout = can + const Offset(-44, 4);
    for (final p in _plants) {
      if ((spout.dx - p.x).abs() < 46 + ctx.hitPad && spout.dy < potY - 10 && spout.dy > potY - 280) return p;
    }
    return null;
  }

  @override
  void tick(double dt) {
    _pouring = _holding ? _under() : null;
    for (final p in _plants) {
      p.t += dt;
      switch (p.state) {
        case _Pl.thirsty:
          if (identical(p, _pouring)) {
            p.water += dt / _drinkTime;
            if (p.water >= 1 && !ended) {
              p
                ..state = _Pl.growing
                ..t = 0
                ..water = 0
                ..drinks += 1;
              watered++;
              score(cfg.base, 'drink-${_plants.indexOf(p)}-${p.drinks}', Offset(p.x, potY - 120));
              ctx.onSfx(Sfx.chirp);
              fx.burst(Offset(p.x, potY - 40), colors: const [Ink.sky, Ink.white, Ink.mint], count: 10);
            }
          }
        case _Pl.growing:
          p.stage = (p.stage + dt / _growTime).clamp(0, 1);
          if (p.stage >= 1) {
            p
              ..state = _Pl.bloom
              ..t = 0;
            fx.burst(Offset(p.x, potY - 120), colors: [_bloomColors[p.color], Ink.yellow], count: 8);
          }
        case _Pl.bloom:
          if (p.t > _bloomTime) {
            p
              ..state = _Pl.shrinking
              ..t = 0;
          }
        case _Pl.shrinking:
          p.stage = (p.stage - dt / _shrinkTime).clamp(0, 1);
          if (p.stage <= 0) {
            p
              ..state = _Pl.thirsty
              ..t = 0;
          }
      }
    }
    if (_pouring != null && time % 0.08 < dt) {
      final spout = can + const Offset(-50, 10);
      fx.burst(spout, colors: const [Ink.sky, Ink.blue], count: 2, speed: 40, size: 3.5);
    }
  }

  @override
  bool onDragStart(Offset p) {
    if (ended || (p - can).distance > 60 + ctx.hitPad) return false;
    _holding = true;
    _grab = can - p;
    ctx.onSfx(Sfx.tap);
    return true;
  }

  @override
  void onDragMove(Offset p) {
    if (_holding) can = Offset((p + _grab).dx.clamp(40, 330), (p + _grab).dy.clamp(70, 440));
  }

  @override
  void onDragEnd(Offset p) => _holding = false;

  @override
  void cancelDrag() => _holding = false;

  static void _wateringCan(Canvas c) {
    Pen.stroke(
      c,
      Path()..addArc(Rect.fromCenter(center: const Offset(6, -24), width: 40, height: 34), math.pi, math.pi),
      width: 4,
      seed: 3,
    );
    Pen.shape(
      c,
      Pen.poly(const [Offset(-14, -6), Offset(-50, -22), Offset(-52, -16), Offset(-14, 6)]),
      fill: Ink.sky,
      solid: true,
      hatch: Ink.blue,
      seed: 4,
      width: 2,
    );
    Pen.shape(c, Pen.oval(const Offset(-53, -20), 5, 8), fill: Ink.blue, solid: true, width: 1.8, seed: 5);
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-20, -24, 50, 46), 10),
      fill: Ink.blue,
      solid: true,
      hatch: Ink.shade(Ink.blue, 0.15),
      seed: 2,
    );
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-14, -4, 38, 10), 4), fill: Ink.white, solid: true, width: 1.6, seed: 6);
    Pen.face(c, const Offset(5, -12), 18);
  }

  void _drawPlant(Canvas c, _Plant p) {
    final s = p.stage;
    final droop = p.state == _Pl.thirsty ? 0.35 : 0.0;
    final h = 26 + s * 96;
    c.save();
    c.translate(p.x, potY - 30);
    c.rotate(droop * wave(p.t, 1.2, p.x).abs() * 0.4 + droop * 0.5);
    Nature.stem(c, h, seed: p.color + 1, leaves: s > 0.25);
    c.translate(0, -h);
    if (s > 0.85) {
      Nature.flower(c, _bloomColors[p.color], r: 12 + (s - 0.85) / 0.15 * 12, seed: p.color + 2);
    } else if (s > 0.45) {
      Nature.bud(c, _bloomColors[p.color], r: 8 + s * 6, seed: p.color + 2);
    } else {
      // Seedling: two tiny leaves.
      for (final a in [-2.4, -0.7]) {
        c.save();
        c.rotate(a);
        Nature.leaf(c, 18, color: Ink.mint, width: 0.45, seed: p.color);
        c.restore();
      }
    }
    c.restore();
  }

  @override
  void paintBackground(Canvas c) {
    c.drawRect(GameScene.worldRect, Pen.fillPaint(Ink.tint(Ink.sky, 0.35)));
    Paper.gridOverlay(c, GameScene.worldRect, alpha: 0.3, cell: 20);
    c.save();
    c.translate(56, 70);
    Nature.sun(c, 26);
    c.restore();
    for (final (o, w) in [(const Offset(200, 70), 90.0), (const Offset(320, 260), 70.0)]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.cloud(c, w, seed: w.round());
      c.restore();
    }
    groundBand(c, const Rect.fromLTRB(-10, 520, 370, 620), Ink.mint, seed: 4);
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-6, 490, 372, 40), 6),
      fill: Ink.tint(Ink.brown, 0.6),
      solid: true,
      hatch: Ink.brown,
      seed: 7,
    );
  }

  @override
  void paint(Canvas c) {
    for (final p in _plants) {
      _drawPlant(c, p);
      sprite(c, 'plant-pot', Offset(p.x, potY - 14), (c) {
        final pot = Pen.poly(const [Offset(-30, -20), Offset(30, -20), Offset(22, 22), Offset(-22, 22)]);
        Pen.shape(c, pot, fill: Ink.coral, solid: true, hatch: Ink.shade(Ink.coral, 0.15), seed: 3);
        Pen.shape(
          c,
          Pen.rrect(const Rect.fromLTWH(-34, -26, 68, 12), 4),
          fill: Ink.shade(Ink.coral, 0.08),
          solid: true,
          seed: 4,
        );
      });
      if (p.state == _Pl.thirsty) {
        // Thought bubble asking for water, plus a little fill meter.
        final at = Offset(p.x + 26, potY - 110 + wave(time, 3, p.x) * 4);
        sprite(c, 'thirsty-bubble', at, (c) {
          Pen.shape(c, Pen.circle(Offset.zero, 20), fill: Ink.white, solid: true, width: 2, seed: 2);
          Pen.dot(c, const Offset(-16, 20), 4, Ink.white);
          c.scale(1.2);
          Props.raindrop(c, 10);
        });
        if (p.water > 0) {
          final r = Rect.fromLTWH(p.x - 26, potY + 14, 52, 8);
          c.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(4)), Pen.fillPaint(Ink.white));
          c.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(r.left, r.top, r.width * p.water, r.height),
              const Radius.circular(4),
            ),
            Pen.fillPaint(Ink.blue),
          );
        }
      }
    }
    sprite(c, 'watering-can', can, _wateringCan, rotation: _pouring != null ? -0.5 : 0, scale: ctx.simple ? 1.15 : 1);
  }

  @override
  String get progressText => tr.progWatered(watered);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'watering-can', s.center(Offset.zero), _wateringCan, scale: s.width / 110);
}

final waterPlantsGame = GameDefinition(
  gameId: 'water_the_plants',
  name: (l) => l.gameWaterPlantsName,
  objective: (l) => l.gameWaterPlantsGoal,
  instructions: (l) => l.gameWaterPlantsHowTo,
  interactionType: Interaction.drag,
  accent: Ink.mint,
  scoreConfig: const ScoreConfig(base: 4, bonus: 8),
  assetManifest: const ['watering-can', 'pot', 'flower', 'bud'],
  create: WaterPlantsScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, Ink.tint(Ink.sky, 0.35));
    Thumb.put(c, s, 0.5, 1.02, (c) => groundBand(c, const Rect.fromLTRB(-200, -20, 200, 10), Ink.mint));
    Thumb.put(c, s, 0.3, 0.78, (c) {
      Nature.stem(c, 50);
      c.translate(0, -50);
      Nature.flower(c, Ink.pink, r: 18);
    });
    Thumb.put(c, s, 0.72, 0.38, WaterPlantsScene._wateringCan, rotation: -0.4, scale: 0.8);
  },
);
