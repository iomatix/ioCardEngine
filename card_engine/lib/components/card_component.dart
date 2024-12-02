import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

import '../card_engine.dart';
import '../tools/engine_tool.dart';
import '../worlds/table_world.dart';
import '../models/card.dart';

class CardComponent extends SpriteGroupComponent<ButtonState>
    with
        RiverpodComponentMixin,
        HasGameReference<CardEngine>,
        HasWorldReference<TableWorld>,
        HasVisibility {
  final String id;
  Card card;

  CardComponent({required this.card})
      : id =
            "Card_Component_${card.id}_${DateTime.now().millisecondsSinceEpoch}",
        super(
            size: Vector2(card.width, card.height),
            key: ComponentKey.named('card'),
            anchor: Anchor.center);

  @override
  Future<void>? onLoad() async {
    final frontSprite =
        await EngineTool.loadSpriteFromFile(card.frontSrc, card.name);
    final reverseSprite = await EngineTool
        .loadSpriteFromFile(card.reverseSrc, '${card.name}_reverse');

    sprites = {
      ButtonState.down: frontSprite,
      ButtonState.up: reverseSprite,
    };

    // Initialize the current state to a default value.
    current = ButtonState.up;

    show();
    setPosition(Vector2(0, 0));
  }

  @override
  void onMount() {
    addToGameWidgetBuild(() {
      // ref.listen(exampleProvider, (previous, next) { }); goes here
    });
    super.onMount();
    // any other operations go here e.g. add(Component(value: someValue))
  }

  void hide() async {
    isVisible = false;
  }

  void show() async {
    isVisible = true;
  }

  void setPosition(Vector2 newPos) {
    position = newPos;
  }
}
