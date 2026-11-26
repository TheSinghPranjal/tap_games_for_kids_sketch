import 'common.dart';

enum _Home { toyBox, shelf, laundry }

enum _Kind { teddy, ball, car, block, bookRed, bookBlue, bookGreen, sock, shirt, pants }

extension on _Kind {
  _Home get home => switch (this) {
    _Kind.teddy || _Kind.ball || _Kind.car || _Kind.block => _Home.toyBox,
    _Kind.bookRed || _Kind.bookBlue || _Kind.bookGreen => _Home.shelf,
    _Kind.sock || _Kind.shirt || _Kind.pants => _Home.laundry,
  };
}

void _drawItem(Canvas c, _Kind k) {
  switch (k) {
    case _Kind.teddy:
      Props.teddy(c);
    case _Kind.ball:
      Props.toyBall(c);
    case _Kind.car:
      Props.toyCar(c);
    case _Kind.block:
      Props.block(c, Ink.yellow, 'A');
    case _Kind.bookRed:
      Props.book(c, Ink.coral);
    case _Kind.bookBlue:
      Props.book(c, Ink.blue);
    case _Kind.bookGreen:
      Props.book(c, Ink.mint);
    case _Kind.sock:
      Props.sock(c, Ink.pink);
    case _Kind.shirt:
      Props.shirt(c, Ink.sky);
    case _Kind.pants:
      Props.pants(c, Ink.purple);
  }
}

class _Item {
  _Item(this.kind, this.pos);
  final _Kind kind;
  Offset pos;
  Offset rest = Offset.zero;
  bool stored = false;
  bool moving = false;
  int gen = 0;
}

class CleanRoomScene extends GameScene {
  CleanRoomScene(this.cfg);
  final ScoreConfig cfg;

  static const _zones = {
    _Home.toyBox: Rect.fromLTWH(18, 470, 120, 82),
    _Home.shelf: Rect.fromLTWH(238, 150, 104, 150),
    _Home.laundry: Rect.fromLTWH(238, 470, 104, 90),
  };
  static const tapModeBtn = Rect.fromLTWH(112, 8, 66, 40);
  static const dragModeBtn = Rect.fromLTWH(182, 8, 66, 40);
  static const _messSpots = [
    Offset(60, 330),
    Offset(140, 300),
    Offset(110, 400),
    Offset(190, 380),
    Offset(200, 460),
    Offset(70, 235),
    Offset(150, 230),
    Offset(180, 560),
    Offset(285, 395),
    Offset(130, 500),
  ];

  final items = [for (final k in _Kind.values) _Item(k, Offset.zero)];
  bool dragMode = false;
  _Item? _dragging;
  Offset _grab = Offset.zero;
  int tidied = 0, rounds = 0;
  double _celebrate = 0;

  double get cleanliness => items.where((i) => i.stored).length / items.length;

  @override
  void setup() => _makeMess(animate: false);

  void _makeMess({bool animate = true}) {
    final spots = List.of(_messSpots)..shuffle(rng);
    for (final (n, it) in items.indexed) {
      final from = it.stored ? _slot(it) : it.pos;
      it
        ..stored = false
        ..gen += 1
        ..rest = spots[n];
      if (animate) {
        // Items come back out of their storage, never vanish.
        it.moving = true;
        final kind = it.kind;
        fly(
          from,
          it.rest,
          0.7 + n * 0.04,
          (c, p, t) => sprite(c, 'room-${kind.name}', p, (c) => _drawItem(c, kind), rotation: t * 6.28),
          arc: -90,
          onArrive: () {
            it
              ..pos = it.rest
              ..moving = false;
          },
        );
      } else {
        it.pos = it.rest;
      }
    }
  }

  /// Where a stored item sits inside its storage.
  Offset _slot(_Item it) {
    final z = _zones[it.kind.home]!;
    final same = _Kind.values.where((k) => k.home == it.kind.home).toList();
    final i = same.indexOf(it.kind);
    return switch (it.kind.home) {
      _Home.toyBox => Offset(z.left + 22 + i * 25.0, z.top + 6),
      _Home.shelf => Offset(z.left + 22 + i * 30.0, z.top + 36),
      _Home.laundry => Offset(z.left + 26 + i * 26.0, z.top + 14),
    };
  }

  void _store(_Item it, {bool snap = false}) {
    it.moving = true;
    tidied++;
    score(cfg.base, 'tidy-${it.kind.name}-${it.gen}', it.pos);
    ctx.onSfx(Sfx.collect);
    final kind = it.kind, to = _slot(it);
    fly(
      it.pos,
      to,
      snap ? 0.25 : 0.75,
      (c, p, t) => sprite(c, 'room-${kind.name}', p, (c) => _drawItem(c, kind), scale: 1 - t * 0.25),
      arc: snap ? -10 : -110,
      trail: !snap,
      onArrive: () {
        it
          ..stored = true
          ..moving = false
          ..pos = to;
        fx.burst(to, count: 6);
        if (items.every((i) => i.stored)) {
          rounds++;
          _celebrate = 1.8;
          score(cfg.bonus, 'room-clean-$rounds', const Offset(180, 140));
          ctx.onSfx(Sfx.cheer);
          fx.confetti(const Offset(180, 200));
        }
      },
    );
  }

  _Item? _itemAt(Offset p) {
    _Item? best;
    var bestD = 32 + ctx.hitPad;
    for (final it in items) {
      if (it.stored || it.moving) continue;
      final d = (it.pos - p).distance;
      if (d < bestD) {
        bestD = d;
        best = it;
      }
    }
    return best;
  }

  bool _modeButtons(Offset p) {
    if (tapModeBtn.inflate(6).contains(p)) {
      if (dragMode) ctx.onSfx(Sfx.tap);
      dragMode = false;
      return true;
    }
    if (dragModeBtn.inflate(6).contains(p)) {
      if (!dragMode) ctx.onSfx(Sfx.tap);
      dragMode = true;
      return true;
    }
    return false;
  }

  @override
  void tick(double dt) {
    if (_celebrate > 0) {
      _celebrate -= dt;
      if (_celebrate <= 0 && !ended) _makeMess();
    }
  }

  @override
  void onTap(Offset p) {
    if (_modeButtons(p) || dragMode) return;
    final it = _itemAt(p);
    if (it != null) _store(it);
  }

  @override
  bool onDragStart(Offset p) {
    if (!dragMode || ended) return false;
    final it = _itemAt(p);
    if (it == null) return false;
    _dragging = it;
    _grab = it.pos - p;
    ctx.onSfx(Sfx.tap);
    return true;
  }

  @override
  void onDragMove(Offset p) {
    _dragging?.pos = p + _grab;
  }

  @override
  void onDragEnd(Offset p) {
    final it = _dragging;
    _dragging = null;
    if (it == null) return;
    if (_zones[it.kind.home]!.inflate(28).contains(it.pos)) {
      _store(it, snap: true);
    } else {
      _returnHome(it);
    }
  }

  /// Wrong place (or released outside the room): glide gently back.
  void _returnHome(_Item it) {
    it.moving = true;
    final kind = it.kind;
    fly(
      it.pos,
      it.rest,
      0.4,
      (c, p, t) => sprite(c, 'room-${kind.name}', p, (c) => _drawItem(c, kind)),
      arc: -20,
      trail: false,
      onArrive: () {
        it
          ..pos = it.rest
          ..moving = false;
      },
    );
  }

  @override
  void cancelDrag() {
    final it = _dragging;
    _dragging = null;
    if (it != null) _returnHome(it);
  }

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    // Wall / floor.
    Pen.shape(
      c,
      Pen.poly(const [Offset(-4, 420), Offset(364, 420), Offset(364, 624), Offset(-4, 624)]),
      fill: Ink.sand,
      seed: 2,
      hatchAngle: 0.1,
      hatchGap: 9,
    );
    for (var y = 450.0; y < 620; y += 34) {
      Pen.line(c, Offset(0, y), Offset(360, y), ink: Ink.brown.withValues(alpha: 0.5), width: 1.4, seed: y.round());
    }
    // Window.
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(30, 70, 110, 90), 4), fill: Ink.sky, seed: 3);
    Pen.line(c, const Offset(85, 70), const Offset(85, 160), width: 2.4);
    Pen.line(c, const Offset(30, 115), const Offset(140, 115), width: 2.4);
    c.save();
    c.translate(60, 95);
    Nature.sun(c, 10, face: false);
    c.restore();
    // Bed.
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(14, 260, 200, 90), 10), fill: Ink.pink, seed: 4);
    Pen.shape(c, Pen.rrect(const Rect.fromLTWH(10, 220, 22, 150), 6), fill: Ink.brown, seed: 5);
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(30, 248, 60, 30), 12),
      fill: Ink.white,
      solid: true,
      hatch: Ink.sky,
      seed: 6,
    );
    // Rug.
    Pen.shape(c, Pen.oval(const Offset(170, 520), 80, 26), fill: Ink.purple, seed: 7, cross: true);
    // Shelf.
    final shelf = _zones[_Home.shelf]!;
    Pen.shape(c, Pen.rrect(shelf, 4), fill: Ink.brown, seed: 8);
    for (final y in [shelf.top + 58, shelf.top + 110]) {
      Pen.line(c, Offset(shelf.left, y), Offset(shelf.right, y), width: 3);
    }
    c.save();
    c.translate(shelf.center.dx, shelf.top + 90);
    Nature.flower(c, Ink.coral, r: 14, face: false);
    c.restore();
    // Toy box.
    final box = _zones[_Home.toyBox]!;
    Pen.shape(c, Pen.rrect(box, 6), fill: Ink.blue, seed: 9);
    Pen.text(c, tr.gameToyBox, box.center + const Offset(0, 10), size: 18, color: Ink.white, maxWidth: box.width - 8);
    // Laundry basket.
    final lb = _zones[_Home.laundry]!;
    Pen.shape(
      c,
      Pen.poly([lb.topLeft, lb.topRight, lb.bottomRight - const Offset(10, 0), lb.bottomLeft + const Offset(10, 0)]),
      fill: Ink.cream,
      solid: true,
      hatch: Ink.brown,
      cross: true,
      seed: 10,
    );
  }

  @override
  void paint(Canvas c) {
    // Mode toggle: Tap or Drag.
    for (final (r, on, label) in [
      (tapModeBtn, !dragMode, tr.interactionTap),
      (dragModeBtn, dragMode, tr.interactionDrag),
    ]) {
      sprite(c, 'room-mode-$label-$on', r.center, (c) {
        Pen.shape(
          c,
          Pen.rrect(Rect.fromCenter(center: Offset.zero, width: r.width, height: r.height), 14),
          fill: on ? Ink.blushPink : Ink.white,
          solid: true,
          seed: label.length,
          width: on ? 2.6 : 1.8,
        );
        Pen.text(c, label, Offset.zero, size: 17, color: on ? Ink.navy : Ink.navySoft, maxWidth: r.width - 12);
      });
    }
    // Cleanliness meter.
    final meter = const Rect.fromLTWH(96, 58, 168, 16);
    c.drawRRect(RRect.fromRectAndRadius(meter, const Radius.circular(8)), Pen.fillPaint(Ink.white));
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(meter.left, meter.top, meter.width * cleanliness, meter.height),
        const Radius.circular(8),
      ),
      Pen.fillPaint(Ink.tint(Ink.mint, 0.8)),
    );
    sprite(
      c,
      'room-meter',
      meter.center,
      (c) => Pen.stroke(
        c,
        Pen.rrect(Rect.fromCenter(center: Offset.zero, width: meter.width, height: meter.height), 8),
        width: 2,
      ),
    );
    Pen.twinkle(c, Offset(meter.right + 14, meter.center.dy), 7, cleanliness >= 1 ? Ink.gold : Ink.grid);
    // Destination highlight while dragging near the right home.
    final d = _dragging;
    if (d != null) {
      for (final e in _zones.entries) {
        final right = e.key == d.kind.home;
        final near = right && e.value.inflate(60).contains(d.pos);
        c.drawRRect(
          RRect.fromRectAndRadius(e.value.inflate(6), const Radius.circular(10)),
          Pen.inkPaint((near ? Ink.mint : Ink.navySoft).withValues(alpha: near ? 0.9 : 0.25), near ? 5 : 2),
        );
      }
    }
    for (final it in items) {
      if (it.moving && !it.stored) continue;
      if (it.stored) {
        sprite(c, 'room-${it.kind.name}', it.pos, (c) => _drawItem(c, it.kind), scale: 0.75);
        continue;
      }
      if (it != d) {
        final glow = 0.5 + 0.5 * wave(time, 3, it.rest.dx);
        c.drawCircle(it.pos, 30, Pen.inkPaint(Ink.coral.withValues(alpha: 0.35 + glow * 0.3), 2.4));
      }
      sprite(
        c,
        'room-${it.kind.name}',
        it.pos,
        (c) => _drawItem(c, it.kind),
        scale: it == d ? 1.15 : (ctx.simple ? 1.15 : 1),
      );
    }
  }

  @override
  String get progressText => tr.progClean((cleanliness * 100).round());

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'room-teddy', s.center(const Offset(0, 4)), (c) => _drawItem(c, _Kind.teddy), scale: s.width / 44);
}

final cleanRoomGame = GameDefinition(
  gameId: 'clean_my_room',
  name: (l) => l.gameCleanRoomName,
  objective: (l) => l.gameCleanRoomGoal,
  instructions: (l) => l.gameCleanRoomHowTo,
  interactionType: Interaction.tapDrag,
  accent: Ink.purple,
  scoreConfig: const ScoreConfig(base: 3, bonus: 8),
  assetManifest: const [
    'teddy',
    'toy-ball',
    'toy-car',
    'block',
    'book',
    'sock',
    'shirt',
    'pants',
    'bed',
    'shelf',
    'toy-box',
  ],
  create: CleanRoomScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(
      c,
      s,
      0.5,
      1.05,
      (c) => Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-200, -40, 400, 50), 2), fill: Ink.sand),
    );
    Thumb.put(c, s, 0.22, 0.6, (c) => Props.teddy(c));
    Thumb.put(c, s, 0.5, 0.72, (c) => Props.sock(c, Ink.pink), rotation: 0.4);
    Thumb.put(c, s, 0.8, 0.55, (c) => Props.book(c, Ink.blue), rotation: -0.3);
  },
);
