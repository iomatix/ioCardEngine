import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:io_card_engine/card_engine.dart';
void main() {
  runApp(
    ProviderScope(
      //child: MainApp(),
      child: GameWidget(game: CardEngine())
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
