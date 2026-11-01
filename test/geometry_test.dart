import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:point_and_click_adventure/engine/geometry.dart';
import 'package:point_and_click_adventure/engine/path_data.dart';

void main() {
  final square = Polygon.box(0, 0, 100, 100);

  test('Punkt im Polygon', () {
    expect(square.contains(const Offset(50, 50)), isTrue);
    expect(square.contains(const Offset(150, 50)), isFalse);
  });

  test('Nächster erlaubter Punkt liegt im Polygon', () {
    final p = square.nearestInside(const Offset(300, 50));
    expect(square.contains(p) || p.dx <= 100, isTrue);
    expect(p.dx, lessThanOrEqualTo(100));
    expect((p.dy - 50).abs(), lessThan(1));
  });

  test('Pfaddaten werden gelesen', () {
    final path = parsePathData('M0 0 L100 0 L100 100 Q50 150 0 100 Z');
    final b = path.getBounds();
    expect(b.width, 100);
    expect(b.height, greaterThan(100));
  });

  test('Ungültige Pfaddaten werfen einen Fehler', () {
    expect(() => parsePathData('M0'), throwsFormatException);
  });
}
