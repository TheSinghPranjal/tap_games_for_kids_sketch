// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TinyThink';

  @override
  String get homeTitleLine1 => 'Toca y Arrastra';

  @override
  String get homeTitleLine2 => 'Juegos';

  @override
  String get homeTitleSemantics => 'Juegos de tocar y arrastrar';

  @override
  String get homePlayGames => '¡A\njugar!';

  @override
  String get homeRewards => 'Premios';

  @override
  String get rewardsTitle => 'Mis premios';

  @override
  String get rewardsGemsSaved => 'gemas guardadas';

  @override
  String rewardsStarsToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrellas hoy',
      one: '1 estrella hoy',
    );
    return '$_temp0';
  }

  @override
  String rewardsStarsPerGem(int points) {
    return 'Cada $points estrellas = 1 gema';
  }

  @override
  String rewardsFreePlaysPerDay(int count) {
    return '$count partidas gratis por juego cada día';
  }

  @override
  String get rewardsYay => '¡Bien!';

  @override
  String get hubTitle => 'Toca y Arrastra';

  @override
  String get hubSubtitle => '¡Elige un juego y juega!';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterTap => 'Tocar';

  @override
  String get filterDrag => 'Arrastrar';

  @override
  String get filterFavorites => 'Favoritos';

  @override
  String get interactionTap => 'Tocar';

  @override
  String get interactionDrag => 'Arrastrar';

  @override
  String get interactionTapDrag => 'Tocar + Arrastrar';

  @override
  String get favoriteAdd => 'Añadir a favoritos';

  @override
  String get favoriteRemove => 'Quitar de favoritos';

  @override
  String freePlaysLeftToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count partidas gratis hoy',
      one: 'Queda 1 partida gratis hoy',
    );
    return '$_temp0';
  }

  @override
  String get nextPlayCostsGem => 'La próxima partida cuesta 1 gema';

  @override
  String get play => 'Jugar';

  @override
  String get resting => 'Descansa';

  @override
  String get favoritesEmpty =>
      '¡Toca un corazón para guardar aquí tus juegos favoritos!';

  @override
  String get moreDragGamesSoon => '¡Pronto habrá más juegos de arrastrar!';

  @override
  String get back => 'Atrás';

  @override
  String get settings => 'Ajustes';

  @override
  String gemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gemas',
      one: '1 gema',
    );
    return '$_temp0';
  }

  @override
  String get noGemsTitle => 'Ahora no tienes gemas';

  @override
  String noGemsBody(int count) {
    return 'Ya usaste tus $count partidas gratis de este juego hoy. ¡Gana gemas en otros juegos o vuelve mañana!';
  }

  @override
  String get restingTitle => 'Este juego está descansando';

  @override
  String get restingBody => '¡Prueba otro juego por ahora!';

  @override
  String get oops => '¡Uy!';

  @override
  String get startFailedBody =>
      'Algo salió mal. No se usó ninguna gema. Inténtalo de nuevo.';

  @override
  String get playAgainTitle => '¿Jugar otra vez?';

  @override
  String get playAgainBody =>
      'Ya no quedan partidas gratis hoy.\nEsta ronda usa 1 gema.';

  @override
  String get youHave => 'Tienes ';

  @override
  String get notNow => 'Ahora no';

  @override
  String get useOneGem => 'Usar 1 ';

  @override
  String get backToGames => 'Volver a los juegos';

  @override
  String get ok => 'Vale';

  @override
  String get freePlaysToday => 'Partidas gratis hoy';

  @override
  String freePlaysRemaining(int remaining, int total) {
    return 'Quedan $remaining de $total';
  }

  @override
  String get nextRoundUsesGem => 'La próxima ronda usa 1 gema';

  @override
  String get comeBackTomorrow => '¡Vuelve mañana para más partidas gratis!';

  @override
  String get gameRestingNow => 'Este juego está descansando ahora';

  @override
  String get start => 'Empezar';

  @override
  String get startWithGem => 'Empezar  1';

  @override
  String get pause => 'Pausa';

  @override
  String get paused => 'En pausa';

  @override
  String get keepPlaying => 'Seguir jugando';

  @override
  String get soundOn => 'Sonido sí';

  @override
  String get soundOff => 'Sonido no';

  @override
  String get games => 'Juegos';

  @override
  String get progressSaved => 'Tus estrellas y gemas están guardadas.';

  @override
  String get cheerAmazing => '¡Increíble!';

  @override
  String get cheerGreat => '¡Muy bien!';

  @override
  String get cheerNice => '¡Bien jugado!';

  @override
  String scoreToEarnGem(int points) {
    return '¡Consigue $points para ganar una gema!';
  }

  @override
  String youEarnedGems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¡Ganaste $count gemas!',
      one: '¡Ganaste 1 gema!',
    );
    return '$_temp0';
  }

  @override
  String get myGems => 'Mis gemas';

  @override
  String get again => 'Otra vez';

  @override
  String get freePlaysDone => 'Se acabaron las partidas gratis de hoy.';

  @override
  String get creditBy => 'por';

  @override
  String get settingsSoundSection => 'Sonido y tacto';

  @override
  String get settingsSoundEffects => 'Efectos de sonido';

  @override
  String get settingsMusic => 'Música';

  @override
  String get settingsVibration => 'Vibración';

  @override
  String get settingsLookSection => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Auto';

  @override
  String get settingsGentleMotion => 'Movimiento suave';

  @override
  String get settingsGentleMotionHint => 'menos animaciones saltarinas';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsPlaySection => 'Juego';

  @override
  String get settingsLittleKid => 'Modo peques';

  @override
  String get settingsLittleKidHint =>
      'más lento, más grande, rondas más largas';

  @override
  String get settingsHowToPlay => 'Cómo jugar';

  @override
  String get settingsHowToPlayHint => 'una guía rápida con dibujos';

  @override
  String get done => 'Listo';

  @override
  String get htpPickTitle => 'Elige un juego';

  @override
  String get htpPickBody => 'Toca la tarjeta de un juego y pulsa Empezar.';

  @override
  String get htpTapTitle => 'Juegos de tocar';

  @override
  String get htpTapBody =>
      '¡Toca las cosas que se mueven lo más rápido que puedas!';

  @override
  String get htpDragTitle => 'Juegos de arrastrar';

  @override
  String get htpDragBody =>
      'Mantén algo pulsado, desliza el dedo y suéltalo en el sitio correcto.';

  @override
  String get htpStarsTitle => 'Estrellas y gemas';

  @override
  String htpStarsBody(int points) {
    return 'Cada buen movimiento te da estrellas. ¡Cada $points estrellas se convierten en 1 gema!';
  }

  @override
  String get htpFreeTitle => 'Partidas gratis';

  @override
  String htpFreeBody(int count) {
    return 'Cada juego tiene $count partidas gratis al día. Después, cada ronda usa 1 gema.';
  }

  @override
  String get htpFavTitle => 'Guarda favoritos';

  @override
  String get htpFavBody =>
      'Toca el corazón de un juego para encontrarlo rápido en Favoritos.';

  @override
  String get htpNext => 'Siguiente';

  @override
  String get htpLetsPlay => '¡A jugar!';

  @override
  String htpStep(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get gameNotInHere => '¡Aquí no!';

  @override
  String get gameWrongShape => '¡Forma equivocada!';

  @override
  String get gameTryAgain => '¡Otra vez!';

  @override
  String get gameNotHere => '¡Aquí no!';

  @override
  String get gameNotThisOne => '¡Ese no!';

  @override
  String get gameSoClose => '¡Casi!';

  @override
  String get gamePerfect => '¡Perfecto!';

  @override
  String get gameOtherBucket => '¡El otro cubo!';

  @override
  String get gameShoot => '¡Tira!';

  @override
  String get gameTidyUp => '¡A ordenar!';

  @override
  String get gameToys => 'Juguetes';

  @override
  String get gameBooks => 'Libros';

  @override
  String get gameClothes => 'Ropa';

  @override
  String gameOnlyLabel(String bin) {
    String _temp0 = intl.Intl.selectLogic(bin, {
      'toys': '¡Solo juguetes!',
      'books': '¡Solo libros!',
      'other': '¡Solo ropa!',
    });
    return '$_temp0';
  }

  @override
  String get gameToyBox => 'JUGUETES';

  @override
  String get gameApples => 'Manzanas';

  @override
  String get gameBananas => 'Plátanos';

  @override
  String get gameOranges => 'Naranjas';

  @override
  String gameCrateFor(String fruit) {
    String _temp0 = intl.Intl.selectLogic(fruit, {
      'apples': '¡Esa caja es de manzanas!',
      'bananas': '¡Esa caja es de plátanos!',
      'other': '¡Esa caja es de naranjas!',
    });
    return '$_temp0';
  }

  @override
  String get gameOrder => 'Pedido';

  @override
  String get gameFind => 'Busca';

  @override
  String get gameMatchShapes => '¡Une las formas!';

  @override
  String get gameMatchSocks => '¡Junta los calcetines!';

  @override
  String get gameFindTwin => '¡Busca su pareja!';

  @override
  String get gameWatchBall => '¡Mira la pelota!';

  @override
  String get gameKeepWatching => 'Sigue mirando...';

  @override
  String get gameWhereBall => '¿Dónde está la pelota?';

  @override
  String get gameFoundIt => '¡La encontraste!';

  @override
  String get gameItWasHere => '¡Estaba aquí!';

  @override
  String get gameGreatPattern => '¡Muy bien!';

  @override
  String get gameWhatNext => '¿Qué sigue?';

  @override
  String progClean(int percent) {
    return '$percent% limpio';
  }

  @override
  String progBalloons(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count globos',
      one: '1 globo',
    );
    return '$_temp0';
  }

  @override
  String progBalls(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pelotas',
      one: '1 pelota',
    );
    return '$_temp0';
  }

  @override
  String progTreasures(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tesoros',
      one: '1 tesoro',
    );
    return '$_temp0';
  }

  @override
  String progBaskets(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canastas',
      one: '1 canasta',
    );
    return '$_temp0';
  }

  @override
  String progBlooms(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flores',
      one: '1 flor',
    );
    return '$_temp0';
  }

  @override
  String progButterflies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mariposas',
      one: '1 mariposa',
    );
    return '$_temp0';
  }

  @override
  String progFireflies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count luciérnagas',
      one: '1 luciérnaga',
    );
    return '$_temp0';
  }

  @override
  String progFound(int count) {
    return '$count encontradas';
  }

  @override
  String progMeals(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comidas',
      one: '1 comida',
    );
    return '$_temp0';
  }

  @override
  String progChicks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pollitos',
      one: '1 pollito',
    );
    return '$_temp0';
  }

  @override
  String progFlowers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flores',
      one: '1 flor',
    );
    return '$_temp0';
  }

  @override
  String progOrders(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos',
      one: '1 pedido',
    );
    return '$_temp0';
  }

  @override
  String progScoops(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bolas',
      one: '1 bola',
    );
    return '$_temp0';
  }

  @override
  String progGemsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gemas',
      one: '1 gema',
    );
    return '$_temp0';
  }

  @override
  String progPatterns(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 serie',
    );
    return '$_temp0';
  }

  @override
  String progSaved(int count) {
    return '$count a salvo';
  }

  @override
  String progLadybugs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mariquitas',
      one: '1 mariquita',
    );
    return '$_temp0';
  }

  @override
  String progCrossed(int count) {
    return '$count cruces';
  }

  @override
  String progPearls(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count perlas',
      one: '1 perla',
    );
    return '$_temp0';
  }

  @override
  String progYummyFish(int count) {
    return '$count peces ricos';
  }

  @override
  String progFish(int count) {
    return '$count peces';
  }

  @override
  String progShooed(int count) {
    return '$count espantados';
  }

  @override
  String progDrops(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gotas',
      one: '1 gota',
    );
    return '$_temp0';
  }

  @override
  String progLanded(int count) {
    return '$count aterrizajes';
  }

  @override
  String progShapes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count formas',
      one: '1 forma',
    );
    return '$_temp0';
  }

  @override
  String progPairs(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pares',
      one: '1 par',
    );
    return '$_temp0';
  }

  @override
  String progTidied(int count) {
    return '$count ordenados';
  }

  @override
  String progTurtles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tortugas a salvo',
      one: '1 tortuga a salvo',
    );
    return '$_temp0';
  }

  @override
  String progStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrellas',
      one: '1 estrella',
    );
    return '$_temp0';
  }

  @override
  String progWakeUps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count despertares',
      one: '1 despertar',
    );
    return '$_temp0';
  }

  @override
  String progWatered(int count) {
    return '$count regadas';
  }

  @override
  String get gamePondFishName => 'Pesca en el estanque';

  @override
  String get gamePondFishGoal => '¡Toca los peces para atraparlos!';

  @override
  String get gamePondFishHowTo =>
      'Toca un pez que nada para meterlo en la cesta.';

  @override
  String get gameFlowerBasketName => 'Cesta de flores';

  @override
  String get gameFlowerBasketGoal => '¡Recoge las flores cuando se abran!';

  @override
  String get gameFlowerBasketHowTo =>
      'Espera a que se abra un capullo y toca la flor.';

  @override
  String get gameStarCollectorName => 'Cazaestrellas';

  @override
  String get gameStarCollectorGoal => '¡Junta estrellas brillantes!';

  @override
  String get gameStarCollectorHowTo =>
      'Toca las estrellas. ¡Las grandes doradas son muy especiales!';

  @override
  String get gamePenguinFeastName => 'Festín del pingüino';

  @override
  String get gamePenguinFeastGoal => '¡Alimenta al pingüino bebé hambriento!';

  @override
  String get gamePenguinFeastHowTo =>
      'Toca un pez que salta para enviárselo al pingüino.';

  @override
  String get gameFireflyName => 'Atrapa luciérnagas';

  @override
  String get gameFireflyGoal => '¡Ilumina el jardín de noche!';

  @override
  String get gameFireflyHowTo =>
      'Toca las luciérnagas brillantes antes de que se vayan volando.';

  @override
  String get gameBeachTreasuresName => 'Tesoros de la playa';

  @override
  String get gameBeachTreasuresGoal => '¡Encuentra conchas y estrellas de mar!';

  @override
  String get gameBeachTreasuresHowTo =>
      'Toca los tesoros en la arena. ¡Las conchas doradas son muy especiales!';

  @override
  String get gameRaindropName => 'Gotas de arcoíris';

  @override
  String get gameRaindropGoal => '¡Llena el frasco para un amigo con sed!';

  @override
  String get gameRaindropHowTo =>
      'Toca las gotas que caen para llenar el frasco.';

  @override
  String get gameRocketLaunchName => 'Lanza el cohete';

  @override
  String get gameRocketLaunchGoal => '¡Aterriza cohetes en el planeta!';

  @override
  String get gameRocketLaunchHowTo =>
      'Cuando la flecha apunte al planeta, ¡toca para lanzar!';

  @override
  String get gameBalloonParadeName => 'Desfile de globos';

  @override
  String get gameBalloonParadeGoal => '¡Revienta los globos que flotan!';

  @override
  String get gameBalloonParadeHowTo =>
      'Toca los globos antes de que se vayan flotando.';

  @override
  String get gameBusyBeeName => 'Jardín de abejas';

  @override
  String get gameBusyBeeGoal => '¡Ayuda a las abejas a abrir flores!';

  @override
  String get gameBusyBeeHowTo =>
      'Toca una abeja cuando visite un capullo para que la flor se abra.';

  @override
  String get gameHatchChickName => '¡Sal, pollito!';

  @override
  String get gameHatchChickGoal => '¡Ayuda a los pollitos a nacer!';

  @override
  String get gameHatchChickHowTo =>
      'Toca varias veces el huevo que se mueve para que salga el pollito.';

  @override
  String get gameLadybugName => 'Mariquitas en la hoja';

  @override
  String get gameLadybugGoal => '¡Ayuda a las mariquitas a volar!';

  @override
  String get gameLadybugHowTo =>
      'Toca una mariquita que camina para que vuele. ¡Las doradas son muy especiales!';

  @override
  String get gameBasketballName => 'Reto de canastas';

  @override
  String get gameBasketballGoal => '¡Encesta con la flecha!';

  @override
  String get gameBasketballHowTo =>
      'Cuando la flecha apunte a una canasta, ¡toca Tira!';

  @override
  String get gameGemMineName => 'Encuentra la gema';

  @override
  String get gameGemMineGoal => '¡Rompe cajas para encontrar la gema!';

  @override
  String get gameGemMineHowTo =>
      'Toca las cajas con el martillo. ¡La caja igual al cartel tiene la gema!';

  @override
  String get gameCupShuffleName => 'Los vasos mágicos';

  @override
  String get gameCupShuffleGoal => '¡Encuentra la pelota bajo el vaso!';

  @override
  String get gameCupShuffleHowTo =>
      'Mira la pelota, sigue su vaso y toca donde se esconde.';

  @override
  String get gamePatternEggsName => 'Huevos en serie';

  @override
  String get gamePatternEggsGoal => '¡Encuentra el huevo que sigue!';

  @override
  String get gamePatternEggsHowTo =>
      'Mira la serie de huevos y toca el huevo que va después.';

  @override
  String get gameCleanRoomName => 'Ordena mi cuarto';

  @override
  String get gameCleanRoomGoal => '¡Guarda juguetes, libros y ropa!';

  @override
  String get gameCleanRoomHowTo =>
      'Toca algo desordenado para guardarlo, o cambia a Arrastrar y llévalo a su sitio.';

  @override
  String get gameButterflyName => 'Atrapa mariposas';

  @override
  String get gameButterflyGoal => '¡Lleva las mariposas a su jardín!';

  @override
  String get gameButterflyHowTo =>
      'Toca una mariposa que revolotea para enviarla al jardín.';

  @override
  String get gameWakeOwlsName => '¡Despierten, buhitos!';

  @override
  String get gameWakeOwlsGoal => '¡Despierta a los búhos dormilones!';

  @override
  String get gameWakeOwlsHowTo =>
      'Toca un búho dormido para despertarlo y verlo volar.';

  @override
  String get gameTurtleRescueName => 'Rescate de tortuguitas';

  @override
  String get gameTurtleRescueGoal =>
      '¡Ayuda a las tortuguitas a llegar al arrecife!';

  @override
  String get gameTurtleRescueHowTo =>
      'Toca una tortuguita y nadará a casa, al arrecife de coral.';

  @override
  String get gamePearlDiverName => 'Buceo de perlas';

  @override
  String get gamePearlDiverGoal => '¡Recoge perlas de las conchas!';

  @override
  String get gamePearlDiverHowTo =>
      'Cuando una concha se abra y muestre su perla, ¡tócala!';

  @override
  String get gameIceCreamName => 'Atrapa helados';

  @override
  String get gameIceCreamGoal => '¡Atrapa las bolas que caen!';

  @override
  String get gameIceCreamHowTo =>
      'Arrastra el cucurucho a izquierda y derecha para atrapar cada bola.';

  @override
  String get gameJellyfishName => 'Medusas brillantes';

  @override
  String get gameJellyfishGoal => '¡Salva al buceador bebé de las medusas!';

  @override
  String get gameJellyfishHowTo =>
      'Arrastra cada medusa brillante fuera de la pantalla para iluminar el mar.';

  @override
  String get gameBouncyBallsName => 'Pelotas saltarinas';

  @override
  String get gameBouncyBallsGoal => '¡Lleva cada pelota a su cubo!';

  @override
  String get gameBouncyBallsHowTo =>
      'Agarra una pelota que bota y suéltala en el cubo del mismo color.';

  @override
  String get gameFruitMarketName => 'Mercado de frutas';

  @override
  String get gameFruitMarketGoal => '¡Pon la fruta en la caja correcta!';

  @override
  String get gameFruitMarketHowTo =>
      'Arrastra cada fruta a su caja para completar el pedido.';

  @override
  String get gameTidyUpName => 'Hora de ordenar';

  @override
  String get gameTidyUpGoal => '¡Guarda juguetes, libros y ropa!';

  @override
  String get gameTidyUpHowTo => 'Arrastra cada cosa al sitio con su etiqueta.';

  @override
  String get gameShapeBoxName => 'Caja de formas';

  @override
  String get gameShapeBoxGoal => '¡Mete cada forma en su hueco!';

  @override
  String get gameShapeBoxHowTo =>
      'Arrastra círculos, cuadrados y triángulos a los huecos iguales.';

  @override
  String get gameSockPairsName => 'Parejas de calcetines';

  @override
  String get gameSockPairsGoal => '¡Encuentra la pareja de cada calcetín!';

  @override
  String get gameSockPairsHowTo =>
      'Arrastra cada calcetín al cajón con el calcetín igual.';

  @override
  String get gameWaterPlantsName => 'Riega las plantas';

  @override
  String get gameWaterPlantsGoal =>
      '¡Riega las plantas con sed para que florezcan!';

  @override
  String get gameWaterPlantsHowTo =>
      'Arrastra la regadera sobre una planta con sed y mantenla ahí.';

  @override
  String get gameFeedPenguinName => 'Dale de comer al pingüino';

  @override
  String get gameFeedPenguinGoal =>
      '¡Dale al pingüino todos los peces que quiera!';

  @override
  String get gameFeedPenguinHowTo =>
      'Arrastra peces del cubo al pingüino hambriento.';

  @override
  String get gamePondPathName => 'Camino del estanque';

  @override
  String get gamePondPathGoal => '¡Haz un camino de piedras para la rana!';

  @override
  String get gamePondPathHowTo =>
      'Arrastra cada piedra al hueco con la misma forma.';

  @override
  String get gameSleepingMonsterName => 'No despiertes al monstruo';

  @override
  String get gameSleepingMonsterGoal =>
      '¡Espanta a los bebés antes de que despierten a papá!';

  @override
  String get gameSleepingMonsterHowTo =>
      'Arrastra o desliza a los monstruitos fuera de la pantalla antes de que toquen al monstruo dormido.';
}
