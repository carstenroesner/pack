import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_and_click_adventure/main.dart';

void main() {
  testWidgets('Startbildschirm zeigt Szene und Verb-Leiste', (tester) async {
    await tester.pumpWidget(const AdventureApp());

    expect(find.text('Vorgarten'), findsOneWidget);
    for (final label in ['Ansehen', 'Nehmen', 'Benutzen', 'Reden']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Inventar leer'), findsOneWidget);
  });

  testWidgets('Gartenschere nehmen füllt das Inventar', (tester) async {
    await tester.pumpWidget(const AdventureApp());

    await tester.tap(find.byKey(const ValueKey('verb_take')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('hotspot_schere')));
    await tester.pump();

    expect(find.byKey(const ValueKey('item_schere')), findsOneWidget);
    expect(find.byKey(const ValueKey('hotspot_schere')), findsNothing);
  });

  testWidgets('Menü öffnet den Funktionsumfang', (tester) async {
    await tester.pumpWidget(const AdventureApp());

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Funktionsumfang'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Stand:'), findsOneWidget);
  });

  testWidgets('Über-Dialog zeigt Copyright', (tester) async {
    await tester.pumpWidget(const AdventureApp());

    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Über diese App'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Carsten Rösner'), findsOneWidget);
  });
}
