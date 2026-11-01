import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../engine/engine.dart';
import '../render/room_renderer.dart';
import '../services/game_settings.dart';

/// Die Spielszene: zeichnet den Raum, nimmt Tipps entgegen und treibt die
/// Engine in festen Zeitschritten an, solange etwas passiert.
class SceneView extends StatefulWidget {
  const SceneView({super.key});

  @override
  State<SceneView> createState() => _SceneViewState();
}

class _SceneViewState extends State<SceneView> with SingleTickerProviderStateMixin {
  static const double _step = 1 / 60;

  late final GameEngine _engine;
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _acc = 0;

  @override
  void initState() {
    super.initState();
    _engine = context.read<GameEngine>();
    _ticker = createTicker(_onTick);
    _engine.addListener(_wake);
    _wake();
  }

  @override
  void dispose() {
    _engine.removeListener(_wake);
    _ticker.dispose();
    super.dispose();
  }

  void _wake() {
    if (_engine.isAnimating && !_ticker.isActive) {
      _last = Duration.zero;
      _acc = 0;
      _ticker.start();
    }
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1000000.0;
    _last = elapsed;
    _acc += dt > 0.1 ? 0.1 : dt;
    while (_acc >= _step) {
      _engine.tick(_step);
      _acc -= _step;
    }
    if (!_engine.isAnimating) _ticker.stop();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<GameSettings>();
    final engine = context.watch<GameEngine>();
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final scale = size.height / GameEngine.roomHeight;

        Offset toRoom(Offset local) {
          final viewW = size.width / scale;
          return Offset(local.dx / scale + _engine.cameraX(viewW), local.dy / scale);
        }

        return Stack(
          children: [
            Positioned.fill(
              child: MouseRegion(
                onHover: (e) => _engine.hover(_engine.objectAt(toRoom(e.localPosition))),
                onExit: (_) => _engine.hover(null),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) => _engine.onSceneTap(toRoom(d.localPosition)),
                  onLongPressStart: (d) => _engine.onSceneLongPress(toRoom(d.localPosition)),
                  onSecondaryTapUp: (d) => _engine.onSceneLongPress(toRoom(d.localPosition)),
                  child: CustomPaint(
                    key: const ValueKey('scene'),
                    size: size,
                    painter: RoomPainter(_engine, settings.retro),
                  ),
                ),
              ),
            ),
            if (engine.inCutscene)
              Positioned(
                right: 8,
                top: 8,
                child: TextButton(
                  key: const ValueKey('skip'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _engine.skipCutscene,
                  child: const Text('Überspringen'),
                ),
              ),
          ],
        );
      },
    );
  }
}
