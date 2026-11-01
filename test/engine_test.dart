import 'package:flutter_test/flutter_test.dart';
import 'package:point_and_click_adventure/engine/engine.dart';
import 'package:point_and_click_adventure/engine/script_parser.dart';

const String mini = '''
spiel "Mini"
start a start
spieler ich
verb gehe "Gehe zu"
verb schau "Schau an"
verb nimm "Nimm"
verb rede "Rede mit"
verb benutze "Benutze" mit "mit"
figur ich "Ich" farbe #FF0000
gegenstand schluessel "Schlüssel"
    beschreibung "Ein Schlüssel."
standard nimm "Nein."
raum a "Raum A"
    lauf 0,500 1000,500 1000,900 0,900
    marke start 100 800
    objekt kiste "Kiste"
        klickkasten 400 600 100 100
        beschreibung "Eine Kiste."
        bei nimm:
            sage "Ich nehme den Schlüssel."
            gib schluessel
        bei benutze mit schluessel:
            setze offen
            sage "Klick."
    objekt tuer "Tür"
        klickkasten 800 400 100 300
        bei gehe:
            raum b
raum b "Raum B"
    lauf 0,500 1000,500 1000,900 0,900
    marke start 50 800
    objekt geist "Geist"
        klickkasten 400 400 100 300
        bei rede:
            dialog d
dialog d
    start:
        wahl:
            option "Hallo":
                sage geist "Buh."
                weiter start
            option "Tschüss":
                beende
figur geist "Geist" farbe #FFFFFF
''';

void settle(GameEngine e) {
  var n = 0;
  while (e.busy && e.choices == null && n++ < 20000) {
    e.tick(1 / 60);
  }
  expect(n, lessThan(20000), reason: 'Skript endet nicht');
}

void main() {
  test('Fehlende Pflicht-Verben werden gemeldet', () {
    expect(
      () => parseGame('spiel "x"\nstart a\nspieler p\nfigur p "P"\nraum a "A"\n    lauf 0,0 1,0 1,1\n'),
      throwsA(isA<ScriptError>()),
    );
  });

  test('Unbekannte Verweise werden beim Laden gefunden', () {
    final bad = mini.replaceFirst('gib schluessel', 'gib nichts');
    expect(() => parseGame(bad), throwsA(isA<ScriptError>()));
    final bad2 = mini.replaceFirst('raum b\n', 'raum zzz\n');
    expect(() => parseGame(bad2), throwsA(isA<ScriptError>()));
  });

  test('Fehler nennen die Zeile', () {
    try {
      parseGame('spiel "x"\nquatsch 1\n');
      fail('Fehler erwartet');
    } on ScriptError catch (e) {
      expect(e.line, 2);
    }
  });

  test('Nehmen, Benutzen mit und Standardantwort', () {
    final e = GameEngine(parseGame(mini));
    settle(e);
    e.selectVerb('nimm');
    e.target('kiste');
    settle(e);
    expect(e.inventory, ['schluessel']);
    e.selectVerb('benutze');
    e.target('schluessel');
    expect(e.firstId, 'schluessel');
    e.target('kiste');
    settle(e);
    expect(e.flags, contains('offen'));
  });

  test('Standardantwort statt Sackgasse', () {
    final e = GameEngine(parseGame(mini));
    e.selectVerb('nimm');
    e.target('tuer');
    expect(e.busy, isTrue);
    settle(e);
    expect(e.busy, isFalse);
  });

  test('Raumwechsel und Dialog sind wiederholbar', () {
    final e = GameEngine(parseGame(mini));
    e.selectVerb('gehe');
    e.target('tuer');
    settle(e);
    expect(e.roomId, 'b');
    e.selectVerb('gehe');
    e.target('geist');
    settle(e);
    e.selectVerb('rede');
    e.target('geist');
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
    e.chooseOption(1);
    settle(e);
    expect(e.busy, isFalse);
  });

  test('Speichern und Laden stellt den Stand her', () {
    final e = GameEngine(parseGame(mini));
    e.selectVerb('nimm');
    e.target('kiste');
    settle(e);
    final saved = e.toJson();
    final f = GameEngine(parseGame(mini));
    expect(f.loadJson(saved), isTrue);
    expect(f.inventory, ['schluessel']);
    expect(f.roomId, 'a');
    expect(f.loadJson({'room': 'gibt-es-nicht'}), isFalse);
  });
}
