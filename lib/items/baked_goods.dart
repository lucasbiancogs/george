import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:george/items/item.dart';
import 'package:george/main.dart';

class BakedGoodComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<GeorgeGame> {
  BakedGoodComponent({
    required super.position,
    required super.size,
    required this.bakedGood,
  }) {
    anchor = Anchor.center;
  }

  final Item bakedGood;

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite(bakedGood.sprite);
    final hitbox = RectangleHitbox(
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
      size: Vector2(size.x / 2, size.y / 2),
    )
      ..debugColor = const Color(0xFFFF0000)
      ..debugMode = game.debugMode;
    add(hitbox);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    gameRef.inventory.add(bakedGood);
    gameRef.pickMeal.start();
    print('George has ${gameRef.inventory} baked goods!');
    gameRef.remove(this);
  }
}
