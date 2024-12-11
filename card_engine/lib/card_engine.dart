library;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

import './worlds/table_world.dart';

import 'Exceptions/engine_not_initialized_exception.dart';
import 'services/user_data_manager.dart';

// TODO: Export any libraries intended for clients of this package.
export './card_engine.dart';

class CardEngine extends FlameGame with RiverpodGameMixin, SingleGameInstance {
  
  final UserDataManager userDataManagerService;
  CardEngine._privateConstructor({required this.userDataManagerService});
  static CardEngine? _instance;

  static CardEngine? initialize({required UserDataManager userDataManagerService}) {
    _instance ??= CardEngine._privateConstructor(userDataManagerService: userDataManagerService);
    return _instance;
  }

  static CardEngine get instance {
    if (_instance == null) {
      throw EngineNotInitializedException('CardEngine has not been initialized. Call CardEngine.initialize(userDataManagerService: ServiceManager().get<UserDataManager>()) first.');
    }
    return _instance!;
  }

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
    world = TableWorld(userDataManagerService: userDataManagerService);

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
