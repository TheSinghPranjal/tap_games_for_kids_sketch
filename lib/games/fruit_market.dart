import 'common.dart';
import 'sort_scene.dart';

String _fruitName(int bin) => [tr.gameApples, tr.gameBananas, tr.gameOranges][bin];

void _fruit(Canvas c, int kind) => switch (kind) {
  0 => Props.apple(c),
  1 => Props.banana(c),
  _ => Props.orange(c),
};

/// Fill the customer's order: drag each fruit into its labelled crate.
class FruitMarketScene extends SortScene {
  FruitMarketScene(super.cfg);

  @override
  int get binCount => ctx.simple ? 2 : 3;

  @override
  Rect binRect(int bin) {
    final w = 360 / binCount;
    return Rect.fromCenter(center: Offset(w * (bin + 0.5), 516), width: ctx.simple ? 124 : 100, height: 88);
  }

  @override
  int binOf(int kind) => kind;

  @override
  Rect get pileArea => const Rect.fromLTRB(50, 236, 310, 376);

  @override
  List<int> nextBatch() {
    // An order of 3-5 fruits using at least two kinds.
    final n = ctx.simple ? 3 : 3 + rng.nextInt(3);
    final order = [0, 1, for (var i = 2; i < n; i++) rng.nextInt(binCount)];
    return order.map((k) => k % binCount).toList()..shuffle(rng);
  }

  @override
  void drawItem(Canvas c, int kind) => _fruit(c, kind);

  @override
  String wrongText(int bin) => tr.gameCrateFor(const ['apples', 'bananas', 'oranges'][bin]);

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    // Striped market awning and a wooden counter.
    for (var i = 0; i < 8; i++) {
      final x = i * 45.0;
      Pen.shape(
        c,
        Path()
          ..moveTo(x, -4)
          ..lineTo(x + 45, -4)
          ..lineTo(x + 45, 34)
          ..quadraticBezierTo(x + 22.5, 52, x, 34)
          ..close(),
        fill: i.isEven ? Ink.mint : Ink.white,
        solid: true,
        hatch: i.isEven ? Ink.leaf : Ink.grid,
        seed: i + 1,
        width: 2,
        doubleLine: false,
      );
    }
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(20, 210, 320, 190), 16),
      fill: const Color(0xFFE2A866),
      solid: true,
      hatch: Ink.brown.withValues(alpha: 0.35),
      hatchAngle: 0,
      seed: 4,
    );
    // Order note pinned at the top.
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(40, 66, 280, 120), 14),
      fill: Ink.paperWarm,
      solid: true,
      seed: 6,
      width: 2.4,
    );
    Pen.dot(c, const Offset(180, 72), 5, Ink.coral);
    Pen.text(c, tr.gameOrder, const Offset(180, 92), size: 20, maxWidth: 150);
    groundBand(c, const Rect.fromLTRB(-10, 576, 370, 620), Ink.mint, seed: 3);
  }

  @override
  void paintBins(Canvas c, List<double> bounce, int? glow) {
    for (var b = 0; b < binCount; b++) {
      final r = binRect(b);
      if (glow == b) {
        c.drawRRect(
          RRect.fromRectAndRadius(r.inflate(10), const Radius.circular(16)),
          Pen.fillPaint(Ink.yellow.withValues(alpha: 0.35)),
        );
      }
      final (sx, sy) = squash(bounce[b], 0.12);
      sprite(
        c,
        'fruit-crate-$b-${r.width.round()}',
        r.center,
        (c) {
          final box = Rect.fromCenter(center: Offset.zero, width: r.width, height: r.height);
          Pen.shape(
            c,
            Pen.rrect(box, 8),
            fill: const Color(0xFFD9A066),
            solid: true,
            hatch: Ink.brown.withValues(alpha: 0.4),
            hatchAngle: 0,
            seed: b + 3,
          );
          for (final y in [-14.0, 14.0]) {
            Pen.line(c, Offset(box.left + 4, y), Offset(box.right - 4, y), ink: Ink.shade(Ink.brown, 0.2), width: 2.4);
          }
          // Paper label with the fruit and its name.
          Pen.shape(
            c,
            Pen.rrect(Rect.fromCenter(center: const Offset(0, 0), width: r.width - 18, height: 40), 8),
            fill: Ink.white,
            solid: true,
            seed: 9,
            width: 1.8,
          );
          c.save();
          c.translate(-r.width / 2 + 30, 0);
          c.scale(0.6);
          _fruit(c, b);
          c.restore();
          Pen.text(c, _fruitName(b), const Offset(12, 0), size: 13, maxWidth: r.width - 58);
        },
        sx: sx,
        sy: sy,
      );
    }
  }

  @override
  void paint(Canvas c) {
    // Order list: each fruit kind with how many are packed so far.
    final kinds = batch.toSet().toList()..sort();
    final gap = 260 / kinds.length;
    for (var i = 0; i < kinds.length; i++) {
      final k = kinds[i];
      final need = batch.where((x) => x == k).length;
      final have = done[k] ?? 0;
      final at = Offset(50 + gap * (i + 0.5), 146);
      sprite(c, 'order-fruit-$k', at - const Offset(18, 0), (c) => _fruit(c, k), scale: 0.7);
      Pen.text(c, '$have/$need', at + const Offset(20, 0), size: 16, color: have >= need ? Ink.leaf : Ink.navy);
    }
    super.paint(c);
  }

  @override
  String get progressText => tr.progOrders(batches);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'order-fruit-0', s.center(Offset.zero), Props.apple, scale: s.width / 48);
}

final fruitMarketGame = GameDefinition(
  gameId: 'fruit_market',
  name: (l) => l.gameFruitMarketName,
  objective: (l) => l.gameFruitMarketGoal,
  instructions: (l) => l.gameFruitMarketHowTo,
  interactionType: Interaction.drag,
  accent: Ink.mint,
  scoreConfig: const ScoreConfig(base: 2, bonus: 8),
  assetManifest: const ['apple', 'banana', 'orange', 'crate', 'awning'],
  create: FruitMarketScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s, wash: Ink.sand);
    Thumb.put(
      c,
      s,
      0.5,
      1.0,
      (c) => Pen.shape(
        c,
        Pen.rrect(const Rect.fromLTWH(-200, -38, 400, 48), 4),
        fill: const Color(0xFFD9A066),
        solid: true,
      ),
    );
    Thumb.put(c, s, 0.22, 0.45, Props.apple, scale: 0.9);
    Thumb.put(c, s, 0.5, 0.38, Props.banana, scale: 0.9);
    Thumb.put(c, s, 0.78, 0.48, Props.orange, scale: 0.9);
  },
);
