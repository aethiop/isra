import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isra/const/constants.dart';

import '../models/tile.dart';
import '../models/board.dart';

import 'next_direction.dart';
import 'round.dart';
import 'package:isra/helpers/board_utils.dart';

class BoardManager extends StateNotifier<Board> with BoardUtils {
  final StateNotifierProviderRef ref;
  final Future<Box<Board>> _box;
  final int boardSize;

  BoardManager(this.ref, this._box, this.boardSize)
      : super(Board.newGame(0, [], boardSize)) {
    load();
  }

  void load() async {
    final box = await _box;
    state = box.get(0) ?? _newGame();
  }

  Board _newGame() {
    return Board.newGame(state.score > state.best ? state.score : state.best,
        [random([], boardSize)], boardSize);
  }

  // Start New Game
  void newGame() {
    state = _newGame();
  }

  void continuePlaying() {
    state = state.copyWith(won: false);
  }

  bool whenMove(SwipeDirection direction) {
    if (state.over) {
      return false;
    }
    List<Tile> tiles = move(direction, state.tiles, boardSize);
    state = state.copyWith(tiles: tiles, undo: state);
    return true;
  }

  //Merge tiles
  void merge() {
    List<Tile> tiles = [];
    var tilesMoved = false;
    List<int> indexes = [];
    var score = state.score;

    for (int i = 0, l = state.tiles.length; i < l; i++) {
      var tile = state.tiles[i];

      var value = tile.value, merged = false;

      if (i + 1 < l) {
        //sum the number of the two tiles with same index and mark the tile as merged and skip the next iteration.
        var next = state.tiles[i + 1];
        if (tile.nextIndex == next.nextIndex ||
            tile.index == next.nextIndex && tile.nextIndex == null) {
          value = tile.value + next.value;
          merged = true;
          score += tile.value;
          i += 1;
        }
      }

      if (merged || tile.nextIndex != null && tile.index != tile.nextIndex) {
        tilesMoved = true;
      }

      tiles.add(tile.copyWith(
          index: tile.nextIndex ?? tile.index,
          nextIndex: null,
          value: value,
          merged: merged));
      indexes.add(tiles.last.index);
    }

    //If tiles got moved then generate a new tile at random position of the available positions on the board.
    if (tilesMoved) {
      tiles.add(random(indexes, boardSize));
    }
    state = state.copyWith(score: score, tiles: tiles);
  }

  //Finish round, win or loose the game.
  void _endRound() async {
    var gameOver = false;
    var gameWon = false;
    List<Tile> tiles = [];

    // Sort tiles by index
    state.tiles.sort((a, b) => a.index.compareTo(b.index));

    // Check for empty spaces and 2048 tile
    bool hasEmptySpace = state.tiles.length < boardSize * boardSize;

    for (var tile in state.tiles) {
      if (tile.value >= targetScores[boardSize]!) {
        gameWon = true;
      }
      tiles.add(tile.copyWith(merged: false));
    }

    // If there are empty spaces, the game is not over
    if (hasEmptySpace) {
      gameOver = false;
    } else {
      // Check for possible moves
      gameOver = true;
      for (int i = 0; i < state.tiles.length; i++) {
        var tile = state.tiles[i];
        int row = i ~/ boardSize;
        int col = i % boardSize;

        // Check right
        if (col < boardSize - 1) {
          var right = state.tiles[i + 1];
          if (tile.value == right.value) {
            gameOver = false;
            break;
          }
        }

        // Check below
        if (row < boardSize - 1) {
          var below = state.tiles[i + boardSize];
          if (tile.value == below.value) {
            gameOver = false;
            break;
          }
        }
      }
    }

    state = state.copyWith(tiles: tiles, won: gameWon, over: gameOver);
  }

  //Mark the merged as false after the merge animation is complete.
  bool endRound() {
    //End round.
    _endRound();
    ref.read(roundManager.notifier).end();

    //If player moved too fast before the current animation/transition finished, start the move for the next direction
    var nextDirection = ref.read(nextDirectionManager);
    if (nextDirection != null) {
      whenMove(nextDirection);
      ref.read(nextDirectionManager.notifier).clear();
      return true;
    }
    return false;
  }

  //undo one round only
  void undo() {
    if (state.undo != null && !state.over) {
      state = state.copyWith(
          score: state.undo!.score,
          best: state.undo!.best,
          tiles: state.undo!.tiles);
    }
  }

  //Move the tiles using the arrow keys on the keyboard.
  bool onKey(RawKeyEvent event) {
    SwipeDirection? direction;
    if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
      direction = SwipeDirection.right;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
      direction = SwipeDirection.left;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowUp)) {
      direction = SwipeDirection.up;
    } else if (event.isKeyPressed(LogicalKeyboardKey.arrowDown)) {
      direction = SwipeDirection.down;
    }

    if (direction != null) {
      whenMove(direction);
      return true;
    }
    return false;
  }

  void save() async {
    final box = await _box;
    try {
      box.putAt(0, state);
    } catch (e) {
      box.add(state);
    }
  }
}

final boardManager =
    StateNotifierProviderFamily<BoardManager, Board, int>((ref, boardSize) {
  final box = Hive.openBox<Board>('board');
  return BoardManager(ref, box, boardSize);
});
