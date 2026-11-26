// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TinyThink';

  @override
  String get homeTitleLine1 => 'Tap & Drag';

  @override
  String get homeTitleLine2 => 'Games';

  @override
  String get homeTitleSemantics => 'Tap and Drag Games';

  @override
  String get homePlayGames => 'Play\nGames';

  @override
  String get homeRewards => 'Rewards';

  @override
  String get rewardsTitle => 'My Rewards';

  @override
  String get rewardsGemsSaved => 'gems saved';

  @override
  String rewardsStarsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars today',
      one: '1 star today',
    );
    return '$_temp0';
  }

  @override
  String rewardsStarsPerGem(int points) {
    return 'Every $points stars = 1 gem';
  }

  @override
  String rewardsFreePlaysPerDay(int count) {
    return '$count free plays per game each day';
  }

  @override
  String get rewardsYay => 'Yay!';

  @override
  String get hubTitle => 'Tap & Drag Games';

  @override
  String get hubSubtitle => 'Pick a game and play!';

  @override
  String get filterAll => 'All Games';

  @override
  String get filterTap => 'Tap';

  @override
  String get filterDrag => 'Drag';

  @override
  String get filterFavorites => 'Favorites';

  @override
  String get interactionTap => 'Tap';

  @override
  String get interactionDrag => 'Drag';

  @override
  String get interactionTapDrag => 'Tap + Drag';

  @override
  String get favoriteAdd => 'Add favorite';

  @override
  String get favoriteRemove => 'Remove favorite';

  @override
  String freePlaysLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count free plays left today',
      one: '1 free play left today',
    );
    return '$_temp0';
  }

  @override
  String get nextPlayCostsGem => 'Next play costs 1 gem';

  @override
  String get play => 'Play';

  @override
  String get resting => 'Resting';

  @override
  String get favoritesEmpty => 'Tap a heart to save your favorite games here!';

  @override
  String get moreDragGamesSoon => 'More drag games are coming soon!';

  @override
  String get back => 'Back';

  @override
  String get settings => 'Settings';

  @override
  String gemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gems',
      one: '1 gem',
    );
    return '$_temp0';
  }

  @override
  String get noGemsTitle => 'No gems right now';

  @override
  String noGemsBody(int count) {
    return 'You used your $count free plays of this game today. Earn gems in other games, or come back tomorrow!';
  }

  @override
  String get restingTitle => 'This game is resting';

  @override
  String get restingBody => 'Try another game for now!';

  @override
  String get oops => 'Oops!';

  @override
  String get startFailedBody =>
      'Something went wrong. No gems were used. Please try again.';

  @override
  String get playAgainTitle => 'Play again?';

  @override
  String get playAgainBody =>
      'Free plays are used up for today.\nThis round uses 1 gem.';

  @override
  String get youHave => 'You have ';

  @override
  String get notNow => 'Not now';

  @override
  String get useOneGem => 'Use 1 ';

  @override
  String get backToGames => 'Back to games';

  @override
  String get ok => 'OK';

  @override
  String get freePlaysToday => 'Free plays today';

  @override
  String freePlaysRemaining(int remaining, int total) {
    return '$remaining of $total left';
  }

  @override
  String get nextRoundUsesGem => 'Next round uses 1 gem';

  @override
  String get comeBackTomorrow => 'Come back tomorrow for more free plays!';

  @override
  String get gameRestingNow => 'This game is resting right now';

  @override
  String get start => 'Start';

  @override
  String get startWithGem => 'Start  1';

  @override
  String get pause => 'Pause';

  @override
  String get paused => 'Paused';

  @override
  String get keepPlaying => 'Keep playing';

  @override
  String get soundOn => 'Sound on';

  @override
  String get soundOff => 'Sound off';

  @override
  String get games => 'Games';

  @override
  String get progressSaved => 'Your stars and gems are saved.';

  @override
  String get cheerAmazing => 'Amazing!';

  @override
  String get cheerGreat => 'Great job!';

  @override
  String get cheerNice => 'Nice playing!';

  @override
  String scoreToEarnGem(int points) {
    return 'Score $points to earn a gem!';
  }

  @override
  String youEarnedGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You earned $count gems!',
      one: 'You earned 1 gem!',
    );
    return '$_temp0';
  }

  @override
  String get myGems => 'My gems';

  @override
  String get again => 'Again';

  @override
  String get freePlaysDone => 'Free plays are done for today.';

  @override
  String get creditBy => 'by';

  @override
  String get settingsSoundSection => 'Sound & touch';

  @override
  String get settingsSoundEffects => 'Sound effects';

  @override
  String get settingsMusic => 'Music';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsLookSection => 'Look';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'Auto';

  @override
  String get settingsGentleMotion => 'Gentle motion';

  @override
  String get settingsGentleMotionHint => 'fewer bouncy animations';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsPlaySection => 'Play';

  @override
  String get settingsLittleKid => 'Little-kid mode';

  @override
  String get settingsLittleKidHint => 'slower, bigger, longer rounds';

  @override
  String get settingsHowToPlay => 'How to play';

  @override
  String get settingsHowToPlayHint => 'a quick picture guide';

  @override
  String get done => 'Done';

  @override
  String get htpPickTitle => 'Pick a game';

  @override
  String get htpPickBody => 'Tap a game card, then press Start.';

  @override
  String get htpTapTitle => 'Tap games';

  @override
  String get htpTapBody => 'Touch the things that move, as quickly as you can!';

  @override
  String get htpDragTitle => 'Drag games';

  @override
  String get htpDragBody =>
      'Hold a thing, slide your finger, and let go in the right place.';

  @override
  String get htpStarsTitle => 'Stars make gems';

  @override
  String htpStarsBody(int points) {
    return 'Every good move gives you stars. Every $points stars turn into 1 gem!';
  }

  @override
  String get htpFreeTitle => 'Free plays';

  @override
  String htpFreeBody(int count) {
    return 'Every game has $count free plays each day. After that, a round uses 1 gem.';
  }

  @override
  String get htpFavTitle => 'Keep favorites';

  @override
  String get htpFavBody =>
      'Tap the heart on a game to find it fast in Favorites.';

  @override
  String get htpNext => 'Next';

  @override
  String get htpLetsPlay => 'Let\'s play!';

  @override
  String htpStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get close => 'Close';

  @override
  String get gameNotInHere => 'Not in here!';

  @override
  String get gameWrongShape => 'Wrong shape!';

  @override
  String get gameTryAgain => 'Try again!';

  @override
  String get gameNotHere => 'Not here!';

  @override
  String get gameNotThisOne => 'Not this one!';

  @override
  String get gameSoClose => 'So close!';

  @override
  String get gamePerfect => 'Perfect!';

  @override
  String get gameOtherBucket => 'Other bucket!';

  @override
  String get gameShoot => 'Shoot!';

  @override
  String get gameTidyUp => 'Tidy up!';

  @override
  String get gameToys => 'Toys';

  @override
  String get gameBooks => 'Books';

  @override
  String get gameClothes => 'Clothes';

  @override
  String gameOnlyLabel(String bin) {
    String _temp0 = intl.Intl.selectLogic(bin, {
      'toys': 'Toys only!',
      'books': 'Books only!',
      'other': 'Clothes only!',
    });
    return '$_temp0';
  }

  @override
  String get gameToyBox => 'TOYS';

  @override
  String get gameApples => 'Apples';

  @override
  String get gameBananas => 'Bananas';

  @override
  String get gameOranges => 'Oranges';

  @override
  String gameCrateFor(String fruit) {
    String _temp0 = intl.Intl.selectLogic(fruit, {
      'apples': 'That crate is for apples!',
      'bananas': 'That crate is for bananas!',
      'other': 'That crate is for oranges!',
    });
    return '$_temp0';
  }

  @override
  String get gameOrder => 'Order';

  @override
  String get gameFind => 'Find';

  @override
  String get gameMatchShapes => 'Match the shapes!';

  @override
  String get gameMatchSocks => 'Match the socks!';

  @override
  String get gameFindTwin => 'Find its twin!';

  @override
  String get gameWatchBall => 'Watch the ball!';

  @override
  String get gameKeepWatching => 'Keep watching...';

  @override
  String get gameWhereBall => 'Where is the ball?';

  @override
  String get gameFoundIt => 'You found it!';

  @override
  String get gameItWasHere => 'It was here!';

  @override
  String get gameGreatPattern => 'Great pattern!';

  @override
  String get gameWhatNext => 'What comes next?';

  @override
  String progClean(int percent) {
    return '$percent% clean';
  }

  @override
  String progBalloons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count balloons',
      one: '1 balloon',
    );
    return '$_temp0';
  }

  @override
  String progBalls(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count balls',
      one: '1 ball',
    );
    return '$_temp0';
  }

  @override
  String progTreasures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count treasures',
      one: '1 treasure',
    );
    return '$_temp0';
  }

  @override
  String progBaskets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count baskets',
      one: '1 basket',
    );
    return '$_temp0';
  }

  @override
  String progBlooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count blooms',
      one: '1 bloom',
    );
    return '$_temp0';
  }

  @override
  String progButterflies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count butterflies',
      one: '1 butterfly',
    );
    return '$_temp0';
  }

  @override
  String progFireflies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fireflies',
      one: '1 firefly',
    );
    return '$_temp0';
  }

  @override
  String progFound(int count) {
    return '$count found';
  }

  @override
  String progMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0';
  }

  @override
  String progChicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count chicks',
      one: '1 chick',
    );
    return '$_temp0';
  }

  @override
  String progFlowers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flowers',
      one: '1 flower',
    );
    return '$_temp0';
  }

  @override
  String progOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count orders',
      one: '1 order',
    );
    return '$_temp0';
  }

  @override
  String progScoops(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scoops',
      one: '1 scoop',
    );
    return '$_temp0';
  }

  @override
  String progGemsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gems found',
      one: '1 gem found',
    );
    return '$_temp0';
  }

  @override
  String progPatterns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count patterns',
      one: '1 pattern',
    );
    return '$_temp0';
  }

  @override
  String progSaved(int count) {
    return '$count saved';
  }

  @override
  String progLadybugs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ladybugs',
      one: '1 ladybug',
    );
    return '$_temp0';
  }

  @override
  String progCrossed(int count) {
    return '$count crossed';
  }

  @override
  String progPearls(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pearls',
      one: '1 pearl',
    );
    return '$_temp0';
  }

  @override
  String progYummyFish(int count) {
    return '$count yummy fish';
  }

  @override
  String progFish(int count) {
    return '$count fish';
  }

  @override
  String progShooed(int count) {
    return '$count shooed';
  }

  @override
  String progDrops(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count drops',
      one: '1 drop',
    );
    return '$_temp0';
  }

  @override
  String progLanded(int count) {
    return '$count landed';
  }

  @override
  String progShapes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shapes',
      one: '1 shape',
    );
    return '$_temp0';
  }

  @override
  String progPairs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pairs',
      one: '1 pair',
    );
    return '$_temp0';
  }

  @override
  String progTidied(int count) {
    return '$count tidied';
  }

  @override
  String progTurtles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count safe turtles',
      one: '1 safe turtle',
    );
    return '$_temp0';
  }

  @override
  String progStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
    );
    return '$_temp0';
  }

  @override
  String progWakeUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wake-ups',
      one: '1 wake-up',
    );
    return '$_temp0';
  }

  @override
  String progWatered(int count) {
    return '$count watered';
  }

  @override
  String get gamePondFishName => 'Pond Fish Catch';

  @override
  String get gamePondFishGoal => 'Tap the fish to catch them!';

  @override
  String get gamePondFishHowTo =>
      'Tap a swimming fish to pop it into the basket.';

  @override
  String get gameFlowerBasketName => 'Blooming Flower Basket';

  @override
  String get gameFlowerBasketGoal => 'Pick flowers when they bloom!';

  @override
  String get gameFlowerBasketHowTo =>
      'Wait for a bud to open, then tap the flower.';

  @override
  String get gameStarCollectorName => 'Star Collector';

  @override
  String get gameStarCollectorGoal => 'Collect twinkling stars!';

  @override
  String get gameStarCollectorHowTo =>
      'Tap the stars. Big golden stars are extra special!';

  @override
  String get gamePenguinFeastName => 'Penguin Fish Feast';

  @override
  String get gamePenguinFeastGoal => 'Feed the hungry baby penguin!';

  @override
  String get gamePenguinFeastHowTo =>
      'Tap a jumping fish to send it to the penguin.';

  @override
  String get gameFireflyName => 'Firefly Catcher';

  @override
  String get gameFireflyGoal => 'Light up the night garden!';

  @override
  String get gameFireflyHowTo =>
      'Tap the glowing fireflies before they fly away.';

  @override
  String get gameBeachTreasuresName => 'Sandy Beach Treasures';

  @override
  String get gameBeachTreasuresGoal => 'Find shells and starfish!';

  @override
  String get gameBeachTreasuresHowTo =>
      'Tap the treasures on the sand. Golden shells are extra special!';

  @override
  String get gameRaindropName => 'Rainbow Raindrop Catch';

  @override
  String get gameRaindropGoal => 'Fill the jar for a thirsty friend!';

  @override
  String get gameRaindropHowTo =>
      'Tap the falling raindrops to fill up the jar.';

  @override
  String get gameRocketLaunchName => 'Rocket Launch';

  @override
  String get gameRocketLaunchGoal => 'Land rockets on the planet!';

  @override
  String get gameRocketLaunchHowTo =>
      'When the arrow points at the planet, tap to launch!';

  @override
  String get gameBalloonParadeName => 'Balloon Tap Parade';

  @override
  String get gameBalloonParadeGoal => 'Pop the floating balloons!';

  @override
  String get gameBalloonParadeHowTo =>
      'Tap the balloons before they float away.';

  @override
  String get gameBusyBeeName => 'Busy Bee Garden';

  @override
  String get gameBusyBeeGoal => 'Help the bees bloom flowers!';

  @override
  String get gameBusyBeeHowTo =>
      'Tap a bee when it visits a bud to make the flower bloom.';

  @override
  String get gameHatchChickName => 'Hatch-a-Chick';

  @override
  String get gameHatchChickGoal => 'Help the baby chicks hatch!';

  @override
  String get gameHatchChickHowTo =>
      'Tap the wobbly egg a few times to help the chick come out.';

  @override
  String get gameLadybugName => 'Ladybug Leaf Tap';

  @override
  String get gameLadybugGoal => 'Help ladybugs fly off the leaves!';

  @override
  String get gameLadybugHowTo =>
      'Tap a crawling ladybug to help it fly. Golden ones are extra special!';

  @override
  String get gameBasketballName => 'Basketball Hoop Challenge';

  @override
  String get gameBasketballGoal => 'Shoot hoops with the arrow!';

  @override
  String get gameBasketballHowTo =>
      'When the arrow points at a hoop, tap Shoot!';

  @override
  String get gameGemMineName => 'Find the Gem';

  @override
  String get gameGemMineGoal => 'Smash boxes to find the gem!';

  @override
  String get gameGemMineHowTo =>
      'Tap boxes with the hammer. The box that matches the sign holds the gem!';

  @override
  String get gameCupShuffleName => 'Cup Shuffle';

  @override
  String get gameCupShuffleGoal => 'Find the ball under the cup!';

  @override
  String get gameCupShuffleHowTo =>
      'Watch the ball, follow its cup, then tap where it is hiding.';

  @override
  String get gamePatternEggsName => 'Pattern Egg Hunt';

  @override
  String get gamePatternEggsGoal => 'Find the egg that comes next!';

  @override
  String get gamePatternEggsHowTo =>
      'Look at the egg pattern, then tap the egg that comes next.';

  @override
  String get gameCleanRoomName => 'Clean My Room';

  @override
  String get gameCleanRoomGoal => 'Put toys, books and clothes away!';

  @override
  String get gameCleanRoomHowTo =>
      'Tap a messy thing to tidy it, or switch to Drag and move it home.';

  @override
  String get gameButterflyName => 'Butterfly Catch';

  @override
  String get gameButterflyGoal => 'Guide butterflies to their garden!';

  @override
  String get gameButterflyHowTo =>
      'Tap a fluttering butterfly to send it to the garden.';

  @override
  String get gameWakeOwlsName => 'Wake Up, Little Owls';

  @override
  String get gameWakeOwlsGoal => 'Wake the sleepy owls!';

  @override
  String get gameWakeOwlsHowTo =>
      'Tap a sleeping owl to wake it up and watch it fly.';

  @override
  String get gameTurtleRescueName => 'Tiny Turtle Rescue';

  @override
  String get gameTurtleRescueGoal => 'Help baby turtles reach the reef!';

  @override
  String get gameTurtleRescueHowTo =>
      'Tap a baby turtle and it will swim home to the coral reef.';

  @override
  String get gamePearlDiverName => 'Pearl Diver';

  @override
  String get gamePearlDiverGoal => 'Collect pearls from the shells!';

  @override
  String get gamePearlDiverHowTo =>
      'When a shell opens and shows its pearl, tap it!';

  @override
  String get gameIceCreamName => 'Ice Cream Catch';

  @override
  String get gameIceCreamGoal => 'Catch the falling scoops!';

  @override
  String get gameIceCreamHowTo =>
      'Drag the cone left and right to catch each scoop.';

  @override
  String get gameJellyfishName => 'Jellyfish Glow';

  @override
  String get gameJellyfishGoal => 'Save the baby diver from the jellyfish!';

  @override
  String get gameJellyfishHowTo =>
      'Drag each glowing jellyfish off the screen to light up the sea.';

  @override
  String get gameBouncyBallsName => 'Bouncy Ball Catch';

  @override
  String get gameBouncyBallsGoal => 'Drag each ball to its bucket!';

  @override
  String get gameBouncyBallsHowTo =>
      'Grab a bouncing ball and drop it in the bucket of the same colour.';

  @override
  String get gameFruitMarketName => 'Fruit Market';

  @override
  String get gameFruitMarketGoal => 'Sort fruit into the right crates!';

  @override
  String get gameFruitMarketHowTo =>
      'Drag each fruit into its crate to fill the order.';

  @override
  String get gameTidyUpName => 'Tidy-Up Time';

  @override
  String get gameTidyUpGoal => 'Put toys, books and clothes away!';

  @override
  String get gameTidyUpHowTo => 'Drag each thing to the place with its label.';

  @override
  String get gameShapeBoxName => 'Shape Box Puzzle';

  @override
  String get gameShapeBoxGoal => 'Fit each shape in its hole!';

  @override
  String get gameShapeBoxHowTo =>
      'Drag circles, squares and triangles into the matching holes.';

  @override
  String get gameSockPairsName => 'Sock Pair Match';

  @override
  String get gameSockPairsGoal => 'Find each sock its twin!';

  @override
  String get gameSockPairsHowTo =>
      'Drag each sock into the drawer with the matching sock.';

  @override
  String get gameWaterPlantsName => 'Water the Plants';

  @override
  String get gameWaterPlantsGoal => 'Water thirsty plants to make them bloom!';

  @override
  String get gameWaterPlantsHowTo =>
      'Drag the watering can over a thirsty plant and hold it there.';

  @override
  String get gameFeedPenguinName => 'Feed the Penguin';

  @override
  String get gameFeedPenguinGoal => 'Give the penguin all the fish it wants!';

  @override
  String get gameFeedPenguinHowTo =>
      'Drag fish from the bucket to the hungry penguin.';

  @override
  String get gamePondPathName => 'Build a Pond Path';

  @override
  String get gamePondPathGoal => 'Build stepping stones for the frog!';

  @override
  String get gamePondPathHowTo =>
      'Drag each stone into the gap with the same shape.';

  @override
  String get gameSleepingMonsterName => 'Don\'t Wake the Monster';

  @override
  String get gameSleepingMonsterGoal =>
      'Shoo the babies before they wake daddy!';

  @override
  String get gameSleepingMonsterHowTo =>
      'Drag or swipe the baby monsters off the screen before they poke the sleepy monster.';
}
