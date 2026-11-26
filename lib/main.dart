import 'package:flutter/material.dart' hide Ink;
import 'package:flutter/services.dart';

import 'app_scope.dart';
import 'core/engine/app_settings.dart';
import 'core/engine/audio_manager.dart';
import 'core/engine/game_definition.dart';
import 'core/rewards/reward_service.dart';
import 'core/rewards/reward_store.dart';
import 'core/sketch/pen.dart';
import 'games/catalog.dart';
import 'l10n/l10n.dart';
import 'screens/splash_screen.dart';
import 'ui/sketch_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final registry = GameRegistry();
  registerAllGames(registry);
  final settings = AppSettings();
  await settings.load();
  final rewards = RewardService(store: PrefsRewardStore(), isGameEnabled: registry.isEnabled);
  await rewards.init();

  final audio = AudioManager(settings)..start();
  runApp(TinyThinkApp(rewards: rewards, settings: settings, audio: audio, registry: registry));
}

class TinyThinkApp extends StatelessWidget {
  const TinyThinkApp({
    super.key,
    required this.rewards,
    required this.settings,
    required this.audio,
    required this.registry,
  });

  final RewardService rewards;
  final AppSettings settings;
  final AudioManager audio;
  final GameRegistry registry;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      rewards: rewards,
      settings: settings,
      audio: audio,
      registry: registry,
      child: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => context.l10n.appTitle,
          debugShowCheckedModeBanner: false,
          locale: L10n.byCode(settings.languageCode).locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: sketchLightTheme,
          darkTheme: sketchDarkTheme,
          themeMode: settings.themeMode,
          // Light <-> dark cross-fades instead of snapping.
          themeAnimationDuration: settings.effectiveReducedMotion ? Duration.zero : const Duration(milliseconds: 380),
          themeAnimationCurve: Curves.easeInOut,
          builder: (context, child) => _LocaleSync(child: child!),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

/// Points [L10n.current] (used by game scenes drawn on a canvas) at the
/// active language, and drops cached sprites that may contain old text.
class _LocaleSync extends StatelessWidget {
  const _LocaleSync({required this.child});
  final Widget child;

  static Locale? _last;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    if (_last != locale) {
      if (_last != null) SpriteCache.clear();
      _last = locale;
    }
    L10n.current = l10n;
    return child;
  }
}
