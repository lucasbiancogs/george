import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:george/characters/friend.dart';
import 'package:george/main.dart';

void addFriends(TiledComponent map, GeorgeGame game) {
  final friendsGroup = map.tileMap.getLayer<ObjectGroup>('friends');

  friendsGroup?.objects.forEach((friendBox) {
    final friendComponent = FriendComponent()
      ..position = Vector2(friendBox.x, friendBox.y)
      ..width = friendBox.width
      ..height = friendBox.height
      ..debugMode = game.debugMode;

    game.add(friendComponent);
  });
}
