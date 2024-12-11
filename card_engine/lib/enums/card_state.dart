/// Enum representing the current state of the Card.
///
/// `[CardState.up]` indicates that the front of the card should be rendered.
/// `[CardState.down]` indicates that the reverse of the card should be rendered.
enum CardState {
  up,   // The front of the card is visible.
  down  // The back of the card is visible.
}