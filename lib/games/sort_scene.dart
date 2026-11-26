import 'package:flutter/foundation.dart' show visibleForTesting;

import 'common.dart';

class _Item {
  _Item(this.id, this.kind, this.rest) : pos = rest;
  final String id;
  final int kind;
  final Offset rest;
  Offset pos;
  bool returning = false;
  double pop = 0;
}

/// Shared rules for the "drag each thing into the right bin" games: a batch
/// of items appears, each correct drop scores [ScoreConfig.base], a wrong
/// bin sends the item back, and clearing the batch scores [ScoreConfig.bonus].
abstract class SortScene extends GameScene {
  SortScene(this.cfg);
  final ScoreConfig cfg;

  // ---- provided by each game ---------------------------------------------

  int get binCount;
  Rect binRect(int bin);
  int binOf(int kind);
  List<int> nextBatch();
  Rect get pileArea;
  void drawItem(Canvas c, int kind);

  /// Paints the bins; [bounce] is 0..1 per bin after a drop, [glow] is the
  /// bin the held item belongs in.
  void paintBins(Canvas c, List<double> bounce, int? glow);

  /// Shown when an item lands in the wrong bin.
  String wrongText(int bin) => tr.gameNotInHere;

  // ---- state ----------------------------------------------------------------

  final _items = <_Item>[];
  _Item? _held;
  Offset _grab = Offset.zero;
  late final List<double> _bounce;
  int sorted = 0, batches = 0;
  double _nextIn = 0;

  /// Kinds in the current batch and how many of each are already sorted.
  List<int> batch = [];
  final done = <int, int>{};

  double get itemScale => ctx.simple ? 1.2 : 1.0;

  @visibleForTesting
  List<(Offset, int)> get debugItems => [
    for (final i in _items)
      if (!i.returning) (i.pos, i.kind),
  ];

  @override
  void setup() {
    _bounce = List.filled(binCount, 1);
    _newBatch();
  }

  void _newBatch() {
    batch = nextBatch();
    done.clear();
    _items.clear();
    for (final kind in batch) {
      final p = freeSpot(pileArea, _items.map((i) => i.rest), 74);
      _items.add(_Item(newId('sort'), kind, p)..pop = -_items.length * 0.12);
    }
  }

  @override
  void tick(double dt) {
    for (var i = 0; i < _bounce.length; i++) {
      _bounce[i] = (_bounce[i] + dt * 3).clamp(0, 1);
    }
    for (final i in _items) {
      i.pop = (i.pop + dt * 4).clamp(-1, 1);
    }
    if (_items.isEmpty && !ended) {
      _nextIn -= dt;
      if (_nextIn <= 0) _newBatch();
    }
  }

  @override
  bool onDragStart(Offset p) {
    if (ended) return false;
    _Item? best;
    var bestD = 42 * itemScale + ctx.hitPad;
    for (final i in _items) {
      final d = (i.pos - p).distance;
      if (!i.returning && i.pop > 0.5 && d < bestD) {
        bestD = d;
        best = i;
      }
    }
    if (best == null) return false;
    _held = best;
    _grab = best.pos - p;
    ctx.onSfx(Sfx.tap);
    return true;
  }

  @override
  void onDragMove(Offset p) => _held?.pos = p + _grab;

  @override
  void onDragEnd(Offset p) {
    final it = _held;
    _held = null;
    if (it == null) return;
    int? bin;
    for (var b = 0; b < binCount; b++) {
      if (binRect(b).inflate(10 + ctx.hitPad).contains(it.pos)) bin = b;
    }
    if (bin == null || ended) return _sendBack(it);
    if (bin != binOf(it.kind)) {
      fx.floatText(binRect(bin).topCenter + const Offset(0, -16), wrongText(bin));
      ctx.onSfx(Sfx.soft);
      return _sendBack(it);
    }
    _items.remove(it);
    sorted++;
    done[it.kind] = (done[it.kind] ?? 0) + 1;
    final target = binRect(bin).center;
    score(cfg.base, it.id, target + const Offset(0, -50));
    ctx.onSfx(Sfx.collect);
    final kind = it.kind, scale = itemScale, b = bin;
    fly(
      it.pos,
      target,
      0.3,
      (c, pos, t) => _paintItem(c, pos, kind, scale * (1 - t * 0.4)),
      arc: -30,
      trail: false,
      onArrive: () {
        _bounce[b] = 0;
        fx.burst(target, colors: const [Ink.yellow, Ink.white], count: 6);
      },
    );
    if (_items.isEmpty) {
      batches++;
      score(cfg.bonus, 'batch-$batches', const Offset(180, 260));
      ctx.onSfx(Sfx.cheer);
      fx.confetti(const Offset(180, 240));
      _nextIn = 1.6;
    }
  }

  @override
  void cancelDrag() {
    final it = _held;
    _held = null;
    if (it != null) _sendBack(it);
  }

  void _sendBack(_Item it) {
    it.returning = true;
    final kind = it.kind, scale = itemScale;
    fly(
      it.pos,
      it.rest,
      0.35,
      (c, pos, t) => _paintItem(c, pos, kind, scale),
      arc: -24,
      trail: false,
      onArrive: () {
        it
          ..pos = it.rest
          ..returning = false;
      },
    );
  }

  void _paintItem(Canvas c, Offset at, int kind, double scale) =>
      sprite(c, '$runtimeType-item-$kind', at, (c) => drawItem(c, kind), scale: scale);

  @override
  void paint(Canvas c) {
    final held = _held;
    paintBins(c, _bounce, held == null ? null : binOf(held.kind));
    for (final i in _items) {
      if (i.returning || identical(i, held) || i.pop <= 0) continue;
      final k = Flight.ease(i.pop.clamp(0, 1));
      _paintItem(c, i.pos, i.kind, itemScale * k);
    }
    if (held != null) _paintItem(c, held.pos, held.kind, itemScale * 1.15);
  }
}
