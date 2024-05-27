import 'dart:math';

import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:uuid/uuid.dart';

import '../models/tile.dart';

mixin BoardUtils {
  final verticalOrder = [12, 8, 4, 0, 13, 9, 5, 1, 14, 10, 6, 2, 15, 11, 7, 3];
  // Check whether the indexes are in the same row or column in the board.

  bool inRange(index, nextIndex) {
    return index < 4 && nextIndex < 4 ||
        index >= 4 && index < 8 && nextIndex >= 4 && nextIndex < 8 ||
        index >= 8 && index < 12 && nextIndex >= 8 && nextIndex < 12 ||
        index >= 12 && nextIndex >= 12;
  }

  Tile calculate(Tile tile, List<Tile> tiles, direction) {
    bool asc =
        direction == SwipeDirection.left || direction == SwipeDirection.up;
    bool vert =
        direction == SwipeDirection.up || direction == SwipeDirection.down;
    // Get the first index from the left in the row
    // Example: for left swipe that can be: 0, 4, 8, 12
    // for right swipe that can be: 3, 7, 11, 15
    // depending which row in the column in the board we need
    // let's say the title.index = 6 (which is the 3rd tile from the left and 2nd from right side, in the second row)
    // ceil means it will ALWAYS round up to the next largest integer
    // NOTE: don't confuse ceil it with floor or round as even if the value is 2.1 output would be 3.
    // ((6 + 1) / 4) = 1.75
    // Ceil(1.75) = 2
    // If it's ascending: 2 * 4 – 4 = 4, which is the first index from the left side in the second row
    // If it's descending: 2 * 4 – 1 = 7, which is the last index from the left side and first index from the right side in the second row
    // If user swipes vertically use the verticalOrder list to retrieve the up/down index else use the existing index
    int index = vert ? verticalOrder[tile.index] : tile.index;
    int nextIndex = ((index + 1) / 4).ceil() * 4 - (asc ? 4 : 1);

    // If the list of the new tiles to be rendered is not empty get the last tile
    // and if that tile is in the same row as the curren tile set the next index for the current tile to be after the last tile
    if (tiles.isNotEmpty) {
      var last = tiles.last;
      // If user swipes vertically use the verticalOrder list to retrieve the up/down index else use the existing index
      var lastIndex = last.nextIndex ?? last.index;
      lastIndex = vert ? verticalOrder[lastIndex] : lastIndex;
      if (inRange(index, lastIndex)) {
        // If the order is ascending set the tile after the last processed tile
        // If the order is descending set the tile before the last processed tile
        nextIndex = lastIndex + (asc ? 1 : -1);
      }
    }

    // Return immutable copy of the current tile with the new next index
    // which can either be the top left index in the row or the last tile nextIndex/index + 1
    return tile.copyWith(
        nextIndex: vert ? verticalOrder.indexOf(nextIndex) : nextIndex);
  }

  // Generates tiles at random place on the board
  Tile random(List<int> indexes) {
    var i = 0;
    var rng = Random();
    do {
      i = rng.nextInt(16);
    } while (indexes.contains(i));
    return Tile(Uuid().v4(), rng.nextInt(10) == 0 ? 4 : 2, i);
  }

  //Move the tile in the direction
  List<Tile> move(SwipeDirection direction, List<Tile> boardTiles) {
    bool asc =
        direction == SwipeDirection.left || direction == SwipeDirection.up;
    bool vert =
        direction == SwipeDirection.up || direction == SwipeDirection.down;
    // Sort the list of tiles by index.
    // If user swipes vertically use the verticalOrder list to retrieve the up/down index

    boardTiles.sort(((a, b) =>
        (asc ? 1 : -1) *
        (vert
            ? verticalOrder[a.index].compareTo(verticalOrder[b.index])
            : a.index.compareTo(b.index))));

    List<Tile> tiles = [];

    for (int i = 0, l = boardTiles.length; i < l; i++) {
      var tile = boardTiles[i];

      // Calculate nextIndex for current tile.
      tile = calculate(tile, tiles, direction);
      tiles.add(tile);

      if (i + 1 < l) {
        var next = boardTiles[i + 1];
        // Assign current tile nextIndex or index to the next tile if its allowed to be moved.
        if (tile.value == next.value) {
          // If user swipes vertically use the verticalOrder list to retrieve the up/down index else use the existing index
          var index = vert ? verticalOrder[tile.index] : tile.index,
              nextIndex = vert ? verticalOrder[next.index] : next.index;
          if (inRange(index, nextIndex)) {
            tiles.add(next.copyWith(nextIndex: tile.nextIndex));
            // Skip next iteration if next tile was already assigned nextIndex.
            i += 1;
            continue;
          }
        }
      }
    }
    return tiles;
  }
}
