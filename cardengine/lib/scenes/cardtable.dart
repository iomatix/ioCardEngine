import 'dart:ui' as dart_ui;

import 'package:cardengine/components/card_component.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';
import 'package:flame/game.dart';

class CardTable extends FlameGame {

  final List<CardComponent> _cardsOnTable = [];

  @override
  Future<void> onLoad() async {
    super.onLoad();

    Image image = await Flame.images.load('placehloder.png');
    _cardsOnTable.add(CardComponent(
      position: Vector2(100, 100), 
      size: Vector2(100, 150), 
      sprite: Sprite(image)));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Draw Table
    final paint = dart_ui.Paint()..color = dart_ui.Color.fromARGB(255, 150, 75, 0 );  
    final tableRect = Rect.fromLTWH(0, 0, size.x, size.y);  
    canvas.drawRect(tableRect, paint);

    // Draw cards
    for (var card in _cardsOnTable) {
      card.render(canvas);
    }
  }


  void addCard(CardComponent card) {
    _cardsOnTable.add(card);
  }

  void removeCard(CardComponent card) {
    _cardsOnTable.remove(card);
  }
}


