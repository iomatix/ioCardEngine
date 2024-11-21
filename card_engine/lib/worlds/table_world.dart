import 'package:flame/components.dart';

import '../components/card_component.dart';
import '../models/meta/card_metadata.dart';
import '../models/card.dart';

class TableWorld extends World {
  @override
  Future<void> onLoad() async {
    super.onLoad();

    Card testcard = Card(
      category: 'test',
      name: 'test_card_model',
      frontSrc: 'placeholder.png',
      reverseSrc: 'placeholder-reverse.png',
      width: 400,
      height: 600,
      metadata: CardMetadata(description: "This is a test model."),
    );
    CardComponent testcard_instance = CardComponent(card: testcard);
    await add(testcard_instance);
    addCard(testcard_instance);

  }

  void addCard(CardComponent card) {
    add(card);
  }

  void removeCard(CardComponent card) {
    remove(card);
  }
}
