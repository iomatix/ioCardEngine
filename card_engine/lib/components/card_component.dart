import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';
import 'package:flutter/cupertino.dart';

import '../card_engine.dart';
import '../tools/engine_tool.dart';
import '../worlds/table_world.dart';
import '../models/card.dart';
import '../enums/card_state.dart';

class CardComponent extends SpriteGroupComponent<CardState>
    with
        RiverpodComponentMixin,
        HasGameReference<CardEngine>,
        HasWorldReference<TableWorld>,
        HasVisibility {
  final String id;
  Card card;
  CardState _currentCardState = CardState.down;
  Vector2? _lastScreenSize;

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
    final reverseSprite = await EngineTool.loadSpriteFromFile(
        card.reverseSrc, '${card.name}_reverse');

    sprites = {
      CardState.up: frontSprite,
      CardState.down: reverseSprite,
    };

    //makeVisible();
    //uncoverCard();
    //setPosition(Vector2(0, 0));
  }

  @override
  void onMount() {
    addToGameWidgetBuild(() {
      // ref.listen(exampleProvider, (previous, next) { }); goes here
    });
    super.onMount();
    // any other operations go here e.g. add(Component(value: someValue))
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    // Use vertical axis (main axis) to calculate the scale ratio
    // Get the previous size; assuming `lastSize` stores the last known size
    if (_lastScreenSize != null) {
      final oldHeight = _lastScreenSize!.y; // Vertical axis of the old size
      final newHeight = size.y; // Vertical axis of the new size

      // Calculate the scale ratio based on the change in vertical size
      final scaleRatio = newHeight / oldHeight;

      // Apply the new scale
      setScale(scale.x * scaleRatio); // Adjust scale proportionally
    }

    // Update the stored last size
    _lastScreenSize = size;
  }

  void _setCardState(CardState cardState) async {
    current = cardState;
  }

  void coverCard() {
    _setCardState(CardState.down);
  }

  void uncoverCard() {
    _setCardState(CardState.up);
  }

  void makeInvisible() async {
    isVisible = false;
  }

  void makeVisible() async {
    isVisible = true;
  }

  void setPosition(Vector2 newPos) {
    position = newPos;
  }

  void setScale(double newScale) {
    scale = Vector2(newScale, newScale);
  }
}
