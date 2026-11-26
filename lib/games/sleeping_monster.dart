import 'dart:math' as math;

import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

const _babyColors = [Ink.mint, Ink.orange, Ink.pink, Ink.sky];
const _dusk = Color(0xFFEDE6FA);

enum _B { walk, held, dizzy, poke }

class _Baby {
  _Baby(this.id, this.pos, this.color, this.kind, this.golden, this.speed, this.phase);
  final String id;
  Offset pos;
  final int color, kind;
  final bool golden;
  final double speed, phase;
  _B state = _B.walk;
  double t = 0;
}

/// A big monster naps in the middle while its babies sneak in from every
/// side to wake it. Drag or flick each baby off the screen before it pokes.
class SleepingMonsterScene extends GameScene {
  SleepingMonsterScene(this.cfg);
  final ScoreConfig cfg;

  static const monsterAt = Offset(180, 330);

  /// Releasing a baby this close to any edge sends it away.
  static const edge = 44.0;

  /// A release faster than this (world units per second) is a flick.
  static const flickSpeed = 420.0;

  final babies = <_Baby>[];
  _Baby? _held;
  Offset _grab = Offset.zero;
  final _trail = <(double, Offset)>[];
  double _spawnIn = 0.8;
  int shooed = 0, naps = 0;

  /// Pokes so far; the monster wakes when it reaches [wakeLimit].
  int pokes = 0;
  double _calm = 0, _stir = 0, _awake = 0;

  int get wakeLimit => ctx.simple ? 4 : 3;
  bool get awake => _awake > 0;

  @visibleForTesting
  List<Offset> get debugBabyPositions => [for (final b in babies) b.pos];

  double get _size => ctx.simple ? 1.2 : 1.0;

  /// More babies join in as the round goes on.
  int get _max => (ctx.simple ? 2 : 3) + math.min(ctx.simple ? 1 : 2, time ~/ 20);

  /// Babies stop and poke when they reach the monster's fur.
  double get _reach => 88 * _size;

  @override
  void setup() {}

  void _spawn() {
    // Pick a spot just outside a random edge, so babies come from everywhere.
    final w = GameScene.world.width, h = GameScene.world.height;
    final p = switch (rng.nextInt(4)) {
      0 => Offset(rand(20, w - 20), -30),
      1 => Offset(rand(20, w - 20), h + 30),
      2 => Offset(-30, rand(60, h - 40)),
      _ => Offset(w + 30, rand(60, h - 40)),
    };
    final golden = rng.nextDouble() < 0.12;
    babies.add(
      _Baby(
        newId('baby'),
        p,
        rng.nextInt(_babyColors.length),
        golden ? 0 : rng.nextInt(3),
        golden,
        (rand(26, 36) + math.min(12, time * 0.2)) * ctx.speed,
        rand(0, 6),
      ),
    );
  }

  @override
  void tick(double dt) {
    _stir = math.max(0, _stir - dt);
    if (_awake > 0) {
      _awake -= dt;
      if (_awake <= 0) {
        pokes = 0;
        ctx.onSfx(Sfx.soft);
      }
    } else if (pokes > 0) {
      // Left alone, the monster slowly settles back into a deep sleep.
      _calm += dt;
      if (_calm > 10) {
        _calm = 0;
        pokes--;
      }
    }
    for (final b in List.of(babies)) {
      b.t += dt;
      switch (b.state) {
        case _B.walk:
          final to = monsterAt - b.pos;
          final dist = to.distance;
          if (dist <= _reach) {
            _poke(b);
          } else {
            // Tiptoe in little sneaky steps.
            final step = 0.55 + math.max(0, math.sin(time * 5 + b.phase)) * 0.9;
            b.pos += to / dist * b.speed * step * dt;
          }
        case _B.dizzy:
          if (b.t > 0.7) b.state = _B.walk;
        case _B.poke:
          if (b.t > 0.6) _runOff(b);
        case _B.held:
          break;
      }
    }
    if (!ended && !awake && babies.length < _max) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(1.3, 2.3) / ctx.speed;
      }
    }
  }

  void _poke(_Baby b) {
    b
      ..state = _B.poke
      ..t = 0;
    if (awake) return;
    pokes++;
    _calm = 0;
    _stir = 0.8;
    ctx.onSfx(Sfx.pop);
    fx.burst(b.pos + (monsterAt - b.pos) * 0.3, count: 5, speed: 50, colors: const [Ink.yellow, Ink.coral]);
    if (pokes >= wakeLimit) _wakeUp();
  }

  void _wakeUp() {
    _awake = 2.6;
    naps++;
    ctx.onSfx(Sfx.chirp);
    fx.ring(monsterAt, radius: 90, color: Ink.coral);
    // Every baby runs in for a big monster hug, then the monster dozes off.
    for (final b in List.of(babies)) {
      if (b == _held) _held = null;
      babies.remove(b);
      final color = b.color, kind = b.kind, golden = b.golden, size = _size;
      fly(
        b.pos,
        monsterAt + Offset(rand(-30, 30), rand(-10, 30)),
        0.5,
        (c, p, t) => _drawBaby(c, p, color, kind, golden, size * (1 - t * 0.6), Mood.happy),
        arc: -40,
        trail: false,
        onArrive: () => fx.hearts(monsterAt + const Offset(0, -60)),
      );
    }
  }

  /// A baby that already poked scampers away giggling (no points).
  void _runOff(_Baby b) {
    babies.remove(b);
    final dir = _away(b.pos);
    final color = b.color, kind = b.kind, golden = b.golden, size = _size;
    fly(b.pos, b.pos + dir * 420, 1.2, (c, p, t) => _drawBaby(c, p, color, kind, golden, size, Mood.happy), arc: -20);
  }

  Offset _away(Offset p) {
    final d = p - monsterAt;
    return d.distance < 1 ? const Offset(0, 1) : d / d.distance;
  }

  bool _nearEdge(Offset p) =>
      p.dx < edge || p.dx > GameScene.world.width - edge || p.dy < edge || p.dy > GameScene.world.height - edge;

  /// Release velocity from the last ~0.12s of drag samples.
  Offset get _flick {
    if (_trail.length < 2) return Offset.zero;
    final (t1, p1) = _trail.last;
    var (t0, p0) = _trail.first;
    for (final (t, p) in _trail) {
      if (t1 - t <= 0.12) {
        (t0, p0) = (t, p);
        break;
      }
    }
    final dt = t1 - t0;
    return dt < 1 / 120 ? Offset.zero : (p1 - p0) / dt;
  }

  void _shoo(_Baby b, Offset dir) {
    babies.remove(b);
    shooed++;
    score(b.golden ? cfg.bonus : cfg.base, b.id, b.pos);
    ctx.onSfx(b.golden ? Sfx.bonus : Sfx.whoosh);
    fx.burst(b.pos, colors: [b.golden ? Ink.yellow : _babyColors[b.color], Ink.white], count: 8);
    final color = b.color, kind = b.kind, golden = b.golden, size = _size;
    // Long enough to leave the screen from anywhere.
    fly(
      b.pos,
      b.pos + dir * 760,
      0.75,
      (c, p, t) => _drawBaby(c, p, color, kind, golden, size, Mood.wow, t * 9),
      arc: 0,
    );
  }

  static void _drawBaby(
    Canvas c,
    Offset p,
    int color,
    int kind,
    bool golden,
    double size,
    Mood mood, [
    double rot = 0,
  ]) {
    if (golden) c.drawCircle(p, 30 * size, Pen.fillPaint(Ink.yellow.withValues(alpha: 0.25)));
    sprite(
      c,
      'baby-monster-$color-$kind-$golden-${mood.name}',
      p,
      (c) => Critters.babyMonster(c, golden ? Ink.yellow : _babyColors[color], kind: kind, golden: golden, mood: mood),
      scale: size,
      rotation: rot,
    );
  }

  @override
  bool onDragStart(Offset p) {
    if (ended) return false;
    _Baby? best;
    var bestD = 36 * _size + ctx.hitPad;
    for (final b in babies) {
      if (b.state == _B.poke) continue;
      final d = (b.pos - p).distance;
      if (d < bestD) {
        bestD = d;
        best = b;
      }
    }
    if (best == null) return false;
    best.state = _B.held;
    _held = best;
    _grab = best.pos - p;
    _trail
      ..clear()
      ..add((time, p));
    ctx.onSfx(Sfx.tap);
    return true;
  }

  @override
  void onDragMove(Offset p) {
    final b = _held;
    if (b == null) return;
    b.pos = p + _grab;
    _trail.add((time, p));
    if (_trail.length > 12) _trail.removeAt(0);
    // Dragging a baby into the monster still counts as a poke.
    if ((b.pos - monsterAt).distance < _reach * 0.7) {
      _held = null;
      _poke(b);
    }
  }

  @override
  void onDragEnd(Offset p) {
    final b = _held;
    _held = null;
    if (b == null) return;
    final v = _flick;
    if (ended) {
      b.state = _B.walk;
    } else if (v.distance > flickSpeed) {
      _shoo(b, v / v.distance);
    } else if (_nearEdge(b.pos)) {
      _shoo(b, _away(b.pos));
    } else {
      // Not far enough: the baby wobbles, then sneaks back in.
      b
        ..state = _B.dizzy
        ..t = 0;
    }
  }

  @override
  void cancelDrag() {
    _held?.state = _B.walk;
    _held = null;
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect, base: _dusk);
    c.save();
    c.translate(306, 120);
    Nature.moon(c, 22);
    c.restore();
    final r = math.Random(7);
    for (var i = 0; i < 9; i++) {
      Pen.twinkle(c, Offset(20 + r.nextDouble() * 320, 100 + r.nextDouble() * 110), 4 + r.nextDouble() * 3, Ink.gold);
    }
    // Cosy patchwork blanket for the nap.
    final rug = Pen.oval(const Offset(180, 396), 150, 58);
    Pen.shape(c, rug, fill: Ink.tint(Ink.coral, 0.7), cross: true, seed: 4, width: 2.4);
    c.save();
    c.clipPath(rug);
    final seam = Pen.inkPaint(Ink.white.withValues(alpha: 0.8), 2);
    for (var x = 40.0; x < 340; x += 40) {
      c.drawLine(Offset(x, 330), Offset(x, 460), seam);
    }
    c.drawLine(const Offset(20, 396), const Offset(340, 396), seam);
    c.restore();
    for (final (x, y) in [(40.0, 560.0), (310.0, 590.0), (60.0, 250.0), (320.0, 470.0), (150.0, 600.0)]) {
      c.save();
      c.translate(x, y);
      Nature.grass(c, 30, seed: x.round());
      c.restore();
    }
  }

  @override
  void paint(Canvas c) {
    final wake = awake ? 2 : (_stir > 0 || pokes >= wakeLimit - 1 ? 1 : 0);
    final breathe = awake ? 0.0 : wave(time, 1.6) * 0.035;
    final jiggle = _stir > 0 ? wave(time, 40) * 0.05 : 0.0;
    final hop = awake ? bump((2.6 - _awake).clamp(0, 0.5) * 2) * 30 : 0.0;
    sprite(
      c,
      'sleepy-monster-$wake',
      monsterAt - Offset(0, hop),
      (c) => Critters.monster(c, wake: wake),
      scale: 1.25 * _size,
      sx: 1 + breathe,
      sy: 1 - breathe,
      rotation: jiggle,
    );
    // Sleep meter: one floating "Z" for every poke the monster can still take.
    if (!awake) {
      for (var i = 0; i < wakeLimit - pokes; i++) {
        final k = (time * 0.35 + i * 0.22) % 1;
        final at = monsterAt + Offset(70 + i * 22 + wave(time, 2, i.toDouble()) * 5, -120 - i * 18 - k * 8) * _size;
        Pen.text(c, 'Z', at, size: 20 + i * 4.0, color: Ink.navy.withValues(alpha: 0.85));
      }
    } else {
      Pen.text(c, '!', monsterAt + Offset(0, -140 * _size - hop), size: 40, color: Ink.coral);
    }
    if (_held != null) {
      // Glowing border: "swipe them out here!"
      final glow = Pen.inkPaint(Ink.yellow.withValues(alpha: 0.35 + wave(time, 6) * 0.15), 6);
      c.drawRRect(RRect.fromRectAndRadius(GameScene.worldRect.deflate(10), const Radius.circular(22)), glow);
    }
    for (final b in babies) {
      final pos = switch (b.state) {
        _B.walk => b.pos - Offset(0, bump((time * 2.5 + b.phase) % 1) * 5),
        _B.poke => b.pos + Offset(wave(time, 30) * 3, 0),
        _ => b.pos,
      };
      final rot = switch (b.state) {
        _B.dizzy => wave(b.t, 18) * 0.3,
        _B.held => wave(time, 10) * 0.15,
        _ => wave(time, 5, b.phase) * 0.08,
      };
      final mood = b.state == _B.held || b.state == _B.dizzy ? Mood.wow : Mood.happy;
      _drawBaby(c, pos, b.color, b.kind, b.golden, _size * (b.state == _B.held ? 1.15 : 1), mood, rot);
    }
  }

  @override
  String get progressText => tr.progShooed(shooed);

  @override
  void paintProgressIcon(Canvas c, Size s) => sprite(
    c,
    'baby-monster-0-0-false-happy',
    s.center(Offset.zero),
    (c) => Critters.babyMonster(c, _babyColors[0]),
    scale: s.width / 56,
  );
}

final sleepingMonsterGame = GameDefinition(
  gameId: 'dont_wake_the_monster',
  name: (l) => l.gameSleepingMonsterName,
  objective: (l) => l.gameSleepingMonsterGoal,
  instructions: (l) => l.gameSleepingMonsterHowTo,
  interactionType: Interaction.drag,
  accent: Ink.purple,
  scoreConfig: const ScoreConfig(base: 2, bonus: 6),
  assetManifest: const ['monster', 'baby-monster', 'nightcap', 'blanket'],
  create: SleepingMonsterScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, _dusk);
    Thumb.put(c, s, 0.5, 0.92, (c) => Pen.shape(c, Pen.oval(Offset.zero, 110, 26), fill: Ink.tint(Ink.coral, 0.7)));
    Thumb.put(c, s, 0.5, 0.56, (c) => Critters.monster(c), scale: 0.5);
    Thumb.put(c, s, 0.13, 0.3, (c) => Critters.babyMonster(c, Ink.mint), rotation: 0.2, scale: 0.75);
    Thumb.put(c, s, 0.87, 0.72, (c) => Critters.babyMonster(c, Ink.orange, kind: 1), rotation: -0.2, scale: 0.75);
    Thumb.put(c, s, 0.84, 0.22, (c) => Pen.text(c, 'Zz', Offset.zero, size: 18));
  },
);
