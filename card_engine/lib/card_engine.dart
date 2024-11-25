library;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

import './worlds/table_world.dart';

// TODO: Export any libraries intended for clients of this package.
export './card_engine.dart';

class CardEngine extends FlameGame with RiverpodGameMixin, SingleGameInstance {

  @override
  Color backgroundColor() => const Color.fromARGB(158, 20, 227, 100);

  @override
  Future<void> onLoad() async {
  await super.onLoad();
  
  // TODO: Game loading

  //await Flame.images.loadAll([
  //      'placeholder.png',
  //      'placeholder-reverse.png',
  //    ]);
    world = TableWorld();

  }

  @override
  void onRemove() {
    super.onRemove();
    removeAll(children);
    processLifecycleEvents();
    Flame.images.clearCache();
    Flame.assets.clearCache();

  }

}
