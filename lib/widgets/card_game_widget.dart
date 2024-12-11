import 'package:flutter/material.dart';
import 'package:card_engine/card_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flame_riverpod/flame_riverpod.dart';

/// The main `[GameWidget]` of the `[CardEngine]` instance
class CardGameWidget extends ConsumerWidget {
  
  CardGameWidget({super.key});

  final CardEngine gameInstance = CardEngine.instance;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RiverpodAwareGameWidget(
      game: gameInstance,
      key: GlobalKey<RiverpodAwareGameWidgetState<CardEngine>>(
          debugLabel:
              '_CardEngine_STATE_'), // (CardEngine based on FlameGame with RiverpodGameMixin)
    );
  }
}
