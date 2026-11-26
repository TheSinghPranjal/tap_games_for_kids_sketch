import 'common.dart';

enum _Kind { shell, starfish, golden }

const _shellColors = [Ink.pink, Ink.coral, Ink.purple];

class _Treasure {
  _Treasure(this.id, this.pos, this.kind, this.color, this.life);
  final String id;
  final Offset pos;
  final _Kind kind;
  final int color;
  final double life;
  double t = 0;
  bool taken = false;
}

class _Crab {
  _Crab(this.pos, this.vx);
  Offset pos;
  double vx;
  double wiggle = 0;
}

void _drawTreasure(
  Canvas c,
  _Kind kind,
  int color,
  Offset at, {
  double scale = 1,
  double rotation = 0,
  double opacity = 1,
}) {
  switch (kind) {
    case _Kind.shell:
      sprite(
        c,
        'shell-$color',
        at,
        (c) => Props.seashell(c, _shellColors[color], seed: color + 1),
        scale: scale,
        rotation: rotation,
        opacity: opacity,
      );
    case _Kind.starfish:
      sprite(
        c,
        'starfish',
        at,
        (c) => Props.starfish(c, Ink.orange),
        scale: scale,
        rotation: rotation,
        opacity: opacity,
      );
    case _Kind.golden:
      sprite(
        c,
        'shell-gold',
        at,
        (c) => Props.seashell(c, Ink.gold, seed: 9),
        scale: scale * 1.2,
        rotation: rotation,
        opacity: opacity,
      );
  }
}

class BeachScene extends GameScene {
  BeachScene(this.cfg);
  final ScoreConfig cfg;

  static const chestAt = Offset(292, 560);
  static const area = Rect.fromLTRB(40, 200, 320, 470);

  final items = <_Treasure>[];
  final crabs = [_Crab(const Offset(70, 520), 22), _Crab(const Offset(200, 600), -16)];
  int found = 0;
  double _spawnIn = 0, _lid = 1;

  void _spawn() {
    final r = rng.nextDouble();
    final kind = r < 0.1 ? _Kind.golden : (r < 0.45 ? _Kind.starfish : _Kind.shell);
    final p = freeSpot(area, items.map((t) => t.pos), 76);
    items.add(_Treasure(newId('treasure'), p, kind, rng.nextInt(_shellColors.length), rand(6.5, 8.5) * ctx.patience));
  }

  @override
  void setup() {
    for (var i = 0; i < 4; i++) {
      _spawn();
    }
  }

  @override
  void tick(double dt) {
    _lid = (_lid + dt * 2.5).clamp(0, 1);
    for (final t in items) {
      t.t += dt;
    }
    items.removeWhere((t) => t.taken || t.t > t.life);
    for (final c in crabs) {
      c.wiggle = (c.wiggle - dt * 2).clamp(0, 1);
      c.pos += Offset(c.vx * dt * ctx.speed, 0);
      if (c.pos.dx < 30 || c.pos.dx > 230) c.vx = -c.vx;
    }
    if (!ended && items.length < (ctx.simple ? 4 : 5)) {
      _spawnIn -= dt;
      if (_spawnIn <= 0) {
        _spawn();
        _spawnIn = rand(0.6, 1.2);
      }
    }
  }

  @override
  void onTap(Offset p) {
    for (final t in items) {
      if (t.taken || (t.pos - p).distance > 30 + ctx.hitPad) continue;
      t.taken = true;
      found++;
      final golden = t.kind == _Kind.golden;
      score(golden ? cfg.bonus : cfg.base, t.id, t.pos);
      ctx.onSfx(golden ? Sfx.bonus : Sfx.collect);
      fx.burst(t.pos, colors: golden ? const [Ink.gold, Ink.yellow] : const [Ink.yellow, Ink.coral, Ink.white]);
      final kind = t.kind, color = t.color;
      fly(
        t.pos,
        chestAt + const Offset(0, -16),
        0.8,
        (c, at, k) {
          _drawTreasure(c, kind, color, at, scale: 1.1 - k * 0.5, rotation: k * 4);
        },
        arc: -80,
        onArrive: () => _lid = 0,
      );
      return;
    }
    for (final c in crabs) {
      if ((c.pos - p).distance < 34) {
        c.wiggle = 1; // just a friendly wave
        ctx.onSfx(Sfx.soft);
      }
    }
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect, base: Ink.paperWarm);
    final sea = Path()
      ..moveTo(-4, -4)
      ..lineTo(364, -4)
      ..lineTo(364, 140)
      ..quadraticBezierTo(270, 165, 180, 140)
      ..quadraticBezierTo(90, 118, -4, 150)
      ..close();
    groundBand(c, const Rect.fromLTRB(0, 130, 360, 620), Ink.sand, seed: 6, wobble: 4);
    waterBody(c, sea, color: Ink.sky, seed: 3);
    final foam = Path()
      ..moveTo(-4, 152)
      ..quadraticBezierTo(90, 122, 180, 146)
      ..quadraticBezierTo(270, 170, 364, 144);
    Pen.stroke(c, foam, ink: Ink.white, width: 5, seed: 4);
    Pen.stroke(c, foam, ink: Ink.navy, width: 1.6, seed: 6);
    final dots = Random(4);
    for (var i = 0; i < 70; i++) {
      Pen.dot(c, Offset(dots.nextDouble() * 360, 170 + dots.nextDouble() * 450), 1.2, Ink.brown.withValues(alpha: 0.4));
    }
    c.save();
    c.translate(300, 50);
    Nature.sun(c, 20);
    c.restore();
  }

  @override
  void paint(Canvas c) {
    for (final t in items) {
      final fadeIn = (t.t / 0.3).clamp(0.0, 1.0);
      final fadeOut = ((t.life - t.t) / 0.6).clamp(0.0, 1.0);
      final wig = fx.reduced ? 0.0 : wave(time, 3, t.pos.dx) * 0.12;
      if (t.kind == _Kind.golden) c.drawCircle(t.pos, 34, Paint()..color = Ink.gold.withValues(alpha: 0.22 * fadeOut));
      _drawTreasure(
        c,
        t.kind,
        t.color,
        t.pos,
        scale: (ctx.simple ? 1.35 : 1.15) * (0.5 + fadeIn * 0.5),
        rotation: wig,
        opacity: fadeOut,
      );
      if (((time + t.pos.dx) % 2.2) < 0.4) Pen.twinkle(c, t.pos + const Offset(18, -18), 5, Ink.white);
    }
    for (final cr in crabs) {
      final hop = bump(cr.wiggle) * 10;
      sprite(
        c,
        'crab',
        cr.pos - Offset(0, hop),
        Critters.crab,
        scale: 0.9,
        rotation: wave(time * 6 + cr.pos.dx) * 0.05 + wave(cr.wiggle * 18) * 0.2 * cr.wiggle,
      );
    }
    c.save();
    c.translate(chestAt.dx, chestAt.dy);
    Props.chest(c: c, open: true, lift: bump(_lid) * 0.3);
    c.restore();
  }

  @override
  String get progressText => tr.progTreasures(found);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      _drawTreasure(c, _Kind.shell, 0, s.center(Offset.zero), scale: s.width / 40);
}

final beachTreasuresGame = GameDefinition(
  gameId: 'sandy_beach_treasures',
  name: (l) => l.gameBeachTreasuresName,
  objective: (l) => l.gameBeachTreasuresGoal,
  instructions: (l) => l.gameBeachTreasuresHowTo,
  interactionType: Interaction.tap,
  accent: Ink.sand,
  assetManifest: const ['seashell', 'starfish', 'crab', 'chest'],
  create: BeachScene.new,
  thumbnail: (c, s) {
    Thumb.scene(c, s, Ink.tint(Ink.sand, 0.8));
    Thumb.put(c, s, 0.5, 0.05, (c) => waterBody(c, Path()..addRect(const Rect.fromLTRB(-200, -20, 200, 18))));
    Thumb.put(c, s, 0.25, 0.55, (c) => Props.seashell(c, Ink.pink));
    Thumb.put(c, s, 0.5, 0.72, (c) => Props.starfish(c, Ink.orange));
    Thumb.put(c, s, 0.8, 0.68, (c) => Props.chest(c: c, open: true), scale: 0.7);
  },
);
