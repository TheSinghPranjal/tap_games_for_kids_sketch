import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tap_games_for_kids_sketch/core/engine/app_settings.dart';
import 'package:tap_games_for_kids_sketch/core/engine/audio_manager.dart';
import 'package:tap_games_for_kids_sketch/core/engine/game_definition.dart';
import 'package:tap_games_for_kids_sketch/core/rewards/reward_service.dart';
import 'package:tap_games_for_kids_sketch/core/rewards/reward_store.dart';
import 'package:tap_games_for_kids_sketch/games/catalog.dart';
import 'package:tap_games_for_kids_sketch/l10n/l10n.dart';
import 'package:tap_games_for_kids_sketch/main.dart';
import 'package:tap_games_for_kids_sketch/screens/how_to_play_screen.dart';
import 'package:tap_games_for_kids_sketch/screens/hub_screen.dart';
import 'package:tap_games_for_kids_sketch/screens/settings_screen.dart';
import 'package:tap_games_for_kids_sketch/ui/sketch_theme.dart';

void main() {
  group('AppSettings', () {
    test('defaults: English, follow the device theme, music and vibration on', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppSettings();
      await s.load();
      expect(s.languageCode, 'en');
      expect(s.themeMode, ThemeMode.system);
      expect(s.soundOn, isTrue);
      expect(s.musicOn, isTrue);
      expect(s.vibrationOn, isTrue);
    });

    test('every choice is saved and comes back after a restart', () async {
      SharedPreferences.setMockInitialValues({});
      final s = AppSettings();
      await s.load();
      s
        ..setLanguage('hi')
        ..setThemeMode(ThemeMode.dark)
        ..setSoundOn(false)
        ..setMusicOn(false)
        ..setVibrationOn(false);

      final again = AppSettings();
      await again.load();
      expect(again.languageCode, 'hi');
      expect(again.themeMode, ThemeMode.dark);
      expect(again.soundOn, isFalse);
      expect(again.musicOn, isFalse);
      expect(again.vibrationOn, isFalse);
    });

    test('an unknown saved theme falls back to following the device', () async {
      SharedPreferences.setMockInitialValues({'settings.themeMode': 'sepia'});
      final s = AppSettings();
      await s.load();
      expect(s.themeMode, ThemeMode.system);
    });
  });

  group('translations', () {
    Map<String, dynamic> arb(String code) =>
        jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync()) as Map<String, dynamic>;
    Set<String> keys(Map<String, dynamic> m) => m.keys.where((k) => !k.startsWith('@')).toSet();

    test('every language translates every message', () {
      final english = keys(arb('en'));
      for (final lang in L10n.languages) {
        final missing = english.difference(keys(arb(lang.code)));
        expect(missing, isEmpty, reason: '${lang.englishName} is missing $missing');
      }
    });

    test('every game has a name, goal and instructions in every language', () {
      final registry = GameRegistry();
      registerAllGames(registry);
      for (final lang in L10n.languages) {
        final l = lookupAppLocalizations(lang.locale);
        for (final def in registry.all) {
          for (final text in [def.name(l), def.objective(l), def.instructions(l)]) {
            expect(text.trim(), isNotEmpty, reason: '${def.gameId} in ${lang.code}');
          }
        }
      }
    });

    test('languages are listed by their own name and English is the default', () {
      expect(L10n.fallback.code, 'en');
      expect(L10n.byCode('xx').code, 'en');
      expect(L10n.languages.map((l) => l.nativeName), containsAll(['English', 'हिन्दी']));
    });
  });

  group('vibration setting', () {
    late List<MethodCall> calls;

    setUp(() {
      calls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    bool vibrated() => calls.any((c) => c.method == 'HapticFeedback.vibrate');

    test('haptics follow the vibration switch, not the sound switch', () {
      final settings = AppSettings()..muted = true;
      final audio = AudioManager(settings);
      audio.play(Sfx.tap);
      expect(vibrated(), isTrue, reason: 'muted sound still vibrates');

      calls.clear();
      settings.vibrationOn = false;
      audio.play(Sfx.pop);
      expect(vibrated(), isFalse);
    });
  });

  group('settings screen', () {
    late AppSettings settings;

    Future<void> pumpHub(WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1170, 2532);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final registry = GameRegistry();
      registerAllGames(registry);
      settings = AppSettings()
        ..muted = true
        ..musicOn = false;
      final rewards = RewardService(store: MemoryRewardStore(), isGameEnabled: registry.isEnabled);
      await rewards.init();
      await tester.pumpWidget(
        TinyThinkApp(rewards: rewards, settings: settings, audio: AudioManager(settings), registry: registry),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Play\nGames'));
      await settle(tester);
      expect(find.byType(HubScreen), findsOneWidget);
    }

    testWidgets('changing the language re-labels the whole app', (tester) async {
      await pumpHub(tester);
      await tester.tap(find.bySemanticsLabel('Settings'));
      await settle(tester);
      expect(find.byType(SettingsScreen), findsOneWidget);

      await tester.tap(find.text('हिन्दी'));
      await settle(tester);
      expect(settings.languageCode, 'hi');
      expect(find.text('सेटिंग्स'), findsOneWidget);
      expect(L10n.current.localeName, 'hi');

      await tester.tap(find.bySemanticsLabel('वापस'));
      await settle(tester);
      expect(find.text('टैप और ड्रैग खेल'), findsOneWidget);
      expect(find.text('तालाब की मछलियाँ'), findsOneWidget);

      // And back to English.
      settings.setLanguage('en');
      await settle(tester);
      expect(find.text('Tap & Drag Games'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('dark mode switches the palette and every screen still lays out', (tester) async {
      await pumpHub(tester);
      await tester.tap(find.bySemanticsLabel('Settings'));
      await settle(tester);

      await tester.tap(find.text('Dark'));
      await settle(tester);
      expect(settings.themeMode, ThemeMode.dark);
      final context = tester.element(find.byType(SettingsScreen));
      expect(context.palette.isDark, isTrue);
      expect(Theme.of(context).brightness, Brightness.dark);

      await tester.tap(find.text('Light'));
      await settle(tester);
      expect(tester.element(find.byType(SettingsScreen)).palette.isDark, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sound, music and vibration switches each flip their own setting', (tester) async {
      await pumpHub(tester);
      await tester.tap(find.bySemanticsLabel('Settings'));
      await settle(tester);

      await tester.tap(find.text('Sound effects'));
      await tester.tap(find.text('Music'));
      await tester.tap(find.text('Vibration'));
      await settle(tester);
      expect(settings.soundOn, isTrue);
      expect(settings.musicOn, isTrue);
      expect(settings.vibrationOn, isFalse);
    });

    testWidgets('how to play walks through every step and returns', (tester) async {
      await pumpHub(tester);
      await tester.tap(find.bySemanticsLabel('Settings'));
      await settle(tester);
      await tester.ensureVisible(find.text('How to play'));
      await settle(tester);
      await tester.tap(find.text('How to play'));
      await settle(tester);
      expect(find.byType(HowToPlayScreen), findsOneWidget);
      expect(find.text('Pick a game'), findsOneWidget);

      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('Next'));
        await settle(tester);
      }
      expect(find.text('Keep favorites'), findsOneWidget);
      await tester.tap(find.text("Let's play!"));
      await settle(tester);
      expect(find.byType(HowToPlayScreen), findsNothing);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

// Demos animate forever, so settle with fixed pumps.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
