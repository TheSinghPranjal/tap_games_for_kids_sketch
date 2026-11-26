import 'common.dart';
import 'sort_scene.dart';

const _sockColors = [Ink.pink, Ink.blue, Ink.yellow, Ink.mint, Ink.purple];

/// Pattern for each sock colour: 0 stripes, 1 dots, 2 zigzag, 3 hearts, 4 plain.
void _sock(Canvas c, int kind) {
  final color = _sockColors[kind];
  final p = Path()
    ..moveTo(-12, -30)
    ..lineTo(12, -30)
    ..lineTo(12, 6)
    ..quadraticBezierTo(33, 9, 30, 24)
    ..quadraticBezierTo(15, 33, -12, 21)
    ..close();
  Pen.shape(c, p, fill: color, solid: true, hatch: Ink.shade(color, 0.12), seed: kind + 4);
  c.save();
  c.clipPath(p);
  final white = Pen.inkPaint(Ink.white, 3.4);
  switch (kind) {
    case 0:
      for (final y in [-8.0, 2.0, 14.0]) {
        c.drawLine(Offset(-14, y), Offset(34, y), white);
      }
    case 1:
      for (final o in const [Offset(-4, -10), Offset(5, 0), Offset(-5, 10), Offset(14, 16), Offset(24, 20)]) {
        Pen.dot(c, o, 3, Ink.white);
      }
    case 2:
      final z = Path()..moveTo(-12, 4);
      for (var i = 0; i < 5; i++) {
        z.lineTo(-6 + i * 8.0, i.isEven ? -6 : 6);
      }
      c.drawPath(z, white);
    case 3:
      Pen.heart(c, const Offset(0, -2), 6, color: Ink.white);
      Pen.heart(c, const Offset(18, 18), 5, color: Ink.white);
  }
  c.restore();
  Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-13, -34, 26, 9), 3), fill: Ink.white, solid: true, width: 1.8, seed: 2);
}

/// Each drawer holds one sock; drag the matching partner into its drawer.
class SockPairScene extends SortScene {
  SockPairScene(super.cfg);

  /// Which sock pattern each drawer holds this round.
  List<int> _drawers = [0, 1, 2];

  @override
  int get binCount => ctx.simple ? 2 : 3;

  @override
  Rect binRect(int bin) {
    final w = 330 / binCount;
    return Rect.fromCenter(center: Offset(15 + w * (bin + 0.5), 494), width: w - 14, height: 96);
  }

  @override
  int binOf(int kind) => _drawers.indexOf(kind);

  @override
  Rect get pileArea => const Rect.fromLTRB(50, 150, 310, 360);

  @override
  List<int> nextBatch() {
    _drawers = (List.generate(_sockColors.length, (i) => i)..shuffle(rng)).take(binCount).toList();
    final n = ctx.simple ? 3 : 4;
    return [for (var i = 0; i < n; i++) _drawers[i % binCount]]..shuffle(rng);
  }

  @override
  void drawItem(Canvas c, int kind) => _sock(c, kind);

  @override
  String wrongText(int bin) => tr.gameFindTwin;

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    Pen.shape(
      c,
      Pen.oval(const Offset(180, 255), 156, 120),
      fill: Ink.tint(Ink.purple, 0.25),
      solid: true,
      hatch: Ink.purple.withValues(alpha: 0.5),
      seed: 5,
    );
    Pen.text(c, tr.gameMatchSocks, const Offset(180, 60), size: 24, maxWidth: 320);
    // The chest of drawers.
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(10, 420, 340, 160), 14),
      fill: const Color(0xFFD9A066),
      solid: true,
      hatch: Ink.brown.withValues(alpha: 0.35),
      hatchAngle: 0,
      seed: 3,
      width: 2.8,
    );
    for (final x in [36.0, 324.0]) {
      Pen.shape(c, Pen.rrect(Rect.fromLTWH(x - 10, 576, 20, 30), 4), fill: Ink.brown, solid: true, seed: x.round());
    }
  }

  @override
  void paintBins(Canvas c, List<double> bounce, int? glow) {
    for (var b = 0; b < binCount; b++) {
      final r = binRect(b);
      if (glow == b) {
        c.drawRRect(
          RRect.fromRectAndRadius(r.inflate(8), const Radius.circular(14)),
          Pen.fillPaint(Ink.yellow.withValues(alpha: 0.4)),
        );
      }
      final (sx, sy) = squash(bounce[b], 0.1);
      final kind = _drawers[b];
      sprite(
        c,
        'sock-drawer-$kind-${r.width.round()}',
        r.center,
        (c) {
          final box = Rect.fromCenter(center: Offset.zero, width: r.width, height: r.height);
          Pen.shape(
            c,
            Pen.rrect(box, 10),
            fill: Ink.tint(Ink.brown, 0.35),
            solid: true,
            hatch: Ink.brown.withValues(alpha: 0.3),
            seed: b + 7,
          );
          Pen.shape(
            c,
            Pen.rrect(Rect.fromCenter(center: Offset(0, box.bottom - 10), width: 36, height: 8), 4),
            fill: Ink.gold,
            solid: true,
            width: 1.6,
          );
          // The waiting sock peeks out of its drawer.
          c.save();
          c.translate(-4, -6);
          c.rotate(-0.25);
          _sock(c, kind);
          c.restore();
        },
        sx: sx,
        sy: sy,
      );
    }
  }

  @override
  String get progressText => tr.progPairs(sorted);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'sock-icon', s.center(Offset.zero), (c) => _sock(c, 0), scale: s.width / 72);
}

final sockPairGame = GameDefinition(
  gameId: 'sock_pair_match',
  name: (l) => l.gameSockPairsName,
  objective: (l) => l.gameSockPairsGoal,
  instructions: (l) => l.gameSockPairsHowTo,
  interactionType: Interaction.drag,
  accent: Ink.purple,
  scoreConfig: const ScoreConfig(base: 3, bonus: 8),
  assetManifest: const ['sock', 'drawers'],
  create: SockPairScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(
      c,
      s,
      0.5,
      1.0,
      (c) => Pen.shape(
        c,
        Pen.rrect(const Rect.fromLTWH(-200, -30, 400, 40), 8),
        fill: const Color(0xFFD9A066),
        solid: true,
      ),
    );
    Thumb.put(c, s, 0.3, 0.45, (c) => _sock(c, 0), rotation: -0.2);
    Thumb.put(c, s, 0.52, 0.5, (c) => _sock(c, 0), rotation: 0.2);
    Thumb.put(c, s, 0.8, 0.45, (c) => _sock(c, 1));
  },
);
