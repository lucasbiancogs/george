import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:george/assets.dart';
import 'package:george/characters/obstacles.dart';
import 'package:george/dialog/dialog_box.dart';
import 'package:george/main.dart';

class PlayerComponent extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<GeorgeGame> {
  PlayerComponent({
    required this.positionStream,
  }) {
    newPosition = position;
  }

  final Stream<Vector2> positionStream;
  late Vector2 newPosition;
  late SpriteAnimation downPlayerAnimation;
  late SpriteAnimation leftPlayerAnimation;
  late SpriteAnimation upPlayerAnimation;
  late SpriteAnimation rightPlayerAnimation;
  late SpriteAnimation idlePlayerAnimation;
  final double animationSpeed = 0.1;
  final double playerSize = 40;
  final double speed = 120;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final hitbox = RectangleHitbox(isSolid: true);
    positionStream.listen((onNewPosition) {
      newPosition = onNewPosition;
    });
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

    add(hitbox);
    final dialog = DialogBox(
      text:
          "Hi. I'm George. I just moved to Happy Bay Village and I want to make friends.",
      componentRef: this,
    );

    add(dialog);
  }

  @override
  void update(double dt) {
    // TODO: implement update
    super.update(dt);

    if (position != newPosition) {
      move(dt);
      animatePlayer();
    } else {
      animation = idlePlayerAnimation;
    }
  }

  void animatePlayer() {
    final direction = this.direction(position, newPosition);

    switch (direction) {
      case MovementDirection.right:
        animation = rightPlayerAnimation;
        return;
      case MovementDirection.left:
        animation = leftPlayerAnimation;
        return;
      case MovementDirection.up:
        animation = upPlayerAnimation;
        return;
      case MovementDirection.down:
        animation = downPlayerAnimation;
        return;
      case MovementDirection.idle:
        animation = idlePlayerAnimation;
        return;
    }
    // if (newPosition.x > position.x) {
    //   animation = rightPlayerAnimation;
    // } else if (newPosition.x < position.x) {
    //   animation = leftPlayerAnimation;
    // } else if (newPosition.y > position.y) {
    //   animation = downPlayerAnimation;
    // } else if (newPosition.y < position.y) {
    //   animation = upPlayerAnimation;
    // }
  }

  bool _isColliding(MovementDirection movementDirection,
      CollisionIntersectionSurface collisionIntersectionSurface) {
    if (collisionIntersectionSurface ==
        CollisionIntersectionSurface.notColliding) {
      return false;
    }

    return movementDirection == MovementDirection.up &&
            collisionIntersectionSurface ==
                CollisionIntersectionSurface.bottom ||
        movementDirection == MovementDirection.down &&
            collisionIntersectionSurface == CollisionIntersectionSurface.top ||
        movementDirection == MovementDirection.left &&
            collisionIntersectionSurface ==
                CollisionIntersectionSurface.right ||
        movementDirection == MovementDirection.right &&
            collisionIntersectionSurface == CollisionIntersectionSurface.left;
  }

  void move(double dt) {
    if (_shouldMove(position, newPosition)) {
      final verticalDirection = this.verticalDirection(position, newPosition);
      if (!_isColliding(verticalDirection, game.collisionDirection)) {
        if (verticalDirection == MovementDirection.down) {
          _moveDown(dt);
        }

        if (verticalDirection == MovementDirection.up) {
          _moveUp(dt);
        }
      }

      final horizontalDirection =
          this.horizontalDirection(position, newPosition);

      if (!_isColliding(horizontalDirection, game.collisionDirection)) {
        if (horizontalDirection == MovementDirection.right) {
          _moveRight(dt);
        }

        if (horizontalDirection == MovementDirection.left) {
          _moveLeft(dt);
        }
      }
    } else {
      position = newPosition;
    }
  }

  bool _shouldMove(Vector2 a, Vector2 b) {
    const positionTreshold = 1;

    final horizontalDelta = (a.x - b.x).abs();
    final verticalDelta = (a.y - b.y).abs();

    return horizontalDelta > positionTreshold ||
        verticalDelta > positionTreshold;
  }

  void _moveLeft(double dt) => position.x -= dt * speed;
  void _moveRight(double dt) => position.x += dt * speed;
  void _moveUp(double dt) => position.y -= dt * speed;
  void _moveDown(double dt) => position.y += dt * speed;

  // Return the predominant direction of movement
  MovementDirection direction(Vector2 a, Vector2 b) {
    final horizontalDelta = (a.x - b.x).abs();
    final verticalDelta = (a.y - b.y).abs();

    return horizontalDelta > verticalDelta
        ? horizontalDirection(a, b)
        : verticalDirection(a, b);
  }

  MovementDirection horizontalDirection(Vector2 a, Vector2 b) {
    if (a.x > b.x) {
      return MovementDirection.left;
    } else if (a.x < b.x) {
      return MovementDirection.right;
    }

    return MovementDirection.idle;
  }

  MovementDirection verticalDirection(Vector2 a, Vector2 b) {
    if (a.y > b.y) {
      return MovementDirection.up;
    } else if (a.y < b.y) {
      return MovementDirection.down;
    }

    return MovementDirection.idle;
  }
}

enum MovementDirection {
  up,
  down,
  left,
  right,
  idle,
}
