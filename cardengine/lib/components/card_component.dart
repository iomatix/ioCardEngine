import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';


class CardComponent extends PositionComponent {
  final String id;
  final Sprite sprite;

  CardComponent({required Vector2 position, required Vector2 size, required this.sprite})
      : id = DateTime.now().millisecondsSinceEpoch.toString(),
        super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(position.x, position.y, size.x, size.y), paint);
    sprite.render(canvas);
  }
}