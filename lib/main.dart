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
import 'package:george/characters/player.dart';
import 'package:george/dialog/dialog_box.dart';
import 'package:george/items/inventory.dart';
import 'package:george/items/inventory_component.dart';
import 'package:george/loaders/add_baked_goods.dart';
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
  late SpriteAnimation downPlayerAnimation;
  late SpriteAnimation leftPlayerAnimation;
  late SpriteAnimation upPlayerAnimation;
  late SpriteAnimation rightPlayerAnimation;
  late SpriteAnimation idlePlayerAnimation;

  late PlayerComponent george;
  late double mapWidth;
  late double mapHeight;

  late AudioPool pickMeal;
  late AudioPool meetFriend;
  late AudioPool blablabla;

  int playerDirection = 0;
  final double animationSpeed = 0.1;
  final double playerSize = 40;
  final double playerSpeed = 120;
  final Inventory inventory = Inventory([], capacity: 16);

  final debugMode = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final map = await TiledComponent.load(Maps.happyVillage, Vector2.all(16));

    meetFriend = await FlameAudio.createPool(Audios.hello, maxPlayers: 1);
    pickMeal = await FlameAudio.createPool(Audios.nhaum, maxPlayers: 1);
    blablabla = await FlameAudio.createPool(Audios.blablabla, maxPlayers: 1);

    add(map);
    // addBakedGoods(map, this);

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

    final playerAsset = await images.load(Sprites.player);
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

    final respawnLayer = map.tileMap.getLayer<ObjectGroup>('respawn');
    final respawn = respawnLayer!.objects.first;

    george = PlayerComponent()
      ..animation = idlePlayerAnimation
      ..position = Vector2(respawn.x, respawn.y)
      ..debugMode = debugMode
      ..size = Vector2.all(playerSize);

    add(george);

    camera.followComponent(
      george,
      worldBounds: Rect.fromLTRB(0, 0, mapWidth, mapHeight),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    final animations = [
      idlePlayerAnimation,
      downPlayerAnimation,
      leftPlayerAnimation,
      upPlayerAnimation,
      rightPlayerAnimation,
    ];

    switch (playerDirection) {
      case 1:
        if (george.y < mapHeight - george.height) {
          george.y += dt * playerSpeed;
        }
      case 2:
        if (george.x > 0) {
          george.x -= dt * playerSpeed;
        }
      case 3:
        if (george.y > 0) {
          george.y -= dt * playerSpeed;
        }
      case 4:
        if (george.x < mapWidth - george.width) {
          george.x += dt * playerSpeed;
        }
        break;
    }

    george.animation = animations[playerDirection];
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
