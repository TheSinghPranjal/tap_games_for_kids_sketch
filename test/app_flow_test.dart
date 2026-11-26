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
import 'package:tap_games_for_kids_sketch/screens/home_screen.dart';
import 'package:tap_games_for_kids_sketch/screens/hub_screen.dart';
import 'package:tap_games_for_kids_sketch/screens/play_screen.dart';
import 'package:tap_games_for_kids_sketch/ui/sketch_widgets.dart';

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
    // Splash -> home -> games hub.
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HomeScreen), findsOneWidget);
    await tester.tap(find.text('Play\nGames'));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(HubScreen), findsOneWidget);
  }

  Finder dots(int remaining) => find.byWidgetPredicate((w) => w is FreePlayDots && w.remaining == remaining);

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

  testWidgets('hub lists all 32 games with real free-play counts', (tester) async {
    await pumpApp(tester);
    expect(find.text('Tap & Drag Games'), findsOneWidget);
    expect(registry.all, hasLength(32));
    expect(dots(3), findsWidgets);
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
    expect(dots(2), findsOneWidget);
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

  testWidgets('hub cards fit on phones and iPads in both orientations', (tester) async {
    await pumpApp(tester);
    const sizes = [
      Size(375, 667),
      Size(430, 932),
      Size(744, 1133),
      Size(820, 1180),
      Size(1024, 1366),
      Size(1366, 1024),
    ];
    for (final size in sizes) {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'overflow at $size');
      // Scroll through the whole grid so every card gets laid out.
      for (var i = 0; i < 8; i++) {
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull, reason: 'overflow at $size');
      }
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 20000));
      await settle(tester);
    }
  });
}
