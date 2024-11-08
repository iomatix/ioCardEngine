import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

enum CardCategory { A, B, C }

class CardComponent extends PositionComponent {
  final CardCategory category;
  Sprite? sprite;

  CardComponent(this.category);

  @override
  Future<void> onLoad() async {

    sprite = await Sprite.load('images/card_${category.name.toLowerCase()}.png');
    size = Vector2(100, 150);
  }

  @override
  void render(Canvas canvas) {
    sprite?.render(canvas, size: size);
  }
  
  @override
  bool onDragUpdate(DragUpdateInfo info) {
  position += info.delta.global;
  return true;
}

}