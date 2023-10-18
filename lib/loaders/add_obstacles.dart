import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:george/characters/obstacles.dart';
import 'package:george/main.dart';

void addObstacles(TiledComponent map, GeorgeGame game) {
  final obstacleGroup = map.tileMap.getLayer<ObjectGroup>('obstacles');

  obstacleGroup?.objects.forEach((obstacleBox) {
    final obstacleComponent = ObstacleComponent()
      ..position = Vector2(obstacleBox.x, obstacleBox.y)
      ..width = obstacleBox.width
      ..height = obstacleBox.height
      ..debugMode = game.debugMode;

    game.add(obstacleComponent);
  });
}
