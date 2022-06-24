import 'dart:math';

class AssetHelper {
  static final bgAsset = [
    "assets/images/a1.png",
    "assets/images/a2.png",
    "assets/images/a3.png",
    "assets/images/a4.png",
    "assets/images/a5.png",
    "assets/images/a6.png",
    "assets/images/a7.png",
    "assets/images/a8.png",
    "assets/images/a9.png",
  ];

  static final iconAsset = [
    "001-rope.svg",
    "001-sakura.svg",
    "002-nomad.svg",
    "002-tree.svg",
    "003-axe.svg",
    "003-banyan tree.svg",
    "004-fishing hook.svg",
    "004-pine tree.svg",
    "005-forest.svg",
    "005-pine tree.svg",
    "006-bow.svg",
    "006-cypress.svg",
    "007-pine tree.svg",
    "007-torch.svg",
    "008-deer.svg",
    "008-tree.svg",
    "009-spider.svg",
    "009-tree.svg",
    "010-pine tree.svg",
    "010-tent.svg",
    "011-fire.svg",
    "011-tree.svg",
    "012-dead tree.svg",
    "012-mountain.svg",
    "013-coconut.svg",
    "013-rope.svg",
    "014-bamboo.svg",
    "014-bandage.svg",
    "015-banana.svg",
    "015-reflection.svg",
    "016-cactus.svg",
    "016-snack.svg",
    "017-island.svg",
    "017-tree.svg",
    "018-bush.svg",
    "018-sos.svg",
    "019-bush.svg",
    "019-fish.svg",
    "020-bonfire.svg",
    "020-grass.svg",
    "021-fishing rod.svg",
    "021-snake plant.svg",
    "022-roast chicken.svg",
    "022-tree.svg",
    "023-bear.svg",
    "023-bush.svg",
    "024-stump.svg",
    "024-wolf.svg",
    "025-knife.svg",
    "025-stump.svg",
    "026-stone.svg",
    "027-stone.svg",
    "028-stone.svg",
    "029-plants.svg",
    "030-flower.svg",
    "031-plant.svg",
    "032-plant.svg",
    "033-tree.svg",
    "034-mushroom.svg",
    "035-flower.svg",
    "036-mountain.svg",
    "037-volcano.svg",
    "038-cave.svg",
    "039-hill.svg",
    "040-waterfall.svg",
    "041-river.svg",
    "042-forest.svg",
    "043-cottage.svg",
    "044-tree.svg",
    "045-ruins.svg",
    "046-tree.svg",
    "047-tree.svg",
    "048-tree.svg",
    "049-tree.svg",
    "050-tree.svg",
    "adventure.svg",
    "adventurer.svg",
    "beach (1).svg",
    "beach.svg",
    "bonfire.svg",
    "bottle.svg",
    "capybara.svg",
    "diver.svg",
    "farm.svg",
    "fuji-mountain.svg",
    "garden.svg",
    "golden-gate-bridge.svg",
    "humming-bird.svg",
    "island (1).svg",
    "island.svg",
    "jungle.svg",
    "kayak.svg",
    "map.svg",
    "monkey.svg",
    "pig.svg",
    "rainy.svg",
    "scuba-diving.svg",
    "shed.svg",
    "shrine.svg",
    "snowflake.svg",
    "stones.svg",
    "tapir.svg",
    "travel.svg",
    "travelers.svg",
    "tree-stump.svg",
    "tree.svg",
    "umbrella.svg",
    "volcano.svg",
    "waterfall (1).svg",
    "waterfall.svg",
    "wave.svg",
    "adventurer_1.svg",
    "castle.svg",
    "compass.svg",
    "grand-canyon.svg",
    "olympus.svg",
    "stonehenge.svg"
  ];

  static String getRandomBackgroundAsset() {
    int randomNumber = Random().nextInt(bgAsset.length - 1);
    return bgAsset[randomNumber];
  }

  static String getRandomIconAsset() {
    int randomNumber = Random().nextInt(iconAsset.length - 1);
    return "assets/icons/${iconAsset[randomNumber]}";
  }
}