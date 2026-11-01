import 'dart:ui';

/// Liest Pfaddaten im SVG-Stil. Unterstützt absolute Befehle M, L, H, V, Q, C, Z.
Path parsePathData(String d) {
  final tokens = RegExp(r'[MLHVQCZ]|-?\d*\.?\d+(?:[eE][-+]?\d+)?')
      .allMatches(d)
      .map((m) => m.group(0)!)
      .toList();
  final isCmd = RegExp(r'^[A-Za-z]$');
  final path = Path();
  var i = 0;
  var cmd = '';
  var cx = 0.0;
  var cy = 0.0;

  double next() {
    if (i >= tokens.length || isCmd.hasMatch(tokens[i])) {
      throw FormatException('Zahl erwartet in Pfad "$d"');
    }
    return double.parse(tokens[i++]);
  }

  while (i < tokens.length) {
    if (isCmd.hasMatch(tokens[i])) {
      cmd = tokens[i++];
    } else if (cmd.isEmpty) {
      throw FormatException('Pfad muss mit einem Befehl beginnen: "$d"');
    }
    switch (cmd) {
      case 'M':
        cx = next();
        cy = next();
        path.moveTo(cx, cy);
        cmd = 'L';
        break;
      case 'L':
        cx = next();
        cy = next();
        path.lineTo(cx, cy);
        break;
      case 'H':
        cx = next();
        path.lineTo(cx, cy);
        break;
      case 'V':
        cy = next();
        path.lineTo(cx, cy);
        break;
      case 'Q':
        final x1 = next();
        final y1 = next();
        cx = next();
        cy = next();
        path.quadraticBezierTo(x1, y1, cx, cy);
        break;
      case 'C':
        final x1 = next();
        final y1 = next();
        final x2 = next();
        final y2 = next();
        cx = next();
        cy = next();
        path.cubicTo(x1, y1, x2, y2, cx, cy);
        break;
      case 'Z':
        path.close();
        cmd = '';
        break;
      default:
        throw FormatException('Unbekannter Pfadbefehl "$cmd"');
    }
  }
  return path;
}
