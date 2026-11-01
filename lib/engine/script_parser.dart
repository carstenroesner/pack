import 'dart:ui';

import 'ast.dart';
import 'game_data.dart';
import 'geometry.dart';
import 'path_data.dart';
import 'script_error.dart';
import 'tokenizer.dart';

export 'script_error.dart';

/// Liest ein komplettes Spiel aus dem Skripttext und prüft alle Verweise.
GameDef parseGame(String source) {
  final roots = buildTree(readLines(source));
  final game = _GameParser().parse(roots);
  _validate(game);
  return game;
}

Color? parseColor(String text, [int? line]) {
  if (text == '-') return null;
  if (!text.startsWith('#')) {
    throw ScriptError('Farbe erwartet (#RGB, #RRGGBB, #RRGGBBAA oder -): $text', line);
  }
  var h = text.substring(1);
  if (h.length == 3) {
    h = h.split('').map((c) => '$c$c').join();
  }
  if (h.length == 6) {
    h = 'FF$h';
  } else if (h.length == 8) {
    h = h.substring(6) + h.substring(0, 6);
  } else {
    throw ScriptError('Ungültige Farbe: $text', line);
  }
  final v = int.tryParse(h, radix: 16);
  if (v == null) throw ScriptError('Ungültige Farbe: $text', line);
  return Color(v);
}

class _GameParser {
  final GameDef game = GameDef();

  static const Set<String> _shapeWords = <String>{
    'kreis',
    'ellipse',
    'rechteck',
    'vieleck',
    'pfad',
    'vorne',
  };

  GameDef parse(List<Node> roots) {
    for (final n in roots) {
      if (n.tokens[0].text == 'kontur') game.stroke = _colorAt(n, 1);
    }
    for (final n in roots) {
      final kw = n.tokens[0].text;
      switch (kw) {
        case 'kontur':
          break;
        case 'spiel':
          game.title = _quoted(n, 1);
          break;
        case 'start':
          game.startRoom = _word(n, 1);
          game.startMark = n.tokens.length > 2 ? _word(n, 2) : null;
          break;
        case 'spieler':
          game.player = _word(n, 1);
          break;
        case 'verb':
          _verb(n);
          break;
        case 'figur':
          _figure(n);
          break;
        case 'gegenstand':
          _item(n);
          break;
        case 'standard':
          _defaults(n);
          break;
        case 'raum':
          _room(n);
          break;
        case 'dialog':
          _dialog(n);
          break;
        case 'skript':
          _script(n);
          break;
        default:
          throw ScriptError('Unbekannte Anweisung "$kw"', n.lineNo);
      }
    }
    return game;
  }

  // ---------------------------------------------------------------- Helfer

  Token _tok(Node n, int i) {
    if (i >= n.tokens.length) throw ScriptError('Angabe fehlt', n.lineNo);
    return n.tokens[i];
  }

  String _word(Node n, int i) {
    final t = _tok(n, i);
    if (t.quoted) {
      throw ScriptError('Wort statt Text erwartet: "${t.text}"', n.lineNo);
    }
    return t.text;
  }

  String _quoted(Node n, int i) {
    final t = _tok(n, i);
    if (!t.quoted) {
      throw ScriptError('Text in Anführungszeichen erwartet: ${t.text}', n.lineNo);
    }
    return t.text;
  }

  double _num(Node n, int i) {
    final t = _tok(n, i);
    final v = t.quoted ? null : double.tryParse(t.text);
    if (v == null) throw ScriptError('Zahl erwartet: ${t.text}', n.lineNo);
    return v;
  }

  Color? _colorAt(Node n, int i) => parseColor(_word(n, i), n.lineNo);

  bool _isColorToken(Token t) =>
      !t.quoted && (t.text.startsWith('#') || t.text == '-');

  Offset _point(Node n, int i) {
    final w = _word(n, i);
    final parts = w.split(',');
    final x = parts.length == 2 ? double.tryParse(parts[0]) : null;
    final y = parts.length == 2 ? double.tryParse(parts[1]) : null;
    if (x == null || y == null) {
      throw ScriptError('Punkt erwartet (x,y): $w', n.lineNo);
    }
    return Offset(x, y);
  }

  List<Offset> _points(Node n, int start) {
    final pts = <Offset>[];
    for (var i = start; i < n.tokens.length; i++) {
      pts.add(_point(n, i));
    }
    if (pts.length < 3) {
      throw ScriptError('Ein Vieleck braucht mindestens drei Punkte', n.lineNo);
    }
    return pts;
  }

  Cond _condFrom(Node n, int start) {
    final toks = n.tokens;
    var end = toks.length;
    if (end > start && toks[end - 1].text == ':' && !toks[end - 1].quoted) end--;
    final terms = <CondTerm>[];
    var negate = false;
    var item = false;
    for (var i = start; i < end; i++) {
      final t = toks[i];
      if (t.quoted) throw ScriptError('Bedingung: Wort erwartet', n.lineNo);
      switch (t.text) {
        case 'und':
          break;
        case 'nicht':
          negate = true;
          break;
        case 'hat':
          item = true;
          break;
        default:
          terms.add(CondTerm(t.text, item: item, negate: negate));
          negate = false;
          item = false;
      }
    }
    if (terms.isEmpty) throw ScriptError('Bedingung fehlt', n.lineNo);
    return Cond(terms);
  }

  // --------------------------------------------------------- Definitionen

  void _verb(Node n) {
    final id = _word(n, 1);
    final label = _quoted(n, 2);
    String? prep;
    if (n.tokens.length > 3) {
      if (_word(n, 3) != 'mit') {
        throw ScriptError('Aufbau: verb <id> "Beschriftung" [mit "Wort"]', n.lineNo);
      }
      prep = _quoted(n, 4);
    }
    final v = VerbDef(id, label, preposition: prep);
    game.verbs.add(v);
    game.verbById[id] = v;
  }

  void _figure(Node n) {
    final id = _word(n, 1);
    final name = _quoted(n, 2);
    var color = const Color(0xFFFFFFFF);
    if (n.tokens.length > 3) {
      if (_word(n, 3) != 'farbe') {
        throw ScriptError('Aufbau: figur <id> "Name" farbe #RRGGBB', n.lineNo);
      }
      color = _colorAt(n, 4) ?? color;
    }
    game.figures[id] = FigureDef(id, name, color);
  }

  void _item(Node n) {
    final item = ItemDef(_word(n, 1), _quoted(n, 2));
    if (game.items.containsKey(item.id)) {
      throw ScriptError('Gegenstand "${item.id}" doppelt definiert', n.lineNo);
    }
    for (final c in n.children) {
      final kw = c.tokens[0].text;
      switch (kw) {
        case 'beschreibung':
          item.description = _quoted(c, 1);
          break;
        case 'bei':
          item.handlers.add(_handler(c));
          break;
        default:
          throw ScriptError('Unbekannte Angabe "$kw" im Gegenstand', c.lineNo);
      }
    }
    game.items[item.id] = item;
  }

  void _defaults(Node n) {
    final verb = _word(n, 1);
    final list = <String>[];
    for (var i = 2; i < n.tokens.length; i++) {
      list.add(_quoted(n, i));
    }
    if (list.isEmpty) throw ScriptError('Mindestens ein Text erwartet', n.lineNo);
    game.defaults[verb] = list;
  }

  void _dialog(Node n) {
    final d = DialogDef(_word(n, 1));
    for (final c in n.children) {
      final toks = c.tokens;
      if (toks.length != 2 || toks[1].text != ':' || toks[1].quoted) {
        throw ScriptError('Dialogthema erwartet: <name>:', c.lineNo);
      }
      d.topics[toks[0].text] = _stmts(c.children);
    }
    if (!d.topics.containsKey('start')) {
      throw ScriptError('Dialog "${d.id}" braucht das Thema "start"', n.lineNo);
    }
    game.dialogs[d.id] = d;
  }

  void _script(Node n) {
    final toks = n.tokens;
    if (toks.length != 3 || toks[2].text != ':') {
      throw ScriptError('Aufbau: skript <name>:', n.lineNo);
    }
    game.scripts[toks[1].text] = _stmts(n.children);
  }

  HandlerDef _handler(Node n) {
    final toks = n.tokens;
    if (toks.last.text != ':' || toks.last.quoted) {
      throw ScriptError('Doppelpunkt fehlt hinter "bei"', n.lineNo);
    }
    final verb = _word(n, 1);
    String? withId;
    if (toks.length == 5) {
      if (_word(n, 2) != 'mit') {
        throw ScriptError('Aufbau: bei <verb> [mit <id>]:', n.lineNo);
      }
      withId = _word(n, 3);
    } else if (toks.length != 3) {
      throw ScriptError('Aufbau: bei <verb> [mit <id>]:', n.lineNo);
    }
    return HandlerDef(verb, withId, _stmts(n.children), n.lineNo);
  }

  // ------------------------------------------------------------------ Raum

  void _room(Node n) {
    final room = RoomDef(_word(n, 1), _quoted(n, 2));
    if (game.rooms.containsKey(room.id)) {
      throw ScriptError('Raum "${room.id}" doppelt definiert', n.lineNo);
    }
    for (final c in n.children) {
      final kw = c.tokens[0].text;
      switch (kw) {
        case 'groesse':
          room.width = _num(c, 1);
          break;
        case 'himmel':
          room.skyTop = _colorAt(c, 1)!;
          room.skyBottom = _colorAt(c, 2)!;
          break;
        case 'boden':
          room.groundColor = _colorAt(c, 1)!;
          if (_word(c, 2) != 'ab') {
            throw ScriptError('Aufbau: boden #farbe ab <y>', c.lineNo);
          }
          room.groundTop = _num(c, 3);
          break;
        case 'lauf':
          room.walk = Polygon(_points(c, 1));
          break;
        case 'marke':
          room.marks[_word(c, 1)] = Offset(_num(c, 2), _num(c, 3));
          break;
        case 'dunkel':
          room.darkWhen = _condFrom(c, 1);
          break;
        case 'beim_betreten':
          room.onEnter = _stmts(c.children);
          break;
        case 'objekt':
          final o = _object(c);
          if (game.objects.containsKey(o.id) || game.items.containsKey(o.id)) {
            throw ScriptError('Die Id "${o.id}" ist schon vergeben', c.lineNo);
          }
          room.objects.add(o);
          game.objects[o.id] = o;
          break;
        case 'wenn':
          _addConditional(room.groups, c);
          break;
        default:
          if (_shapeWords.contains(kw)) {
            _addShape(room.groups, _shape(c));
          } else {
            throw ScriptError('Unbekannte Angabe "$kw" im Raum', c.lineNo);
          }
      }
    }
    game.rooms[room.id] = room;
  }

  ObjectDef _object(Node n) {
    final id = _word(n, 1);
    final name = _quoted(n, 2);
    Polygon? area;
    String? mark;
    String? desc;
    var hidden = false;
    var visible = Cond.always;
    final groups = <ShapeGroup>[];
    final handlers = <HandlerDef>[];
    for (final c in n.children) {
      final kw = c.tokens[0].text;
      switch (kw) {
        case 'klick':
          area = Polygon(_points(c, 1));
          break;
        case 'klickkasten':
          area = Polygon.box(_num(c, 1), _num(c, 2), _num(c, 3), _num(c, 4));
          break;
        case 'ziel':
          mark = _word(c, 1);
          break;
        case 'beschreibung':
          desc = _quoted(c, 1);
          break;
        case 'versteckt':
          hidden = true;
          break;
        case 'sichtbar':
          if (_word(c, 1) != 'wenn') {
            throw ScriptError('Aufbau: sichtbar wenn <bedingung>', c.lineNo);
          }
          visible = _condFrom(c, 2);
          break;
        case 'wenn':
          _addConditional(groups, c);
          break;
        case 'bei':
          handlers.add(_handler(c));
          break;
        default:
          if (_shapeWords.contains(kw)) {
            _addShape(groups, _shape(c));
          } else {
            throw ScriptError('Unbekannte Angabe "$kw" im Objekt "$id"', c.lineNo);
          }
      }
    }
    if (area == null) {
      throw ScriptError('Objekt "$id" braucht "klick" oder "klickkasten"', n.lineNo);
    }
    final o = ObjectDef(id, name, area)
      ..mark = mark
      ..description = desc
      ..startsHidden = hidden
      ..visibleWhen = visible;
    o.groups.addAll(groups);
    o.handlers.addAll(handlers);
    return o;
  }

  // --------------------------------------------------------------- Formen

  void _addShape(List<ShapeGroup> groups, ShapeDef s) {
    if (groups.isEmpty || !groups.last.cond.isAlways) {
      groups.add(ShapeGroup(Cond.always));
    }
    groups.last.shapes.add(s);
  }

  void _addConditional(List<ShapeGroup> groups, Node c) {
    final g = ShapeGroup(_condFrom(c, 1));
    for (final k in c.children) {
      if (!_shapeWords.contains(k.tokens[0].text)) {
        throw ScriptError('Unter "wenn" sind hier nur Formen erlaubt', k.lineNo);
      }
      g.shapes.add(_shape(k));
    }
    groups.add(g);
  }

  ShapeDef _shape(Node n) {
    final toks = n.tokens;
    var i = 0;
    var front = false;
    if (toks[0].text == 'vorne') {
      front = true;
      i = 1;
    }
    final kw = _word(n, i);
    final a = i + 1;
    Path? path;
    int c;
    switch (kw) {
      case 'kreis':
        {
          final x = _num(n, a);
          final y = _num(n, a + 1);
          final r = _num(n, a + 2);
          path = Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));
          c = a + 3;
          break;
        }
      case 'ellipse':
        {
          final x = _num(n, a);
          final y = _num(n, a + 1);
          final rx = _num(n, a + 2);
          final ry = _num(n, a + 3);
          path = Path()
            ..addOval(Rect.fromCenter(center: Offset(x, y), width: rx * 2, height: ry * 2));
          c = a + 4;
          break;
        }
      case 'rechteck':
        {
          final x = _num(n, a);
          final y = _num(n, a + 1);
          final w = _num(n, a + 2);
          final h = _num(n, a + 3);
          path = Path()..addRect(Rect.fromLTWH(x, y, w, h));
          c = a + 4;
          break;
        }
      case 'vieleck':
      case 'pfad':
        c = a;
        break;
      default:
        throw ScriptError('Unbekannte Form "$kw"', n.lineNo);
    }
    final fill = _colorAt(n, c);
    Color? stroke = game.stroke;
    var next = c + 1;
    if (next < toks.length && _isColorToken(toks[next])) {
      stroke = _colorAt(n, next);
      next++;
    }
    var width = 5.0;
    if (next < toks.length && toks[next].text == 'dick' && !toks[next].quoted) {
      width = _num(n, next + 1);
      next += 2;
    }
    if (kw == 'vieleck') {
      path = Path()..addPolygon(_points(n, next), true);
    } else if (kw == 'pfad') {
      try {
        path = parsePathData(_quoted(n, next));
      } on FormatException catch (e) {
        throw ScriptError(e.message, n.lineNo);
      }
    } else if (next < toks.length) {
      throw ScriptError('Überzählige Angaben bei "$kw"', n.lineNo);
    }
    return ShapeDef(
      path: path!,
      fill: fill,
      stroke: stroke,
      strokeWidth: width,
      front: front,
    );
  }

  // ---------------------------------------------------------- Anweisungen

  List<Stmt> _stmts(List<Node> nodes) {
    final out = <Stmt>[];
    for (var i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      final t = n.tokens;
      final kw = t[0].text;
      switch (kw) {
        case 'sage':
          if (t.length == 2 && t[1].quoted) {
            out.add(Say(null, t[1].text));
          } else if (t.length == 3 && !t[1].quoted && t[2].quoted) {
            out.add(Say(t[1].text == 'ich' ? null : t[1].text, t[2].text));
          } else {
            throw ScriptError('Aufbau: sage [figur] "Text"', n.lineNo);
          }
          break;
        case 'warte':
          out.add(Pause(_num(n, 1)));
          break;
        case 'gib':
          out.add(GiveItem(_word(n, 1)));
          break;
        case 'entferne':
          out.add(RemoveItem(_word(n, 1)));
          break;
        case 'setze':
          out.add(SetFlag(_word(n, 1), true));
          break;
        case 'loesche':
          out.add(SetFlag(_word(n, 1), false));
          break;
        case 'wenn':
          {
            final cond = _condFrom(n, 1);
            final then = _stmts(n.children);
            var other = <Stmt>[];
            if (i + 1 < nodes.length && nodes[i + 1].tokens[0].text == 'sonst') {
              other = _stmts(nodes[i + 1].children);
              i++;
            }
            out.add(If(cond, then, other));
            break;
          }
        case 'sonst':
          throw ScriptError('"sonst" ohne passendes "wenn"', n.lineNo);
        case 'gehezu':
          out.add(WalkMark(_word(n, 1)));
          break;
        case 'raum':
          out.add(GotoRoom(_word(n, 1), t.length > 2 ? _word(n, 2) : null));
          break;
        case 'zeige':
          out.add(ShowHide(true, t.length > 1 ? _word(n, 1) : null));
          break;
        case 'verstecke':
          out.add(ShowHide(false, t.length > 1 ? _word(n, 1) : null));
          break;
        case 'dialog':
          out.add(StartDialog(_word(n, 1)));
          break;
        case 'wahl':
          {
            final opts = <ChoiceOption>[];
            for (final c in n.children) {
              if (c.tokens[0].text != 'option') {
                throw ScriptError('In "wahl" sind nur "option"-Zeilen erlaubt', c.lineNo);
              }
              final text = _quoted(c, 1);
              var cond = Cond.always;
              if (c.tokens.length > 3 && c.tokens[2].text == 'wenn') {
                cond = _condFrom(c, 3);
              }
              opts.add(ChoiceOption(text, cond, _stmts(c.children)));
            }
            if (opts.isEmpty) throw ScriptError('"wahl" ohne Optionen', n.lineNo);
            out.add(Choice(opts));
            break;
          }
        case 'weiter':
          out.add(Jump(_word(n, 1)));
          break;
        case 'beende':
          out.add(const EndDialog());
          break;
        case 'zwischensequenz':
          out.add(Cutscene(_stmts(n.children)));
          break;
        case 'spielende':
          out.add(EndGame(_quoted(n, 1)));
          break;
        case 'starte':
          out.add(RunScript(_word(n, 1)));
          break;
        default:
          throw ScriptError('Unbekannter Befehl "$kw"', n.lineNo);
      }
    }
    return out;
  }
}

// ------------------------------------------------------------- Prüfung

void _validate(GameDef g) {
  if (g.rooms.isEmpty) throw ScriptError('Es ist kein Raum definiert');
  final start = g.rooms[g.startRoom];
  if (start == null) {
    throw ScriptError('Der Startraum "${g.startRoom}" existiert nicht');
  }
  if (g.startMark != null && !start.marks.containsKey(g.startMark)) {
    throw ScriptError('Die Startmarke "${g.startMark}" existiert nicht');
  }
  if (!g.figures.containsKey(g.player)) {
    throw ScriptError('Die Spielfigur "${g.player}" ist nicht als figur definiert');
  }
  for (final v in <String>['gehe', 'schau']) {
    if (!g.verbById.containsKey(v)) {
      throw ScriptError('Das Verb "$v" muss definiert sein');
    }
  }

  bool knownThing(String id) => g.items.containsKey(id) || g.objects.containsKey(id);

  void checkHandlers(List<HandlerDef> list, RoomDef? room, String owner) {
    for (final h in list) {
      if (h.verb != '*' && !g.verbById.containsKey(h.verb)) {
        throw ScriptError('Unbekanntes Verb "${h.verb}" bei $owner', h.line);
      }
      if (h.withId != null && !knownThing(h.withId!)) {
        throw ScriptError('Unbekannte Id "${h.withId}" bei $owner', h.line);
      }
      _checkBody(g, h.body, room, null, owner);
    }
  }

  for (final item in g.items.values) {
    checkHandlers(item.handlers, null, 'Gegenstand ${item.id}');
  }
  for (final room in g.rooms.values) {
    _checkBody(g, room.onEnter, room, null, 'Raum ${room.id}');
    for (final o in room.objects) {
      if (o.mark != null && !room.marks.containsKey(o.mark)) {
        throw ScriptError('Objekt ${o.id}: Marke "${o.mark}" existiert nicht in ${room.id}');
      }
      checkHandlers(o.handlers, room, 'Objekt ${o.id}');
    }
  }
  for (final d in g.dialogs.values) {
    for (final e in d.topics.entries) {
      _checkBody(g, e.value, null, d, 'Dialog ${d.id}/${e.key}');
    }
  }
  for (final e in g.scripts.entries) {
    _checkBody(g, e.value, null, null, 'Skript ${e.key}');
  }
}

void _checkBody(GameDef g, List<Stmt> body, RoomDef? room, DialogDef? dialog, String where) {
  Never fail(String m) => throw ScriptError('$m (in $where)');
  forEachStmt(body, (s) {
    if (s is GiveItem && !g.items.containsKey(s.item)) {
      fail('Gegenstand "${s.item}" ist unbekannt');
    } else if (s is RemoveItem && !g.items.containsKey(s.item)) {
      fail('Gegenstand "${s.item}" ist unbekannt');
    } else if (s is WalkMark && room != null && !room.marks.containsKey(s.mark)) {
      fail('Marke "${s.mark}" existiert nicht im Raum ${room.id}');
    } else if (s is GotoRoom) {
      final target = g.rooms[s.room];
      if (target == null) {
        throw ScriptError('Raum "${s.room}" ist unbekannt (in $where)');
      }
      if (s.mark != null && !target.marks.containsKey(s.mark)) {
        throw ScriptError('Marke "${s.mark}" existiert nicht im Raum ${s.room} (in $where)');
      }
    } else if (s is ShowHide && s.id != null && !g.objects.containsKey(s.id)) {
      fail('Objekt "${s.id}" ist unbekannt');
    } else if (s is StartDialog && !g.dialogs.containsKey(s.dialogId)) {
      fail('Dialog "${s.dialogId}" ist unbekannt');
    } else if (s is Jump && dialog != null && !dialog.topics.containsKey(s.topic)) {
      fail('Dialogthema "${s.topic}" ist unbekannt');
    } else if (s is RunScript && !g.scripts.containsKey(s.name)) {
      fail('Skript "${s.name}" ist unbekannt');
    } else if (s is Say && s.actor != null && !g.figures.containsKey(s.actor)) {
      fail('Figur "${s.actor}" ist nicht definiert');
    }
  });
}
