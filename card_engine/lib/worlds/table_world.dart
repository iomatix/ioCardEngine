import 'package:flame/components.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

import '../components/card_component.dart';
import '../models/meta/card_metadata.dart';
import '../models/card.dart';

class TableWorld extends World with RiverpodComponentMixin {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

      // TODO: Level Scene loading
    
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

  @override
  void onMount() {
    addToGameWidgetBuild(() {
      // ref.listen(exampleProvider, (previous, next) { }); goes here
    });
    super.onMount();
    // any other operations go here e.g. add(Component(value: someValue))
  }
  
  void addCard(CardComponent card) {
    add(card);
  }

  void removeCard(CardComponent card) {
    remove(card);
  }
}
