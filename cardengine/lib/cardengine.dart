library;

import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/palette.dart';

// TODO: Export any libraries intended for clients of this package.
export './cardengine.dart';

class CardEngine extends FlameGame {
  @override
  Future<void> onLoad() async {
    // Initialize Game, Loading
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFF00FF00);
    final rect = Rect.fromLTWH(100, 100, 200, 200);
    canvas.drawRect(rect, paint);
  }
}
