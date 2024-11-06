import 'package:uuid/uuid.dart';

class Card {
  final String id;
  final String name;

  Card({required this.name}) : id = Uuid().v4();
}