import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_and_click_adventure/main.dart';
import 'package:point_and_click_adventure/services/game_settings.dart';

Future<void> startApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AdventureApp(
      source: File('assets/game/knarz.scr').readAsStringSync(),
      settings: GameSettings(),
    ),
  );
  // Die Einleitung läuft über Zeit; mit festen Schritten abwarten.
  for (var i = 0; i < 1200; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byKey(const ValueKey('verb_nimm')).evaluate().isNotEmpty) break;
  }
}

void main() {
  testWidgets('Startbildschirm zeigt Verbtafel und leeres Inventar', (tester) async {
    await startApp(tester);
    for (final id in ['oeffne', 'gehe', 'nimm', 'rede', 'benutze', 'schau', 'mach_aus']) {
      expect(find.byKey(ValueKey('verb_$id')), findsOneWidget, reason: id);
    }
    expect(find.text('Rede mit'), findsOneWidget);
    expect(find.text('Nichts dabei'), findsOneWidget);
    expect(find.text('Vor dem Haus'), findsOneWidget);
  });

  testWidgets('Menü öffnet den Funktionsumfang', (tester) async {
    await startApp(tester);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Funktionsumfang'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Stand:'), findsOneWidget);
  });

  testWidgets('Menü schaltet die Retro-Ansicht um', (tester) async {
    await startApp(tester);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Retro-Ansicht: an'), findsOneWidget);
    await tester.tap(find.text('Retro-Ansicht: an'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Retro-Ansicht: aus'), findsOneWidget);
  });

  testWidgets('Über-Dialog zeigt Copyright', (tester) async {
    await startApp(tester);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Über diese App'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Carsten Rösner'), findsOneWidget);
  });
}
