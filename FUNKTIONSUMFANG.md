# Knarz Manor – Funktionsumfang

Stand: 31.10.2026

## Spielidee
- Point-and-Click-Adventure im Halloween-Spukhaus Knarz Manor.
- Du spielst Mina Moderschein, Geisterjägerin im Praktikum.
- Alle Figuren, Orte und Rätsel sind eigene Erfindungen.

## Steuerung
- Verb-Leiste: Ansehen, Nehmen, Benutzen, Reden.
- Verb wählen, dann auf eine Stelle in der Szene tippen.
- Inventar: Gegenstand antippen, dann auf ein Ziel tippen (Benutzen mit).
- Im Modus "Ansehen" beschreibt ein Tipp auf einen Inventar-Gegenstand diesen.
- Dialoge mit Auswahlmöglichkeiten.

## Inhalt (erster Prototyp)
- 3 Szenen: Vorgarten, Eingangshalle, Küche.
- 7 Gegenstände und eine durchgehende Rätselkette.
- 2 sprechende Figuren: Rabe Edgar und Herr von Knarz.
- Ein Ende mit Neustart-Möglichkeit.

### Rätselkette (Lösungsweg)
1. Vorgarten: Gartenschere nehmen, damit die Dornenhecke schneiden, Messingknopf erhalten.
2. Knopf dem Raben Edgar geben, Rostigen Schlüssel erhalten, Haustür aufschließen.
3. Halle: Streichhölzer nehmen. Die Halle ist dunkel.
4. Küche: Kerzenstummel und Schöpfkelle nehmen, mit der Kelle die Rasselkette aus dem Hexenkessel fischen.
5. Halle: Kerzenstummel auf den Kandelaber stecken, mit Streichhölzern anzünden, Herr von Knarz erscheint.
6. Rasselkette an Herrn von Knarz geben: Ende.

## Menü (⋮)
- Funktionsumfang: diese Übersicht, auch in der App einsehbar.
- Problem melden: öffnet ein vorausgefülltes GitHub-Issue (Problem oder Anregung).
- Über diese App.

## Technik
- Flutter mit Material 3 und Provider.
- Automatischer Web-Deploy per GitHub Actions auf GitHub Pages (`.github/workflows/deploy-web.yml`).
- Automatische Tests (`flutter test`) bei jedem Push, Deploy nur bei grünen Tests.

## Umsetzungsstand
- Spiel-Engine, Inhalte, Menü, Tests und Workflow geschrieben.
- Noch offen: erster CI-Lauf und Live-Verifikation im Browser (lokal war kein Flutter-SDK verfügbar, der Code ist bisher nicht kompiliert).

## Backlog
- Spielstand speichern.
- Eigene Illustrationen statt Symbolen.
- Sound und Musik.
- Weitere Kapitel.

## Änderungshistorie
- 31.10.2026: Erster Prototyp (3 Szenen, 7 Gegenstände, 2 Dialoge, Standard-Menü, Tests, CI-Workflow).
