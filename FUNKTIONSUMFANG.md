# PACK – Funktionsumfang

Stand: 02.11.2026

## Zweck
- PACK ist das Premium Adventure Creation Kit: eine wiederverwendbare Engine für Point-and-Click-Adventures im SCUMM-Stil.
- Die Engine enthält keinen Spielinhalt; jedes Spiel liegt in einem eigenen Repository und bindet PACK als Flutter-Paket ein.
- Läuft im Web, auf iOS und auf Android aus einer Codebasis.

## Skriptsprache
- Eigene Textsprache mit deutschen Schlüsselwörtern: Räume, Objekte, Gegenstände, Verben, Figuren, Dialoge, Skripte und Zeichnungen.
- Verbhandler pro Objekt, Kombinationen mit zweitem Objekt, Standardantworten pro Verb.
- Skripte mit Warten, Sprechen und Gehen, Bedingungen, Zwischensequenzen, Dialogbäume und Spielende.
- Alle Verweise werden beim Laden geprüft, Fehlermeldungen nennen die Zeile.

## Darstellung
- Vektorgrafik aus Formen (Kreis, Ellipse, Rechteck, Vieleck, Pfad) in Raumeinheiten, Raumhöhe 1000; bleibt in jeder Auflösung scharf.
- Retro-Ansicht: Rendern in 400 Pixel Höhe ohne Kantenglättung, mit reduzierter Farbpalette, scharf hochskaliert.
- Scrollende Räume mit Kamera, Lauf- und Klickflächen als Polygone, bedingte Formen und Vordergrundformen.
- Mitgelieferte Spielfigur im Comic-Stil mit Lauf- und Wippanimation.

## Oberfläche
- Klassische Verbtafel mit konfigurierbaren Verben, Satzzeile und Textinventar mit Bildlaufpfeilen.
- Langes Drücken oder Rechtsklick schaut ein Objekt an; Tipp überspringt Texte, Zwischensequenzen lassen sich überspringen.
- Menü (⋮): Spiel speichern, Spiel laden, Neu starten, Retro-Ansicht, Funktionsumfang, Problem melden, Über diese App.
- Spielstand und Einstellungen über shared_preferences, getrennt je Spiel.

## Einbindung
- Ein Spiel liefert nur Skript, Assets und eine GameInfo (Titel, Über-Text, Repository, Funktionsumfang) und startet PackApp.
- Die App-Hülle PackApp lädt das Skript und stellt Oberfläche, Menü und Funktionsumfang bereit.

## Gestaltungsprinzipien
- Keine Sackgassen und kein Tod; per Test prüfbar.
- Jedes Objekt hat einen Blicktext, jede Verb-Objekt-Kombination antwortet.
- Dialoge sind wiederholbar, Speichern ist jederzeit möglich.
- Sammlung von Rätselmustern und Ideen: siehe Ideen-Datenbank im Projekt.

## Technik
- Flutter mit Material 3 und Provider; Engine läuft in festen Zeitschritten (reproduzierbar testbar).
- Automatische Tests bei jedem Push: Tokenizer, Parser, Geometrie, Engine und Oberflächen-Hülle mit einem Mini-Spiel.

## Geplant
- Duelle (Beleidigungsfechten), mehrere spielbare Figuren, abgestufte Hinweise, Journal mit Zielen.
- Rasterebenen zusätzlich zu den Vektorformen.
- Mehrere Spielstände.

## Änderungshistorie
- 31.10.2026: Erster Prototyp als Teil eines Spiels.
- 01.11.2026: Engine mit Skriptsprache, Vektorgrafik und Retro-Ansicht.
- 02.11.2026: Als eigenständiges Paket PACK herausgelöst, Spiele in eigene Repositories.
