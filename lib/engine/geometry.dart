import 'dart:math' as math;
import 'dart:ui';

/// Ein Vieleck in Raumkoordinaten (Einheiten, nicht Pixel).
class Polygon {
  const Polygon(this.points);

  factory Polygon.box(double x, double y, double w, double h) => Polygon(<Offset>[
        Offset(x, y),
        Offset(x + w, y),
        Offset(x + w, y + h),
        Offset(x, y + h),
      ]);

  final List<Offset> points;

  Rect get bounds {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = -double.infinity;
    var maxY = -double.infinity;
    for (final p in points) {
      minX = math.min(minX, p.dx);
      minY = math.min(minY, p.dy);
      maxX = math.max(maxX, p.dx);
      maxY = math.max(maxY, p.dy);
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  bool contains(Offset p) {
    var inside = false;
    for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
      final a = points[i];
      final b = points[j];
      final crosses = (a.dy > p.dy) != (b.dy > p.dy) &&
          p.dx < (b.dx - a.dx) * (p.dy - a.dy) / (b.dy - a.dy) + a.dx;
      if (crosses) inside = !inside;
    }
    return inside;
  }

  /// Der Punkt selbst, wenn er im Vieleck liegt, sonst der nächste Randpunkt.
  Offset nearestInside(Offset p) {
    if (contains(p)) return p;
    var best = points.first;
    var bestDist = double.infinity;
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      final c = _closestOnSegment(p, a, b);
      final d = (c - p).distanceSquared;
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    return best;
  }
}

Offset _closestOnSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.distanceSquared;
  if (len2 == 0) return a;
  final t = (((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / len2)
      .clamp(0.0, 1.0)
      .toDouble();
  return Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
}
