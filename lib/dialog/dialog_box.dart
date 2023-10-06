import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:george/main.dart';

class DialogBox extends TextBoxComponent with HasGameRef<GeorgeGame> {
  DialogBox({required super.text, required this.componentRef})
      : super(
          textRenderer: TextPaint(
              style: const TextStyle(fontSize: 15, color: Colors.white)),
          boxConfig: TextBoxConfig(
            dismissDelay: 1,
            maxWidth: 300,
            timePerChar: 0.1,
            growingBox: true,
          ),
        ) {
    position = Vector2(20, -30);
  }

  final PositionComponent componentRef;

  @override
  void onMount() {
    super.onMount();
    game.blablabla.start();
  }

  @override
  void drawBackground(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, width, height);
    final rRect = RRect.fromRectAndCorners(rect,
        topRight: const Radius.circular(10),
        topLeft: Radius.circular(10),
        bottomRight: const Radius.circular(10));

    final paint = Paint()..color = Colors.grey.shade600.withOpacity(0.4);
    canvas.drawRRect(rRect, paint);
  }

  @override
  void update(double dt) async {
    super.update(dt);

    if (finished) {
      componentRef.remove(this);
    }
  }
}
