import 'package:json_annotation/json_annotation.dart';

part 'tile.g.dart';

@JsonSerializable(anyMap: true)
class Tile {
  //Unique id used as ValueKey for the TileWidget
  final String id;
  //The number on the tile
  final int value;
  //The index of the tile on the board from which the position of the tile will be calculated
  final int index;
  //The next index of the tile on the board
  final int? nextIndex;
  //Whether the tile was merged with another tile
  final bool merged;

  Tile(this.id, this.value, this.index, {this.nextIndex, this.merged = false});

  double getTop(double size, int boardSize) {
    return (index ~/ boardSize) * size;
  }

  double getLeft(double size, int boardSize) {
    return (index % boardSize) * size;
  }

  double? getNextTop(double size, int boardSize) {
    return nextIndex != null ? (nextIndex! ~/ boardSize) * size : null;
  }

  double? getNextLeft(double size, int boardSize) {
    return nextIndex != null ? (nextIndex! % boardSize) * size : null;
  }

  //Create an immutable copy of the tile
  Tile copyWith(
          {String? id, int? value, int? index, int? nextIndex, bool? merged}) =>
      Tile(id ?? this.id, value ?? this.value, index ?? this.index,
          nextIndex: nextIndex ?? this.nextIndex,
          merged: merged ?? this.merged);

  //Create a Tile from json data
  factory Tile.fromJson(Map<String, dynamic> json) => _$TileFromJson(json);

  //Generate json data from the Tile
  Map<String, dynamic> toJson() => _$TileToJson(this);
}
