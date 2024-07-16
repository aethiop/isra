import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/tile.dart';
import '../models/board.dart';

import 'next_direction.dart';
import 'round.dart';
import 'package:isra/helpers/board_utils.dart';

class BoardManager extends StateNotifier<Board> with BoardUtils {
  // We will use this list to retrieve the right index when user swipes up/down
  // which will allow us to reuse most of the logic.
  final StateNotifierProviderRef ref;
  final Future<Box<Board>> _box;

  BoardManager(this.ref, this._box) : super(Board.newGame(0, [])) {
    //Load the last saved state or start a new game.
    load();
  }
  void load() async {
    //Access the box and get the first item at index 0
    //which will always be just one item of the Board model
    //and here we don't need to call fromJson function of the board model
    //in order to construct the Board model
    //instead the adapter we added earlier will do that automatically.
    //If there is no save locally it will start a new game.
    final box = await _box;
    state = box.get(0) ?? _newGame();
  }

  // Create New Game state.
  Board _newGame() {
    return Board.newGame(
        state.score > state.best ? state.score : state.best, [random([])]);
  }

  // Start New Game
  void newGame() {
    state = _newGame();
  }

  bool whenMove(SwipeDirection direction) {
    if (state.over) {
      return false;
    }
    List<Tile> tiles = move(direction, state.tiles);
    // Assign immutable copy of the new board state and trigger rebuild.
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
      tiles.add(random(indexes));
    }
    state = state.copyWith(score: score, tiles: tiles);
  }

  //Finish round, win or loose the game.
  void _endRound() async {
    var gameOver = true, gameWon = false;
    List<Tile> tiles = [];

    //If there is no more empty place on the board
    if (state.tiles.length == 16) {
      state.tiles.sort(((a, b) => a.index.compareTo(b.index)));

      for (int i = 0, l = state.tiles.length; i < l; i++) {
        var tile = state.tiles[i];

        //If there is a tile with 2048 then the game is won.
        if (tile.value >= 2048) {
          gameWon = true;
        }

        var x = (i - (((i + 1) / 4).ceil() * 4 - 4));

        if (x > 0 && i - 1 >= 0) {
          //If tile can be merged with left tile then game is not lost.
          var left = state.tiles[i - 1];
          if (tile.value == left.value) {
            gameOver = false;
          }
        }

        if (x < 3 && i + 1 < l) {
          //If tile can be merged with right tile then game is not lost.
          var right = state.tiles[i + 1];
          if (tile.value == right.value) {
            gameOver = false;
          }
        }

        if (i - 4 >= 0) {
          //If tile can be merged with above tile then game is not lost.
          var top = state.tiles[i - 4];
          if (tile.value == top.value) {
            gameOver = false;
          }
        }

        if (i + 4 < l) {
          //If tile can be merged with the bellow tile then game is not lost.
          var bottom = state.tiles[i + 4];
          if (tile.value == bottom.value) {
            gameOver = false;
          }
        }
        //Set the tile merged: false
        tiles.add(tile.copyWith(merged: false));
      }
    } else {
      //There is still a place on the board to add a tile so the game is not lost.
      gameOver = false;
      for (var tile in state.tiles) {
        //If there is a tile with 2048 then the game is won.
        if (tile.value == 2048) {
          gameWon = true;
        }
        //Set the tile merged: false
        tiles.add(tile.copyWith(merged: false));
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

final boardManager = StateNotifierProvider<BoardManager, Board>((ref) {
  final box = Hive.openBox<Board>('board');
  return BoardManager(ref, box);
});
