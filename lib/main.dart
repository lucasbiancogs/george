import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:george/assets.dart';
import 'package:george/characters/friend.dart';
import 'package:george/characters/player_component.dart';
import 'package:george/game_state.dart';
import 'package:george/items/inventory.dart';
import 'package:george/items/inventory_component.dart';
import 'package:george/loaders/add_baked_goods.dart';
import 'package:george/volume_controller.dart';

import 'characters/player.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: "AIzaSyBqGnoriuZTW1teb1kFPumXExHVu_87yO4",
    appId: "1:600369544814:web:8d16d4997969e5ce5bb07f",
    messagingSenderId: "600369544814",
    projectId: "george-f574d",
  ));

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
  late List<PlayerComponent> players;
  late double mapWidth;
  late double mapHeight;

  late AudioPool pickMeal;
  late AudioPool meetFriend;
  late AudioPool blablabla;

  final gameState = GameState();

  int playerDirection = 0;
  final double playerSpeed = 120;

  final Inventory inventory = Inventory([], capacity: 16);

  PlayerComponent get george =>
      players.firstWhere((element) => element.playerId == playerName);

  final debugMode = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final map = await TiledComponent.load(Maps.georgeTown, Vector2.all(16));

    meetFriend = await FlameAudio.createPool(Audios.hello, maxPlayers: 1);
    pickMeal = await FlameAudio.createPool(Audios.nhaum, maxPlayers: 1);
    blablabla = await FlameAudio.createPool(Audios.blablabla, maxPlayers: 1);

    add(map);
    addBakedGoods(map, this);

    mapHeight = map.tileMap.map.height * 16;
    mapWidth = map.tileMap.map.width * 16;

    final friendsGroup = map.tileMap.getLayer<ObjectGroup>('friends');

    friendsGroup?.objects.forEach((friendBox) {
      final friendComponent = FriendComponent()
        ..position = Vector2(friendBox.x, friendBox.y)
        ..width = friendBox.width
        ..height = friendBox.height
        ..debugMode = debugMode;

      add(friendComponent);
    });

    FlameAudio.bgm.initialize();
    FlameAudio.audioCache.load(Audios.ukulele);

    overlays.add('volumeController');
    overlays.add('inventory');

    players =
        gameState.players.map((player) => PlayerComponent(player.id)).toList();

    players.forEach((element) {
      add(element);
    });

    camera.followComponent(
      george,
      worldBounds: Rect.fromLTRB(0, 0, mapWidth, mapHeight),
    );
  }

  final playerName = 'lucasbianco';

  @override
  void update(double dt) {
    super.update(dt);

    gameState.players.forEach((player) {
      final playerComponent = players.firstWhere(
        (element) => element.playerId == player.id,
      );

      playerComponent.x = player.x;
      playerComponent.y = player.y;
    });

    // final animations = [
    //   idlePlayerAnimation,
    //   downPlayerAnimation,
    //   leftPlayerAnimation,
    //   upPlayerAnimation,
    //   rightPlayerAnimation,
    // ];

    switch (playerDirection) {
      case 1:
        if (george.y < mapHeight - george.height) {
          FirebaseFirestore.instance
              .collection('lobby')
              .doc(playerName)
              .update({
            'y': george.y + dt * playerSpeed,
          });
          // george.y += dt * playerSpeed;
        }
      case 2:
        if (george.x > 0) {
          FirebaseFirestore.instance
              .collection('lobby')
              .doc(playerName)
              .update({
            'x': george.x - dt * playerSpeed,
          });
          // george.x -= dt * playerSpeed;
        }
      case 3:
        if (george.y > 0) {
          FirebaseFirestore.instance
              .collection('lobby')
              .doc(playerName)
              .update({
            'y': george.y - dt * playerSpeed,
          });
          // george.y -= dt * playerSpeed;
        }
      case 4:
        if (george.x < mapWidth - george.width) {
          FirebaseFirestore.instance
              .collection('lobby')
              .doc(playerName)
              .update({
            'x': george.x + dt * playerSpeed,
          });
          // george.x += dt * playerSpeed;
        }
        break;
    }

    // george.animation = animations[playerDirection];
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    final keyPressing = keysPressed.isNotEmpty;

    if (!keyPressing) {
      playerDirection = 0;
      return KeyEventResult.handled;
    }

    final lastKeyPressed = keysPressed.last;
    final isKeyDown = lastKeyPressed == LogicalKeyboardKey.arrowDown;
    final isKeyUp = lastKeyPressed == LogicalKeyboardKey.arrowUp;
    final isKeyLeft = lastKeyPressed == LogicalKeyboardKey.arrowLeft;
    final isKeyRight = lastKeyPressed == LogicalKeyboardKey.arrowRight;

    if (keyPressing) {
      if (isKeyDown) {
        playerDirection = 1;
        return KeyEventResult.handled;
      }
      if (isKeyLeft) {
        playerDirection = 2;
        return KeyEventResult.handled;
      }
      if (isKeyUp) {
        playerDirection = 3;
        return KeyEventResult.handled;
      }
      if (isKeyRight) {
        playerDirection = 4;
        return KeyEventResult.handled;
      }
    } else {
      playerDirection = 0;
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void onTapUp(TapUpInfo info) {
    if (playerDirection >= 4) {
      playerDirection = 0;
    } else {
      playerDirection++;
    }
  }
}
