import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:george/items/baked_goods.dart';
import 'package:george/items/item.dart';
import 'package:george/main.dart';

void addBakedGoods(TiledComponent homeMap, GeorgeGame game) {
  final bakedGoodsGroup = homeMap.tileMap.getLayer<ObjectGroup>('bakedGoods');

  bakedGoodsGroup?.objects.forEach((bakedGoodBox) {
    final bakedGood = Item(
      name: bakedGoodBox.name,
      sprite: '${bakedGoodBox.name}.png',
    );

    final bakedGoodComponent = BakedGoodComponent(
      position: Vector2(bakedGoodBox.x, bakedGoodBox.y),
      size: Vector2(bakedGoodBox.width, bakedGoodBox.height),
      bakedGood: bakedGood,
    );

    game.add(bakedGoodComponent);
  });
}
