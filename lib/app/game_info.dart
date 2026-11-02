import '../content/feature_section.dart';

/// Alles, was ein Spiel der Hülle von PACK über sich verrät.
class GameInfo {
  const GameInfo({
    required this.title,
    required this.about,
    required this.repoOwner,
    required this.repoName,
    required this.featureStand,
    required this.featureSections,
    required this.storageKey,
  });

  /// Titel des Spiels (App-Titel).
  final String title;

  /// Text des Dialogs "Über diese App" (ohne Copyright-Zeile).
  final String about;

  /// GitHub-Konto und Repository des Spiels, für "Problem melden".
  final String repoOwner;
  final String repoName;

  /// Inhalt des Bildschirms "Funktionsumfang".
  final String featureStand;
  final List<FeatureSection> featureSections;

  /// Vorsilbe für gespeicherte Werte (Spielstand, Einstellungen).
  final String storageKey;
}
