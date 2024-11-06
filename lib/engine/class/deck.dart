import 'package:uuid/uuid.dart';
import 'card.dart';

class Deck {
  final String id;
  final List<Card> cards;

  Deck() : id = Uuid().v4(), cards = [];




  void addCard(Card card) {
    cards.add(card);
  }

    void removeCard(Card card) {
    cards.remove(card);
  }


}