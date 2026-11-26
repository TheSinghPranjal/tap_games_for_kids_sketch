import 'package:flutter/widgets.dart';

import 'core/engine/app_settings.dart';
import 'core/engine/audio_manager.dart';
import 'core/engine/game_definition.dart';
import 'core/rewards/reward_service.dart';

/// Provides the shared services to every screen.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.rewards,
    required this.settings,
    required this.audio,
    required this.registry,
    required super.child,
  });

  final RewardService rewards;
  final AppSettings settings;
  final AudioManager audio;
  final GameRegistry registry;

  static AppScope of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  /// Like [of], but null outside the app (e.g. widget previews) and without
  /// registering a dependency.
  static AppScope? maybeOf(BuildContext context) => context.getInheritedWidgetOfExactType<AppScope>();

  @override
  bool updateShouldNotify(AppScope old) =>
      rewards != old.rewards || settings != old.settings || registry != old.registry;
}
