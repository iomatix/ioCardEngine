
import 'package:flame/components.dart';

import '../cardengine.dart';
import '../worlds/table_world.dart';
import '../models/card.dart';

class CardComponent extends SpriteGroupComponent<ButtonState> with HasGameReference<CardEngine>, HasWorldReference<TableWorld>, HasVisibility {
  final String id;
  Card card;

  CardComponent({required this.card})
      : id = "Card_Component_${card.id}_${DateTime.now().millisecondsSinceEpoch}",
        super(size: Vector2(card.width,card.height), key: ComponentKey.named('card'));

  @override
  Future<void>? onLoad() async {
    final frontSprite = await game.loadSprite(card.frontSrc);
    final reverseSprite = await game.loadSprite(card.reverseSrc);

    sprites = {
      ButtonState.down: frontSprite,
      ButtonState.up: reverseSprite,
    };

    show();
    setPosition(Vector2(64, 64));
    
  }



  void hide() async{
    isVisible = false;
  }

  void show() async{
    isVisible = true;
  }

  void setPosition(Vector2 newPos){
    position = newPos;
  }

}