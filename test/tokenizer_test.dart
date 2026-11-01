import 'package:flutter_test/flutter_test.dart';
import 'package:point_and_click_adventure/engine/script_error.dart';
import 'package:point_and_click_adventure/engine/tokenizer.dart';

void main() {
  test('Wörter, Texte und Doppelpunkt werden getrennt', () {
    final t = tokenizeLine('bei benutze mit schere:', 1);
    expect(t.map((e) => e.text), ['bei', 'benutze', 'mit', 'schere', ':']);
    final q = tokenizeLine('sage rabe "Kraah, glänzt!"', 2);
    expect(q.length, 3);
    expect(q[2].quoted, isTrue);
    expect(q[2].text, 'Kraah, glänzt!');
  });

  test('Kommentare werden ignoriert, auch hinter Code', () {
    expect(tokenizeLine('// nur Kommentar', 1), isEmpty);
    expect(tokenizeLine('warte 1 // kurz', 1).map((e) => e.text), ['warte', '1']);
  });

  test('Doppelpunkt nach einem Text bleibt ein eigenes Token', () {
    final t = tokenizeLine('option "Hallo":', 1);
    expect(t.length, 3);
    expect(t[2].text, ':');
    expect(t[2].quoted, isFalse);
  });

  test('Nicht beendeter Text meldet die Zeile', () {
    expect(
      () => tokenizeLine('sage "offen', 7),
      throwsA(isA<ScriptError>().having((e) => e.line, 'line', 7)),
    );
  });

  test('Einrückung ergibt einen Baum', () {
    final tree = buildTree(readLines('raum a "A"\n    marke m 1 2\n    objekt o "O"\n        klick 1,1 2,2 3,3\nraum b "B"\n'));
    expect(tree.length, 2);
    expect(tree[0].children.length, 2);
    expect(tree[0].children[1].children.length, 1);
    expect(tree[1].children, isEmpty);
  });
}
