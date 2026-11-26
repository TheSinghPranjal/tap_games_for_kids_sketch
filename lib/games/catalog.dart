import '../core/engine/game_definition.dart';
import 'balloon_parade.dart';
import 'basketball.dart';
import 'beach_treasures.dart';
import 'bouncy_balls.dart';
import 'busy_bee.dart';
import 'butterfly_catch.dart';
import 'clean_room.dart';
import 'feed_penguin.dart';
import 'cup_shuffle.dart';
import 'firefly_catcher.dart';
import 'flower_basket.dart';
import 'fruit_market.dart';
import 'gem_mine.dart';
import 'hatch_chick.dart';
import 'ice_cream_catch.dart';
import 'jellyfish_glow.dart';
import 'ladybug_leaf.dart';
import 'pattern_eggs.dart';
import 'pearl_diver.dart';
import 'penguin_feast.dart';
import 'pond_fish.dart';
import 'pond_path.dart';
import 'raindrop_catch.dart';
import 'shape_box.dart';
import 'sleeping_monster.dart';
import 'sock_pairs.dart';
import 'rocket_launch.dart';
import 'star_collector.dart';
import 'tidy_up.dart';
import 'turtle_rescue.dart';
import 'wake_owls.dart';
import 'water_plants.dart';

/// Every game in the Tap & Drag hub. New tap or drag games only need a
/// GameDefinition here; the lifecycle and gem economy come for free.
final allGames = <GameDefinition>[
  pondFishGame,
  flowerBasketGame,
  starCollectorGame,
  penguinFeastGame,
  fireflyGame,
  beachTreasuresGame,
  raindropGame,
  rocketLaunchGame,
  balloonParadeGame,
  busyBeeGame,
  hatchChickGame,
  ladybugGame,
  basketballGame,
  gemMineGame,
  cupShuffleGame,
  patternEggGame,
  cleanRoomGame,
  butterflyGame,
  wakeOwlsGame,
  turtleRescueGame,
  pearlDiverGame,
  iceCreamCatchGame,
  jellyfishGlowGame,
  bouncyBallGame,
  fruitMarketGame,
  tidyUpGame,
  shapeBoxGame,
  sockPairGame,
  waterPlantsGame,
  feedPenguinGame,
  pondPathGame,
  sleepingMonsterGame,
];

void registerAllGames(GameRegistry registry) {
  for (final g in allGames) {
    registry.register(g);
  }
}
