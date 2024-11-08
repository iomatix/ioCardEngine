/// Metadata type for `[Deck]` model.
class DeckMetadata {
  String _description;
  final DateTime _creationDate;
  DateTime _modificationDate;

  DeckMetadata({
    String description = "",
    required double probability,
  })  : _description = description,
        _creationDate = DateTime.now(),
        _modificationDate = DateTime.now();

  /// Getter for description
  String get description => _description;

  /// Setter for description
  set description(String newDescription) {
    if (newDescription.isNotEmpty) {
      _description = newDescription;
      _modificationDate = DateTime.now(); // Update modification date whenever description changes
    }
    else{
      throw ArgumentError('Description must be not empty.');
    }
  }

  /// Getter for creation date (no setter because it's immutable)
  DateTime get creationDate => _creationDate;

  /// Getter for modification date
  DateTime get modificationDate => _modificationDate;

  // Method to update all card metadata
  void updateMetadata(String newDescription) {
    description = newDescription;
    _modificationDate = DateTime.now(); // Update modification date
  }
}
