import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_games_for_kids_sketch/core/engine/app_settings.dart';
import 'package:tap_games_for_kids_sketch/core/engine/audio_manager.dart';
import 'package:tap_games_for_kids_sketch/core/engine/game_definition.dart';
import 'package:tap_games_for_kids_sketch/core/rewards/reward_service.dart';
import 'package:tap_games_for_kids_sketch/core/rewards/reward_store.dart';
import 'package:tap_games_for_kids_sketch/games/catalog.dart';
import 'package:tap_games_for_kids_sketch/main.dart';
import 'package:tap_games_for_kids_sketch/screens/intro_screen.dart';
import 'package:tap_games_for_kids_sketch/screens/play_screen.dart';

void main() {
  late RewardService rewards;
  late GameRegistry registry;

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    registry = GameRegistry();
    registerAllGames(registry);
    final settings = AppSettings()..muted = true;
    rewards = RewardService(store: MemoryRewardStore(), isGameEnabled: registry.isEnabled);
    await rewards.init();
    await tester.pumpWidget(
      TinyThinkApp(rewards: rewards, settings: settings, audio: AudioManager(settings), registry: registry),
    );
    await tester.pump();
  }

  // The intro demo animates forever, so settle with fixed pumps.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> openPond(WidgetTester tester) async {
    await tester.tap(find.text('Pond Fish Catch'));
    await settle(tester);
    expect(find.byType(IntroScreen), findsOneWidget);
  }

  testWidgets('hub lists all 17 games with real free-play counts', (tester) async {
    await pumpApp(tester);
    expect(find.text('Tap & Drag Games'), findsOneWidget);
    expect(registry.all, hasLength(17));
    expect(find.text('0/3 free plays used'), findsWidgets);
  });

  testWidgets('a free round plays to the results and counts once', (tester) async {
    await pumpApp(tester);
    await openPond(tester);
    await tester.tap(find.text('Start'));
    await tester.tap(find.text('Start'), warnIfMissed: false); // rapid double tap
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PlayScreen), findsOneWidget);
    expect(rewards.freePlaysUsed('pond_fish_catch'), 1);

    // Play out the 60 second round.
    // Frames are clamped to 50ms of game time each, so step in real frames.
    for (var i = 0; i < 1260; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await settle(tester);
    expect(find.text('Games'), findsOneWidget);
    expect(rewards.getDailyPlayStats()['pond_fish_catch']!.totalRoundsCompleted, 1);

    await tester.tap(find.text('Games'));
    await settle(tester);
    expect(find.text('1/3 free plays used'), findsOneWidget);
  });

  testWidgets('fourth round asks before spending a gem', (tester) async {
    await pumpApp(tester);
    await rewards.grantGems(2);
    for (var i = 0; i < 3; i++) {
      await rewards.startGame('pond_fish_catch', requestId: 'pre-$i');
    }
    await tester.pump();
    await openPond(tester);
    await tester.tap(find.text('Start  1'));
    await settle(tester);
    expect(find.text('Play again?'), findsOneWidget);
    expect(rewards.getGemBalance(), 2, reason: 'nothing charged before confirming');

    await tester.tap(find.text('Not now'));
    await settle(tester);
    expect(rewards.getGemBalance(), 2);

    await tester.tap(find.text('Start  1'));
    await settle(tester);
    await tester.tap(find.text('Use 1 '));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(PlayScreen), findsOneWidget);
    expect(rewards.getGemBalance(), 1);
  });

  testWidgets('no gems shows a friendly message and never starts', (tester) async {
    await pumpApp(tester);
    for (var i = 0; i < 3; i++) {
      await rewards.startGame('pond_fish_catch', requestId: 'pre-$i');
    }
    await tester.pump();
    await openPond(tester);
    await tester.tap(find.text('Start'));
    await settle(tester);
    expect(find.text('No gems right now'), findsOneWidget);
    await tester.tap(find.text('Back to games'));
    await settle(tester);
    expect(find.text('Tap & Drag Games'), findsOneWidget);
    expect(rewards.getGemBalance(), 0);
  });
}
