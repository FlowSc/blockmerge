import 'package:flutter/foundation.dart';

@immutable
final class Position {
  const Position({required this.row, required this.col});

  final int row;
  final int col;

  Position copyWith({int? row, int? col}) {
    return Position(row: row ?? this.row, col: col ?? this.col);
  }

  Position offset(int dRow, int dCol) {
    return Position(row: row + dRow, col: col + dCol);
  }

  /// Returns the four cardinal neighbors (up, down, left, right).
  List<Position> get neighbors => [
        offset(-1, 0),
        offset(1, 0),
        offset(0, -1),
        offset(0, 1),
      ];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => 'Position($row, $col)';
}
