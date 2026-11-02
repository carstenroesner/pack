import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pack/pack.dart';

import 'support/mini_game.dart';

const GameInfo info = GameInfo(
  title: 'Mini',
  about: 'Ein Testspiel.',
  repoOwner: 'owner',
  repoName: 'repo',
  featureStand: '01.11.2026',
  featureSections: [
    FeatureSection(title: 'Test', items: ['Eintrag eins']),
  ],
  storageKey: 'mini',
);

Future<void> start(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    PackApp(info: info, source: mini, settings: GameSettings(storageKey: 'mini')),
  );
  await tester.pump();
}

void main() {
  testWidgets('Hülle zeigt Raumname, Verbtafel und leeres Inventar', (tester) async {
    await start(tester);
    expect(find.text('Raum A'), findsOneWidget);
    expect(find.byKey(const ValueKey('verb_nimm')), findsOneWidget);
    expect(find.text('Nichts dabei'), findsOneWidget);
  });

  testWidgets('Menü zeigt Funktionsumfang des Spiels', (tester) async {
    await start(tester);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Funktionsumfang'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Stand: 01.11.2026'), findsOneWidget);
    expect(find.text('Eintrag eins'), findsOneWidget);
  });

  testWidgets('Über-Dialog nennt Spieltitel', (tester) async {
    await start(tester);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Über diese App'));
    await tester.pumpAndSettle();
    expect(find.text('Über Mini'), findsOneWidget);
    expect(find.textContaining('Carsten Rösner'), findsOneWidget);
  });

  testWidgets('Retro-Ansicht lässt sich umschalten', (tester) async {
    await start(tester);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retro-Ansicht: an'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Retro-Ansicht: aus'), findsOneWidget);
  });
}
