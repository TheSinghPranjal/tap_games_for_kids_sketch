// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TinyThink';

  @override
  String get homeTitleLine1 => 'Touche et Glisse';

  @override
  String get homeTitleLine2 => 'Jeux';

  @override
  String get homeTitleSemantics => 'Jeux à toucher et glisser';

  @override
  String get homePlayGames => 'Jouer';

  @override
  String get homeRewards => 'Récompenses';

  @override
  String get rewardsTitle => 'Mes récompenses';

  @override
  String get rewardsGemsSaved => 'gemmes gardées';

  @override
  String rewardsStarsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles aujourd\'hui',
      one: '1 étoile aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String rewardsStarsPerGem(int points) {
    return 'Toutes les $points étoiles = 1 gemme';
  }

  @override
  String rewardsFreePlaysPerDay(int count) {
    return '$count parties gratuites par jeu chaque jour';
  }

  @override
  String get rewardsYay => 'Youpi !';

  @override
  String get hubTitle => 'Touche et Glisse';

  @override
  String get hubSubtitle => 'Choisis un jeu et joue !';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterTap => 'Toucher';

  @override
  String get filterDrag => 'Glisser';

  @override
  String get filterFavorites => 'Favoris';

  @override
  String get interactionTap => 'Toucher';

  @override
  String get interactionDrag => 'Glisser';

  @override
  String get interactionTapDrag => 'Toucher + Glisser';

  @override
  String get favoriteAdd => 'Ajouter aux favoris';

  @override
  String get favoriteRemove => 'Retirer des favoris';

  @override
  String freePlaysLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count parties gratuites aujourd\'hui',
      one: 'Encore 1 partie gratuite aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String get nextPlayCostsGem => 'La prochaine partie coûte 1 gemme';

  @override
  String get play => 'Jouer';

  @override
  String get resting => 'En pause';

  @override
  String get favoritesEmpty =>
      'Touche un cœur pour garder tes jeux préférés ici !';

  @override
  String get moreDragGamesSoon => 'D\'autres jeux à glisser arrivent bientôt !';

  @override
  String get back => 'Retour';

  @override
  String get settings => 'Réglages';

  @override
  String gemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gemmes',
      one: '1 gemme',
    );
    return '$_temp0';
  }

  @override
  String get noGemsTitle => 'Pas de gemmes pour l\'instant';

  @override
  String noGemsBody(int count) {
    return 'Tu as utilisé tes $count parties gratuites de ce jeu aujourd\'hui. Gagne des gemmes dans d\'autres jeux, ou reviens demain !';
  }

  @override
  String get restingTitle => 'Ce jeu se repose';

  @override
  String get restingBody => 'Essaie un autre jeu pour l\'instant !';

  @override
  String get oops => 'Oups !';

  @override
  String get startFailedBody =>
      'Un problème est survenu. Aucune gemme n\'a été utilisée. Réessaie.';

  @override
  String get playAgainTitle => 'Rejouer ?';

  @override
  String get playAgainBody =>
      'Plus de parties gratuites aujourd\'hui.\nCette manche coûte 1 gemme.';

  @override
  String get youHave => 'Tu as ';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get useOneGem => 'Utiliser 1 ';

  @override
  String get backToGames => 'Retour aux jeux';

  @override
  String get ok => 'OK';

  @override
  String get freePlaysToday => 'Parties gratuites aujourd\'hui';

  @override
  String freePlaysRemaining(int remaining, int total) {
    return 'Encore $remaining sur $total';
  }

  @override
  String get nextRoundUsesGem => 'La prochaine manche coûte 1 gemme';

  @override
  String get comeBackTomorrow =>
      'Reviens demain pour d\'autres parties gratuites !';

  @override
  String get gameRestingNow => 'Ce jeu se repose en ce moment';

  @override
  String get start => 'Commencer';

  @override
  String get startWithGem => 'Commencer  1';

  @override
  String get pause => 'Pause';

  @override
  String get paused => 'En pause';

  @override
  String get keepPlaying => 'Continuer';

  @override
  String get soundOn => 'Son activé';

  @override
  String get soundOff => 'Son coupé';

  @override
  String get games => 'Jeux';

  @override
  String get progressSaved => 'Tes étoiles et gemmes sont gardées.';

  @override
  String get cheerAmazing => 'Génial !';

  @override
  String get cheerGreat => 'Bravo !';

  @override
  String get cheerNice => 'Bien joué !';

  @override
  String scoreToEarnGem(int points) {
    return 'Marque $points pour gagner une gemme !';
  }

  @override
  String youEarnedGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tu as gagné $count gemmes !',
      one: 'Tu as gagné 1 gemme !',
    );
    return '$_temp0';
  }

  @override
  String get myGems => 'Mes gemmes';

  @override
  String get again => 'Encore';

  @override
  String get freePlaysDone =>
      'Les parties gratuites sont finies pour aujourd\'hui.';

  @override
  String get creditBy => 'par';

  @override
  String get settingsSoundSection => 'Son et toucher';

  @override
  String get settingsSoundEffects => 'Effets sonores';

  @override
  String get settingsMusic => 'Musique';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get settingsLookSection => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Auto';

  @override
  String get settingsGentleMotion => 'Mouvements doux';

  @override
  String get settingsGentleMotionHint => 'moins d\'animations rebondissantes';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsPlaySection => 'Jeu';

  @override
  String get settingsLittleKid => 'Mode tout-petits';

  @override
  String get settingsLittleKidHint =>
      'plus lent, plus grand, manches plus longues';

  @override
  String get settingsHowToPlay => 'Comment jouer';

  @override
  String get settingsHowToPlayHint => 'un petit guide en images';

  @override
  String get done => 'Terminé';

  @override
  String get htpPickTitle => 'Choisis un jeu';

  @override
  String get htpPickBody =>
      'Touche la carte d\'un jeu, puis appuie sur Commencer.';

  @override
  String get htpTapTitle => 'Jeux à toucher';

  @override
  String get htpTapBody => 'Touche vite les choses qui bougent !';

  @override
  String get htpDragTitle => 'Jeux à glisser';

  @override
  String get htpDragBody =>
      'Garde le doigt sur un objet, fais-le glisser et lâche-le au bon endroit.';

  @override
  String get htpStarsTitle => 'Étoiles et gemmes';

  @override
  String htpStarsBody(int points) {
    return 'Chaque bon geste te donne des étoiles. Toutes les $points étoiles deviennent 1 gemme !';
  }

  @override
  String get htpFreeTitle => 'Parties gratuites';

  @override
  String htpFreeBody(int count) {
    return 'Chaque jeu a $count parties gratuites par jour. Ensuite, une manche coûte 1 gemme.';
  }

  @override
  String get htpFavTitle => 'Garde tes favoris';

  @override
  String get htpFavBody =>
      'Touche le cœur d\'un jeu pour le retrouver vite dans Favoris.';

  @override
  String get htpNext => 'Suivant';

  @override
  String get htpLetsPlay => 'On joue !';

  @override
  String htpStep(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get close => 'Fermer';

  @override
  String get gameNotInHere => 'Pas ici !';

  @override
  String get gameWrongShape => 'Mauvaise forme !';

  @override
  String get gameTryAgain => 'Essaie encore !';

  @override
  String get gameNotHere => 'Pas ici !';

  @override
  String get gameNotThisOne => 'Pas celle-là !';

  @override
  String get gameSoClose => 'Presque !';

  @override
  String get gamePerfect => 'Parfait !';

  @override
  String get gameOtherBucket => 'L\'autre seau !';

  @override
  String get gameShoot => 'Tire !';

  @override
  String get gameTidyUp => 'On range !';

  @override
  String get gameToys => 'Jouets';

  @override
  String get gameBooks => 'Livres';

  @override
  String get gameClothes => 'Habits';

  @override
  String gameOnlyLabel(String bin) {
    String _temp0 = intl.Intl.selectLogic(bin, {
      'toys': 'Que des jouets !',
      'books': 'Que des livres !',
      'other': 'Que des habits !',
    });
    return '$_temp0';
  }

  @override
  String get gameToyBox => 'JOUETS';

  @override
  String get gameApples => 'Pommes';

  @override
  String get gameBananas => 'Bananes';

  @override
  String get gameOranges => 'Oranges';

  @override
  String gameCrateFor(String fruit) {
    String _temp0 = intl.Intl.selectLogic(fruit, {
      'apples': 'Cette caisse est pour les pommes !',
      'bananas': 'Cette caisse est pour les bananes !',
      'other': 'Cette caisse est pour les oranges !',
    });
    return '$_temp0';
  }

  @override
  String get gameOrder => 'Commande';

  @override
  String get gameFind => 'Trouve';

  @override
  String get gameMatchShapes => 'Assortis les formes !';

  @override
  String get gameMatchSocks => 'Assortis les chaussettes !';

  @override
  String get gameFindTwin => 'Trouve sa jumelle !';

  @override
  String get gameWatchBall => 'Regarde la balle !';

  @override
  String get gameKeepWatching => 'Regarde bien...';

  @override
  String get gameWhereBall => 'Où est la balle ?';

  @override
  String get gameFoundIt => 'Trouvée !';

  @override
  String get gameItWasHere => 'Elle était là !';

  @override
  String get gameGreatPattern => 'Super motif !';

  @override
  String get gameWhatNext => 'Et ensuite ?';

  @override
  String progClean(int percent) {
    return '$percent % propre';
  }

  @override
  String progBalloons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ballons',
      one: '1 ballon',
    );
    return '$_temp0';
  }

  @override
  String progBalls(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count balles',
      one: '1 balle',
    );
    return '$_temp0';
  }

  @override
  String progTreasures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trésors',
      one: '1 trésor',
    );
    return '$_temp0';
  }

  @override
  String progBaskets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paniers',
      one: '1 panier',
    );
    return '$_temp0';
  }

  @override
  String progBlooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fleurs',
      one: '1 fleur',
    );
    return '$_temp0';
  }

  @override
  String progButterflies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count papillons',
      one: '1 papillon',
    );
    return '$_temp0';
  }

  @override
  String progFireflies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lucioles',
      one: '1 luciole',
    );
    return '$_temp0';
  }

  @override
  String progFound(int count) {
    return '$count trouvées';
  }

  @override
  String progMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repas',
      one: '1 repas',
    );
    return '$_temp0';
  }

  @override
  String progChicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count poussins',
      one: '1 poussin',
    );
    return '$_temp0';
  }

  @override
  String progFlowers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fleurs',
      one: '1 fleur',
    );
    return '$_temp0';
  }

  @override
  String progOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commandes',
      one: '1 commande',
    );
    return '$_temp0';
  }

  @override
  String progScoops(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boules',
      one: '1 boule',
    );
    return '$_temp0';
  }

  @override
  String progGemsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gemmes',
      one: '1 gemme',
    );
    return '$_temp0';
  }

  @override
  String progPatterns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count motifs',
      one: '1 motif',
    );
    return '$_temp0';
  }

  @override
  String progSaved(int count) {
    return '$count sauvés';
  }

  @override
  String progLadybugs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count coccinelles',
      one: '1 coccinelle',
    );
    return '$_temp0';
  }

  @override
  String progCrossed(int count) {
    return '$count traversées';
  }

  @override
  String progPearls(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perles',
      one: '1 perle',
    );
    return '$_temp0';
  }

  @override
  String progYummyFish(int count) {
    return '$count bons poissons';
  }

  @override
  String progFish(int count) {
    return '$count poissons';
  }

  @override
  String progShooed(int count) {
    return '$count chassés';
  }

  @override
  String progDrops(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gouttes',
      one: '1 goutte',
    );
    return '$_temp0';
  }

  @override
  String progLanded(int count) {
    return '$count atterrissages';
  }

  @override
  String progShapes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count formes',
      one: '1 forme',
    );
    return '$_temp0';
  }

  @override
  String progPairs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paires',
      one: '1 paire',
    );
    return '$_temp0';
  }

  @override
  String progTidied(int count) {
    return '$count rangés';
  }

  @override
  String progTurtles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tortues sauvées',
      one: '1 tortue sauvée',
    );
    return '$_temp0';
  }

  @override
  String progStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles',
      one: '1 étoile',
    );
    return '$_temp0';
  }

  @override
  String progWakeUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réveils',
      one: '1 réveil',
    );
    return '$_temp0';
  }

  @override
  String progWatered(int count) {
    return '$count arrosées';
  }

  @override
  String get gamePondFishName => 'Pêche à l\'étang';

  @override
  String get gamePondFishGoal => 'Touche les poissons pour les attraper !';

  @override
  String get gamePondFishHowTo =>
      'Touche un poisson qui nage pour le mettre dans le panier.';

  @override
  String get gameFlowerBasketName => 'Panier de fleurs';

  @override
  String get gameFlowerBasketGoal =>
      'Cueille les fleurs quand elles s\'ouvrent !';

  @override
  String get gameFlowerBasketHowTo =>
      'Attends qu\'un bouton s\'ouvre, puis touche la fleur.';

  @override
  String get gameStarCollectorName => 'Attrape-étoiles';

  @override
  String get gameStarCollectorGoal => 'Ramasse les étoiles qui scintillent !';

  @override
  String get gameStarCollectorHowTo =>
      'Touche les étoiles. Les grandes étoiles dorées sont très spéciales !';

  @override
  String get gamePenguinFeastName => 'Festin du pingouin';

  @override
  String get gamePenguinFeastGoal => 'Nourris le bébé pingouin affamé !';

  @override
  String get gamePenguinFeastHowTo =>
      'Touche un poisson qui saute pour l\'envoyer au pingouin.';

  @override
  String get gameFireflyName => 'Attrape-lucioles';

  @override
  String get gameFireflyGoal => 'Illumine le jardin de nuit !';

  @override
  String get gameFireflyHowTo =>
      'Touche les lucioles brillantes avant qu\'elles s\'envolent.';

  @override
  String get gameBeachTreasuresName => 'Trésors de la plage';

  @override
  String get gameBeachTreasuresGoal =>
      'Trouve des coquillages et des étoiles de mer !';

  @override
  String get gameBeachTreasuresHowTo =>
      'Touche les trésors sur le sable. Les coquillages dorés sont très spéciaux !';

  @override
  String get gameRaindropName => 'Gouttes arc-en-ciel';

  @override
  String get gameRaindropGoal => 'Remplis le bocal pour un ami assoiffé !';

  @override
  String get gameRaindropHowTo =>
      'Touche les gouttes qui tombent pour remplir le bocal.';

  @override
  String get gameRocketLaunchName => 'Décollage';

  @override
  String get gameRocketLaunchGoal => 'Pose les fusées sur la planète !';

  @override
  String get gameRocketLaunchHowTo =>
      'Quand la flèche vise la planète, touche pour décoller !';

  @override
  String get gameBalloonParadeName => 'Parade de ballons';

  @override
  String get gameBalloonParadeGoal => 'Éclate les ballons qui flottent !';

  @override
  String get gameBalloonParadeHowTo =>
      'Touche les ballons avant qu\'ils s\'envolent.';

  @override
  String get gameBusyBeeName => 'Jardin des abeilles';

  @override
  String get gameBusyBeeGoal => 'Aide les abeilles à faire fleurir !';

  @override
  String get gameBusyBeeHowTo =>
      'Touche une abeille quand elle visite un bouton pour faire éclore la fleur.';

  @override
  String get gameHatchChickName => 'Éclos, poussin';

  @override
  String get gameHatchChickGoal => 'Aide les poussins à éclore !';

  @override
  String get gameHatchChickHowTo =>
      'Touche plusieurs fois l\'œuf qui bouge pour aider le poussin à sortir.';

  @override
  String get gameLadybugName => 'Coccinelles sur la feuille';

  @override
  String get gameLadybugGoal => 'Aide les coccinelles à s\'envoler !';

  @override
  String get gameLadybugHowTo =>
      'Touche une coccinelle qui marche pour l\'aider à voler. Les dorées sont très spéciales !';

  @override
  String get gameBasketballName => 'Défi panier de basket';

  @override
  String get gameBasketballGoal => 'Marque des paniers avec la flèche !';

  @override
  String get gameBasketballHowTo =>
      'Quand la flèche vise un panier, touche Tire !';

  @override
  String get gameGemMineName => 'Trouve la gemme';

  @override
  String get gameGemMineGoal => 'Casse les caisses pour trouver la gemme !';

  @override
  String get gameGemMineHowTo =>
      'Touche les caisses avec le marteau. Celle qui ressemble au panneau cache la gemme !';

  @override
  String get gameCupShuffleName => 'Le jeu des gobelets';

  @override
  String get gameCupShuffleGoal => 'Trouve la balle sous le gobelet !';

  @override
  String get gameCupShuffleHowTo =>
      'Regarde la balle, suis son gobelet, puis touche là où elle se cache.';

  @override
  String get gamePatternEggsName => 'Chasse aux œufs';

  @override
  String get gamePatternEggsGoal => 'Trouve l\'œuf qui vient ensuite !';

  @override
  String get gamePatternEggsHowTo =>
      'Regarde la suite d\'œufs, puis touche l\'œuf qui vient après.';

  @override
  String get gameCleanRoomName => 'Range ma chambre';

  @override
  String get gameCleanRoomGoal =>
      'Range les jouets, les livres et les habits !';

  @override
  String get gameCleanRoomHowTo =>
      'Touche un objet en désordre pour le ranger, ou passe à Glisser et ramène-le à sa place.';

  @override
  String get gameButterflyName => 'Attrape-papillons';

  @override
  String get gameButterflyGoal => 'Guide les papillons vers leur jardin !';

  @override
  String get gameButterflyHowTo =>
      'Touche un papillon qui volette pour l\'envoyer au jardin.';

  @override
  String get gameWakeOwlsName => 'Réveillez-vous, hiboux';

  @override
  String get gameWakeOwlsGoal => 'Réveille les hiboux endormis !';

  @override
  String get gameWakeOwlsHowTo =>
      'Touche un hibou qui dort pour le réveiller et le voir voler.';

  @override
  String get gameTurtleRescueName => 'Sauvetage des tortues';

  @override
  String get gameTurtleRescueGoal =>
      'Aide les bébés tortues à rejoindre le récif !';

  @override
  String get gameTurtleRescueHowTo =>
      'Touche un bébé tortue et il nagera jusqu\'au récif de corail.';

  @override
  String get gamePearlDiverName => 'Pêcheur de perles';

  @override
  String get gamePearlDiverGoal => 'Ramasse les perles des coquillages !';

  @override
  String get gamePearlDiverHowTo =>
      'Quand un coquillage s\'ouvre et montre sa perle, touche-le !';

  @override
  String get gameIceCreamName => 'Attrape la glace';

  @override
  String get gameIceCreamGoal => 'Attrape les boules qui tombent !';

  @override
  String get gameIceCreamHowTo =>
      'Fais glisser le cornet à gauche et à droite pour attraper chaque boule.';

  @override
  String get gameJellyfishName => 'Méduses lumineuses';

  @override
  String get gameJellyfishGoal => 'Sauve le bébé plongeur des méduses !';

  @override
  String get gameJellyfishHowTo =>
      'Fais glisser chaque méduse lumineuse hors de l\'écran pour éclairer la mer.';

  @override
  String get gameBouncyBallsName => 'Balles rebondissantes';

  @override
  String get gameBouncyBallsGoal => 'Mets chaque balle dans son seau !';

  @override
  String get gameBouncyBallsHowTo =>
      'Attrape une balle qui rebondit et lâche-la dans le seau de la même couleur.';

  @override
  String get gameFruitMarketName => 'Marché aux fruits';

  @override
  String get gameFruitMarketGoal => 'Trie les fruits dans les bonnes caisses !';

  @override
  String get gameFruitMarketHowTo =>
      'Fais glisser chaque fruit dans sa caisse pour remplir la commande.';

  @override
  String get gameTidyUpName => 'L\'heure du rangement';

  @override
  String get gameTidyUpGoal => 'Range les jouets, les livres et les habits !';

  @override
  String get gameTidyUpHowTo =>
      'Fais glisser chaque objet vers l\'endroit avec son étiquette.';

  @override
  String get gameShapeBoxName => 'Boîte à formes';

  @override
  String get gameShapeBoxGoal => 'Mets chaque forme dans son trou !';

  @override
  String get gameShapeBoxHowTo =>
      'Fais glisser les cercles, carrés et triangles dans les bons trous.';

  @override
  String get gameSockPairsName => 'Paires de chaussettes';

  @override
  String get gameSockPairsGoal => 'Trouve la jumelle de chaque chaussette !';

  @override
  String get gameSockPairsHowTo =>
      'Fais glisser chaque chaussette dans le tiroir avec sa jumelle.';

  @override
  String get gameWaterPlantsName => 'Arrose les plantes';

  @override
  String get gameWaterPlantsGoal =>
      'Arrose les plantes assoiffées pour qu\'elles fleurissent !';

  @override
  String get gameWaterPlantsHowTo =>
      'Fais glisser l\'arrosoir au-dessus d\'une plante assoiffée et garde-le là.';

  @override
  String get gameFeedPenguinName => 'Nourris le pingouin';

  @override
  String get gameFeedPenguinGoal =>
      'Donne au pingouin tous les poissons qu\'il veut !';

  @override
  String get gameFeedPenguinHowTo =>
      'Fais glisser les poissons du seau jusqu\'au pingouin affamé.';

  @override
  String get gamePondPathName => 'Le chemin de l\'étang';

  @override
  String get gamePondPathGoal =>
      'Construis un chemin de pierres pour la grenouille !';

  @override
  String get gamePondPathHowTo =>
      'Fais glisser chaque pierre dans le trou de la même forme.';

  @override
  String get gameSleepingMonsterName => 'Ne réveille pas le monstre';

  @override
  String get gameSleepingMonsterGoal =>
      'Chasse les petits avant qu\'ils réveillent papa !';

  @override
  String get gameSleepingMonsterHowTo =>
      'Fais glisser les bébés monstres hors de l\'écran avant qu\'ils touchent le monstre endormi.';
}
