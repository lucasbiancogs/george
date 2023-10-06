class Player {
  Player(this.id, this.x, this.y);

  final String id;
  final double x;
  final double y;

  Player.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        x = json['x'],
        y = json['y'];
}
