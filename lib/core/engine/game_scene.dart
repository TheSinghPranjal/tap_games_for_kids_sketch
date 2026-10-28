import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../sketch/ink.dart';
import '../sketch/pen.dart';
import 'audio_manager.dart';

/// What a scene may ask of the session: scoring, sounds and settings.
class GameContext {
  GameContext({
    required this.rng,
    required this.simple,
    required this.reducedMotion,
    required this.onScore,
    required this.onSfx,
  });

  final math.Random rng;
  final bool simple;
  final bool reducedMotion;

  /// Returns false if the event was a duplicate or the round is over.
  final bool Function(int points, String eventKey) onScore;
  final void Function(Sfx sfx) onSfx;

  /// Movement speed multiplier (slower in little-kid mode).
  double get speed => simple ? 0.65 : 1.0;

  /// Extra hit radius in world units.
  double get hitPad => simple ? 16 : 9;

  /// Multiplier for how long objects stay collectable.
  double get patience => simple ? 1.6 : 1.0;
}

/// Base class for every mini-game. Simulation happens in [tick]; drawing in
/// [paintBackground] (static, cached once) and [paint] (per frame).
/// Coordinates are in a fixed 360x620 world scaled to fit the screen.
abstract class GameScene {
  static const world = Size(360, 620);
  static final worldRect = Offset.zero & world;

  late GameContext ctx;
  final fx = Fx();
  final flights = <Flight>[];
  double time = 0;
  bool _ended = false;
  int _ids = 0;

  bool get ended => _ended;
  math.Random get rng => ctx.rng;
  double rand(double a, double b) => a + rng.nextDouble() * (b - a);
  T pick<T>(List<T> items) => items[rng.nextInt(items.length)];
  String newId(String prefix) => '$prefix-${_ids++}';

  void attach(GameContext context) {
    ctx = context;
    fx.reduced = context.reducedMotion;
    setup();
  }

  void setup();
  void tick(double dt);
  void paintBackground(Canvas c);
  void paint(Canvas c);

  /// Number/label shown next to [paintProgressIcon] in the HUD.
  String get progressText;
  void paintProgressIcon(Canvas c, Size s);

  /// Only games that use lives override this.
  int? get lives => null;

  void onTap(Offset p) {}
  bool onDragStart(Offset p) => false;
  void onDragMove(Offset p) {}
  void onDragEnd(Offset p) {}
  void cancelDrag() {}

  void update(double dt) {
    time += dt;
    tick(dt);
    for (final f in List.of(flights)) {
      f.update(dt);
      if (f.done) flights.remove(f);
    }
    fx.update(dt);
  }

  void paintEffects(Canvas c) {
    for (final f in flights) {
      f.paint(c);
    }
    fx.paint(c);
  }

  /// Stops spawning and disables further score-generating input.
  void end() {
    _ended = true;
    cancelDrag();
  }

  /// Scores once per [key]; shows a floating "+n" at [at].
  bool score(int points, String key, Offset at) {
    if (_ended) return false;
    final ok = ctx.onScore(points, key);
    if (ok) fx.floatText(at, '+$points');
    return ok;
  }

  Flight fly(
    Offset from,
    Offset to,
    double duration,
    void Function(Canvas c, Offset p, double t) draw, {
    double arc = -80,
    void Function()? onArrive,
    bool trail = true,
  }) {
    final f = Flight(from, to, duration, draw, arc: arc, onArrive: onArrive, trail: trail && !fx.reduced);
    flights.add(f);
    return f;
  }

  /// Picks a point inside [area] at least [gap] from every point in [others].
  Offset freeSpot(Rect area, Iterable<Offset> others, double gap, {int tries = 24}) {
    var best = area.center;
    var bestD = -1.0;
    for (var i = 0; i < tries; i++) {
      final p = Offset(rand(area.left, area.right), rand(area.top, area.bottom));
      var d = double.infinity;
      for (final o in others) {
        d = math.min(d, (o - p).distance);
      }
      if (d >= gap) return p;
      if (d > bestD) {
        bestD = d;
        best = p;
      }
    }
    return best;
  }
}

/// An object travelling along a curved (quadratic) path, e.g. into a basket.
class Flight {
  Flight(this.from, this.to, this.duration, this.draw, {this.arc = -80, this.onArrive, this.trail = true})
    : control = Offset((from.dx + to.dx) / 2, math.min(from.dy, to.dy) + arc);

  final Offset from, to, control;
  final double duration;
  final double arc;
  final void Function(Canvas c, Offset p, double t) draw;
  final void Function()? onArrive;
  final bool trail;
  double elapsed = 0;
  bool done = false;

  double get t => (elapsed / duration).clamp(0.0, 1.0);

  Offset at(double t) {
    final u = 1 - t;
    return from * (u * u) + control * (2 * u * t) + to * (t * t);
  }

  static double ease(double t) => t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2) / 2;

  void update(double dt) {
    if (done) return;
    elapsed += dt;
    if (elapsed >= duration) {
      done = true;
      onArrive?.call();
    }
  }

  void paint(Canvas c) {
    final e = ease(t);
    final p = at(e);
    if (trail && e > 0.05 && e < 0.95) {
      // Pencil motion lines behind the object.
      final back = at(math.max(0, e - 0.12));
      final dir = (p - back);
      if (dir.distance > 4) {
        final n = Offset(-dir.dy, dir.dx) / dir.distance;
        final paint = Pen.inkPaint(Ink.navy.withValues(alpha: 0.35), 1.6);
        for (final k in [-7.0, 0.0, 7.0]) {
          final a = back + n * k;
          c.drawLine(a, a + dir * 0.55, paint);
        }
      }
    }
    draw(c, p, e);
  }
}

enum _P { sparkle, confetti, ring, text, heart, drop, plus }

class _Particle {
  _P kind = _P.sparkle;
  Offset pos = Offset.zero;
  Offset vel = Offset.zero;
  double life = 0, maxLife = 1, size = 4, rot = 0, spin = 0, gravity = 0;
  Color color = Ink.yellow;
  String text = '';
}

/// Lightweight pooled particle effects. Capped so rapid tapping on a budget
/// phone never creates unbounded objects.
class Fx {
  static const cap = 140;
  final _live = <_Particle>[];
  final _pool = <_Particle>[];
  final _texts = <String, TextPainter>{};
  bool reduced = false;
  final _r = math.Random();

  _Particle? _spawn() {
    if (_live.length >= cap) return null;
    final p = _pool.isNotEmpty ? _pool.removeLast() : _Particle();
    p
      ..life = 0
      ..rot = 0
      ..spin = 0
      ..gravity = 0
      ..vel = Offset.zero;
    _live.add(p);
    return p;
  }

  void burst(Offset at, {int count = 8, List<Color>? colors, double speed = 90, double size = 5}) {
    final n = reduced ? (count / 2).ceil() : count;
    for (var i = 0; i < n; i++) {
      final p = _spawn();
      if (p == null) return;
      final a = i / n * math.pi * 2 + _r.nextDouble() * 0.5;
      final s = speed * (0.6 + _r.nextDouble() * 0.6) * (reduced ? 0.5 : 1);
      p
        ..kind = i.isEven ? _P.sparkle : _P.plus
        ..pos = at
        ..vel = Offset(math.cos(a), math.sin(a)) * s
        ..maxLife = 0.55 + _r.nextDouble() * 0.25
        ..size = size * (0.7 + _r.nextDouble() * 0.6)
        ..color = (colors ?? const [Ink.yellow, Ink.coral, Ink.blue])[i % (colors?.length ?? 3)];
    }
  }

  void confetti(Offset at, {int count = 14, List<Color> colors = Ink.bright}) {
    final n = reduced ? count ~/ 3 : count;
    for (var i = 0; i < n; i++) {
      final p = _spawn();
      if (p == null) return;
      final a = -math.pi / 2 + (_r.nextDouble() - 0.5) * 2.6;
      p
        ..kind = _P.confetti
        ..pos = at
        ..vel = Offset(math.cos(a), math.sin(a)) * (70 + _r.nextDouble() * 90)
        ..gravity = 220
        ..maxLife = 0.9 + _r.nextDouble() * 0.4
        ..size = 4 + _r.nextDouble() * 3
        ..spin = reduced ? 0 : (_r.nextDouble() - 0.5) * 12
        ..color = colors[i % colors.length];
    }
  }

  void ring(Offset at, {double radius = 30, Color color = Ink.navy}) {
    final p = _spawn();
    if (p == null) return;
    p
      ..kind = _P.ring
      ..pos = at
      ..size = radius
      ..maxLife = 0.45
      ..color = color;
  }

  void splash(Offset at, {Color color = Ink.blue}) {
    ring(at, radius: 26, color: color);
    for (var i = 0; i < (reduced ? 3 : 6); i++) {
      final p = _spawn();
      if (p == null) return;
      final a = -math.pi / 2 + (i - 2.5) * 0.35;
      p
        ..kind = _P.drop
        ..pos = at
        ..vel = Offset(math.cos(a), math.sin(a)) * (80 + _r.nextDouble() * 40)
        ..gravity = 300
        ..maxLife = 0.5
        ..size = 3 + _r.nextDouble() * 2
        ..color = color;
    }
  }

  void hearts(Offset at, {int count = 3, Color color = Ink.coral}) {
    for (var i = 0; i < count; i++) {
      final p = _spawn();
      if (p == null) return;
      p
        ..kind = _P.heart
        ..pos = at + Offset((i - (count - 1) / 2) * 16, 0)
        ..vel = Offset((i - (count - 1) / 2) * 12, -55 - _r.nextDouble() * 20)
        ..maxLife = 1.0
        ..size = 6
        ..color = color;
    }
  }

  void floatText(Offset at, String text, {Color color = Ink.navy}) {
    final p = _spawn();
    if (p == null) return;
    p
      ..kind = _P.text
      ..pos = at + const Offset(0, -18)
      ..vel = const Offset(0, -48)
      ..maxLife = 0.9
      ..color = color
      ..text = text;
  }

  void update(double dt) {
    for (var i = _live.length - 1; i >= 0; i--) {
      final p = _live[i];
      p.life += dt;
      if (p.life >= p.maxLife) {
        _live.removeAt(i);
        _pool.add(p);
        continue;
      }
      p.vel = Offset(p.vel.dx * (1 - dt * 1.5), p.vel.dy * (1 - dt * 1.5) + p.gravity * dt);
      p.pos += p.vel * dt;
      p.rot += p.spin * dt;
    }
  }

  void paint(Canvas c) {
    for (final p in _live) {
      final k = p.life / p.maxLife;
      final alpha = (1 - k * k).clamp(0.0, 1.0);
      switch (p.kind) {
        case _P.sparkle:
          Pen.twinkle(c, p.pos, p.size * (1.2 - k * 0.5), p.color.withValues(alpha: alpha));
        case _P.plus:
          Pen.plus(c, p.pos, p.size * 0.9, p.color.withValues(alpha: alpha), width: 2);
        case _P.confetti:
          c.save();
          c.translate(p.pos.dx, p.pos.dy);
          c.rotate(p.rot);
          c.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
            Paint()..color = p.color.withValues(alpha: alpha),
          );
          c.restore();
        case _P.ring:
          c.drawCircle(p.pos, p.size * (0.5 + k * 0.8), Pen.inkPaint(p.color.withValues(alpha: alpha * 0.7), 2));
        case _P.drop:
          c.drawCircle(p.pos, p.size, Paint()..color = p.color.withValues(alpha: alpha));
        case _P.heart:
          c.drawPath(Pen.heartPath(p.pos, p.size), Paint()..color = p.color.withValues(alpha: alpha));
        case _P.text:
          final tp = _texts.putIfAbsent(
            p.text,
            () => TextPainter(
              text: TextSpan(
                text: p.text,
                style: const TextStyle(
                  color: Ink.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Ink.white, blurRadius: 0, offset: Offset(1.5, 1.5))],
                ),
              ),
              textDirection: TextDirection.ltr,
            )..layout(),
          );
          c.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, alpha));
          tp.paint(c, p.pos - Offset(tp.width / 2, tp.height / 2));
          c.restore();
      }
    }
  }
}
