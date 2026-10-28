import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../sketch/ink.dart';
import '../sketch/pen.dart';
import 'game_scene.dart';
import 'game_session.dart';

/// GameRenderer + InputController: ticks the session, paints the scene into
/// a letterboxed 360x620 world and routes pointer events (taps and drags).
class GameCanvas extends StatefulWidget {
  const GameCanvas({super.key, required this.session});
  final GameSessionManager session;

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _frame = ValueNotifier<int>(0);
  Duration _last = Duration.zero;
  Rect _view = Rect.zero;
  int? _dragPointer;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    var dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt > 0.05) dt = 0.05; // avoid big jumps after hitches
    if (dt <= 0) return;
    widget.session.update(dt);
    _frame.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _frame.dispose();
    super.dispose();
  }

  Offset _toWorld(Offset local) {
    if (_view.isEmpty) return local;
    final s = _view.width / GameScene.world.width;
    final p = (local - _view.topLeft) / s;
    // Clamp so drags released outside the play area stay in bounds.
    return Offset(p.dx.clamp(0, GameScene.world.width), p.dy.clamp(0, GameScene.world.height));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = GameScene.world;
        final scale = (box.maxWidth / w.width) < (box.maxHeight / w.height)
            ? box.maxWidth / w.width
            : box.maxHeight / w.height;
        final size = Size(w.width * scale, w.height * scale);
        _view = Offset((box.maxWidth - size.width) / 2, (box.maxHeight - size.height) / 2) & size;
        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (e) {
            final p = _toWorld(e.localPosition);
            if (_dragPointer == null && widget.session.dragStart(p)) {
              _dragPointer = e.pointer;
            } else {
              widget.session.tap(p);
            }
          },
          onPointerMove: (e) {
            if (e.pointer == _dragPointer) widget.session.dragMove(_toWorld(e.localPosition));
          },
          onPointerUp: (e) {
            if (e.pointer == _dragPointer) {
              _dragPointer = null;
              widget.session.dragEnd(_toWorld(e.localPosition));
            }
          },
          onPointerCancel: (e) {
            if (e.pointer == _dragPointer) {
              _dragPointer = null;
              widget.session.scene.cancelDrag();
            }
          },
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(box.maxWidth, box.maxHeight),
              painter: ScenePainter(widget.session.scene, _view, repaint: _frame),
            ),
          ),
        );
      },
    );
  }
}

class ScenePainter extends CustomPainter {
  ScenePainter(this.scene, this.view, {super.repaint});
  final GameScene scene;
  final Rect view;

  static final _bgCache = Expando<ui.Picture>();

  @override
  void paint(Canvas canvas, Size size) {
    final s = view.width / GameScene.world.width;
    canvas.save();
    canvas.translate(view.left, view.top);
    canvas.scale(s);
    final frame = Pen.rrect(GameScene.worldRect.deflate(2), 18);
    canvas.save();
    canvas.clipPath(frame);
    var bg = _bgCache[scene];
    if (bg == null) {
      final rec = ui.PictureRecorder();
      scene.paintBackground(Canvas(rec));
      bg = rec.endRecording();
      _bgCache[scene] = bg;
    }
    canvas.drawPicture(bg);
    scene.paint(canvas);
    scene.paintEffects(canvas);
    canvas.restore();
    // Hand-drawn notebook frame around the play area.
    SpriteCache.draw(canvas, 'world-frame', (c) => Pen.shape(c, frame, width: 2.6, seed: 11, ink: Ink.navy));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ScenePainter old) => old.scene != scene || old.view != view;
}

/// Paints a scene once without ticking (used by tests and previews).
void paintSceneSnapshot(Canvas canvas, GameScene scene) {
  scene.paintBackground(canvas);
  scene.paint(canvas);
  scene.paintEffects(canvas);
}
