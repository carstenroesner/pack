import 'package:flutter_test/flutter_test.dart';
import 'package:point_and_click_adventure/models/game_models.dart';
import 'package:point_and_click_adventure/services/game_state.dart';

void tap(GameState state, String hotspotId) {
  final matches = state.visibleHotspots.where((h) => h.id == hotspotId);
  expect(matches, isNotEmpty,
      reason: 'Hotspot $hotspotId ist in Szene ${state.sceneId} nicht sichtbar');
  state.tapHotspot(matches.first);
}

void main() {
  test('Startzustand', () {
    final state = GameState();
    expect(state.sceneId, 'garden');
    expect(state.inventory, isEmpty);
    expect(state.finished, isFalse);
    expect(state.verb, Verb.look);
  });

  test('Ansehen zeigt die Beschreibung des Hotspots', () {
    final state = GameState();
    tap(state, 'kuerbis');
    expect(state.message, contains('Kürbis'));
  });

  test('Verschlossene Tür lässt sich nicht öffnen', () {
    final state = GameState();
    state.setVerb(Verb.use);
    tap(state, 'tuer');
    expect(state.sceneId, 'garden');
    expect(state.message, contains('Verschlossen'));
  });

  test('Falscher Gegenstand bewirkt nichts und bleibt im Inventar', () {
    final state = GameState();
    state.setVerb(Verb.take);
    tap(state, 'schere');
    state.tapItem('schere');
    tap(state, 'rabe');
    expect(state.inventory, contains('schere'));
    expect(state.selectedItem, isNull);
    expect(state.message, contains('nichts anfangen'));
  });

  test('Dialog mit dem Raben lässt sich führen und beenden', () {
    final state = GameState();
    state.setVerb(Verb.talk);
    tap(state, 'rabe');
    expect(state.dialogNode, isNotNull);
    state.chooseDialogOption(0);
    expect(state.dialogId, 'rabe_schluessel');
    state.chooseDialogOption(0);
    expect(state.dialogId, 'rabe_start');
    state.chooseDialogOption(2);
    expect(state.dialogNode, isNull);
  });

  test('Komplettes Spiel lässt sich durchspielen', () {
    final state = GameState();

    // Vorgarten: Schere, Hecke, Knopf, Rabe, Schlüssel, Tür
    state.setVerb(Verb.take);
    tap(state, 'schere');
    expect(state.inventory, contains('schere'));

    state.tapItem('schere');
    tap(state, 'hecke');
    expect(state.inventory, contains('knopf'));
    expect(state.inventory, contains('schere'));

    state.tapItem('knopf');
    tap(state, 'rabe');
    expect(state.inventory, contains('schluessel'));
    expect(state.inventory, isNot(contains('knopf')));

    state.tapItem('schluessel');
    tap(state, 'tuer');
    expect(state.hasFlag('tuer_offen'), isTrue);

    state.setVerb(Verb.use);
    tap(state, 'tuer');
    expect(state.sceneId, 'halle');

    // Halle: Streichhölzer holen, dann in die Küche
    state.setVerb(Verb.take);
    tap(state, 'streichhoelzer');
    expect(state.inventory, contains('streichhoelzer'));

    state.setVerb(Verb.use);
    tap(state, 'kuechentuer');
    expect(state.sceneId, 'kueche');

    // Küche: Kerze, Kelle, Kette aus dem Kessel
    state.setVerb(Verb.take);
    tap(state, 'kerze');
    tap(state, 'kelle');
    expect(state.inventory, containsAll(['kerze', 'kelle']));

    state.tapItem('kelle');
    tap(state, 'kessel');
    expect(state.inventory, contains('kette'));

    state.setVerb(Verb.use);
    tap(state, 'zurueck');
    expect(state.sceneId, 'halle');

    // Halle: Kerze auf den Kandelaber, anzünden, Geist erscheint
    expect(state.visibleHotspots.any((h) => h.id == 'knarz'), isFalse);
    state.tapItem('kerze');
    tap(state, 'kandelaber');
    expect(state.hasFlag('kerze_steckt'), isTrue);

    state.tapItem('streichhoelzer');
    tap(state, 'kandelaber');
    expect(state.hasFlag('halle_hell'), isTrue);
    expect(state.visibleHotspots.any((h) => h.id == 'knarz'), isTrue);

    // Ende: Kette zurückgeben
    state.tapItem('kette');
    tap(state, 'knarz');
    expect(state.finished, isTrue);
  });

  test('Neustart setzt alles zurück', () {
    final state = GameState();
    state.setVerb(Verb.take);
    tap(state, 'schere');
    state.restart();
    expect(state.inventory, isEmpty);
    expect(state.flags, isEmpty);
    expect(state.sceneId, 'garden');
    expect(state.finished, isFalse);
  });
}
