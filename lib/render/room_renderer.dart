import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/engine.dart';
import '../engine/game_data.dart';

/// Zeichnet einen Raum aus Vektorformen.
///
/// Normalmodus: in der Auflösung des Geräts, mit Kantenglättung.
/// Retro-Modus: Der Raum wird erst in einen kleinen Puffer von
/// [retroHeight] Pixeln Höhe gerendert (ohne Kantenglättung, mit reduzierter
/// Farbpalette) und dann ohne Weichzeichnen vergrößert.
class RoomRenderer {
  RoomRenderer(this.engine);

  final GameEngine engine;

  static const double retroHeight = 400;

  void paint(Canvas canvas, Size size, {required bool retro}) {
    if (size.isEmpty) return;
    if (retro) {
      try {
        _paintRetro(canvas, size);
      } catch (_) {
        _paintWorld(canvas, size, false);
      }
    } else {
      _paintWorld(canvas, size, false);
    }
    _paintSpeech(canvas, size);
  }

  // ------------------------------------------------------------- Retro

  void _paintRetro(Canvas canvas, Size size) {
    final w = (retroHeight * size.width / size.height).roundToDouble();
    final target = Size(w, retroHeight);
    final recorder = ui.PictureRecorder();
    final c = Canvas(recorder);
    _paintWorld(c, target, true);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(w.toInt(), retroHeight.toInt());
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, w, retroHeight),
      Offset.zero & size,
      Paint()
        ..filterQuality = FilterQuality.none
        ..isAntiAlias = false,
    );
    image.dispose();
    picture.dispose();
  }

  Color _col(Color c, bool retro) {
    if (!retro) return c;
    int q(double v) => ((v * 255 / 17).round() * 17).clamp(0, 255).toInt();
    return Color.fromARGB((c.a * 255).round(), q(c.r), q(c.g), q(c.b));
  }

  // -------------------------------------------------------------- Welt

  void _paintWorld(Canvas canvas, Size size, bool retro) {
    final room = engine.room;
    final scale = size.height / GameEngine.roomHeight;
    final viewW = size.width / scale;
    final camX = engine.cameraX(viewW);

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF000000));
    canvas.scale(scale);
    canvas.translate(-camX, 0);

    _drawBackground(canvas, room, retro, camX, viewW);

    final front = <ShapeDef>[];
    _drawGroups(canvas, room.groups, retro, scale, front);
    for (final o in room.objects) {
      if (!engine.isVisible(o)) continue;
      _drawGroups(canvas, o.groups, retro, scale, front);
    }
    _drawPlayer(canvas, retro, scale);
    for (final s in front) {
      _drawShape(canvas, s, retro, scale);
    }

    final dark = room.darkWhen;
    if (dark != null && engine.holds(dark)) {
      canvas.drawRect(
        Rect.fromLTWH(camX - 10, 0, viewW + 20, GameEngine.roomHeight),
        Paint()
          ..color = _col(const Color(0xAA000010), retro)
          ..isAntiAlias = !retro,
      );
    }
    canvas.restore();
  }

  void _drawBackground(Canvas canvas, RoomDef room, bool retro, double camX, double viewW) {
    final x0 = camX - 20;
    final x1 = camX + viewW + 20;
    if (retro) {
      const bands = 18;
      for (var i = 0; i < bands; i++) {
        final c = Color.lerp(room.skyTop, room.skyBottom, (i + 0.5) / bands)!;
        final y0 = room.groundTop * i / bands;
        final y1 = room.groundTop * (i + 1) / bands + 1;
        canvas.drawRect(
          Rect.fromLTRB(x0, y0, x1, y1),
          Paint()
            ..color = _col(c, true)
            ..isAntiAlias = false,
        );
      }
    } else {
      final rect = Rect.fromLTRB(x0, 0, x1, room.groundTop + 1);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(0, 0),
            Offset(0, room.groundTop),
            <Color>[room.skyTop, room.skyBottom],
          ),
      );
    }
    canvas.drawRect(
      Rect.fromLTRB(x0, room.groundTop, x1, GameEngine.roomHeight + 1),
      Paint()
        ..color = _col(room.groundColor, retro)
        ..isAntiAlias = !retro,
    );
  }

  void _drawGroups(
    Canvas canvas,
    List<ShapeGroup> groups,
    bool retro,
    double scale,
    List<ShapeDef> front,
  ) {
    for (final g in groups) {
      if (!engine.holds(g.cond)) continue;
      for (final s in g.shapes) {
        if (s.front) {
          front.add(s);
        } else {
          _drawShape(canvas, s, retro, scale);
        }
      }
    }
  }

  void _drawShape(Canvas canvas, ShapeDef s, bool retro, double scale) {
    final fill = s.fill;
    if (fill != null) {
      canvas.drawPath(
        s.path,
        Paint()
          ..color = _col(fill, retro)
          ..style = PaintingStyle.fill
          ..isAntiAlias = !retro,
      );
    }
    final stroke = s.stroke;
    if (stroke != null) {
      canvas.drawPath(
        s.path,
        Paint()
          ..color = _col(stroke, retro)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(s.strokeWidth, retro ? 1 / scale : 0.0)
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round
          ..isAntiAlias = !retro,
      );
    }
  }

  // ---------------------------------------------------------- Spielfigur

  void _fillStroke(Canvas c, Path path, Color fill, Color stroke, bool retro, double scale) {
    c.drawPath(
      path,
      Paint()
        ..color = _col(fill, retro)
        ..style = PaintingStyle.fill
        ..isAntiAlias = !retro,
    );
    c.drawPath(
      path,
      Paint()
        ..color = _col(stroke, retro)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(5.0, retro ? 1 / scale : 0.0)
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = !retro,
    );
  }

  Path _rrect(double x, double y, double w, double h, double r) =>
      Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)));

  void _drawPlayer(Canvas canvas, bool retro, double scale) {
    final p = engine.player;
    final game = engine.game;
    final body = game.figures[game.player]?.color ?? const Color(0xFFE8564A);
    final line = game.stroke ?? const Color(0xFF120B1C);
    final k = (0.78 + 0.22 * ((p.pos.dy - 760) / 210).clamp(0.0, 1.0)).toDouble();
    final bob = p.walking ? math.sin(p.phase * 2) * 5 : 0.0;
    final swing = p.walking ? math.sin(p.phase) * 22 : 0.0;

    canvas.save();
    canvas.translate(p.pos.dx, p.pos.dy);
    canvas.scale(p.facingRight ? k : -k, k);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 2), width: 130, height: 26),
      Paint()
        ..color = _col(const Color(0x66000000), retro)
        ..isAntiAlias = !retro,
    );

    const pants = Color(0xFF2B3A67);
    const shoes = Color(0xFF1B1B2A);
    const skin = Color(0xFFF4C8A0);
    const hair = Color(0xFF5B2A86);

    _fillStroke(canvas, _rrect(-34 + swing, -100, 28, 100, 8), pants, line, retro, scale);
    _fillStroke(canvas, _rrect(6 - swing, -100, 28, 100, 8), pants, line, retro, scale);
    _fillStroke(canvas, _rrect(-42 + swing, -18, 46, 18, 7), shoes, line, retro, scale);
    _fillStroke(canvas, _rrect(4 - swing, -18, 46, 18, 7), shoes, line, retro, scale);
    _fillStroke(canvas, _rrect(-64, -190 + bob + swing * 0.3, 22, 84, 10), body, line, retro, scale);
    _fillStroke(canvas, _rrect(-48, -200 + bob, 96, 114, 20), body, line, retro, scale);
    _fillStroke(canvas, _rrect(42, -190 + bob - swing * 0.3, 22, 84, 10), body, line, retro, scale);

    final head = Path()..addOval(Rect.fromCircle(center: Offset(4, -240 + bob), radius: 42));
    _fillStroke(canvas, head, skin, line, retro, scale);
    final hairPath = Path()
      ..moveTo(-38, -240 + bob)
      ..quadraticBezierTo(-30, -296 + bob, 6, -292 + bob)
      ..quadraticBezierTo(50, -290 + bob, 46, -246 + bob)
      ..quadraticBezierTo(20, -264 + bob, -8, -252 + bob)
      ..quadraticBezierTo(-24, -246 + bob, -38, -240 + bob)
      ..close();
    _fillStroke(canvas, hairPath, hair, line, retro, scale);
    canvas.drawCircle(
      Offset(24, -240 + bob),
      6,
      Paint()
        ..color = _col(const Color(0xFF120B1C), retro)
        ..isAntiAlias = !retro,
    );
    canvas.restore();
  }

  // ----------------------------------------------------------- Sprechblase

  void _paintSpeech(Canvas canvas, Size size) {
    final s = engine.speech;
    if (s == null) return;
    final scale = size.height / GameEngine.roomHeight;
    final viewW = size.width / scale;
    final camX = engine.cameraX(viewW);
    final anchor = engine.speakerAnchor(s.actor);
    final color = engine.game.figures[s.actor]?.color ?? const Color(0xFFFFFFFF);
    final fontSize = math.max(15.0, size.height * 0.045);
    final maxW = math.min(size.width * 0.8, 560.0);

    TextPainter build(Paint? foreground, Color? fillColor) => TextPainter(
          text: TextSpan(
            text: s.text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              height: 1.15,
              color: foreground == null ? fillColor : null,
              foreground: foreground,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: maxW);

    final outline = build(
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF000000),
      null,
    );
    final fill = build(null, color);

    var x = (anchor.dx - camX) * scale - fill.width / 2;
    var y = anchor.dy * scale - fill.height;
    x = x.clamp(8.0, math.max(8.0, size.width - fill.width - 8)).toDouble();
    y = y.clamp(8.0, math.max(8.0, size.height - fill.height - 8)).toDouble();
    outline.paint(canvas, Offset(x, y));
    fill.paint(canvas, Offset(x, y));
  }
}

class RoomPainter extends CustomPainter {
  RoomPainter(this.engine, this.retro)
      : super(repaint: Listenable.merge(<Listenable>[engine, engine.frame]));

  final GameEngine engine;
  final bool retro;

  @override
  void paint(Canvas canvas, Size size) {
    RoomRenderer(engine).paint(canvas, size, retro: retro);
  }

  @override
  bool shouldRepaint(covariant RoomPainter oldDelegate) =>
      oldDelegate.retro != retro || oldDelegate.engine != engine;
}
