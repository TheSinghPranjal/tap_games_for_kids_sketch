import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

/// Drag fish from the pile to the hungry penguin until it has eaten as many
/// as it asked for.
class FeedPenguinScene extends GameScene {
  FeedPenguinScene(this.cfg);
  final ScoreConfig cfg;

  static const penguinAt = Offset(240, 380);
  static const mouth = Offset(240, 336);
  static const pileAt = Offset(84, 488);

  int request = 3, eaten = 0, meals = 0;
  int? _heldColor;
  Offset _held = Offset.zero;
  double _chomp = 1, _happy = 0;

  double get _size => ctx.simple ? 1.15 : 1.0;

  @visibleForTesting
  bool get debugReady => _happy <= 0;

  @override
  void setup() => _newRequest();

  void _newRequest() {
    request = ctx.simple ? 1 + rng.nextInt(3) : 2 + rng.nextInt(4);
    eaten = 0;
  }

  @override
  void tick(double dt) {
    _chomp = (_chomp + dt * 3).clamp(0, 1);
    if (_happy > 0) {
      _happy -= dt;
      if (_happy <= 0 && !ended) _newRequest();
    }
  }

  @override
  bool onDragStart(Offset p) {
    if (ended || _happy > 0) return false;
    if ((p - pileAt).distance > 80 + ctx.hitPad) return false;
    // Every grab takes a fresh fish off the pile.
    _heldColor = rng.nextInt(Critters.fishColors.length);
    _held = p;
    ctx.onSfx(Sfx.tap);
    return true;
  }

  @override
  void onDragMove(Offset p) => _held = p;

  @override
  void onDragEnd(Offset p) {
    final color = _heldColor;
    _heldColor = null;
    if (color == null) return;
    if ((_held - mouth).distance > 70 * _size + ctx.hitPad || ended) {
      // Not at the penguin: the fish flops back onto the pile.
      fly(
        _held,
        pileAt + const Offset(0, -20),
        0.35,
        (c, pos, t) => _fish(c, color, pos, t * 3),
        arc: -30,
        trail: false,
      );
      return;
    }
    eaten++;
    _chomp = 0;
    ctx.onSfx(Sfx.pop);
    fx.hearts(mouth + const Offset(0, -20), count: 2);
    fly(_held, mouth, 0.18, (c, pos, t) => _fish(c, color, pos, 0, 1 - t * 0.7), trail: false);
    if (eaten >= request) {
      // Meal complete: points grow with the number of fish asked for.
      meals++;
      score(cfg.base * request, 'meal-$meals', mouth + const Offset(0, -60));
      ctx.onSfx(Sfx.cheer);
      fx.confetti(mouth);
      _happy = 1.6;
    }
  }

  @override
  void cancelDrag() => _heldColor = null;

  void _fish(Canvas c, int color, Offset at, [double rotation = 0, double scale = 1]) => sprite(
    c,
    'fish-$color',
    at,
    (c) => Critters.fish(c, Critters.fishColors[color], seed: color + 1),
    scale: 0.8 * scale,
    rotation: rotation,
  );

  @override
  void paintBackground(Canvas c) {
    c.drawRect(GameScene.worldRect, Pen.fillPaint(Ink.tint(Ink.sky, 0.4)));
    Paper.gridOverlay(c, GameScene.worldRect, alpha: 0.3, cell: 20);
    for (final (o, w) in [(const Offset(80, 90), 90.0), (const Offset(290, 150), 70.0)]) {
      c.save();
      c.translate(o.dx, o.dy);
      Nature.cloud(c, w, seed: w.round());
      c.restore();
    }
    // Sea, an ice floe for the penguin and a snowy bank with the fish pile.
    waterBody(c, Path()..addRect(const Rect.fromLTRB(-10, 300, 370, 630)), color: Ink.tint(Ink.blue, 0.6), seed: 4);
    Pen.shape(c, Pen.oval(const Offset(240, 440), 110, 34), fill: Ink.white, solid: true, hatch: Ink.sky, seed: 5);
    Pen.shape(c, Pen.oval(const Offset(80, 540), 130, 60), fill: Ink.white, solid: true, hatch: Ink.sky, seed: 6);
    // Bucket of fish.
    final bucket = Pen.poly(const [Offset(36, 470), Offset(132, 470), Offset(120, 540), Offset(48, 540)]);
    Pen.shape(c, bucket, fill: Ink.coral, solid: true, hatch: Ink.shade(Ink.coral, 0.15), seed: 7);
    for (var i = 0; i < 4; i++) {
      c.save();
      c.translate(56 + i * 18.0, 466 - (i.isEven ? 4 : 10));
      c.rotate(i.isEven ? -0.5 : 0.4);
      c.scale(0.55);
      Critters.fish(c, Critters.fishColors[i], seed: i + 1);
      c.restore();
    }
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(30, 462, 108, 14), 5),
      fill: Ink.shade(Ink.coral, 0.1),
      solid: true,
      seed: 8,
    );
  }

  @override
  void paint(Canvas c) {
    // Speech bubble: one fish slot per fish asked for, filled in as it eats.
    final bubble = Rect.fromCenter(center: const Offset(196, 196), width: 40.0 * request + 30, height: 74);
    Pen.shape(c, Pen.rrect(bubble, 22), fill: Ink.white, solid: true, seed: 3, width: 2.4);
    Pen.shape(
      c,
      Pen.poly([
        bubble.bottomCenter + const Offset(14, -2),
        bubble.bottomCenter + const Offset(34, -2),
        mouth + const Offset(-6, -46),
      ]),
      fill: Ink.white,
      solid: true,
      width: 0,
    );
    for (var i = 0; i < request; i++) {
      final at = Offset(bubble.left + 35 + i * 40.0, bubble.center.dy);
      if (i < eaten) {
        Pen.shape(c, Pen.circle(at, 16), fill: Ink.tint(Ink.mint, 0.5), solid: true, width: 1.6, doubleLine: false);
        Pen.line(c, at + const Offset(-7, 0), at + const Offset(-2, 6), ink: Ink.leaf, width: 3);
        Pen.line(c, at + const Offset(-2, 6), at + const Offset(8, -6), ink: Ink.leaf, width: 3);
      } else {
        sprite(c, 'want-fish', at, (c) => Critters.fish(c, Ink.tint(Ink.navy, 0.25), seed: 9), scale: 0.45);
      }
    }
    final hop = _happy > 0 ? bump((_happy * 2) % 1) * 18 : 0.0;
    final mood = _chomp < 0.4 ? Mood.chomp : (_happy > 0 ? Mood.wow : Mood.happy);
    final (sx, sy) = squash(_chomp, 0.1);
    sprite(
      c,
      'feed-penguin-${mood.name}',
      penguinAt - Offset(0, hop),
      (c) => Critters.penguin(c, mood: mood),
      scale: 2.0 * _size,
      sx: sx,
      sy: sy,
    );
    final held = _heldColor;
    if (held != null) _fish(c, held, _held, wave(time, 10) * 0.15, 1.2);
  }

  @override
  String get progressText => tr.progMeals(meals);

  @override
  void paintProgressIcon(Canvas c, Size s) => sprite(
    c,
    'fish-3',
    s.center(Offset.zero),
    (c) => Critters.fish(c, Critters.fishColors[3], seed: 4),
    scale: s.width / 72,
  );
}

final feedPenguinGame = GameDefinition(
  gameId: 'feed_the_penguin',
  name: (l) => l.gameFeedPenguinName,
  objective: (l) => l.gameFeedPenguinGoal,
  instructions: (l) => l.gameFeedPenguinHowTo,
  interactionType: Interaction.drag,
  accent: Ink.blue,
  scoreConfig: const ScoreConfig(base: 2, bonus: 8),
  assetManifest: const ['penguin', 'fish', 'bucket', 'ice'],
  create: FeedPenguinScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, Ink.tint(Ink.sky, 0.4));
    Thumb.put(
      c,
      s,
      0.5,
      0.95,
      (c) => waterBody(c, Path()..addRect(const Rect.fromLTRB(-200, -16, 200, 30)), color: Ink.tint(Ink.blue, 0.6)),
    );
    Thumb.put(c, s, 0.68, 0.55, (c) => Critters.penguin(c, mood: Mood.chomp), scale: 1.1);
    Thumb.put(c, s, 0.28, 0.45, (c) => Critters.fish(c, Critters.fishColors[3], seed: 4), rotation: 0.3, scale: 0.9);
  },
);
