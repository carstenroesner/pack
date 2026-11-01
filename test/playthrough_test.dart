import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:point_and_click_adventure/engine/engine.dart';
import 'package:point_and_click_adventure/engine/script_parser.dart';

void settle(GameEngine e) {
  var n = 0;
  while (e.busy && e.choices == null && n++ < 30000) {
    e.tick(1 / 60);
  }
  expect(n, lessThan(30000), reason: 'Ein Skript endet nicht');
}

/// Beendet offene Gespräche über die letzte Antwort (immer "Tschüss").
void leaveDialogs(GameEngine e) {
  var n = 0;
  while (e.choices != null && n++ < 20) {
    e.chooseOption(e.choices!.length - 1);
    settle(e);
  }
}

void act(GameEngine e, String verb, String a, [String? b]) {
  expect(e.canInteract, isTrue, reason: 'Eingabe gesperrt bei $verb $a');
  e.selectVerb(verb);
  e.target(a);
  if (b != null) e.target(b);
  settle(e);
}

String loadSource() => File('assets/game/knarz.scr').readAsStringSync();

void main() {
  test('Das Skript wird fehlerfrei gelesen', () {
    final g = parseGame(loadSource());
    expect(g.title, 'Knarz Manor');
    expect(g.rooms.keys, containsAll(['garten', 'halle', 'kueche']));
    expect(g.verbs.length, 12);
  });

  test('Das Spiel lässt sich von Anfang bis Ende lösen', () {
    final e = GameEngine(parseGame(loadSource()));
    settle(e); // Einleitung
    expect(e.roomId, 'garten');

    act(e, 'nimm', 'schere_o');
    expect(e.inventory, contains('schere'));
    act(e, 'benutze', 'schere', 'hecke');
    expect(e.inventory, contains('knopf'));
    act(e, 'gib', 'knopf', 'rabe');
    expect(e.inventory, contains('schluessel'));
    act(e, 'benutze', 'schluessel', 'haustuer');
    expect(e.flags, contains('tuer_offen'));
    act(e, 'gehe', 'haustuer');
    expect(e.roomId, 'halle');

    act(e, 'nimm', 'streichhoelzer_o');
    act(e, 'gehe', 'kuechentuer');
    expect(e.roomId, 'kueche');
    act(e, 'nimm', 'kerze_o');
    act(e, 'nimm', 'kelle_o');
    act(e, 'benutze', 'kelle', 'kessel');
    expect(e.inventory, contains('kette'));
    act(e, 'gehe', 'tuer_halle');
    expect(e.roomId, 'halle');

    act(e, 'benutze', 'kerze', 'kandelaber');
    act(e, 'benutze', 'streichhoelzer', 'kandelaber');
    expect(e.flags, contains('halle_hell'));
    expect(e.isVisible(e.game.objects['knarz']!), isTrue);
    act(e, 'gib', 'kette', 'knarz');
    expect(e.finished, isTrue);
    expect(e.endingText, isNotEmpty);
  });

  test('Zwischensequenzen lassen sich überspringen', () {
    final e = GameEngine(parseGame(loadSource()));
    e.tick(1 / 60);
    expect(e.inCutscene, isTrue);
    e.skipCutscene();
    e.tick(1 / 60);
    e.tick(1 / 60);
    expect(e.busy, isFalse);
  });

  test('Jedes Verb auf jedem Objekt und Gegenstand endet ohne Fehler', () {
    final g = parseGame(loadSource());
    for (final roomId in g.rooms.keys) {
      for (final o in g.rooms[roomId]!.objects) {
        for (final v in g.verbs) {
          if (v.takesSecond) continue;
          final e = GameEngine(g);
          settle(e);
          expect(
            e.loadJson({
              'room': roomId,
              'flags': <String>[],
              'hidden': <String>[],
              'inventory': <String>[],
              'x': 300.0,
              'y': 880.0,
              'right': true,
            }),
            isTrue,
          );
          e.selectVerb(v.id);
          e.target(o.id);
          settle(e);
          leaveDialogs(e);
          expect(e.busy, isFalse, reason: '${v.id} ${o.id}');
        }
      }
    }
  });

  test('Jeder Gegenstand kann angesehen werden', () {
    final e = GameEngine(parseGame(loadSource()));
    settle(e);
    for (final id in e.game.items.keys) {
      e.inventory.add(id);
      act(e, 'schau', id);
    }
  });

  test('Speichern und Laden mitten im Spiel', () {
    final e = GameEngine(parseGame(loadSource()));
    settle(e);
    act(e, 'nimm', 'schere_o');
    final saved = e.toJson();
    final f = GameEngine(parseGame(loadSource()));
    expect(f.loadJson(saved), isTrue);
    expect(f.inventory, ['schere']);
    expect(f.isVisible(f.game.objects['schere_o']!), isFalse);
  });

  test('Rabe lässt sich ansprechen und der Dialog ist wiederholbar', () {
    final e = GameEngine(parseGame(loadSource()));
    settle(e);
    e.selectVerb('rede');
    e.target('rabe');
    var n = 0;
    while (e.choices == null && n++ < 5000) {
      e.tick(1 / 60);
    }
    expect(e.choices, isNotNull);
    e.chooseOption(0);
    n = 0;
    while (e.choices == null && n++ < 5000) {
      e.tick(1 / 60);
    }
    expect(e.choices, isNotNull, reason: 'Nach der Antwort kommt die Auswahl wieder');
    e.chooseOption(e.choices!.length - 1);
    settle(e);
    expect(e.busy, isFalse);
  });
}
