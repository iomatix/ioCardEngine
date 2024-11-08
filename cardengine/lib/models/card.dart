import 'dart:ui';
import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';

import '../components/card_component.dart';
import 'meta/card_metadata.dart';

class Card {
  final String id;
  final String name;
  final CardCategory category;
  final List<String> tags;

  final Size size;
  final Sprite front;
  final Sprite reverse;

  final CardMetadata metadata;

  Card({
    required this.name,
    required this.front,
    required this.reverse,
    required this.size,
    required this.metadata,
    this.tags = const [],
  }) : id = Uuid().v4();
}
