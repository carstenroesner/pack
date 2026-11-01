import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'ast.dart';
import 'game_data.dart';
import 'process.dart';

class ActorState {
  ActorState(this.pos);

  Offset pos;
  Offset? target;
  bool walking = false;
  bool facingRight = true;
  double phase = 0;
}

class Speech {
  Speech(this.actor, this.text, this.owner, this.remaining);

  final String actor;
  final String text;
  final ScriptProcess owner;
  double remaining;
}

class _Found {
  const _Found(this.owner, this.handler);

  final String owner;
  final HandlerDef handler;
}

/// Die Spiel-Engine: Zustand, Eingabe (Verb + Objekt), Skriptausführung.
///
/// Alle Koordinaten sind Raumeinheiten, unabhängig von Gerät und Auflösung.
/// Ein Raum ist [roomHeight] Einheiten hoch und beliebig breit.
/// Die Logik läuft in festen Zeitschritten über [tick] und ist damit
/// reproduzierbar testbar.
class GameEngine extends ChangeNotifier {
  GameEngine(this.game) {
    newGame();
  }

  static const double roomHeight = 1000;
  static const double walkSpeed = 380;
  static const double figureHeight = 270;

  final GameDef game;

  /// Zählt Bildschritte; der Renderer hört darauf, ohne die Oberfläche
  /// jedes Mal neu aufzubauen.
  final ValueNotifier<int> frame = ValueNotifier<int>(0);

  String roomId = '';
  final Set<String> flags = <String>{};
  final List<String> inventory = <String>[];
  final Set<String> hidden = <String>{};
  ActorState player = ActorState(Offset.zero);
  String verbId = 'gehe';
  String? firstId;
  String? hoverId;
  Speech? speech;
  List<ChoiceOption>? choices;
  bool finished = false;
  String endingText = '';

  final List<ScriptProcess> _procs = <ScriptProcess>[];
  ScriptProcess? _choiceProc;
  int _defaultCounter = 0;

  @override
  void dispose() {
    frame.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------- Zustand

  RoomDef get room => game.rooms[roomId]!;
  bool get busy => _procs.isNotEmpty;
  bool get isWalking => player.walking;
  bool get isAnimating => busy || player.walking || speech != null;
  bool get canInteract => !busy && !finished;
  bool get canSave => canInteract && !player.walking;
  bool get inCutscene => _procs.any((p) => p.cutscene > 0);

  bool holds(Cond c) => c.terms.every((t) {
        final v = t.item ? inventory.contains(t.name) : flags.contains(t.name);
        return t.negate ? !v : v;
      });

  bool isVisible(ObjectDef o) => !hidden.contains(o.id) && holds(o.visibleWhen);

  String nameOf(String id) => game.objects[id]?.name ?? game.items[id]?.name ?? id;

  String? descriptionOf(String id) =>
      game.objects[id]?.description ?? game.items[id]?.description;

  List<HandlerDef> _handlersOf(String id) =>
      game.objects[id]?.handlers ?? game.items[id]?.handlers ?? const <HandlerDef>[];

  ObjectDef? _roomObject(String id) {
    final o = game.objects[id];
    if (o != null && room.objects.contains(o)) return o;
    return null;
  }

  String get sentence {
    if (busy || finished || choices != null) return '';
    final v = game.verbById[verbId]!;
    final b = StringBuffer(v.label);
    final first = firstId;
    if (first != null) {
      b.write(' ${nameOf(first)}');
      if (v.preposition != null) b.write(' ${v.preposition}');
    }
    final h = hoverId;
    if (h != null && h != first) b.write(' ${nameOf(h)}');
    return b.toString();
  }

  void _changed() => notifyListeners();

  // -------------------------------------------------------- Neues Spiel

  void newGame() {
    _procs.clear();
    flags.clear();
    inventory.clear();
    hidden
      ..clear()
      ..addAll(game.objects.values.where((o) => o.startsHidden).map((o) => o.id));
    speech = null;
    choices = null;
    _choiceProc = null;
    finished = false;
    endingText = '';
    _defaultCounter = 0;
    player = ActorState(Offset.zero);
    _reset();
    hoverId = null;
    _enterRoom(game.startRoom, game.startMark);
    final start = game.scripts['start'];
    if (start != null) _spawn(start, null);
    _changed();
  }

  void _reset() {
    verbId = game.defaultVerb;
    firstId = null;
  }

  void _enterRoom(String id, String? mark) {
    roomId = id;
    final r = room;
    final pos = (mark != null ? r.marks[mark] : null) ??
        r.marks['start'] ??
        r.walk.bounds.center;
    player
      ..pos = pos
      ..walking = false
      ..target = null;
    _reset();
    hoverId = null;
    if (r.onEnter.isNotEmpty) _spawn(r.onEnter, null);
  }

  void _spawn(List<Stmt> body, String? contextObject) {
    _procs.add(ScriptProcess(body, contextObject: contextObject));
  }

  // -------------------------------------------------------------- Eingabe

  void selectVerb(String id) {
    if (!canInteract || !game.verbById.containsKey(id)) return;
    verbId = id;
    firstId = null;
    _changed();
  }

  void hover(String? id) {
    if (hoverId == id) return;
    hoverId = id;
    _changed();
  }

  String? objectAt(Offset p) {
    final list = room.objects;
    for (var i = list.length - 1; i >= 0; i--) {
      final o = list[i];
      if (isVisible(o) && o.area.contains(p)) return o.id;
    }
    return null;
  }

  /// Tipp auf die Szene (Raumkoordinaten).
  void onSceneTap(Offset p) {
    if (finished) return;
    if (busy) {
      if (speech != null) skipSpeech();
      return;
    }
    final id = objectAt(p);
    if (id != null) {
      target(id);
      return;
    }
    if (firstId != null) {
      _reset();
      _changed();
      return;
    }
    _reset();
    _startWalk(p);
    _changed();
  }

  /// Langes Drücken (Rechtsklick): Objekt ansehen.
  void onSceneLongPress(Offset p) {
    if (!canInteract) return;
    final id = objectAt(p);
    if (id == null) return;
    _reset();
    _perform('schau', id, null);
  }

  /// Wendet das gewählte Verb auf ein Objekt oder einen Gegenstand an.
  void target(String id) {
    if (!canInteract) return;
    var verb = verbId;
    final first = firstId;
    if (first == null) {
      final v = game.verbById[verb]!;
      if (v.takesSecond && game.items.containsKey(id)) {
        firstId = id;
        hoverId = null;
        _changed();
        return;
      }
      if (verb == game.defaultVerb && game.items.containsKey(id)) verb = 'schau';
      _reset();
      _perform(verb, id, null);
    } else {
      _reset();
      _perform(verb, first, id);
    }
  }

  void chooseOption(int index) {
    final opts = choices;
    final p = _choiceProc;
    if (opts == null || p == null || index < 0 || index >= opts.length) return;
    final o = opts[index];
    choices = null;
    _choiceProc = null;
    p.frames.add(Frame(<Stmt>[Say(null, o.text), ...o.body]));
    p.wait = WaitKind.none;
    _changed();
  }

  void skipSpeech() {
    if (speech == null) return;
    speech = null;
    _changed();
  }

  void skipCutscene() {
    for (final p in _procs) {
      if (p.cutscene > 0) p.fast = true;
    }
    speech = null;
    _changed();
  }

  // ----------------------------------------------------------- Handlungen

  _Found? _findHandler(String verb, String a, String? b) {
    if (b != null) {
      for (final h in _handlersOf(b)) {
        if (h.verb == verb && h.withId == a) return _Found(b, h);
      }
      for (final h in _handlersOf(a)) {
        if (h.verb == verb && h.withId == b) return _Found(a, h);
      }
      return null;
    }
    for (final h in _handlersOf(a)) {
      if (h.verb == verb && h.withId == null) return _Found(a, h);
    }
    for (final h in _handlersOf(a)) {
      if (h.verb == '*' && h.withId == null) return _Found(a, h);
    }
    return null;
  }

  List<Stmt> _defaultFor(String verb, String a, String? b) {
    if (verb == 'schau' && b == null) {
      return <Stmt>[Say(null, descriptionOf(a) ?? 'Nichts Besonderes.')];
    }
    if (verb == game.defaultVerb && b == null) return const <Stmt>[];
    final list = game.defaults[verb] ?? game.defaults['*'] ?? const <String>['Das geht nicht.'];
    final text = list[_defaultCounter++ % list.length];
    return <Stmt>[Say(null, text)];
  }

  void _perform(String verb, String a, String? b) {
    final found = _findHandler(verb, a, b);
    final body = <Stmt>[];
    final String? worldId;
    if (b != null && _roomObject(b) != null) {
      worldId = b;
    } else if (_roomObject(a) != null) {
      worldId = a;
    } else {
      worldId = null;
    }
    if (verb != 'schau' && worldId != null) body.add(WalkObject(worldId));
    if (found != null) {
      body.addAll(found.handler.body);
    } else {
      body.addAll(_defaultFor(verb, a, b));
    }
    _spawn(body, found?.owner ?? worldId);
    _changed();
  }

  // ---------------------------------------------------------------- Gehen

  bool _startWalk(Offset target) {
    final t = room.walk.nearestInside(target);
    if ((t - player.pos).distance < 1) {
      player
        ..pos = t
        ..walking = false
        ..target = null;
      return false;
    }
    player
      ..target = t
      ..walking = true;
    return true;
  }

  Offset _walkPointFor(ObjectDef o) {
    final m = o.mark != null ? room.marks[o.mark] : null;
    if (m != null) return m;
    final b = o.area.bounds;
    return Offset(b.center.dx, b.bottom);
  }

  void _updateWalk(double dt) {
    if (!player.walking || player.target == null) return;
    final t = player.target!;
    final d = t - player.pos;
    final dist = d.distance;
    final step = walkSpeed * dt;
    if (d.dx.abs() > 0.5) player.facingRight = d.dx > 0;
    player.phase += dt * 9;
    if (dist <= step) {
      player
        ..pos = t
        ..walking = false
        ..target = null;
    } else {
      player.pos = player.pos + d / dist * step;
    }
  }

  // ----------------------------------------------------------------- Takt

  /// Ein fester Zeitschritt in Sekunden.
  void tick(double dt) {
    _updateWalk(dt);
    final s = speech;
    if (s != null) {
      s.remaining -= dt;
      if (s.remaining <= 0) {
        speech = null;
        _changed();
      }
    }
    for (final p in List<ScriptProcess>.of(_procs)) {
      _run(p, dt);
    }
    final before = _procs.length;
    _procs.removeWhere((p) => p.done);
    if (_procs.length != before) _changed();
    frame.value++;
  }

  void _run(ScriptProcess p, double dt) {
    if (p.fast && p.wait != WaitKind.choice) {
      p.wait = WaitKind.none;
      final t = player.target;
      if (player.walking && t != null) {
        player
          ..pos = t
          ..walking = false
          ..target = null;
      }
    }
    switch (p.wait) {
      case WaitKind.none:
        break;
      case WaitKind.time:
        p.timeLeft -= dt;
        if (p.timeLeft > 0) return;
        p.wait = WaitKind.none;
        break;
      case WaitKind.speech:
        final s = speech;
        if (s != null && identical(s.owner, p)) return;
        p.wait = WaitKind.none;
        break;
      case WaitKind.walk:
        if (player.walking) return;
        p.wait = WaitKind.none;
        break;
      case WaitKind.choice:
        return;
    }
    var guard = 0;
    while (!p.done && p.wait == WaitKind.none) {
      if (++guard > 5000) throw StateError('Ein Skript läuft endlos.');
      final s = p.next();
      if (s == null) {
        p.done = true;
        break;
      }
      _exec(p, s);
    }
  }

  String? _popToTopic(ScriptProcess p) {
    while (p.frames.isNotEmpty) {
      final f = p.frames.removeLast();
      f.onExit?.call();
      if (f.dialogId != null) return f.dialogId;
    }
    return null;
  }

  void _exec(ScriptProcess p, Stmt s) {
    if (s is Say) {
      if (p.fast) return;
      final who = s.actor ?? game.player;
      final secs = math.max(1.4, s.text.length * 0.06);
      speech = Speech(who, s.text, p, secs);
      p.wait = WaitKind.speech;
      _changed();
    } else if (s is Pause) {
      if (p.fast) return;
      p.timeLeft = s.seconds;
      p.wait = WaitKind.time;
    } else if (s is GiveItem) {
      if (!inventory.contains(s.item)) inventory.add(s.item);
      _changed();
    } else if (s is RemoveItem) {
      inventory.remove(s.item);
      _changed();
    } else if (s is SetFlag) {
      if (s.value) {
        flags.add(s.name);
      } else {
        flags.remove(s.name);
      }
      _changed();
    } else if (s is If) {
      p.frames.add(Frame(holds(s.cond) ? s.then : s.otherwise));
    } else if (s is WalkMark) {
      final m = room.marks[s.mark];
      if (m == null) throw StateError('Marke "${s.mark}" fehlt im Raum $roomId.');
      _walkFor(p, m);
    } else if (s is WalkObject) {
      final o = _roomObject(s.objectId);
      if (o != null) _walkFor(p, _walkPointFor(o));
    } else if (s is GotoRoom) {
      _enterRoom(s.room, s.mark);
      _changed();
    } else if (s is ShowHide) {
      final id = s.id ?? p.contextObject;
      if (id == null) throw StateError('"zeige"/"verstecke" braucht hier eine Objekt-Id.');
      if (s.show) {
        hidden.remove(id);
      } else {
        hidden.add(id);
      }
      _changed();
    } else if (s is StartDialog) {
      final d = game.dialogs[s.dialogId]!;
      p.frames.add(Frame(d.topics['start']!, dialogId: d.id));
    } else if (s is Choice) {
      final opts = s.options.where((o) => holds(o.cond)).toList();
      if (opts.isEmpty) return;
      choices = opts;
      _choiceProc = p;
      p.wait = WaitKind.choice;
      _changed();
    } else if (s is Jump) {
      final id = _popToTopic(p);
      if (id == null) throw StateError('"weiter" steht außerhalb eines Dialogs.');
      p.frames.add(Frame(game.dialogs[id]!.topics[s.topic]!, dialogId: id));
    } else if (s is EndDialog) {
      _popToTopic(p);
    } else if (s is Cutscene) {
      p.cutscene++;
      p.frames.add(Frame(s.body, onExit: () {
        p.cutscene--;
        if (p.cutscene == 0) p.fast = false;
      }));
    } else if (s is EndGame) {
      finished = true;
      endingText = s.text;
      speech = null;
      choices = null;
      _choiceProc = null;
      for (final q in _procs) {
        q.done = true;
      }
      _changed();
    } else if (s is RunScript) {
      p.frames.add(Frame(game.scripts[s.name]!));
    }
  }

  void _walkFor(ScriptProcess p, Offset target) {
    if (p.fast) {
      player
        ..pos = room.walk.nearestInside(target)
        ..walking = false
        ..target = null;
      return;
    }
    if (_startWalk(target)) p.wait = WaitKind.walk;
  }

  // ------------------------------------------------------------ Darstellung

  Offset speakerAnchor(String actorId) {
    if (actorId == game.player) {
      return player.pos + const Offset(0, -(figureHeight + 30));
    }
    final o = _roomObject(actorId);
    if (o != null) {
      final b = o.area.bounds;
      return Offset(b.center.dx, b.top - 10);
    }
    return Offset(room.width / 2, 160);
  }

  /// Linker Rand des sichtbaren Ausschnitts in Raumeinheiten.
  double cameraX(double viewWidthUnits) {
    final maxX = room.width - viewWidthUnits;
    if (maxX <= 0) return maxX / 2;
    return (player.pos.dx - viewWidthUnits / 2).clamp(0.0, maxX).toDouble();
  }

  // ------------------------------------------------------------- Speichern

  Map<String, dynamic> toJson() => <String, dynamic>{
        'version': 1,
        'room': roomId,
        'flags': flags.toList()..sort(),
        'hidden': hidden.toList()..sort(),
        'inventory': List<String>.of(inventory),
        'x': player.pos.dx,
        'y': player.pos.dy,
        'right': player.facingRight,
      };

  bool loadJson(Map<String, dynamic> j) {
    try {
      final r = j['room'];
      if (r is! String || !game.rooms.containsKey(r)) return false;
      final newFlags = (j['flags'] as List).cast<String>();
      final newHidden = (j['hidden'] as List).cast<String>();
      final newInv = (j['inventory'] as List).cast<String>();
      final x = (j['x'] as num).toDouble();
      final y = (j['y'] as num).toDouble();
      _procs.clear();
      speech = null;
      choices = null;
      _choiceProc = null;
      finished = false;
      endingText = '';
      roomId = r;
      flags
        ..clear()
        ..addAll(newFlags);
      hidden
        ..clear()
        ..addAll(newHidden);
      inventory
        ..clear()
        ..addAll(newInv);
      player
        ..pos = Offset(x, y)
        ..facingRight = (j['right'] as bool?) ?? true
        ..walking = false
        ..target = null;
      _reset();
      hoverId = null;
      _changed();
      return true;
    } catch (_) {
      return false;
    }
  }
}
