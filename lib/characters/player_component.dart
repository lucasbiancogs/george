import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:george/assets.dart';
import 'package:george/dialog/dialog_box.dart';
import 'package:george/main.dart';

class PlayerComponent extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<GeorgeGame> {
  PlayerComponent(this.playerId);

  final String playerId;

  final double animationSpeed = 0.1;
  final double playerSize = 70;

  late SpriteAnimation downPlayerAnimation;
  late SpriteAnimation leftPlayerAnimation;
  late SpriteAnimation upPlayerAnimation;
  late SpriteAnimation rightPlayerAnimation;
  late SpriteAnimation idlePlayerAnimation;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await createAnimation();
    final hitbox = RectangleHitbox();

    add(hitbox);
    final dialog = DialogBox(
      text:
          "Hi. I'm George. I just moved to Happy Bay Village and I want to make friends.",
      componentRef: this,
    );

    add(dialog);
  }

  Future<void> createAnimation() async {
    final playerAsset = await game.images.load(Sprites.player);
    final spriteSheet = SpriteSheet(
      image: playerAsset,
      srcSize: Vector2(48, 48),
    );

    idlePlayerAnimation = spriteSheet.createAnimation(
      row: 0,
      stepTime: animationSpeed,
      to: 1,
    );
    downPlayerAnimation = spriteSheet.createAnimation(
      row: 0,
      stepTime: animationSpeed,
      to: 4,
    );
    leftPlayerAnimation = spriteSheet.createAnimation(
      row: 1,
      stepTime: animationSpeed,
      to: 4,
    );
    upPlayerAnimation = spriteSheet.createAnimation(
      row: 2,
      stepTime: animationSpeed,
      to: 4,
    );
    rightPlayerAnimation = spriteSheet.createAnimation(
      row: 3,
      stepTime: animationSpeed,
      to: 4,
    );

    animation = idlePlayerAnimation;
    size = Vector2.all(playerSize);
  }
}
