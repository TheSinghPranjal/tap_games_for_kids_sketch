// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'TinyThink';

  @override
  String get homeTitleLine1 => 'टैप और ड्रैग';

  @override
  String get homeTitleLine2 => 'खेल';

  @override
  String get homeTitleSemantics => 'टैप और ड्रैग खेल';

  @override
  String get homePlayGames => 'खेल\nखेलें';

  @override
  String get homeRewards => 'इनाम';

  @override
  String get rewardsTitle => 'मेरे इनाम';

  @override
  String get rewardsGemsSaved => 'रत्न जमा हैं';

  @override
  String rewardsStarsToday(int count) {
    return 'आज $count सितारे';
  }

  @override
  String rewardsStarsPerGem(int points) {
    return 'हर $points सितारे = 1 रत्न';
  }

  @override
  String rewardsFreePlaysPerDay(int count) {
    return 'हर खेल रोज़ $count बार मुफ़्त';
  }

  @override
  String get rewardsYay => 'वाह!';

  @override
  String get hubTitle => 'टैप और ड्रैग खेल';

  @override
  String get hubSubtitle => 'कोई खेल चुनो और खेलो!';

  @override
  String get filterAll => 'सभी खेल';

  @override
  String get filterTap => 'टैप';

  @override
  String get filterDrag => 'ड्रैग';

  @override
  String get filterFavorites => 'पसंदीदा';

  @override
  String get interactionTap => 'टैप';

  @override
  String get interactionDrag => 'ड्रैग';

  @override
  String get interactionTapDrag => 'टैप + ड्रैग';

  @override
  String get favoriteAdd => 'पसंदीदा में जोड़ें';

  @override
  String get favoriteRemove => 'पसंदीदा से हटाएँ';

  @override
  String freePlaysLeftToday(int count) {
    return 'आज $count मुफ़्त खेल बाकी';
  }

  @override
  String get nextPlayCostsGem => 'अगला खेल 1 रत्न का है';

  @override
  String get play => 'खेलो';

  @override
  String get resting => 'आराम';

  @override
  String get favoritesEmpty =>
      'अपने पसंदीदा खेल यहाँ रखने के लिए दिल पर टैप करो!';

  @override
  String get moreDragGamesSoon => 'और ड्रैग खेल जल्द आ रहे हैं!';

  @override
  String get back => 'वापस';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String gemsCount(int count) {
    return '$count रत्न';
  }

  @override
  String get noGemsTitle => 'अभी कोई रत्न नहीं';

  @override
  String noGemsBody(int count) {
    return 'तुमने आज इस खेल के $count मुफ़्त खेल खेल लिए। दूसरे खेलों में रत्न कमाओ, या कल फिर आओ!';
  }

  @override
  String get restingTitle => 'यह खेल आराम कर रहा है';

  @override
  String get restingBody => 'अभी कोई दूसरा खेल खेलो!';

  @override
  String get oops => 'उफ़!';

  @override
  String get startFailedBody =>
      'कुछ गड़बड़ हो गई। कोई रत्न खर्च नहीं हुआ। फिर से कोशिश करो।';

  @override
  String get playAgainTitle => 'फिर से खेलें?';

  @override
  String get playAgainBody =>
      'आज के मुफ़्त खेल खत्म हो गए।\nइस बार 1 रत्न लगेगा।';

  @override
  String get youHave => 'तुम्हारे पास ';

  @override
  String get notNow => 'अभी नहीं';

  @override
  String get useOneGem => '1 लगाओ ';

  @override
  String get backToGames => 'खेलों पर वापस';

  @override
  String get ok => 'ठीक है';

  @override
  String get freePlaysToday => 'आज के मुफ़्त खेल';

  @override
  String freePlaysRemaining(int remaining, int total) {
    return '$total में से $remaining बाकी';
  }

  @override
  String get nextRoundUsesGem => 'अगली बार 1 रत्न लगेगा';

  @override
  String get comeBackTomorrow => 'और मुफ़्त खेलों के लिए कल आना!';

  @override
  String get gameRestingNow => 'यह खेल अभी आराम कर रहा है';

  @override
  String get start => 'शुरू करो';

  @override
  String get startWithGem => 'शुरू करो  1';

  @override
  String get pause => 'रोको';

  @override
  String get paused => 'रुका हुआ';

  @override
  String get keepPlaying => 'खेलते रहो';

  @override
  String get soundOn => 'आवाज़ चालू';

  @override
  String get soundOff => 'आवाज़ बंद';

  @override
  String get games => 'खेल';

  @override
  String get progressSaved => 'तुम्हारे सितारे और रत्न सुरक्षित हैं।';

  @override
  String get cheerAmazing => 'कमाल!';

  @override
  String get cheerGreat => 'शाबाश!';

  @override
  String get cheerNice => 'बढ़िया खेला!';

  @override
  String scoreToEarnGem(int points) {
    return 'रत्न पाने के लिए $points अंक बनाओ!';
  }

  @override
  String youEarnedGems(int count) {
    return 'तुमने $count रत्न जीते!';
  }

  @override
  String get myGems => 'मेरे रत्न';

  @override
  String get again => 'फिर से';

  @override
  String get freePlaysDone => 'आज के मुफ़्त खेल खत्म।';

  @override
  String get creditBy => 'प्रस्तुति';

  @override
  String get settingsSoundSection => 'आवाज़ और छुअन';

  @override
  String get settingsSoundEffects => 'आवाज़ें';

  @override
  String get settingsMusic => 'संगीत';

  @override
  String get settingsVibration => 'कंपन';

  @override
  String get settingsLookSection => 'रूप';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get themeSystem => 'ऑटो';

  @override
  String get settingsGentleMotion => 'धीमी हलचल';

  @override
  String get settingsGentleMotionHint => 'कम उछलने वाली एनिमेशन';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsPlaySection => 'खेल';

  @override
  String get settingsLittleKid => 'छोटे बच्चों का मोड';

  @override
  String get settingsLittleKidHint => 'धीमा, बड़ा, लंबा खेल';

  @override
  String get settingsHowToPlay => 'कैसे खेलें';

  @override
  String get settingsHowToPlayHint => 'चित्रों में छोटी सी गाइड';

  @override
  String get done => 'हो गया';

  @override
  String get htpPickTitle => 'एक खेल चुनो';

  @override
  String get htpPickBody =>
      'किसी खेल के कार्ड पर टैप करो, फिर \'शुरू करो\' दबाओ।';

  @override
  String get htpTapTitle => 'टैप वाले खेल';

  @override
  String get htpTapBody => 'हिलती चीज़ों को जल्दी से छुओ!';

  @override
  String get htpDragTitle => 'ड्रैग वाले खेल';

  @override
  String get htpDragBody =>
      'किसी चीज़ को पकड़ो, उंगली खिसकाओ और सही जगह पर छोड़ दो।';

  @override
  String get htpStarsTitle => 'सितारों से रत्न';

  @override
  String htpStarsBody(int points) {
    return 'हर सही चाल पर सितारे मिलते हैं। हर $points सितारे 1 रत्न बन जाते हैं!';
  }

  @override
  String get htpFreeTitle => 'मुफ़्त खेल';

  @override
  String htpFreeBody(int count) {
    return 'हर खेल रोज़ $count बार मुफ़्त है। उसके बाद हर बार 1 रत्न लगता है।';
  }

  @override
  String get htpFavTitle => 'पसंदीदा रखो';

  @override
  String get htpFavBody =>
      'किसी खेल के दिल पर टैप करो, वह \'पसंदीदा\' में मिलेगा।';

  @override
  String get htpNext => 'आगे';

  @override
  String get htpLetsPlay => 'चलो खेलें!';

  @override
  String htpStep(int current, int total) {
    return '$total में से कदम $current';
  }

  @override
  String get close => 'बंद करो';

  @override
  String get gameNotInHere => 'यहाँ नहीं!';

  @override
  String get gameWrongShape => 'गलत आकार!';

  @override
  String get gameTryAgain => 'फिर कोशिश करो!';

  @override
  String get gameNotHere => 'यहाँ नहीं!';

  @override
  String get gameNotThisOne => 'यह वाला नहीं!';

  @override
  String get gameSoClose => 'बस थोड़ा सा!';

  @override
  String get gamePerfect => 'एकदम सही!';

  @override
  String get gameOtherBucket => 'दूसरी बाल्टी!';

  @override
  String get gameShoot => 'फेंको!';

  @override
  String get gameTidyUp => 'सफ़ाई करो!';

  @override
  String get gameToys => 'खिलौने';

  @override
  String get gameBooks => 'किताबें';

  @override
  String get gameClothes => 'कपड़े';

  @override
  String gameOnlyLabel(String bin) {
    String _temp0 = intl.Intl.selectLogic(bin, {
      'toys': 'सिर्फ़ खिलौने!',
      'books': 'सिर्फ़ किताबें!',
      'other': 'सिर्फ़ कपड़े!',
    });
    return '$_temp0';
  }

  @override
  String get gameToyBox => 'खिलौने';

  @override
  String get gameApples => 'सेब';

  @override
  String get gameBananas => 'केले';

  @override
  String get gameOranges => 'संतरे';

  @override
  String gameCrateFor(String fruit) {
    String _temp0 = intl.Intl.selectLogic(fruit, {
      'apples': 'वह टोकरी सेब की है!',
      'bananas': 'वह टोकरी केलों की है!',
      'other': 'वह टोकरी संतरों की है!',
    });
    return '$_temp0';
  }

  @override
  String get gameOrder => 'ऑर्डर';

  @override
  String get gameFind => 'खोजो';

  @override
  String get gameMatchShapes => 'आकार मिलाओ!';

  @override
  String get gameMatchSocks => 'मोज़े मिलाओ!';

  @override
  String get gameFindTwin => 'इसका जोड़ा ढूँढो!';

  @override
  String get gameWatchBall => 'गेंद को देखो!';

  @override
  String get gameKeepWatching => 'देखते रहो...';

  @override
  String get gameWhereBall => 'गेंद कहाँ है?';

  @override
  String get gameFoundIt => 'मिल गई!';

  @override
  String get gameItWasHere => 'यह यहाँ थी!';

  @override
  String get gameGreatPattern => 'बढ़िया पैटर्न!';

  @override
  String get gameWhatNext => 'आगे क्या आएगा?';

  @override
  String progClean(int percent) {
    return '$percent% साफ़';
  }

  @override
  String progBalloons(int count) {
    return '$count गुब्बारे';
  }

  @override
  String progBalls(int count) {
    return '$count गेंदें';
  }

  @override
  String progTreasures(int count) {
    return '$count खज़ाने';
  }

  @override
  String progBaskets(int count) {
    return '$count बास्केट';
  }

  @override
  String progBlooms(int count) {
    return '$count फूल खिले';
  }

  @override
  String progButterflies(int count) {
    return '$count तितलियाँ';
  }

  @override
  String progFireflies(int count) {
    return '$count जुगनू';
  }

  @override
  String progFound(int count) {
    return '$count मिलीं';
  }

  @override
  String progMeals(int count) {
    return '$count बार खाना';
  }

  @override
  String progChicks(int count) {
    return '$count चूज़े';
  }

  @override
  String progFlowers(int count) {
    return '$count फूल';
  }

  @override
  String progOrders(int count) {
    return '$count ऑर्डर';
  }

  @override
  String progScoops(int count) {
    return '$count स्कूप';
  }

  @override
  String progGemsFound(int count) {
    return '$count रत्न मिले';
  }

  @override
  String progPatterns(int count) {
    return '$count पैटर्न';
  }

  @override
  String progSaved(int count) {
    return '$count बचाए';
  }

  @override
  String progLadybugs(int count) {
    return '$count लेडीबग';
  }

  @override
  String progCrossed(int count) {
    return '$count बार पार';
  }

  @override
  String progPearls(int count) {
    return '$count मोती';
  }

  @override
  String progYummyFish(int count) {
    return '$count मज़ेदार मछलियाँ';
  }

  @override
  String progFish(int count) {
    return '$count मछलियाँ';
  }

  @override
  String progShooed(int count) {
    return '$count भगाए';
  }

  @override
  String progDrops(int count) {
    return '$count बूँदें';
  }

  @override
  String progLanded(int count) {
    return '$count उतरे';
  }

  @override
  String progShapes(int count) {
    return '$count आकार';
  }

  @override
  String progPairs(int count) {
    return '$count जोड़े';
  }

  @override
  String progTidied(int count) {
    return '$count जमाए';
  }

  @override
  String progTurtles(int count) {
    return '$count कछुए सुरक्षित';
  }

  @override
  String progStars(int count) {
    return '$count सितारे';
  }

  @override
  String progWakeUps(int count) {
    return '$count बार जगाया';
  }

  @override
  String progWatered(int count) {
    return '$count को पानी दिया';
  }

  @override
  String get gamePondFishName => 'तालाब की मछलियाँ';

  @override
  String get gamePondFishGoal => 'मछलियों को टैप करके पकड़ो!';

  @override
  String get gamePondFishHowTo =>
      'तैरती मछली पर टैप करो और उसे टोकरी में डालो।';

  @override
  String get gameFlowerBasketName => 'फूलों की टोकरी';

  @override
  String get gameFlowerBasketGoal => 'खिलते ही फूल तोड़ो!';

  @override
  String get gameFlowerBasketHowTo =>
      'कली खुलने का इंतज़ार करो, फिर फूल पर टैप करो।';

  @override
  String get gameStarCollectorName => 'सितारे जमा करो';

  @override
  String get gameStarCollectorGoal => 'टिमटिमाते सितारे जमा करो!';

  @override
  String get gameStarCollectorHowTo =>
      'सितारों पर टैप करो। बड़े सुनहरे सितारे बहुत खास हैं!';

  @override
  String get gamePenguinFeastName => 'पेंगुइन की दावत';

  @override
  String get gamePenguinFeastGoal => 'भूखे नन्हे पेंगुइन को खाना खिलाओ!';

  @override
  String get gamePenguinFeastHowTo =>
      'उछलती मछली पर टैप करो, वह पेंगुइन के पास जाएगी।';

  @override
  String get gameFireflyName => 'जुगनू पकड़ो';

  @override
  String get gameFireflyGoal => 'रात के बगीचे को रोशन करो!';

  @override
  String get gameFireflyHowTo =>
      'चमकते जुगनुओं के उड़ने से पहले उन पर टैप करो।';

  @override
  String get gameBeachTreasuresName => 'समुद्र तट का खज़ाना';

  @override
  String get gameBeachTreasuresGoal => 'सीपियाँ और तारा मछली ढूँढो!';

  @override
  String get gameBeachTreasuresHowTo =>
      'रेत पर पड़े खज़ानों पर टैप करो। सुनहरी सीपियाँ बहुत खास हैं!';

  @override
  String get gameRaindropName => 'इंद्रधनुषी बूँदें';

  @override
  String get gameRaindropGoal => 'प्यासे दोस्त के लिए जार भरो!';

  @override
  String get gameRaindropHowTo => 'गिरती बूँदों पर टैप करके जार भरो।';

  @override
  String get gameRocketLaunchName => 'रॉकेट उड़ाओ';

  @override
  String get gameRocketLaunchGoal => 'रॉकेट को ग्रह पर उतारो!';

  @override
  String get gameRocketLaunchHowTo =>
      'जब तीर ग्रह की ओर हो, टैप करके रॉकेट छोड़ो!';

  @override
  String get gameBalloonParadeName => 'गुब्बारों की परेड';

  @override
  String get gameBalloonParadeGoal => 'उड़ते गुब्बारे फोड़ो!';

  @override
  String get gameBalloonParadeHowTo =>
      'गुब्बारों के उड़ जाने से पहले उन पर टैप करो।';

  @override
  String get gameBusyBeeName => 'मधुमक्खी का बगीचा';

  @override
  String get gameBusyBeeGoal => 'मधुमक्खियों के साथ फूल खिलाओ!';

  @override
  String get gameBusyBeeHowTo =>
      'जब मधुमक्खी कली पर बैठे, उस पर टैप करो और फूल खिलाओ।';

  @override
  String get gameHatchChickName => 'चूज़ा निकालो';

  @override
  String get gameHatchChickGoal => 'नन्हे चूज़ों को अंडे से निकालो!';

  @override
  String get gameHatchChickHowTo =>
      'हिलते अंडे पर कुछ बार टैप करो ताकि चूज़ा बाहर आए।';

  @override
  String get gameLadybugName => 'पत्ती पर लेडीबग';

  @override
  String get gameLadybugGoal => 'लेडीबग को पत्तियों से उड़ाओ!';

  @override
  String get gameLadybugHowTo =>
      'रेंगती लेडीबग पर टैप करो ताकि वह उड़ जाए। सुनहरी वाली बहुत खास हैं!';

  @override
  String get gameBasketballName => 'बास्केटबॉल चैलेंज';

  @override
  String get gameBasketballGoal => 'तीर से निशाना लगाकर बास्केट करो!';

  @override
  String get gameBasketballHowTo =>
      'जब तीर बास्केट की ओर हो, \'फेंको!\' पर टैप करो।';

  @override
  String get gameGemMineName => 'रत्न ढूँढो';

  @override
  String get gameGemMineGoal => 'डिब्बे तोड़कर रत्न ढूँढो!';

  @override
  String get gameGemMineHowTo =>
      'हथौड़े से डिब्बों पर टैप करो। जो डिब्बा निशान से मिलता है, उसमें रत्न है!';

  @override
  String get gameCupShuffleName => 'कप का खेल';

  @override
  String get gameCupShuffleGoal => 'कप के नीचे गेंद ढूँढो!';

  @override
  String get gameCupShuffleHowTo =>
      'गेंद को देखो, उसके कप पर नज़र रखो, फिर जहाँ वह छिपी है वहाँ टैप करो।';

  @override
  String get gamePatternEggsName => 'अंडों का पैटर्न';

  @override
  String get gamePatternEggsGoal => 'अगला अंडा ढूँढो!';

  @override
  String get gamePatternEggsHowTo =>
      'अंडों का पैटर्न देखो, फिर अगले अंडे पर टैप करो।';

  @override
  String get gameCleanRoomName => 'मेरा कमरा साफ़ करो';

  @override
  String get gameCleanRoomGoal => 'खिलौने, किताबें और कपड़े जगह पर रखो!';

  @override
  String get gameCleanRoomHowTo =>
      'बिखरी चीज़ पर टैप करके उसे जमाओ, या \'ड्रैग\' चुनकर उसे उसकी जगह ले जाओ।';

  @override
  String get gameButterflyName => 'तितली पकड़ो';

  @override
  String get gameButterflyGoal => 'तितलियों को उनके बगीचे तक पहुँचाओ!';

  @override
  String get gameButterflyHowTo =>
      'उड़ती तितली पर टैप करो, वह बगीचे में चली जाएगी।';

  @override
  String get gameWakeOwlsName => 'जागो, नन्हे उल्लू';

  @override
  String get gameWakeOwlsGoal => 'सोते उल्लुओं को जगाओ!';

  @override
  String get gameWakeOwlsHowTo =>
      'सोते उल्लू पर टैप करके उसे जगाओ और उड़ते देखो।';

  @override
  String get gameTurtleRescueName => 'नन्हे कछुए बचाओ';

  @override
  String get gameTurtleRescueGoal =>
      'नन्हे कछुओं को मूंगे की चट्टान तक पहुँचाओ!';

  @override
  String get gameTurtleRescueHowTo =>
      'नन्हे कछुए पर टैप करो, वह तैरकर अपने घर मूंगे की चट्टान तक जाएगा।';

  @override
  String get gamePearlDiverName => 'मोती गोताखोर';

  @override
  String get gamePearlDiverGoal => 'सीपियों से मोती जमा करो!';

  @override
  String get gamePearlDiverHowTo => 'जब सीप खुले और मोती दिखे, उस पर टैप करो!';

  @override
  String get gameIceCreamName => 'आइसक्रीम पकड़ो';

  @override
  String get gameIceCreamGoal => 'गिरते स्कूप पकड़ो!';

  @override
  String get gameIceCreamHowTo =>
      'हर स्कूप पकड़ने के लिए कोन को दाएँ-बाएँ खिसकाओ।';

  @override
  String get gameJellyfishName => 'चमकती जेलीफ़िश';

  @override
  String get gameJellyfishGoal => 'नन्हे गोताखोर को जेलीफ़िश से बचाओ!';

  @override
  String get gameJellyfishHowTo =>
      'हर चमकती जेलीफ़िश को स्क्रीन से बाहर खींचो और समुद्र रोशन करो।';

  @override
  String get gameBouncyBallsName => 'उछलती गेंदें';

  @override
  String get gameBouncyBallsGoal => 'हर गेंद को उसकी बाल्टी में डालो!';

  @override
  String get gameBouncyBallsHowTo =>
      'उछलती गेंद पकड़ो और उसी रंग की बाल्टी में छोड़ दो।';

  @override
  String get gameFruitMarketName => 'फलों का बाज़ार';

  @override
  String get gameFruitMarketGoal => 'फलों को सही टोकरी में रखो!';

  @override
  String get gameFruitMarketHowTo =>
      'ऑर्डर पूरा करने के लिए हर फल को उसकी टोकरी में खींचो।';

  @override
  String get gameTidyUpName => 'सफ़ाई का समय';

  @override
  String get gameTidyUpGoal => 'खिलौने, किताबें और कपड़े जगह पर रखो!';

  @override
  String get gameTidyUpHowTo => 'हर चीज़ को उसके नाम वाली जगह पर खींचो।';

  @override
  String get gameShapeBoxName => 'आकारों का डिब्बा';

  @override
  String get gameShapeBoxGoal => 'हर आकार को उसके छेद में डालो!';

  @override
  String get gameShapeBoxHowTo =>
      'गोले, चौकोर और त्रिकोण को उनके जैसे छेदों में खींचो।';

  @override
  String get gameSockPairsName => 'मोज़ों के जोड़े';

  @override
  String get gameSockPairsGoal => 'हर मोज़े का जोड़ा ढूँढो!';

  @override
  String get gameSockPairsHowTo =>
      'हर मोज़े को उस दराज़ में खींचो जिसमें उसका जोड़ीदार मोज़ा है।';

  @override
  String get gameWaterPlantsName => 'पौधों को पानी दो';

  @override
  String get gameWaterPlantsGoal => 'प्यासे पौधों को पानी देकर खिलाओ!';

  @override
  String get gameWaterPlantsHowTo =>
      'पानी का डिब्बा प्यासे पौधे के ऊपर ले जाओ और वहीं रोके रखो।';

  @override
  String get gameFeedPenguinName => 'पेंगुइन को खिलाओ';

  @override
  String get gameFeedPenguinGoal => 'पेंगुइन को उसकी पसंद की सारी मछलियाँ दो!';

  @override
  String get gameFeedPenguinHowTo =>
      'बाल्टी से मछली खींचकर भूखे पेंगुइन तक ले जाओ।';

  @override
  String get gamePondPathName => 'तालाब का रास्ता';

  @override
  String get gamePondPathGoal => 'मेंढक के लिए पत्थरों का रास्ता बनाओ!';

  @override
  String get gamePondPathHowTo => 'हर पत्थर को उसी आकार की खाली जगह में खींचो।';

  @override
  String get gameSleepingMonsterName => 'राक्षस को मत जगाओ';

  @override
  String get gameSleepingMonsterGoal => 'बच्चों को भगाओ, वरना पापा जाग जाएँगे!';

  @override
  String get gameSleepingMonsterHowTo =>
      'नन्हे राक्षसों को सोते राक्षस को छूने से पहले स्क्रीन से बाहर खींचो या झटको।';
}
