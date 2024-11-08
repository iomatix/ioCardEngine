import 'dart:ui';
import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';

import '../components/card_component.dart';
import 'meta/card_metadata.dart';

/// `[Card]` model designed to be instantiated in the engine and store the data in the application. 
class Card {
  final String id;
  String _name;
  CardCategory _category;
  List<String> _tags;

  Size _size;
  Sprite _front;
  Sprite _reverse;

  CardMetadata _metadata;

  Card({
    required CardCategory category,
    required String name,
    required Sprite front,
    required Sprite reverse,
    required Size size,
    required CardMetadata metadata,
    List<String> tags = const [],
  })  : _category = category,
        _name = name,
        _front = front,
        _reverse = reverse,
        _size = size,
        _metadata = metadata,
        _tags = tags,
        id = Uuid().v4();

  // Getters
  String get name => _name;
  CardCategory get category => _category;
  List<String> get tags =>
      List.unmodifiable(_tags); // Prevent modification from outside
  Size get size => _size;
  Sprite get front => _front;
  Sprite get reverse => _reverse;
  CardMetadata get metadata => _metadata;

  // Setters
  set name(String newName) {
    _name = newName;
  }

  set category(CardCategory newCategory) {
    _category = newCategory;
  }

  set size(Size newSize) {
    _size = newSize;
  }

  set front(Sprite newFront) {
    _front = newFront;
  }

  set reverse(Sprite newReverse) {
    _reverse = newReverse;
  }

  /// Adds a new tag to the list.
  void addTag(String tag) {
    if (!_tags.contains(tag)) {
      _tags.add(tag);
    } else {
      throw ArgumentError('The $tag tag already exists.');
    }
  }

  /// Removes an existing tag from the list.
  void removeTag(String tag) {
    if (_tags.contains(tag)) {
      _tags.remove(tag);
    } else {
      throw ArgumentError('The $tag tag does not exists.');
    }
  }

  /// Directly modifies `[Card]` metadata.
  void updateMetadata(String newDescription) {
    _metadata.updateMetadata(newDescription);
  }
}
