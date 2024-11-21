library;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

import './worlds/table_world.dart';

// TODO: Export any libraries intended for clients of this package.
export './cardengine.dart';

class CardEngine extends FlameGame with SingleGameInstance {

  @override
  Color backgroundColor() => const Color.fromARGB(158, 20, 227, 100);

  @override
  Future<void> onLoad() async {
    world = TableWorld();

  }

  @override
  void onRemove() {
    removeAll(children);
    processLifecycleEvents();
    Flame.images.clearCache();
    Flame.assets.clearCache();

  }

}
