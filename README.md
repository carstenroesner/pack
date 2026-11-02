# PACK – Premium Adventure Creation Kit

PACK ist die Engine für Point-and-Click-Adventures im Stil der klassischen SCUMM-Spiele. Sie ist ein Flutter-Paket und läuft im Web, auf iOS und auf Android.

Die Engine enthält keinen Spielinhalt. Jedes Spiel liegt in einem eigenen Repository und bindet PACK als Abhängigkeit ein:

```yaml
dependencies:
  pack:
    git:
      url: https://github.com/carstenroesner/pack.git
      ref: master
```

Ein Spiel besteht aus einer Skriptdatei (zum Beispiel `assets/game/spiel.scr`), einer kleinen `main.dart` und der Beschreibung `GameInfo`:

```dart
final source = await rootBundle.loadString('assets/game/spiel.scr');
runApp(PackApp(info: info, source: source, settings: GameSettings(storageKey: 'spiel')));
```

Was PACK kann, steht in [FUNKTIONSUMFANG.md](FUNKTIONSUMFANG.md).

## Spiele
- [Spook](https://github.com/carstenroesner/spook) – Halloween-Spukhaus (erstes Spiel)
- [Olymp und Hades](https://github.com/carstenroesner/olymp_und_hades) – Idee (privat)
- [Dreamland](https://github.com/carstenroesner/dreamland) – Idee (privat)

## Entwicklung
```
flutter pub get
flutter test
```
