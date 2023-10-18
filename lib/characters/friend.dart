import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:george/characters/obstacles.dart';
import 'package:george/characters/player.dart';
import 'package:george/dialog/dialog_box.dart';
import 'package:george/main.dart';

class FriendComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef<GeorgeGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final hitbox = RectangleHitbox();

    add(hitbox);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayerComponent) {
      game.collisionDirection =
          getCollisionIntersectionSurface(intersectionPoints, other);
      _talkToFriend();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) async {
    super.onCollisionEnd(other);

    game.collisionDirection = CollisionIntersectionSurface.notColliding;
  }

  void _talkToFriend() {
    if (game.inventory.itemsAmount > 0) {
      final dialog = DialogBox(
        text:
            "Wow. Thanks so much! I'll take that! Please come over this weekend for a meal! I have to go now.",
        componentRef: this,
      );
      add(dialog);
      game.inventory.remove(game.inventory.items.last);
    } else {
      final dialog = DialogBox(
        text: "Oh sorry. I'm late for a meeting.",
        componentRef: this,
      );
      add(dialog);
    }
  }
}
