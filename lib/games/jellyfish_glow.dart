import 'dart:math' as math;

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

const _jellyColors = [Ink.pink, Ink.purple, Ink.sky, Ink.mint];
const _deep = Color(0xFF1B3A78);

enum _J { swim, stuck, held }

class _Jelly {
  _Jelly(this.id, this.pos, this.color, this.golden, this.phase, this.speed);
  final String id;
  Offset pos;
  final int color;
  final bool golden;
  final double phase;
  final double speed;
  _J state = _J.swim;
  Offset stick = Offset.zero;
}

class JellyfishGlowScene extends GameScene {
  JellyfishGlowScene(this.cfg);
  final ScoreConfig cfg;

  static const diver = Offset(180, 318);

  /// Releasing a jellyfish this close to any edge sends it away.
  static const edge = 44.0;

  final jellies = <_Jelly>[];
  _Jelly? _held;
  Offset _grab = Offset.zero;
  double _spawnIn = 1.0;
  int saved = 0;

  /// How much the dark sea has been lit up by saved jellyfish (0..1).
  double _light = 0;

  @visibleForTesting
  List<Offset> get debugJellyPositions => [for (final j in jellies) j.pos];

  double get _size => ctx.simple ? 1.2 : 1.0;
  int get _max => ctx.simple ? 2 : 3;

  Offset get _diverAt => diver + Offset(0, wave(time, 1.4) * 6);

  @override
  void setup() {}

  void _spawn() {
    final left = rng.nextBool();
    final p = Offset(left ? -30 : 390, rand(110, 540));
    jellies.add(
      _Jelly(
        newId('jelly'),
        p,
        rng.nextInt(_jellyColors.length),
        rng.nextDouble() < 0.12,
        rand(0, 6),
        rand(30, 46) * ctx.speed,
      ),
    );
  }

  @override
  void tick(double dt) {
    final d = _diverAt;
    for (final j in jellies) {
      switch (j.state) {
        case _J.swim:
          final to = d - j.pos;
          final dist = to.distance;
          if (dist < 56 * _size) {
            j
              ..state = _J.stuck
              ..stick = to / -dist * 50 * _size;
            ctx.onSfx(Sfx.soft);
          } else {
            // Pulse forward in little pushes, like a real jellyfish.
            final push = 0.6 + math.max(0, math.sin(time * 3 + j.phase)) * 0.9;
            j.pos += to / dist * j.speed * push * dt + Offset(0, wave(time, 2, j.phase) * 10 * dt);
          }
        case _J.stuck:
          j.pos = d + j.stick + Offset(wave(time, 7, j.phase) * 2, 0);
        case _J.held:
          break;
      }
    }
    if (!ended && jellies.length < _max) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(1.2, 2.2) / ctx.speed;
      }
    }
  }

  bool _nearEdge(Offset p) =>
      p.dx < edge || p.dx > GameScene.world.width - edge || p.dy < edge || p.dy > GameScene.world.height - edge;

  void _save(_Jelly j) {
    jellies.remove(j);
    saved++;
    _light = (_light + 0.07).clamp(0, 0.85);
    score(j.golden ? cfg.bonus : cfg.base, j.id, j.pos);
    ctx.onSfx(j.golden ? Sfx.bonus : Sfx.collect);
    final col = j.golden ? Ink.yellow : _jellyColors[j.color];
    fx.burst(j.pos, colors: [col, Ink.white], count: 10);
    // Swim off the nearest edge, away from the diver.
    final away = j.pos - diver;
    final out = j.pos + away / math.max(1, away.distance) * 260;
    final golden = j.golden, color = j.color, size = _size;
    fly(j.pos, out, 0.7, (c, p, t) => _drawJelly(c, p, color, golden, size, t * 0.6), arc: -30, trail: false);
  }

  static void _drawJelly(Canvas c, Offset p, int color, bool golden, double size, [double rot = 0]) {
    final col = golden ? Ink.yellow : _jellyColors[color];
    c.drawCircle(p, 40 * size, Pen.fillPaint(col.withValues(alpha: 0.16)));
    c.drawCircle(p, 28 * size, Pen.fillPaint(col.withValues(alpha: 0.18)));
    sprite(
      c,
      'jelly-$color-$golden',
      p,
      (c) => Critters.jellyfish(c, col, seed: color + 1),
      scale: size,
      rotation: rot,
    );
  }

  @override
  bool onDragStart(Offset p) {
    if (ended) return false;
    _Jelly? best;
    var bestD = 40 * _size + ctx.hitPad;
    for (final j in jellies) {
      final dd = (j.pos - p).distance;
      if (dd < bestD) {
        bestD = dd;
        best = j;
      }
    }
    if (best == null) return false;
    best.state = _J.held;
    _held = best;
    _grab = best.pos - p;
    ctx.onSfx(Sfx.tap);
    return true;
  }

  @override
  void onDragMove(Offset p) => _held?.pos = p + _grab;

  @override
  void onDragEnd(Offset p) {
    final j = _held;
    _held = null;
    if (j == null) return;
    if (_nearEdge(j.pos) && !ended) {
      _save(j);
    } else {
      j.state = _J.swim; // not far enough: it drifts back towards the diver
    }
  }

  @override
  void cancelDrag() {
    _held?.state = _J.swim;
    _held = null;
  }

  @override
  void paintBackground(Canvas c) {
    c.drawRect(GameScene.worldRect, Pen.fillPaint(_deep));
    Paper.gridOverlay(c, GameScene.worldRect, alpha: 0.07);
    // Soft light shafts from the surface.
    for (final (x, w) in [(70.0, 50.0), (200.0, 70.0), (310.0, 40.0)]) {
      c.drawPath(
        Pen.poly([Offset(x - w / 4, 0), Offset(x + w / 4, 0), Offset(x + w, 480), Offset(x - w * 0.6, 480)]),
        Pen.fillPaint(Ink.white.withValues(alpha: 0.05)),
      );
    }
    final r = math.Random(4);
    final ring = Pen.inkPaint(Ink.white.withValues(alpha: 0.35), 1.4);
    for (var i = 0; i < 18; i++) {
      c.drawCircle(Offset(r.nextDouble() * 360, r.nextDouble() * 520), 2 + r.nextDouble() * 4, ring);
    }
    // Sandy floor with seaweed, coral and rocks.
    groundBand(c, const Rect.fromLTRB(-10, 566, 370, 620), Ink.sand, seed: 6);
    for (final (x, h) in [(26.0, 90.0), (54.0, 60.0), (300.0, 80.0), (336.0, 110.0)]) {
      c.save();
      c.translate(x, 584);
      Nature.seaweed(c, h, seed: x.round());
      c.restore();
    }
    for (final (x, col) in [(110.0, Ink.coral), (250.0, Ink.pink)]) {
      c.save();
      c.translate(x, 590);
      Nature.coral(c, col, h: 40, seed: x.round());
      c.restore();
    }
    c.save();
    c.translate(180, 598);
    Nature.rock(c, 44, seed: 3);
    c.restore();
  }

  @override
  void paint(Canvas c) {
    // The sea starts dark and brightens with every jellyfish saved.
    c.drawRect(GameScene.worldRect, Pen.fillPaint(Ink.nightDeep.withValues(alpha: 0.55 * (1 - _light))));
    final d = _diverAt;
    c.drawCircle(d, 70 * _size, Pen.fillPaint(Ink.yellow.withValues(alpha: 0.08)));
    // Bubbles rising from the helmet.
    final bubble = Pen.inkPaint(Ink.white.withValues(alpha: 0.7), 1.6);
    for (var i = 0; i < 3; i++) {
      final k = (time * 0.5 + i / 3) % 1;
      c.drawCircle(d + Offset(18 + wave(time * 2 + i) * 4, -40 - k * 90) * _size, 3 + i * 1.5, bubble);
    }
    final worried = jellies.any((j) => j.state == _J.stuck);
    sprite(
      c,
      'baby-diver-$worried',
      d,
      (c) => Critters.babyDiver(c, mood: worried ? Mood.wow : Mood.happy),
      scale: _size * 1.15,
      rotation: wave(time, 1.1) * 0.05,
    );
    if (_held != null) {
      // Glowing border: "drag it out here!"
      final glow = Pen.inkPaint(Ink.yellow.withValues(alpha: 0.35 + wave(time, 6) * 0.15), 6);
      c.drawRRect(RRect.fromRectAndRadius(GameScene.worldRect.deflate(10), const Radius.circular(22)), glow);
    }
    for (final j in jellies) {
      final pulse = 1 + wave(time, 3, j.phase) * 0.06;
      c.save();
      c.translate(j.pos.dx, j.pos.dy);
      c.scale(1 / pulse, pulse);
      c.translate(-j.pos.dx, -j.pos.dy);
      _drawJelly(c, j.pos, j.color, j.golden, _size * (j.state == _J.held ? 1.1 : 1));
      c.restore();
    }
  }

  @override
  String get progressText => tr.progSaved(saved);

  @override
  void paintProgressIcon(Canvas c, Size s) => sprite(
    c,
    'jelly-0-false',
    s.center(Offset.zero),
    (c) => Critters.jellyfish(c, Ink.pink, seed: 1),
    scale: s.width / 52,
  );
}

final jellyfishGlowGame = GameDefinition(
  gameId: 'jellyfish_glow',
  name: (l) => l.gameJellyfishName,
  objective: (l) => l.gameJellyfishGoal,
  instructions: (l) => l.gameJellyfishHowTo,
  interactionType: Interaction.drag,
  accent: Ink.purple,
  scoreConfig: const ScoreConfig(base: 3, bonus: 8),
  assetManifest: const ['jellyfish', 'baby-diver', 'seaweed', 'coral'],
  create: JellyfishGlowScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, _deep);
    Thumb.put(c, s, 0.5, 1.02, (c) => groundBand(c, const Rect.fromLTRB(-200, -16, 200, 10), Ink.sand));
    Thumb.put(c, s, 0.5, 0.5, (c) => Critters.babyDiver(c), scale: 0.7);
    for (final (x, y, col) in [(0.18, 0.4, Ink.pink), (0.82, 0.32, Ink.purple), (0.8, 0.75, Ink.sky)]) {
      Thumb.put(c, s, x, y, (c) {
        c.drawCircle(Offset.zero, 30, Pen.fillPaint(col.withValues(alpha: 0.25)));
        Critters.jellyfish(c, col);
      }, scale: 0.6);
    }
  },
);
