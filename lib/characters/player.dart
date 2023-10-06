import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:george/dialog/dialog_box.dart';

class PlayerComponent extends SpriteAnimationComponent with CollisionCallbacks {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final hitbox = RectangleHitbox();

    add(hitbox);
    final dialog = DialogBox(
      text:
          "Hi. I'm George. I just moved to Happy Bay Village and I want to make friends.",
      componentRef: this,
    );

    add(dialog);
  }
}
