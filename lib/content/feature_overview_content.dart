/// Strukturierter Inhalt für den In-App-Screen "Funktionsumfang".
/// Muss fachlich deckungsgleich mit FUNKTIONSUMFANG.md im Repo-Root sein.
class FeatureSection {
  const FeatureSection({required this.title, required this.items});

  final String title;
  final List<String> items;
}

const String featureOverviewStand = '31.10.2026';

const List<FeatureSection> featureSections = [
  FeatureSection(
    title: 'Spielidee',
    items: [
      'Point-and-Click-Adventure im Halloween-Spukhaus Knarz Manor.',
      'Du spielst Mina Moderschein, Geisterjägerin im Praktikum.',
      'Alle Figuren, Orte und Rätsel sind eigene Erfindungen.',
    ],
  ),
  FeatureSection(
    title: 'Steuerung',
    items: [
      'Verb-Leiste: Ansehen, Nehmen, Benutzen, Reden.',
      'Verb wählen, dann auf eine Stelle in der Szene tippen.',
      'Inventar: Gegenstand antippen, dann auf ein Ziel tippen (Benutzen mit).',
      'Im Modus "Ansehen" beschreibt ein Tipp auf einen Inventar-Gegenstand diesen.',
      'Dialoge mit Auswahlmöglichkeiten.',
    ],
  ),
  FeatureSection(
    title: 'Inhalt (erster Prototyp)',
    items: [
      '3 Szenen: Vorgarten, Eingangshalle, Küche.',
      '7 Gegenstände und eine durchgehende Rätselkette.',
      '2 sprechende Figuren: Rabe Edgar und Herr von Knarz.',
      'Ein Ende mit Neustart-Möglichkeit.',
    ],
  ),
  FeatureSection(
    title: 'Menü (⋮)',
    items: [
      'Funktionsumfang: diese Übersicht.',
      'Problem melden: öffnet ein vorausgefülltes GitHub-Issue.',
      'Über diese App.',
    ],
  ),
  FeatureSection(
    title: 'Technik',
    items: [
      'Flutter mit Material 3 und Provider.',
      'Automatischer Web-Deploy per GitHub Actions auf GitHub Pages.',
      'Automatische Tests bei jedem Push.',
    ],
  ),
  FeatureSection(
    title: 'Geplant',
    items: [
      'Spielstand speichern.',
      'Eigene Illustrationen statt Symbolen.',
      'Sound und Musik.',
      'Weitere Kapitel.',
    ],
  ),
];
