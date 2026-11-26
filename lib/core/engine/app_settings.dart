import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every player preference, persisted with shared_preferences: language,
/// theme, sound effects, music, vibration, accessibility (reduced motion,
/// little-kid mode) and favourites. Acts as the AccessibilityController for
/// all games.
class AppSettings extends ChangeNotifier {
  static const _kMuted = 'settings.muted';
  static const _kMusic = 'settings.music';
  static const _kVibration = 'settings.vibration';
  static const _kLanguage = 'settings.language';
  static const _kTheme = 'settings.themeMode';
  static const _kReduced = 'settings.reducedMotion';
  static const _kSimple = 'settings.simpleMode';
  static const _kFav = 'settings.favorites';

  /// Sound effects off. (Music has its own switch.)
  bool muted = false;
  bool musicOn = true;
  bool vibrationOn = true;

  /// ISO 639-1 code of the chosen language. English until the player picks.
  String languageCode = 'en';
  ThemeMode themeMode = ThemeMode.system;

  bool reducedMotion = false;

  /// Slower objects, bigger hit areas and longer rounds for ages ~2-4.
  bool simpleMode = false;
  final Set<String> favorites = {};

  /// Set from MediaQuery when the OS asks for fewer animations.
  bool systemReducedMotion = false;

  bool get effectiveReducedMotion => reducedMotion || systemReducedMotion;
  bool get soundOn => !muted;

  SharedPreferences? _prefs;

  Future<void> load() async {
    final p = _prefs = await SharedPreferences.getInstance();
    muted = p.getBool(_kMuted) ?? false;
    musicOn = p.getBool(_kMusic) ?? true;
    vibrationOn = p.getBool(_kVibration) ?? true;
    languageCode = p.getString(_kLanguage) ?? 'en';
    themeMode = ThemeMode.values.asNameMap()[p.getString(_kTheme)] ?? ThemeMode.system;
    reducedMotion = p.getBool(_kReduced) ?? false;
    simpleMode = p.getBool(_kSimple) ?? false;
    favorites
      ..clear()
      ..addAll(p.getStringList(_kFav) ?? const []);
    notifyListeners();
  }

  void setMuted(bool v) => _set(() => muted = v, () => _prefs?.setBool(_kMuted, v));
  void setSoundOn(bool v) => setMuted(!v);
  void setMusicOn(bool v) => _set(() => musicOn = v, () => _prefs?.setBool(_kMusic, v));
  void setVibrationOn(bool v) => _set(() => vibrationOn = v, () => _prefs?.setBool(_kVibration, v));
  void setLanguage(String code) => _set(() => languageCode = code, () => _prefs?.setString(_kLanguage, code));
  void setThemeMode(ThemeMode m) => _set(() => themeMode = m, () => _prefs?.setString(_kTheme, m.name));
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
