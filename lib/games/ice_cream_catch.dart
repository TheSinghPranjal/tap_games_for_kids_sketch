import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

const _flavors = [Ink.pink, Ink.mint, Ink.brown, Color(0xFFFFF0C2), Ink.purple];
const _sky = Color(0xFFDDF0FB);

class _Scoop {
  _Scoop(this.id, this.x, this.vy, this.flavor, this.sprinkles);
  final String id;
  final double x;
  final double vy;
  final int flavor;
  final bool sprinkles;
  double y = IceCreamCatchScene.dropY;

  /// Set once the scoop has passed the cone without landing in it.
  bool missed = false;
}

class IceCreamCatchScene extends GameScene {
  IceCreamCatchScene(this.cfg);
  final ScoreConfig cfg;

  static const dropY = 64.0;
  static const coneY = 516.0; // centre of the cone's rim
  static const groundY = 594.0;
  static const trayAt = Offset(316, 34);

  /// Only one scoop is ever falling; this is it.
  _Scoop? _scoop;
  double coneX = 180;
  double _grab = 0;
  bool _dragging = false;

  /// Waits before the next scoop so there's time to move the new cone.
  double _gap = 0.8;

  /// 0..1 while a fresh empty cone pops in.
  double _conePop = 1;
  int caught = 0;

  @visibleForTesting
  double? get debugScoopX => _scoop?.x;
  @visibleForTesting
  double get debugScoopY => _scoop?.y ?? 0;
  @visibleForTesting
  int get debugScoopIndex => _spawned;
  int _spawned = 0;

  double get _size => ctx.simple ? 1.2 : 1.0;
  double get _interval => ctx.simple ? 1.4 : 1.0;

  @override
  void setup() {}

  @override
  void tick(double dt) {
    _conePop = (_conePop + dt * 3.5).clamp(0, 1);
    final s = _scoop;
    if (s == null) {
      if (ended) return;
      _gap -= dt;
      if (_gap <= 0) _spawn();
      return;
    }
    s.y += s.vy * dt;
    // Scoop reaches the rim: in the cone, or it keeps falling past.
    final rim = coneY - 18 * _size;
    if (!s.missed && s.y >= rim) {
      if ((s.x - coneX).abs() < 34 * _size + ctx.hitPad && _conePop >= 1) {
        _catch(s);
        return;
      }
      s.missed = true;
    }
    if (s.y >= groundY - 10) {
      // A missed scoop just goes splat; nothing is lost.
      fx.burst(Offset(s.x, groundY - 6), colors: [_flavors[s.flavor], Ink.white], count: 8, speed: 70);
      fx.floatText(Offset(s.x, groundY - 40), tr.oops);
      ctx.onSfx(Sfx.soft);
      _scoop = null;
      _gap = _interval;
    }
  }

  void _spawn() {
    _spawned++;
    final speed = (130 + (caught * 5).clamp(0, 80)) * ctx.speed;
    _scoop = _Scoop(newId('scoop'), rand(48, 312), speed, rng.nextInt(_flavors.length), rng.nextDouble() < 0.15);
  }

  void _catch(_Scoop s) {
    _scoop = null;
    _gap = _interval;
    caught++;
    final top = Offset(coneX, coneY - 18 * _size);
    score(s.sprinkles ? cfg.bonus : cfg.base, s.id, top + const Offset(0, -30));
    ctx.onSfx(s.sprinkles ? Sfx.bonus : Sfx.collect);
    fx.burst(top, colors: [_flavors[s.flavor], Ink.yellow, Ink.white], count: s.sprinkles ? 14 : 9);
    // The full cone heads off to the tray and an empty one pops in.
    final flavor = s.flavor, sprinkles = s.sprinkles, size = _size;
    fly(
      Offset(coneX, coneY),
      trayAt,
      0.8,
      (c, p, t) => _drawCone(c, p, size * (1 - t * 0.6), flavor: flavor, sprinkles: sprinkles),
      arc: -60,
      trail: false,
    );
    _conePop = 0;
  }

  static void _drawCone(Canvas c, Offset at, double scale, {int? flavor, bool sprinkles = false}) {
    sprite(c, 'cone', at, (c) => Props.cone(c), scale: scale);
    if (flavor != null) {
      sprite(
        c,
        'scoop-$flavor-$sprinkles',
        at + Offset(0, -18 * scale),
        (c) => Props.scoop(c, _flavors[flavor], sprinkles: sprinkles, seed: flavor + 1),
        scale: scale,
      );
    }
  }

  @override
  bool onDragStart(Offset p) {
    if (ended) return false;
    // Grab anywhere: the cone follows the finger sideways.
    _dragging = true;
    _grab = (p.dx - coneX).abs() < 60 ? coneX - p.dx : 0;
    _moveTo(p.dx + _grab);
    ctx.onSfx(Sfx.tap);
    return true;
  }

  @override
  void onDragMove(Offset p) {
    if (_dragging) _moveTo(p.dx + _grab);
  }

  @override
  void onDragEnd(Offset p) => _dragging = false;

  @override
  void cancelDrag() => _dragging = false;

  void _moveTo(double x) => coneX = x.clamp(32.0, 328.0);

  @override
  void paintBackground(Canvas c) {
    c.drawRect(GameScene.worldRect, Pen.fillPaint(_sky));
    Paper.gridOverlay(c, GameScene.worldRect, alpha: 0.35, cell: 20);
    for (final (o, w) in [
      (const Offset(70, 150), 90.0),
      (const Offset(290, 230), 80.0),
      (const Offset(120, 330), 60.0),
    ]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.cloud(c, w, seed: w.round());
      c.restore();
    }
    // Striped shop awning the scoops drop from.
    const stripe = 360 / 8;
    for (var i = 0; i < 8; i++) {
      final x = i * stripe;
      final scallop = Path()
        ..moveTo(x, -4)
        ..lineTo(x + stripe, -4)
        ..lineTo(x + stripe, 44)
        ..quadraticBezierTo(x + stripe / 2, 66, x, 44)
        ..close();
      Pen.shape(
        c,
        scallop,
        fill: i.isEven ? Ink.coral : Ink.white,
        solid: true,
        hatch: i.isEven ? Ink.shade(Ink.coral, 0.1) : Ink.blushPink,
        seed: i + 1,
        width: 2,
        doubleLine: false,
      );
    }
    Pen.line(c, const Offset(0, 2), const Offset(360, 2), width: 3);
    // Park grass at the bottom.
    groundBand(c, const Rect.fromLTRB(-10, 572, 370, 620), Ink.mint, seed: 4);
    for (final (x, col) in [(28.0, Ink.pink), (110.0, Ink.yellow), (250.0, Ink.white), (338.0, Ink.purple)]) {
      c.save();
      c.translate(x, 604);
      Nature.flower(c, col, r: 9, face: false, seed: x.round());
      c.restore();
    }
  }

  @override
  void paint(Canvas c) {
    final s = _scoop;
    if (s != null && !s.missed) {
      // Shadow on the grass shows where the scoop will land.
      final k = ((s.y - dropY) / (coneY - dropY)).clamp(0.0, 1.0);
      c.drawOval(
        Rect.fromCenter(center: Offset(s.x, groundY - 4), width: 24 + k * 30, height: 8 + k * 4),
        Pen.fillPaint(Ink.navy.withValues(alpha: 0.1 + k * 0.15)),
      );
    }
    final pop = Flight.ease(_conePop);
    _drawCone(c, Offset(coneX, coneY + (1 - pop) * 26), _size * (0.6 + pop * 0.4));
    if (s != null) {
      sprite(
        c,
        'scoop-${s.flavor}-${s.sprinkles}',
        Offset(s.x, s.y),
        (c) => Props.scoop(c, _flavors[s.flavor], sprinkles: s.sprinkles, seed: s.flavor + 1),
        scale: _size,
        rotation: wave(time, 3) * 0.06,
      );
    }
  }

  @override
  String get progressText => tr.progScoops(caught);

  @override
  void paintProgressIcon(Canvas c, Size s) => _drawCone(c, s.center(const Offset(0, -2)), s.width / 92, flavor: 0);
}

final iceCreamCatchGame = GameDefinition(
  gameId: 'ice_cream_catch',
  name: (l) => l.gameIceCreamName,
  objective: (l) => l.gameIceCreamGoal,
  instructions: (l) => l.gameIceCreamHowTo,
  interactionType: Interaction.drag,
  accent: Ink.pink,
  scoreConfig: const ScoreConfig(base: 4, bonus: 8),
  assetManifest: const ['cone', 'scoop', 'awning'],
  create: IceCreamCatchScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, _sky);
    for (var i = 0; i < 6; i++) {
      final w = s.width / 6;
      c.drawRect(Rect.fromLTWH(i * w, 0, w, s.height * 0.14), Pen.fillPaint(i.isEven ? Ink.coral : Ink.white));
    }
    Thumb.put(c, s, 0.5, 1.02, (c) => groundBand(c, const Rect.fromLTRB(-200, -16, 200, 10), Ink.mint));
    Thumb.put(c, s, 0.68, 0.38, (c) => Props.scoop(c, Ink.mint, seed: 2), scale: 0.8);
    Thumb.put(c, s, 0.34, 0.66, (c) {
      Props.cone(c);
      c.translate(0, -18);
      Props.scoop(c, Ink.pink, sprinkles: true);
    }, scale: 0.75);
  },
);
