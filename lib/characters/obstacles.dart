import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:george/characters/player.dart';
import 'package:george/main.dart';

class ObstacleComponent extends PositionComponent
    with CollisionCallbacks, HasGameRef<GeorgeGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final hitbox = RectangleHitbox(anchor: Anchor.topLeft, isSolid: true);
    add(hitbox);
    debugMode = true;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayerComponent) {
      game.collisionDirection =
          getCollisionIntersectionSurface(intersectionPoints, this);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) async {
    super.onCollisionEnd(other);

    game.collisionDirection = CollisionIntersectionSurface.notColliding;
  }
}

CollisionIntersectionSurface getCollisionIntersectionSurface(
    Set<Vector2> intersectionPoints, PositionComponent other) {
  const collisionThreshold = 2;

  final isTop = (intersectionPoints.first.y - other.position.y).abs() <
      collisionThreshold;
  final isBottom =
      (intersectionPoints.first.y - other.position.y - other.size.y).abs() <
          collisionThreshold;
  final isLeft = (intersectionPoints.first.x - other.position.x).abs() <
      collisionThreshold;
  final isRight =
      (intersectionPoints.first.x - other.position.x - other.size.x).abs() <
          collisionThreshold;

  if (isTop) {
    return CollisionIntersectionSurface.top;
  }

  if (isBottom) {
    return CollisionIntersectionSurface.bottom;
  }

  if (isLeft) {
    return CollisionIntersectionSurface.left;
  }

  if (isRight) {
    return CollisionIntersectionSurface.right;
  }

  return CollisionIntersectionSurface.notColliding;
}

enum CollisionIntersectionSurface {
  top,
  bottom,
  left,
  right,
  notColliding,
}
