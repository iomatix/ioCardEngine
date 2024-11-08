import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:cardengine/cardengine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main widget of the FlameGame instance
class CardGameWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GameWidget(
      game: CardEngine(), // (CardEngine based on FlameGame)
    );
  }
}
