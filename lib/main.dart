import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:george/assets.dart';
import 'package:george/characters/obstacles.dart';
import 'package:george/characters/player.dart';
import 'package:george/items/inventory.dart';
import 'package:george/items/inventory_component.dart';
import 'package:george/loaders/add_baked_goods.dart';
import 'package:george/loaders/add_friends.dart';
import 'package:george/loaders/add_obstacles.dart';
import 'package:george/volume_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          game: GeorgeGame(),
          overlayBuilderMap: {
            'inventory': (BuildContext context, GeorgeGame game) =>
                InventoryComponent(inventory: game.inventory),
            'volumeController': (BuildContext context, GeorgeGame game) =>
                VolumeController()
          },
        ),
      ),
    ),
  );
}

class GeorgeGame extends FlameGame
    with TapDetector, KeyboardEvents, HasCollisionDetection {
  late PlayerComponent george;
  late double mapWidth;
  late double mapHeight;

  late AudioPool pickMeal;
  late AudioPool meetFriend;
  late AudioPool blablabla;

  MovementDirection playerDirection = MovementDirection.idle;
  // TODO(lucasbiancogs): Refactor this
  CollisionIntersectionSurface collisionDirection =
      CollisionIntersectionSurface.notColliding;

  final Inventory inventory = Inventory([], capacity: 16);

  final StreamController<Vector2> _positionStream =
      StreamController.broadcast();

  @override
  Future<void> onLoad() async {
    debugMode = false;

    await super.onLoad();

    final map = await TiledComponent.load(Maps.happyVillage, Vector2.all(16));

    meetFriend = await FlameAudio.createPool(Audios.hello, maxPlayers: 1);
    pickMeal = await FlameAudio.createPool(Audios.nhaum, maxPlayers: 1);
    blablabla = await FlameAudio.createPool(Audios.blablabla, maxPlayers: 1);

    add(map);
    addBakedGoods(map, this);

    mapHeight = map.tileMap.map.height * 16;
    mapWidth = map.tileMap.map.width * 16;

    addFriends(map, this);
    addObstacles(map, this);

    FlameAudio.bgm.initialize();
    FlameAudio.audioCache.load(Audios.ukulele);

    overlays.add('volumeController');
    overlays.add('inventory');

    final respawnLayer = map.tileMap.getLayer<ObjectGroup>('respawn');
    final respawn = respawnLayer!.objects.first;

    george = PlayerComponent(positionStream: _positionStream.stream)
      ..position = Vector2(respawn.x, respawn.y)
      ..debugMode = debugMode;

    add(george);

    camera.followComponent(
      george,
      worldBounds: Rect.fromLTRB(0, 0, mapWidth, mapHeight),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // TODO(lucasbiancogs): Refactor this
    Vector2? newPosition;

    switch (playerDirection) {
      case MovementDirection.down:
        if (george.y < mapHeight - george.height) {
          final y = george.y + 5;
          newPosition = Vector2(george.x, y);
        }
        break;
      case MovementDirection.left:
        if (george.x > 0) {
          final x = george.x - 5;
          newPosition = Vector2(x, george.y);
        }
        break;
      case MovementDirection.up:
        if (george.y > 0) {
          final y = george.y - 5;
          newPosition = Vector2(george.x, y);
        }
        break;
      case MovementDirection.right:
        if (george.x < mapWidth - george.width) {
          final x = george.x + 5;
          newPosition = Vector2(x, george.y);
        }
        break;
      case MovementDirection.idle:
        break;
    }

    if (newPosition != null) {
      _positionStream.add(newPosition);
    }
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final keyPressing = keysPressed.isNotEmpty;

    if (!keyPressing) {
      playerDirection = MovementDirection.idle;
      return KeyEventResult.handled;
    }

    final lastKeyPressed = keysPressed.last;
    final isKeyDown = lastKeyPressed == LogicalKeyboardKey.arrowDown;
    final isKeyUp = lastKeyPressed == LogicalKeyboardKey.arrowUp;
    final isKeyLeft = lastKeyPressed == LogicalKeyboardKey.arrowLeft;
    final isKeyRight = lastKeyPressed == LogicalKeyboardKey.arrowRight;

    if (keyPressing) {
      if (isKeyDown) {
        playerDirection = MovementDirection.down;
        return KeyEventResult.handled;
      }
      if (isKeyLeft) {
        playerDirection = MovementDirection.left;
        return KeyEventResult.handled;
      }
      if (isKeyUp) {
        playerDirection = MovementDirection.up;
        return KeyEventResult.handled;
      }
      if (isKeyRight) {
        playerDirection = MovementDirection.right;
        return KeyEventResult.handled;
      }
    } else {
      playerDirection = MovementDirection.idle;
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void onTapUp(TapUpInfo info) {
    final position = info.eventPosition.game;
    _positionStream.add(position);
  }
}
