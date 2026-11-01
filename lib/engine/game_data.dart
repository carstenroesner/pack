import 'dart:ui';

import 'ast.dart';
import 'geometry.dart';

class VerbDef {
  const VerbDef(this.id, this.label, {this.preposition});

  final String id;
  final String label;

  /// Wenn gesetzt, braucht das Verb ein zweites Objekt ("Benutze X mit Y").
  final String? preposition;

  bool get takesSecond => preposition != null;
}

class FigureDef {
  const FigureDef(this.id, this.name, this.color);

  final String id;
  final String name;
  final Color color;
}

/// Eine Zeichenform in Raumkoordinaten.
class ShapeDef {
  const ShapeDef({
    required this.path,
    this.fill,
    this.stroke,
    this.strokeWidth = 5,
    this.front = false,
  });

  final Path path;
  final Color? fill;
  final Color? stroke;
  final double strokeWidth;

  /// Wird vor der Spielfigur gezeichnet statt dahinter.
  final bool front;
}

class ShapeGroup {
  ShapeGroup(this.cond);

  final Cond cond;
  final List<ShapeDef> shapes = <ShapeDef>[];
}

/// Behandlung eines Verbs an einem Objekt oder Gegenstand.
class HandlerDef {
  const HandlerDef(this.verb, this.withId, this.body, this.line);

  /// Verb-Id oder "*" für jedes Verb.
  final String verb;

  /// Zweites Objekt ("Benutze X mit Y": das Y bzw. X, siehe Engine).
  final String? withId;
  final List<Stmt> body;
  final int line;
}

class ItemDef {
  ItemDef(this.id, this.name);

  final String id;
  final String name;
  String? description;
  final List<HandlerDef> handlers = <HandlerDef>[];
}

class ObjectDef {
  ObjectDef(this.id, this.name, this.area);

  final String id;
  final String name;
  final Polygon area;
  String? mark;
  String? description;
  bool startsHidden = false;
  Cond visibleWhen = Cond.always;
  final List<ShapeGroup> groups = <ShapeGroup>[];
  final List<HandlerDef> handlers = <HandlerDef>[];
}

class RoomDef {
  RoomDef(this.id, this.name);

  final String id;
  final String name;
  double width = 1600;
  Color skyTop = const Color(0xFF000000);
  Color skyBottom = const Color(0xFF222222);
  Color groundColor = const Color(0xFF111111);
  double groundTop = 700;
  Polygon walk = Polygon.box(0, 700, 1600, 280);
  final Map<String, Offset> marks = <String, Offset>{};
  final List<ObjectDef> objects = <ObjectDef>[];
  final List<ShapeGroup> groups = <ShapeGroup>[];
  List<Stmt> onEnter = const <Stmt>[];
  Cond? darkWhen;
}

class DialogDef {
  DialogDef(this.id);

  final String id;
  final Map<String, List<Stmt>> topics = <String, List<Stmt>>{};
}

class GameDef {
  String title = '';
  String player = '';
  String startRoom = '';
  String? startMark;
  Color? stroke;
  final List<VerbDef> verbs = <VerbDef>[];
  final Map<String, VerbDef> verbById = <String, VerbDef>{};
  final Map<String, FigureDef> figures = <String, FigureDef>{};
  final Map<String, ItemDef> items = <String, ItemDef>{};
  final Map<String, RoomDef> rooms = <String, RoomDef>{};
  final Map<String, ObjectDef> objects = <String, ObjectDef>{};
  final Map<String, DialogDef> dialogs = <String, DialogDef>{};
  final Map<String, List<Stmt>> scripts = <String, List<Stmt>>{};
  final Map<String, List<String>> defaults = <String, List<String>>{};

  /// Die Standard-Aktion ("Gehe zu").
  String defaultVerb = 'gehe';
}
