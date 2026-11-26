import 'common.dart';
import 'sort_scene.dart';

String _label(int bin) => [tr.gameToys, tr.gameBooks, tr.gameClothes][bin];

/// Kinds 0-3 are toys, 4-6 books and 7-9 clothes.
void _thing(Canvas c, int kind) => switch (kind) {
  0 => Props.teddy(c),
  1 => Props.toyBall(c),
  2 => Props.toyCar(c),
  3 => Props.block(c, Ink.yellow, 'A'),
  4 => Props.book(c, Ink.coral),
  5 => Props.book(c, Ink.blue),
  6 => Props.book(c, Ink.mint),
  7 => Props.sock(c, Ink.pink),
  8 => Props.shirt(c, Ink.sky),
  _ => Props.pants(c, Ink.purple),
};

/// Drag every toy, book and piece of clothing to where it lives.
class TidyUpScene extends SortScene {
  TidyUpScene(super.cfg);

  @override
  int get binCount => 3;

  @override
  Rect binRect(int bin) => Rect.fromCenter(center: Offset(66 + bin * 114.0, 506), width: 104, height: 120);

  @override
  int binOf(int kind) => kind < 4 ? 0 : (kind < 7 ? 1 : 2);

  @override
  Rect get pileArea => const Rect.fromLTRB(46, 140, 314, 360);

  @override
  List<int> nextBatch() {
    final n = ctx.simple ? 4 : 5;
    // One of each kind of thing first, so every place gets used.
    final kinds = [rng.nextInt(4), 4 + rng.nextInt(3), 7 + rng.nextInt(3)];
    while (kinds.length < n) {
      kinds.add(rng.nextInt(10));
    }
    return kinds..shuffle(rng);
  }

  @override
  void drawItem(Canvas c, int kind) {
    c.scale(1.35);
    _thing(c, kind);
  }

  @override
  String wrongText(int bin) => tr.gameOnlyLabel(const ['toys', 'books', 'clothes'][bin]);

  @override
  void paintBackground(Canvas c) {
    Paper.graph(c, GameScene.worldRect);
    // Wallpaper, skirting board and a round rug.
    for (var x = 0.0; x < 360; x += 30) {
      c.drawRect(Rect.fromLTWH(x, 0, 15, 420), Pen.fillPaint(Ink.tint(Ink.yellow, 0.14)));
    }
    Pen.shape(
      c,
      Pen.rrect(const Rect.fromLTWH(-10, 420, 380, 210), 2),
      fill: Ink.sand,
      solid: true,
      hatch: Ink.brown.withValues(alpha: 0.25),
      hatchAngle: 0,
      seed: 3,
    );
    Pen.shape(
      c,
      Pen.oval(const Offset(180, 250), 150, 116),
      fill: Ink.tint(Ink.pink, 0.4),
      solid: true,
      hatch: Ink.pink,
      seed: 5,
    );
    Pen.text(c, tr.gameTidyUp, const Offset(180, 60), size: 28, maxWidth: 320);
  }

  @override
  void paintBins(Canvas c, List<double> bounce, int? glow) {
    for (var b = 0; b < 3; b++) {
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
        'tidy-bin-$b',
        r.center,
        (c) {
          final box = Rect.fromCenter(center: const Offset(0, 10), width: r.width, height: r.height - 20);
          final color = [Ink.coral, const Color(0xFFD9A066), Ink.purple][b];
          Pen.shape(c, Pen.rrect(box, 10), fill: color, solid: true, hatch: Ink.shade(color, 0.15), seed: b + 2);
          switch (b) {
            case 0: // toy chest lid
              Pen.shape(
                c,
                Pen.rrect(Rect.fromLTWH(box.left - 4, box.top - 8, box.width + 8, 18), 8),
                fill: Ink.shade(color, 0.1),
                solid: true,
                seed: 7,
              );
            case 1: // bookcase shelves with books
              for (final y in [box.top + 30, box.top + 62]) {
                Pen.line(
                  c,
                  Offset(box.left + 6, y),
                  Offset(box.right - 6, y),
                  ink: Ink.shade(Ink.brown, 0.3),
                  width: 3,
                );
                for (var i = 0; i < 4; i++) {
                  c.drawRect(
                    Rect.fromLTWH(box.left + 12 + i * 12, y - 20, 9, 20),
                    Pen.fillPaint(Ink.bright[(i + y.round()) % 7]),
                  );
                }
              }
            default: // wardrobe doors
              Pen.line(c, Offset(0, box.top + 6), Offset(0, box.bottom - 6), width: 2.4);
              for (final x in [-8.0, 8.0]) {
                Pen.dot(c, Offset(x, box.center.dy), 3, Ink.gold);
              }
          }
          // Label sign above.
          Pen.shape(
            c,
            Pen.rrect(Rect.fromCenter(center: Offset(0, -r.height / 2 + 2), width: 86, height: 26), 8),
            fill: Ink.white,
            solid: true,
            width: 1.8,
            seed: 9,
          );
          Pen.text(c, _label(b), Offset(0, -r.height / 2 + 2), size: 15, maxWidth: 78);
        },
        sx: sx,
        sy: sy,
      );
    }
  }

  @override
  String get progressText => tr.progTidied(sorted);

  @override
  void paintProgressIcon(Canvas c, Size s) =>
      sprite(c, 'tidy-icon', s.center(Offset.zero), Props.teddy, scale: s.width / 44);
}

final tidyUpGame = GameDefinition(
  gameId: 'tidy_up_time',
  name: (l) => l.gameTidyUpName,
  objective: (l) => l.gameTidyUpGoal,
  instructions: (l) => l.gameTidyUpHowTo,
  interactionType: Interaction.drag,
  accent: Ink.coral,
  scoreConfig: const ScoreConfig(base: 2, bonus: 8),
  assetManifest: const ['teddy', 'book', 'shirt', 'toy-chest', 'bookcase', 'wardrobe'],
  create: TidyUpScene.new,
  thumbnail: (c, s) {
    Thumb.paper(c, s);
    Thumb.put(
      c,
      s,
      0.5,
      1.0,
      (c) => Pen.shape(c, Pen.rrect(const Rect.fromLTWH(-200, -26, 400, 40), 2), fill: Ink.sand, solid: true),
    );
    Thumb.put(c, s, 0.24, 0.5, Props.teddy);
    Thumb.put(c, s, 0.52, 0.55, (c) => Props.book(c, Ink.blue), rotation: -0.3);
    Thumb.put(c, s, 0.8, 0.5, (c) => Props.shirt(c, Ink.sky));
  },
);
