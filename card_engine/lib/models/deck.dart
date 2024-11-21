import 'package:uuid/uuid.dart';
import 'card.dart';

/// `[Deck]` model designed to be instantiated in the engine and store the data in the application. 
class Deck {
  final String id;
  List<Card> _cards;

  Deck() : id = Uuid().v4(), _cards = [];

  /// Getter to get an unmodifiable list of cards
  List<Card> get cards => List.unmodifiable(_cards);

  /// Adds an instance of the card to the deck
  void addCard(Card card) {
    _cards.add(card);
  }

  /// Removes instance of the card to the deck
  void removeCard(Card card) {
    _cards.remove(card);
  }

  /// Modifies instance of the card within the deck at `index`
  void updateCard(int index, Card updatedCard) {
    if (index >= 0 && index < _cards.length) {
      _cards[index] = updatedCard;
    }
  }

  /// Clear all instances of cards from the deck
  void clearDeck() {
    _cards.clear();
  }
}