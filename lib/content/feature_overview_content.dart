/// Strukturierter Inhalt für den In-App-Screen "Funktionsumfang".
/// Muss fachlich deckungsgleich mit FUNKTIONSUMFANG.md im Repo-Root sein.
class FeatureSection {
  const FeatureSection({required this.title, required this.items});

  final String title;
  final List<String> items;
}

const String featureOverviewStand = '01.11.2026';

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
      'Klassische Verbtafel mit zwölf Verben in drei Spalten: Öffne, Schließe, Drücke, Ziehe, Gehe zu, Nimm, Rede mit, Gib, Benutze, Schau an, Mach an, Mach aus.',
      'Die Satzzeile zeigt die Handlung, zum Beispiel "Benutze Gartenschere mit Hecke".',
      'Verb wählen, dann ein Objekt in der Szene oder im Inventar antippen. Ein Tipp auf den Boden lässt Mina hingehen.',
      'Langes Drücken oder Rechtsklick auf ein Objekt schaut es an, ohne ein Verb zu wählen.',
      'Ein Tipp während eines Textes überspringt ihn, Zwischensequenzen haben einen Überspringen-Knopf.',
      'Inventar rechts als Textliste mit Bildlauf-Pfeilen.',
      'Dialoge mit Auswahlmöglichkeiten, jederzeit wiederholbar.',
    ],
  ),
  FeatureSection(
    title: 'Darstellung',
    items: [
      'Vektorgrafik in Comic-Optik, immer in der Auflösung des Geräts.',
      'Retro-Ansicht im Menü: Die Szene wird in 400 Pixel Höhe ohne Kantenglättung und mit reduzierten Farben gezeichnet und scharf hochskaliert, wie bei 640×400.',
      'Räume bestehen aus Einheiten statt Pixeln (Höhe 1000), das Bild bleibt in jeder Größe scharf.',
      'Breite Räume scrollen, die Kamera folgt Mina.',
    ],
  ),
  FeatureSection(
    title: 'Engine',
    items: [
      'Eigene Skriptsprache in einer Textdatei (assets/game/knarz.scr): Räume, Objekte, Gegenstände, Dialoge, Skripte und Zeichnungen.',
      'Verbhandler pro Objekt, Kombinationen mit "mit" und "an", witzige Standardantworten pro Verb.',
      'Skripte mit Warten, Sprechen und Gehen, Zwischensequenzen und Dialogbäume.',
      'Alle Verweise werden beim Laden geprüft, Fehlermeldungen nennen die Zeile.',
      'Spielstand speichern und laden, jederzeit außer während eines Skripts.',
      'Gestaltungsprinzipien: keine Sackgassen (per Test geprüft), jedes Objekt hat einen Blicktext, jede Verb-Objekt-Kombination antwortet.',
    ],
  ),
  FeatureSection(
    title: 'Inhalt',
    items: [
      '3 Szenen: Vor dem Haus, Eingangshalle, Küche.',
      '7 Gegenstände, 18 Objekte und eine durchgehende Rätselkette.',
      '3 sprechende Figuren: Rabe Edgar, Herr von Knarz und Spinne Gerda.',
      'Ein Ende mit Neustart-Möglichkeit.',
    ],
  ),
  FeatureSection(
    title: 'Menü (⋮)',
    items: [
      'Spiel speichern und Spiel laden.',
      'Neu starten.',
      'Retro-Ansicht an oder aus.',
      'Funktionsumfang: diese Übersicht.',
      'Problem melden: öffnet ein vorausgefülltes GitHub-Issue.',
      'Über diese App.',
    ],
  ),
  FeatureSection(
    title: 'Technik',
    items: [
      'Flutter mit Material 3 und Provider.',
      'Spielstand und Einstellungen über shared_preferences.',
      'Automatischer Web-Deploy per GitHub Actions auf GitHub Pages.',
      'Automatische Tests bei jedem Push: Tokenizer, Parser, Engine, kompletter Durchspieltest und Oberfläche.',
    ],
  ),
  FeatureSection(
    title: 'Geplant',
    items: [
      'Eigene Illustrationen als Rasterebenen zusätzlich zu den Vektorformen.',
      'Mehrere Spielstände.',
      'Sound und Musik.',
      'Weitere Kapitel.',
    ],
  ),
  FeatureSection(
    title: 'Änderungshistorie',
    items: [
      '31.10.2026: Erster Prototyp mit Standard-Menü und CI-Workflow.',
      '01.11.2026: Eigene Engine mit Skriptsprache, SCUMM-Oberfläche, Vektorgrafik, Retro-Ansicht und Speicherfunktion.',
    ],
  ),
];
