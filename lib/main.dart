import 'package:flutter/material.dart' hide Ink;
import 'package:flutter/services.dart';

import 'app_scope.dart';
import 'core/engine/app_settings.dart';
import 'core/engine/audio_manager.dart';
import 'core/engine/game_definition.dart';
import 'core/rewards/reward_service.dart';
import 'core/rewards/reward_store.dart';
import 'core/sketch/ink.dart';
import 'games/catalog.dart';
import 'screens/hub_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final registry = GameRegistry();
  registerAllGames(registry);
  final settings = AppSettings();
  await settings.load();
  final rewards = RewardService(store: PrefsRewardStore(), isGameEnabled: registry.isEnabled);
  await rewards.init();

  runApp(TinyThinkApp(rewards: rewards, settings: settings, audio: AudioManager(settings), registry: registry));
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
      child: MaterialApp(
        title: 'TinyThink',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Ink.paper,
          colorScheme: ColorScheme.fromSeed(seedColor: Ink.navy, surface: Ink.paper),
          splashFactory: NoSplash.splashFactory,
        ),
        home: const HubScreen(),
      ),
    );
  }
}
