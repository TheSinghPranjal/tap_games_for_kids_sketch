import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global mute, accessibility (reduced motion, little-kid mode) and
/// favourites. Acts as the AccessibilityController for all games.
class AppSettings extends ChangeNotifier {
  static const _kMuted = 'settings.muted';
  static const _kReduced = 'settings.reducedMotion';
  static const _kSimple = 'settings.simpleMode';
  static const _kFav = 'settings.favorites';

  bool muted = false;
  bool reducedMotion = false;

  /// Slower objects, bigger hit areas and longer rounds for ages ~2-4.
  bool simpleMode = false;
  final Set<String> favorites = {};

  /// Set from MediaQuery when the OS asks for fewer animations.
  bool systemReducedMotion = false;

  bool get effectiveReducedMotion => reducedMotion || systemReducedMotion;

  SharedPreferences? _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    muted = _prefs!.getBool(_kMuted) ?? false;
    reducedMotion = _prefs!.getBool(_kReduced) ?? false;
    simpleMode = _prefs!.getBool(_kSimple) ?? false;
    favorites
      ..clear()
      ..addAll(_prefs!.getStringList(_kFav) ?? const []);
    notifyListeners();
  }

  void setMuted(bool v) => _set(() => muted = v, () => _prefs?.setBool(_kMuted, v));
  void setReducedMotion(bool v) => _set(() => reducedMotion = v, () => _prefs?.setBool(_kReduced, v));
  void setSimpleMode(bool v) => _set(() => simpleMode = v, () => _prefs?.setBool(_kSimple, v));

  void toggleFavorite(String gameId) => _set(
    () => favorites.contains(gameId) ? favorites.remove(gameId) : favorites.add(gameId),
    () => _prefs?.setStringList(_kFav, favorites.toList()),
  );

  void _set(void Function() change, void Function() persist) {
    change();
    persist();
    notifyListeners();
  }
}
