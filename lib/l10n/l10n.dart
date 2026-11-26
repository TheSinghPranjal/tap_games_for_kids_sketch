import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// A language the app ships with. [nativeName] is always shown in that
/// language's own script so a parent can find it whatever is selected.
class AppLanguage {
  const AppLanguage(this.code, this.nativeName, this.englishName);
  final String code;
  final String nativeName;
  final String englishName;

  Locale get locale => Locale(code);
}

class L10n {
  L10n._();

  /// The default language; used until the player picks another one.
  static const fallback = AppLanguage('en', 'English', 'English');

  /// Order shown in Settings. Add a language by adding `lib/l10n/app_<code>.arb`
  /// and an entry here.
  static const languages = [
    fallback,
    AppLanguage('hi', 'हिन्दी', 'Hindi'),
    AppLanguage('es', 'Español', 'Spanish'),
    AppLanguage('fr', 'Français', 'French'),
  ];

  static AppLanguage byCode(String? code) => languages.firstWhere((l) => l.code == code, orElse: () => fallback);

  /// Strings for code that has no [BuildContext]: game scenes drawn on a
  /// canvas. Widgets use `context.l10n` instead. Kept in sync with the app's
  /// locale by the root widget.
  static AppLocalizations current = lookupAppLocalizations(fallback.locale);
}

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
