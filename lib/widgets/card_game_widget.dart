import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:card_engine/card_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main `[GameWidget]` of the `[CardEngine]` instance
class CardGameWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GameWidget(
      game: CardEngine(), // (CardEngine based on FlameGame)
    );
  }
}
