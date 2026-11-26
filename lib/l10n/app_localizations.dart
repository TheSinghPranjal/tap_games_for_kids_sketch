import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'TinyThink'**
  String get appTitle;

  /// First line of the colourful title sign. Each word gets its own colour.
  ///
  /// In en, this message translates to:
  /// **'Tap & Drag'**
  String get homeTitleLine1;

  /// Second line of the title sign.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get homeTitleLine2;

  /// Screen-reader label for the title sign.
  ///
  /// In en, this message translates to:
  /// **'Tap and Drag Games'**
  String get homeTitleSemantics;

  /// Big home button; may use a line break.
  ///
  /// In en, this message translates to:
  /// **'Play\nGames'**
  String get homePlayGames;

  /// No description provided for @homeRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get homeRewards;

  /// No description provided for @rewardsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Rewards'**
  String get rewardsTitle;

  /// No description provided for @rewardsGemsSaved.
  ///
  /// In en, this message translates to:
  /// **'gems saved'**
  String get rewardsGemsSaved;

  /// No description provided for @rewardsStarsToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star today} other{{count} stars today}}'**
  String rewardsStarsToday(int count);

  /// No description provided for @rewardsStarsPerGem.
  ///
  /// In en, this message translates to:
  /// **'Every {points} stars = 1 gem'**
  String rewardsStarsPerGem(int points);

  /// No description provided for @rewardsFreePlaysPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} free plays per game each day'**
  String rewardsFreePlaysPerDay(int count);

  /// No description provided for @rewardsYay.
  ///
  /// In en, this message translates to:
  /// **'Yay!'**
  String get rewardsYay;

  /// No description provided for @hubTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap & Drag Games'**
  String get hubTitle;

  /// No description provided for @hubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a game and play!'**
  String get hubSubtitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All Games'**
  String get filterAll;

  /// No description provided for @filterTap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get filterTap;

  /// No description provided for @filterDrag.
  ///
  /// In en, this message translates to:
  /// **'Drag'**
  String get filterDrag;

  /// No description provided for @filterFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get filterFavorites;

  /// Game type tag, and the Tap mode button.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get interactionTap;

  /// Game type tag, and the Drag mode button.
  ///
  /// In en, this message translates to:
  /// **'Drag'**
  String get interactionDrag;

  /// No description provided for @interactionTapDrag.
  ///
  /// In en, this message translates to:
  /// **'Tap + Drag'**
  String get interactionTapDrag;

  /// No description provided for @favoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get favoriteRemove;

  /// No description provided for @freePlaysLeftToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 free play left today} other{{count} free plays left today}}'**
  String freePlaysLeftToday(int count);

  /// No description provided for @nextPlayCostsGem.
  ///
  /// In en, this message translates to:
  /// **'Next play costs 1 gem'**
  String get nextPlayCostsGem;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @resting.
  ///
  /// In en, this message translates to:
  /// **'Resting'**
  String get resting;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap a heart to save your favorite games here!'**
  String get favoritesEmpty;

  /// No description provided for @moreDragGamesSoon.
  ///
  /// In en, this message translates to:
  /// **'More drag games are coming soon!'**
  String get moreDragGamesSoon;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @gemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 gem} other{{count} gems}}'**
  String gemsCount(int count);

  /// No description provided for @noGemsTitle.
  ///
  /// In en, this message translates to:
  /// **'No gems right now'**
  String get noGemsTitle;

  /// No description provided for @noGemsBody.
  ///
  /// In en, this message translates to:
  /// **'You used your {count} free plays of this game today. Earn gems in other games, or come back tomorrow!'**
  String noGemsBody(int count);

  /// No description provided for @restingTitle.
  ///
  /// In en, this message translates to:
  /// **'This game is resting'**
  String get restingTitle;

  /// No description provided for @restingBody.
  ///
  /// In en, this message translates to:
  /// **'Try another game for now!'**
  String get restingBody;

  /// No description provided for @oops.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get oops;

  /// No description provided for @startFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. No gems were used. Please try again.'**
  String get startFailedBody;

  /// No description provided for @playAgainTitle.
  ///
  /// In en, this message translates to:
  /// **'Play again?'**
  String get playAgainTitle;

  /// No description provided for @playAgainBody.
  ///
  /// In en, this message translates to:
  /// **'Free plays are used up for today.\nThis round uses 1 gem.'**
  String get playAgainBody;

  /// Followed by a gem icon and the balance.
  ///
  /// In en, this message translates to:
  /// **'You have '**
  String get youHave;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Followed by a gem icon.
  ///
  /// In en, this message translates to:
  /// **'Use 1 '**
  String get useOneGem;

  /// No description provided for @backToGames.
  ///
  /// In en, this message translates to:
  /// **'Back to games'**
  String get backToGames;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @freePlaysToday.
  ///
  /// In en, this message translates to:
  /// **'Free plays today'**
  String get freePlaysToday;

  /// No description provided for @freePlaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining} of {total} left'**
  String freePlaysRemaining(int remaining, int total);

  /// No description provided for @nextRoundUsesGem.
  ///
  /// In en, this message translates to:
  /// **'Next round uses 1 gem'**
  String get nextRoundUsesGem;

  /// No description provided for @comeBackTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Come back tomorrow for more free plays!'**
  String get comeBackTomorrow;

  /// No description provided for @gameRestingNow.
  ///
  /// In en, this message translates to:
  /// **'This game is resting right now'**
  String get gameRestingNow;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Followed by a gem icon.
  ///
  /// In en, this message translates to:
  /// **'Start  1'**
  String get startWithGem;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @keepPlaying.
  ///
  /// In en, this message translates to:
  /// **'Keep playing'**
  String get keepPlaying;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Sound on'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Sound off'**
  String get soundOff;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @progressSaved.
  ///
  /// In en, this message translates to:
  /// **'Your stars and gems are saved.'**
  String get progressSaved;

  /// No description provided for @cheerAmazing.
  ///
  /// In en, this message translates to:
  /// **'Amazing!'**
  String get cheerAmazing;

  /// No description provided for @cheerGreat.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get cheerGreat;

  /// No description provided for @cheerNice.
  ///
  /// In en, this message translates to:
  /// **'Nice playing!'**
  String get cheerNice;

  /// No description provided for @scoreToEarnGem.
  ///
  /// In en, this message translates to:
  /// **'Score {points} to earn a gem!'**
  String scoreToEarnGem(int points);

  /// No description provided for @youEarnedGems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You earned 1 gem!} other{You earned {count} gems!}}'**
  String youEarnedGems(int count);

  /// No description provided for @myGems.
  ///
  /// In en, this message translates to:
  /// **'My gems'**
  String get myGems;

  /// No description provided for @again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get again;

  /// No description provided for @freePlaysDone.
  ///
  /// In en, this message translates to:
  /// **'Free plays are done for today.'**
  String get freePlaysDone;

  /// Above the studio name on the splash screen.
  ///
  /// In en, this message translates to:
  /// **'by'**
  String get creditBy;

  /// No description provided for @settingsSoundSection.
  ///
  /// In en, this message translates to:
  /// **'Sound & touch'**
  String get settingsSoundSection;

  /// No description provided for @settingsSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound effects'**
  String get settingsSoundEffects;

  /// No description provided for @settingsMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get settingsMusic;

  /// No description provided for @settingsVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// No description provided for @settingsLookSection.
  ///
  /// In en, this message translates to:
  /// **'Look'**
  String get settingsLookSection;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Follow the device light/dark setting.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get themeSystem;

  /// No description provided for @settingsGentleMotion.
  ///
  /// In en, this message translates to:
  /// **'Gentle motion'**
  String get settingsGentleMotion;

  /// No description provided for @settingsGentleMotionHint.
  ///
  /// In en, this message translates to:
  /// **'fewer bouncy animations'**
  String get settingsGentleMotionHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsPlaySection.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get settingsPlaySection;

  /// No description provided for @settingsLittleKid.
  ///
  /// In en, this message translates to:
  /// **'Little-kid mode'**
  String get settingsLittleKid;

  /// No description provided for @settingsLittleKidHint.
  ///
  /// In en, this message translates to:
  /// **'slower, bigger, longer rounds'**
  String get settingsLittleKidHint;

  /// No description provided for @settingsHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get settingsHowToPlay;

  /// No description provided for @settingsHowToPlayHint.
  ///
  /// In en, this message translates to:
  /// **'a quick picture guide'**
  String get settingsHowToPlayHint;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @htpPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a game'**
  String get htpPickTitle;

  /// No description provided for @htpPickBody.
  ///
  /// In en, this message translates to:
  /// **'Tap a game card, then press Start.'**
  String get htpPickBody;

  /// No description provided for @htpTapTitle.
  ///
  /// In en, this message translates to:
  /// **'Tap games'**
  String get htpTapTitle;

  /// No description provided for @htpTapBody.
  ///
  /// In en, this message translates to:
  /// **'Touch the things that move, as quickly as you can!'**
  String get htpTapBody;

  /// No description provided for @htpDragTitle.
  ///
  /// In en, this message translates to:
  /// **'Drag games'**
  String get htpDragTitle;

  /// No description provided for @htpDragBody.
  ///
  /// In en, this message translates to:
  /// **'Hold a thing, slide your finger, and let go in the right place.'**
  String get htpDragBody;

  /// No description provided for @htpStarsTitle.
  ///
  /// In en, this message translates to:
  /// **'Stars make gems'**
  String get htpStarsTitle;

  /// No description provided for @htpStarsBody.
  ///
  /// In en, this message translates to:
  /// **'Every good move gives you stars. Every {points} stars turn into 1 gem!'**
  String htpStarsBody(int points);

  /// No description provided for @htpFreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Free plays'**
  String get htpFreeTitle;

  /// No description provided for @htpFreeBody.
  ///
  /// In en, this message translates to:
  /// **'Every game has {count} free plays each day. After that, a round uses 1 gem.'**
  String htpFreeBody(int count);

  /// No description provided for @htpFavTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep favorites'**
  String get htpFavTitle;

  /// No description provided for @htpFavBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on a game to find it fast in Favorites.'**
  String get htpFavBody;

  /// No description provided for @htpNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get htpNext;

  /// No description provided for @htpLetsPlay.
  ///
  /// In en, this message translates to:
  /// **'Let\'s play!'**
  String get htpLetsPlay;

  /// No description provided for @htpStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String htpStep(int current, int total);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @gameNotInHere.
  ///
  /// In en, this message translates to:
  /// **'Not in here!'**
  String get gameNotInHere;

  /// No description provided for @gameWrongShape.
  ///
  /// In en, this message translates to:
  /// **'Wrong shape!'**
  String get gameWrongShape;

  /// No description provided for @gameTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again!'**
  String get gameTryAgain;

  /// No description provided for @gameNotHere.
  ///
  /// In en, this message translates to:
  /// **'Not here!'**
  String get gameNotHere;

  /// No description provided for @gameNotThisOne.
  ///
  /// In en, this message translates to:
  /// **'Not this one!'**
  String get gameNotThisOne;

  /// No description provided for @gameSoClose.
  ///
  /// In en, this message translates to:
  /// **'So close!'**
  String get gameSoClose;

  /// No description provided for @gamePerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get gamePerfect;

  /// No description provided for @gameOtherBucket.
  ///
  /// In en, this message translates to:
  /// **'Other bucket!'**
  String get gameOtherBucket;

  /// No description provided for @gameShoot.
  ///
  /// In en, this message translates to:
  /// **'Shoot!'**
  String get gameShoot;

  /// No description provided for @gameTidyUp.
  ///
  /// In en, this message translates to:
  /// **'Tidy up!'**
  String get gameTidyUp;

  /// No description provided for @gameToys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get gameToys;

  /// No description provided for @gameBooks.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get gameBooks;

  /// No description provided for @gameClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get gameClothes;

  /// No description provided for @gameOnlyLabel.
  ///
  /// In en, this message translates to:
  /// **'{bin, select, toys{Toys only!} books{Books only!} other{Clothes only!}}'**
  String gameOnlyLabel(String bin);

  /// Written on the toy box.
  ///
  /// In en, this message translates to:
  /// **'TOYS'**
  String get gameToyBox;

  /// No description provided for @gameApples.
  ///
  /// In en, this message translates to:
  /// **'Apples'**
  String get gameApples;

  /// No description provided for @gameBananas.
  ///
  /// In en, this message translates to:
  /// **'Bananas'**
  String get gameBananas;

  /// No description provided for @gameOranges.
  ///
  /// In en, this message translates to:
  /// **'Oranges'**
  String get gameOranges;

  /// No description provided for @gameCrateFor.
  ///
  /// In en, this message translates to:
  /// **'{fruit, select, apples{That crate is for apples!} bananas{That crate is for bananas!} other{That crate is for oranges!}}'**
  String gameCrateFor(String fruit);

  /// No description provided for @gameOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get gameOrder;

  /// No description provided for @gameFind.
  ///
  /// In en, this message translates to:
  /// **'Find'**
  String get gameFind;

  /// No description provided for @gameMatchShapes.
  ///
  /// In en, this message translates to:
  /// **'Match the shapes!'**
  String get gameMatchShapes;

  /// No description provided for @gameMatchSocks.
  ///
  /// In en, this message translates to:
  /// **'Match the socks!'**
  String get gameMatchSocks;

  /// No description provided for @gameFindTwin.
  ///
  /// In en, this message translates to:
  /// **'Find its twin!'**
  String get gameFindTwin;

  /// No description provided for @gameWatchBall.
  ///
  /// In en, this message translates to:
  /// **'Watch the ball!'**
  String get gameWatchBall;

  /// No description provided for @gameKeepWatching.
  ///
  /// In en, this message translates to:
  /// **'Keep watching...'**
  String get gameKeepWatching;

  /// No description provided for @gameWhereBall.
  ///
  /// In en, this message translates to:
  /// **'Where is the ball?'**
  String get gameWhereBall;

  /// No description provided for @gameFoundIt.
  ///
  /// In en, this message translates to:
  /// **'You found it!'**
  String get gameFoundIt;

  /// No description provided for @gameItWasHere.
  ///
  /// In en, this message translates to:
  /// **'It was here!'**
  String get gameItWasHere;

  /// No description provided for @gameGreatPattern.
  ///
  /// In en, this message translates to:
  /// **'Great pattern!'**
  String get gameGreatPattern;

  /// No description provided for @gameWhatNext.
  ///
  /// In en, this message translates to:
  /// **'What comes next?'**
  String get gameWhatNext;

  /// No description provided for @progClean.
  ///
  /// In en, this message translates to:
  /// **'{percent}% clean'**
  String progClean(int percent);

  /// No description provided for @progBalloons.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 balloon} other{{count} balloons}}'**
  String progBalloons(int count);

  /// No description provided for @progBalls.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ball} other{{count} balls}}'**
  String progBalls(int count);

  /// No description provided for @progTreasures.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 treasure} other{{count} treasures}}'**
  String progTreasures(int count);

  /// No description provided for @progBaskets.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 basket} other{{count} baskets}}'**
  String progBaskets(int count);

  /// No description provided for @progBlooms.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bloom} other{{count} blooms}}'**
  String progBlooms(int count);

  /// No description provided for @progButterflies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 butterfly} other{{count} butterflies}}'**
  String progButterflies(int count);

  /// No description provided for @progFireflies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 firefly} other{{count} fireflies}}'**
  String progFireflies(int count);

  /// No description provided for @progFound.
  ///
  /// In en, this message translates to:
  /// **'{count} found'**
  String progFound(int count);

  /// No description provided for @progMeals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 meal} other{{count} meals}}'**
  String progMeals(int count);

  /// No description provided for @progChicks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 chick} other{{count} chicks}}'**
  String progChicks(int count);

  /// No description provided for @progFlowers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 flower} other{{count} flowers}}'**
  String progFlowers(int count);

  /// No description provided for @progOrders.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 order} other{{count} orders}}'**
  String progOrders(int count);

  /// No description provided for @progScoops.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scoop} other{{count} scoops}}'**
  String progScoops(int count);

  /// No description provided for @progGemsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 gem found} other{{count} gems found}}'**
  String progGemsFound(int count);

  /// No description provided for @progPatterns.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pattern} other{{count} patterns}}'**
  String progPatterns(int count);

  /// No description provided for @progSaved.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String progSaved(int count);

  /// No description provided for @progLadybugs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 ladybug} other{{count} ladybugs}}'**
  String progLadybugs(int count);

  /// No description provided for @progCrossed.
  ///
  /// In en, this message translates to:
  /// **'{count} crossed'**
  String progCrossed(int count);

  /// No description provided for @progPearls.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pearl} other{{count} pearls}}'**
  String progPearls(int count);

  /// No description provided for @progYummyFish.
  ///
  /// In en, this message translates to:
  /// **'{count} yummy fish'**
  String progYummyFish(int count);

  /// No description provided for @progFish.
  ///
  /// In en, this message translates to:
  /// **'{count} fish'**
  String progFish(int count);

  /// No description provided for @progShooed.
  ///
  /// In en, this message translates to:
  /// **'{count} shooed'**
  String progShooed(int count);

  /// No description provided for @progDrops.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 drop} other{{count} drops}}'**
  String progDrops(int count);

  /// No description provided for @progLanded.
  ///
  /// In en, this message translates to:
  /// **'{count} landed'**
  String progLanded(int count);

  /// No description provided for @progShapes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shape} other{{count} shapes}}'**
  String progShapes(int count);

  /// No description provided for @progPairs.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pair} other{{count} pairs}}'**
  String progPairs(int count);

  /// No description provided for @progTidied.
  ///
  /// In en, this message translates to:
  /// **'{count} tidied'**
  String progTidied(int count);

  /// No description provided for @progTurtles.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 safe turtle} other{{count} safe turtles}}'**
  String progTurtles(int count);

  /// No description provided for @progStars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star} other{{count} stars}}'**
  String progStars(int count);

  /// No description provided for @progWakeUps.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 wake-up} other{{count} wake-ups}}'**
  String progWakeUps(int count);

  /// No description provided for @progWatered.
  ///
  /// In en, this message translates to:
  /// **'{count} watered'**
  String progWatered(int count);

  /// No description provided for @gamePondFishName.
  ///
  /// In en, this message translates to:
  /// **'Pond Fish Catch'**
  String get gamePondFishName;

  /// No description provided for @gamePondFishGoal.
  ///
  /// In en, this message translates to:
  /// **'Tap the fish to catch them!'**
  String get gamePondFishGoal;

  /// No description provided for @gamePondFishHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap a swimming fish to pop it into the basket.'**
  String get gamePondFishHowTo;

  /// No description provided for @gameFlowerBasketName.
  ///
  /// In en, this message translates to:
  /// **'Blooming Flower Basket'**
  String get gameFlowerBasketName;

  /// No description provided for @gameFlowerBasketGoal.
  ///
  /// In en, this message translates to:
  /// **'Pick flowers when they bloom!'**
  String get gameFlowerBasketGoal;

  /// No description provided for @gameFlowerBasketHowTo.
  ///
  /// In en, this message translates to:
  /// **'Wait for a bud to open, then tap the flower.'**
  String get gameFlowerBasketHowTo;

  /// No description provided for @gameStarCollectorName.
  ///
  /// In en, this message translates to:
  /// **'Star Collector'**
  String get gameStarCollectorName;

  /// No description provided for @gameStarCollectorGoal.
  ///
  /// In en, this message translates to:
  /// **'Collect twinkling stars!'**
  String get gameStarCollectorGoal;

  /// No description provided for @gameStarCollectorHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap the stars. Big golden stars are extra special!'**
  String get gameStarCollectorHowTo;

  /// No description provided for @gamePenguinFeastName.
  ///
  /// In en, this message translates to:
  /// **'Penguin Fish Feast'**
  String get gamePenguinFeastName;

  /// No description provided for @gamePenguinFeastGoal.
  ///
  /// In en, this message translates to:
  /// **'Feed the hungry baby penguin!'**
  String get gamePenguinFeastGoal;

  /// No description provided for @gamePenguinFeastHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap a jumping fish to send it to the penguin.'**
  String get gamePenguinFeastHowTo;

  /// No description provided for @gameFireflyName.
  ///
  /// In en, this message translates to:
  /// **'Firefly Catcher'**
  String get gameFireflyName;

  /// No description provided for @gameFireflyGoal.
  ///
  /// In en, this message translates to:
  /// **'Light up the night garden!'**
  String get gameFireflyGoal;

  /// No description provided for @gameFireflyHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap the glowing fireflies before they fly away.'**
  String get gameFireflyHowTo;

  /// No description provided for @gameBeachTreasuresName.
  ///
  /// In en, this message translates to:
  /// **'Sandy Beach Treasures'**
  String get gameBeachTreasuresName;

  /// No description provided for @gameBeachTreasuresGoal.
  ///
  /// In en, this message translates to:
  /// **'Find shells and starfish!'**
  String get gameBeachTreasuresGoal;

  /// No description provided for @gameBeachTreasuresHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap the treasures on the sand. Golden shells are extra special!'**
  String get gameBeachTreasuresHowTo;

  /// No description provided for @gameRaindropName.
  ///
  /// In en, this message translates to:
  /// **'Rainbow Raindrop Catch'**
  String get gameRaindropName;

  /// No description provided for @gameRaindropGoal.
  ///
  /// In en, this message translates to:
  /// **'Fill the jar for a thirsty friend!'**
  String get gameRaindropGoal;

  /// No description provided for @gameRaindropHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap the falling raindrops to fill up the jar.'**
  String get gameRaindropHowTo;

  /// No description provided for @gameRocketLaunchName.
  ///
  /// In en, this message translates to:
  /// **'Rocket Launch'**
  String get gameRocketLaunchName;

  /// No description provided for @gameRocketLaunchGoal.
  ///
  /// In en, this message translates to:
  /// **'Land rockets on the planet!'**
  String get gameRocketLaunchGoal;

  /// No description provided for @gameRocketLaunchHowTo.
  ///
  /// In en, this message translates to:
  /// **'When the arrow points at the planet, tap to launch!'**
  String get gameRocketLaunchHowTo;

  /// No description provided for @gameBalloonParadeName.
  ///
  /// In en, this message translates to:
  /// **'Balloon Tap Parade'**
  String get gameBalloonParadeName;

  /// No description provided for @gameBalloonParadeGoal.
  ///
  /// In en, this message translates to:
  /// **'Pop the floating balloons!'**
  String get gameBalloonParadeGoal;

  /// No description provided for @gameBalloonParadeHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap the balloons before they float away.'**
  String get gameBalloonParadeHowTo;

  /// No description provided for @gameBusyBeeName.
  ///
  /// In en, this message translates to:
  /// **'Busy Bee Garden'**
  String get gameBusyBeeName;

  /// No description provided for @gameBusyBeeGoal.
  ///
  /// In en, this message translates to:
  /// **'Help the bees bloom flowers!'**
  String get gameBusyBeeGoal;

  /// No description provided for @gameBusyBeeHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap a bee when it visits a bud to make the flower bloom.'**
  String get gameBusyBeeHowTo;

  /// No description provided for @gameHatchChickName.
  ///
  /// In en, this message translates to:
  /// **'Hatch-a-Chick'**
  String get gameHatchChickName;

  /// No description provided for @gameHatchChickGoal.
  ///
  /// In en, this message translates to:
  /// **'Help the baby chicks hatch!'**
  String get gameHatchChickGoal;

  /// No description provided for @gameHatchChickHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap the wobbly egg a few times to help the chick come out.'**
  String get gameHatchChickHowTo;

  /// No description provided for @gameLadybugName.
  ///
  /// In en, this message translates to:
  /// **'Ladybug Leaf Tap'**
  String get gameLadybugName;

  /// No description provided for @gameLadybugGoal.
  ///
  /// In en, this message translates to:
  /// **'Help ladybugs fly off the leaves!'**
  String get gameLadybugGoal;

  /// No description provided for @gameLadybugHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap a crawling ladybug to help it fly. Golden ones are extra special!'**
  String get gameLadybugHowTo;

  /// No description provided for @gameBasketballName.
  ///
  /// In en, this message translates to:
  /// **'Basketball Hoop Challenge'**
  String get gameBasketballName;

  /// No description provided for @gameBasketballGoal.
  ///
  /// In en, this message translates to:
  /// **'Shoot hoops with the arrow!'**
  String get gameBasketballGoal;

  /// No description provided for @gameBasketballHowTo.
  ///
  /// In en, this message translates to:
  /// **'When the arrow points at a hoop, tap Shoot!'**
  String get gameBasketballHowTo;

  /// No description provided for @gameGemMineName.
  ///
  /// In en, this message translates to:
  /// **'Find the Gem'**
  String get gameGemMineName;

  /// No description provided for @gameGemMineGoal.
  ///
  /// In en, this message translates to:
  /// **'Smash boxes to find the gem!'**
  String get gameGemMineGoal;

  /// No description provided for @gameGemMineHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap boxes with the hammer. The box that matches the sign holds the gem!'**
  String get gameGemMineHowTo;

  /// No description provided for @gameCupShuffleName.
  ///
  /// In en, this message translates to:
  /// **'Cup Shuffle'**
  String get gameCupShuffleName;

  /// No description provided for @gameCupShuffleGoal.
  ///
  /// In en, this message translates to:
  /// **'Find the ball under the cup!'**
  String get gameCupShuffleGoal;

  /// No description provided for @gameCupShuffleHowTo.
  ///
  /// In en, this message translates to:
  /// **'Watch the ball, follow its cup, then tap where it is hiding.'**
  String get gameCupShuffleHowTo;

  /// No description provided for @gamePatternEggsName.
  ///
  /// In en, this message translates to:
  /// **'Pattern Egg Hunt'**
  String get gamePatternEggsName;

  /// No description provided for @gamePatternEggsGoal.
  ///
  /// In en, this message translates to:
  /// **'Find the egg that comes next!'**
  String get gamePatternEggsGoal;

  /// No description provided for @gamePatternEggsHowTo.
  ///
  /// In en, this message translates to:
  /// **'Look at the egg pattern, then tap the egg that comes next.'**
  String get gamePatternEggsHowTo;

  /// No description provided for @gameCleanRoomName.
  ///
  /// In en, this message translates to:
  /// **'Clean My Room'**
  String get gameCleanRoomName;

  /// No description provided for @gameCleanRoomGoal.
  ///
  /// In en, this message translates to:
  /// **'Put toys, books and clothes away!'**
  String get gameCleanRoomGoal;

  /// No description provided for @gameCleanRoomHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap a messy thing to tidy it, or switch to Drag and move it home.'**
  String get gameCleanRoomHowTo;

  /// No description provided for @gameButterflyName.
  ///
  /// In en, this message translates to:
  /// **'Butterfly Catch'**
  String get gameButterflyName;

  /// No description provided for @gameButterflyGoal.
  ///
  /// In en, this message translates to:
  /// **'Guide butterflies to their garden!'**
  String get gameButterflyGoal;

  /// No description provided for @gameButterflyHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap a fluttering butterfly to send it to the garden.'**
  String get gameButterflyHowTo;

  /// No description provided for @gameWakeOwlsName.
  ///
  /// In en, this message translates to:
  /// **'Wake Up, Little Owls'**
  String get gameWakeOwlsName;

  /// No description provided for @gameWakeOwlsGoal.
  ///
  /// In en, this message translates to:
  /// **'Wake the sleepy owls!'**
  String get gameWakeOwlsGoal;

  /// No description provided for @gameWakeOwlsHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap a sleeping owl to wake it up and watch it fly.'**
  String get gameWakeOwlsHowTo;

  /// No description provided for @gameTurtleRescueName.
  ///
  /// In en, this message translates to:
  /// **'Tiny Turtle Rescue'**
  String get gameTurtleRescueName;

  /// No description provided for @gameTurtleRescueGoal.
  ///
  /// In en, this message translates to:
  /// **'Help baby turtles reach the reef!'**
  String get gameTurtleRescueGoal;

  /// No description provided for @gameTurtleRescueHowTo.
  ///
  /// In en, this message translates to:
  /// **'Tap a baby turtle and it will swim home to the coral reef.'**
  String get gameTurtleRescueHowTo;

  /// No description provided for @gamePearlDiverName.
  ///
  /// In en, this message translates to:
  /// **'Pearl Diver'**
  String get gamePearlDiverName;

  /// No description provided for @gamePearlDiverGoal.
  ///
  /// In en, this message translates to:
  /// **'Collect pearls from the shells!'**
  String get gamePearlDiverGoal;

  /// No description provided for @gamePearlDiverHowTo.
  ///
  /// In en, this message translates to:
  /// **'When a shell opens and shows its pearl, tap it!'**
  String get gamePearlDiverHowTo;

  /// No description provided for @gameIceCreamName.
  ///
  /// In en, this message translates to:
  /// **'Ice Cream Catch'**
  String get gameIceCreamName;

  /// No description provided for @gameIceCreamGoal.
  ///
  /// In en, this message translates to:
  /// **'Catch the falling scoops!'**
  String get gameIceCreamGoal;

  /// No description provided for @gameIceCreamHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag the cone left and right to catch each scoop.'**
  String get gameIceCreamHowTo;

  /// No description provided for @gameJellyfishName.
  ///
  /// In en, this message translates to:
  /// **'Jellyfish Glow'**
  String get gameJellyfishName;

  /// No description provided for @gameJellyfishGoal.
  ///
  /// In en, this message translates to:
  /// **'Save the baby diver from the jellyfish!'**
  String get gameJellyfishGoal;

  /// No description provided for @gameJellyfishHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag each glowing jellyfish off the screen to light up the sea.'**
  String get gameJellyfishHowTo;

  /// No description provided for @gameBouncyBallsName.
  ///
  /// In en, this message translates to:
  /// **'Bouncy Ball Catch'**
  String get gameBouncyBallsName;

  /// No description provided for @gameBouncyBallsGoal.
  ///
  /// In en, this message translates to:
  /// **'Drag each ball to its bucket!'**
  String get gameBouncyBallsGoal;

  /// No description provided for @gameBouncyBallsHowTo.
  ///
  /// In en, this message translates to:
  /// **'Grab a bouncing ball and drop it in the bucket of the same colour.'**
  String get gameBouncyBallsHowTo;

  /// No description provided for @gameFruitMarketName.
  ///
  /// In en, this message translates to:
  /// **'Fruit Market'**
  String get gameFruitMarketName;

  /// No description provided for @gameFruitMarketGoal.
  ///
  /// In en, this message translates to:
  /// **'Sort fruit into the right crates!'**
  String get gameFruitMarketGoal;

  /// No description provided for @gameFruitMarketHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag each fruit into its crate to fill the order.'**
  String get gameFruitMarketHowTo;

  /// No description provided for @gameTidyUpName.
  ///
  /// In en, this message translates to:
  /// **'Tidy-Up Time'**
  String get gameTidyUpName;

  /// No description provided for @gameTidyUpGoal.
  ///
  /// In en, this message translates to:
  /// **'Put toys, books and clothes away!'**
  String get gameTidyUpGoal;

  /// No description provided for @gameTidyUpHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag each thing to the place with its label.'**
  String get gameTidyUpHowTo;

  /// No description provided for @gameShapeBoxName.
  ///
  /// In en, this message translates to:
  /// **'Shape Box Puzzle'**
  String get gameShapeBoxName;

  /// No description provided for @gameShapeBoxGoal.
  ///
  /// In en, this message translates to:
  /// **'Fit each shape in its hole!'**
  String get gameShapeBoxGoal;

  /// No description provided for @gameShapeBoxHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag circles, squares and triangles into the matching holes.'**
  String get gameShapeBoxHowTo;

  /// No description provided for @gameSockPairsName.
  ///
  /// In en, this message translates to:
  /// **'Sock Pair Match'**
  String get gameSockPairsName;

  /// No description provided for @gameSockPairsGoal.
  ///
  /// In en, this message translates to:
  /// **'Find each sock its twin!'**
  String get gameSockPairsGoal;

  /// No description provided for @gameSockPairsHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag each sock into the drawer with the matching sock.'**
  String get gameSockPairsHowTo;

  /// No description provided for @gameWaterPlantsName.
  ///
  /// In en, this message translates to:
  /// **'Water the Plants'**
  String get gameWaterPlantsName;

  /// No description provided for @gameWaterPlantsGoal.
  ///
  /// In en, this message translates to:
  /// **'Water thirsty plants to make them bloom!'**
  String get gameWaterPlantsGoal;

  /// No description provided for @gameWaterPlantsHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag the watering can over a thirsty plant and hold it there.'**
  String get gameWaterPlantsHowTo;

  /// No description provided for @gameFeedPenguinName.
  ///
  /// In en, this message translates to:
  /// **'Feed the Penguin'**
  String get gameFeedPenguinName;

  /// No description provided for @gameFeedPenguinGoal.
  ///
  /// In en, this message translates to:
  /// **'Give the penguin all the fish it wants!'**
  String get gameFeedPenguinGoal;

  /// No description provided for @gameFeedPenguinHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag fish from the bucket to the hungry penguin.'**
  String get gameFeedPenguinHowTo;

  /// No description provided for @gamePondPathName.
  ///
  /// In en, this message translates to:
  /// **'Build a Pond Path'**
  String get gamePondPathName;

  /// No description provided for @gamePondPathGoal.
  ///
  /// In en, this message translates to:
  /// **'Build stepping stones for the frog!'**
  String get gamePondPathGoal;

  /// No description provided for @gamePondPathHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag each stone into the gap with the same shape.'**
  String get gamePondPathHowTo;

  /// No description provided for @gameSleepingMonsterName.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Wake the Monster'**
  String get gameSleepingMonsterName;

  /// No description provided for @gameSleepingMonsterGoal.
  ///
  /// In en, this message translates to:
  /// **'Shoo the babies before they wake daddy!'**
  String get gameSleepingMonsterGoal;

  /// No description provided for @gameSleepingMonsterHowTo.
  ///
  /// In en, this message translates to:
  /// **'Drag or swipe the baby monsters off the screen before they poke the sleepy monster.'**
  String get gameSleepingMonsterHowTo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
