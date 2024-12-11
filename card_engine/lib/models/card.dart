import 'package:uuid/uuid.dart';
import 'meta/card_metadata.dart';


/// `[Card]` model designed to be instantiated in the engine and store the data in the application. 
class Card {
  final String id;
  String _name;
  String _category;
  List<String> _tags;

  double _width;
  double _height;
  String _frontSrc;
  String _reverseSrc;

  CardMetadata _metadata;

  Card({
    required String category,
    required String name,
    required String frontSrc,
    required String reverseSrc,
    required double width,
    required double height,
    required CardMetadata metadata,
    List<String> tags = const [],
  })  : _category = category,
        _name = name,
        _frontSrc = frontSrc,
        _reverseSrc = reverseSrc,
        _width = width,
        _height = height,
        _metadata = metadata,
        _tags = tags,
        id = Uuid().v4();

  // Getters
  String get name => _name;
  String get category => _category;
  List<String> get tags => List.unmodifiable(_tags); // Prevent modification from outside
  double get width => _width;
  double get height => _height;
  String get frontSrc => _frontSrc;
  String get reverseSrc => _reverseSrc;
  CardMetadata get metadata => _metadata;

  // Setters
  set name(String newName) {
    _name = newName;
  }

  set category(String newCategory) {
    _category = newCategory;
  }

  set width(double newWidth) {
    _width = newWidth;
  }

  set height(double newHeight) {
    _height = newHeight;
  }

  set frontSrc(String newFront) {
    _frontSrc = newFront;
  }

  set reverseSrc(String newReverse) {
    _reverseSrc = newReverse;
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
      throw ArgumentError('The $tag tag does not exist.');
    }
  }

  /// Directly modifies `[Card]` metadata.
  void updateMetadata(String newDescription) {
    _metadata.updateMetadata(newDescription);
  }
}
