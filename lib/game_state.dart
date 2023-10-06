import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:george/characters/player.dart';

class GameState {
  GameState() {
    final Stream<List<Player>> players =
        FirebaseFirestore.instance.collection('lobby').snapshots().map((event) {
      return event.docs.map((e) => Player.fromJson(e.data())).toList();
    });

    players.listen((players) {
      this.players = players;
    });
  }

  List<Player> players = [];
}
