/// Fehler beim Lesen oder Prüfen eines Spielskripts.
class ScriptError implements Exception {
  ScriptError(this.message, [this.line]);

  final String message;
  final int? line;

  @override
  String toString() =>
      line == null ? 'Skriptfehler: $message' : 'Skriptfehler (Zeile $line): $message';
}
