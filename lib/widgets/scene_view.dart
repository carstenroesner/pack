import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_models.dart';
import '../services/game_state.dart';

/// Zeichnet die aktuelle Szene und legt die Hotspots darüber.
class SceneView extends StatelessWidget {
  const SceneView({super.key});

  static const double _spotWidth = 92;
  static const double _spotHeight = 92;

  /// Begrenzt die Position auf den sichtbaren Bereich.
  static double _place(double value, double max) {
    final upper = max < 0 ? 0.0 : max;
    if (value < 0) return 0;
    if (value > upper) return upper;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    final dark = state.sceneId == 'halle' && !state.hasFlag('halle_hell');

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final ht = constraints.maxHeight;
        return ClipRect(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _ScenePainter(state.scene)),
              ),
              if (dark)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(color: Color(0x99000000)),
                  ),
                ),
              for (final spot in state.visibleHotspots)
                Positioned(
                  left: _place(spot.x * w - _spotWidth / 2, w - _spotWidth),
                  top: _place(spot.y * ht - _spotHeight / 2, ht - _spotHeight),
                  width: _spotWidth,
                  height: _spotHeight,
                  child: _HotspotButton(
                    spot: spot,
                    onTap: () => context.read<GameState>().tapHotspot(spot),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HotspotButton extends StatelessWidget {
  const _HotspotButton({required this.spot, required this.onTap});

  final Hotspot spot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey('hotspot_${spot.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(spot.emoji, style: const TextStyle(fontSize: 32)),
          Text(
            spot.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              shadows: [Shadow(blurRadius: 3, color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene);

  final SceneData scene;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scene.skyTop, scene.skyBottom],
        ).createShader(rect),
    );

    if (scene.hasMoon) {
      canvas.drawCircle(
        Offset(size.width * 0.86, size.height * 0.16),
        size.shortestSide * 0.09,
        Paint()..color = const Color(0xFFFFF3C4),
      );
    }

    final groundTop = size.height * 0.68;
    canvas.drawRect(
      Rect.fromLTWH(0, groundTop, size.width, size.height - groundTop),
      Paint()..color = scene.ground,
    );

    if (scene.id == 'garden') {
      _paintHouse(canvas, size, groundTop);
    }
  }

  void _paintHouse(Canvas canvas, Size size, double groundTop) {
    final wall = Paint()..color = const Color(0xFF2A1F38);
    final roof = Paint()..color = const Color(0xFF150D20);
    final window = Paint()..color = const Color(0xFFFFC857);

    final left = size.width * 0.28;
    final right = size.width * 0.72;
    final top = size.height * 0.22;

    canvas.drawRect(Rect.fromLTRB(left, top, right, groundTop + 8), wall);

    final roofPath = Path()
      ..moveTo(left - 14, top)
      ..lineTo(size.width * 0.5, size.height * 0.04)
      ..lineTo(right + 14, top)
      ..close();
    canvas.drawPath(roofPath, roof);

    final winW = size.width * 0.05;
    final winH = size.height * 0.10;
    canvas.drawRect(
      Rect.fromLTWH(left + size.width * 0.04, top + size.height * 0.08, winW, winH),
      window,
    );
    canvas.drawRect(
      Rect.fromLTWH(right - size.width * 0.04 - winW, top + size.height * 0.08, winW, winH),
      window,
    );
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.scene != scene;
}
