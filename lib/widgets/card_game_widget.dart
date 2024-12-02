import 'package:card_engine/services/user_data_manager.dart';
import 'package:flutter/material.dart';
import 'package:card_engine/card_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

import '../services/service_manager.dart';

/// The main `[GameWidget]` of the `[CardEngine]` instance
class CardGameWidget extends ConsumerWidget {
  
  const CardGameWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RiverpodAwareGameWidget(
      game: CardEngine(
          userDataManagerService: ServiceManager().get<UserDataManager>()),
      key: GlobalKey<RiverpodAwareGameWidgetState<CardEngine>>(
          debugLabel:
              '_CardEngine_STATE_'), // (CardEngine based on FlameGame with RiverpodGameMixin)
    );
  }
}
