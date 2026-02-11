import 'package:flutter/foundation.dart';

import 'position.dart';

@immutable
final class Tile {
  const Tile({required this.value, required this.position});

  final int value;
  final Position position;

  Tile copyWith({int? value, Position? position}) {
    return Tile(
      value: value ?? this.value,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile && value == other.value && position == other.position;

  @override
  int get hashCode => Object.hash(value, position);

  @override
  String toString() => 'Tile($value at $position)';
}
