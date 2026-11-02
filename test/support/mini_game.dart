/// Kleines Testspiel für Engine- und Oberflächentests.
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
