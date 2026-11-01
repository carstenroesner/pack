import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Einstellungen der Darstellung, zum Beispiel die Retro-Ansicht.
class GameSettings extends ChangeNotifier {
  GameSettings({bool retro = false}) : _retro = retro;

  static const String _retroKey = 'knarz_retro';
  bool _retro;

  bool get retro => _retro;

  set retro(bool value) {
    if (_retro == value) return;
    _retro = value;
    notifyListeners();
    _persist();
  }

  void toggleRetro() => retro = !_retro;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _retro = prefs.getBool(_retroKey) ?? _retro;
      notifyListeners();
    } catch (_) {
      // Ohne Speicher läuft die App mit den Standardwerten weiter.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_retroKey, _retro);
    } catch (_) {
      // Speichern ist optional.
    }
  }
}
