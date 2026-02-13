/// Consumable items that can be used during gameplay.
enum ItemType {
  /// Remove all tiles of a chosen value from the board.
  numberPurge,

  /// Keep only the highest-value tiles, removing everything else.
  maxKeep,

  /// Randomly rearrange all tile positions on the board.
  shuffle,
}
