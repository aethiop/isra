import 'dart:math';

import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:uuid/uuid.dart';

import '../models/tile.dart';

mixin BoardUtils {
  List<int> getVerticalOrder(int boardSize) {
    List<int> order = [];
    for (int i = 0; i < boardSize; i++) {
      for (int j = 0; j < boardSize; j++) {
        order.add(j * boardSize + i);
      }
    }
    return order;
  }

  bool inRange(int index, int nextIndex, int boardSize) {
    return index ~/ boardSize == nextIndex ~/ boardSize;
  }

  Tile calculate(
      Tile tile, List<Tile> tiles, SwipeDirection direction, int boardSize) {
    bool asc =
        direction == SwipeDirection.left || direction == SwipeDirection.up;
    bool vert =
        direction == SwipeDirection.up || direction == SwipeDirection.down;
    List<int> verticalOrder = getVerticalOrder(boardSize);

    int index = vert ? verticalOrder.indexOf(tile.index) : tile.index;
    int nextIndex;

    if (asc) {
      nextIndex = (index ~/ boardSize) * boardSize;
    } else {
      nextIndex = (index ~/ boardSize + 1) * boardSize - 1;
    }

    if (tiles.isNotEmpty) {
      var last = tiles.last;
      var lastIndex = last.nextIndex ?? last.index;
      lastIndex = vert ? verticalOrder.indexOf(lastIndex) : lastIndex;
      if (inRange(index, lastIndex, boardSize)) {
        nextIndex = lastIndex + (asc ? 1 : -1);
      }
    }

    return tile.copyWith(
        nextIndex: vert ? verticalOrder[nextIndex] : nextIndex);
  }

  Tile random(List<int> indexes, int boardSize) {
    var i = 0;
    var rng = Random();
    do {
      i = rng.nextInt(boardSize * boardSize);
    } while (indexes.contains(i));
    return Tile(Uuid().v4(), rng.nextInt(10) == 0 ? 4 : 2, i);
  }

  List<Tile> move(
      SwipeDirection direction, List<Tile> boardTiles, int boardSize) {
    bool asc =
        direction == SwipeDirection.left || direction == SwipeDirection.up;
    bool vert =
        direction == SwipeDirection.up || direction == SwipeDirection.down;
    List<int> verticalOrder = getVerticalOrder(boardSize);

    boardTiles.sort(((a, b) =>
        (asc ? 1 : -1) *
        (vert
            ? verticalOrder
                .indexOf(a.index)
                .compareTo(verticalOrder.indexOf(b.index))
            : a.index.compareTo(b.index))));

    List<Tile> tiles = [];

    for (int i = 0, l = boardTiles.length; i < l; i++) {
      var tile = boardTiles[i];

      tile = calculate(tile, tiles, direction, boardSize);
      tiles.add(tile);

      if (i + 1 < l) {
        var next = boardTiles[i + 1];
        if (tile.value == next.value) {
          var index = vert ? verticalOrder[tile.index] : tile.index,
              nextIndex = vert ? verticalOrder[next.index] : next.index;
          if (inRange(index, nextIndex, boardSize)) {
            tiles.add(next.copyWith(nextIndex: tile.nextIndex));
            i += 1;
            continue;
          }
        }
      }
    }
    return tiles;
  }
}
