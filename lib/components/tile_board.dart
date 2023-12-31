import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';
import '../managers/board.dart';

import 'animated_tile.dart';
import 'button.dart';

class TileBoardWidget extends ConsumerWidget {
  const TileBoardWidget(
      {super.key, required this.moveAnimation, required this.scaleAnimation});

  final CurvedAnimation moveAnimation;
  final CurvedAnimation scaleAnimation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<int, String> enToGeez = {
      2: '፩',
      4: '፪',
      8: '፫',
      16: '፬',
      32: '፭',
      64: '፮',
      128: '፯',
      256: '፰',
      512: '፱',
      1024: '፲',
      2048: '፳',
    };
    final board = ref.watch(boardManager);

    //Decides the maximum size the Board can be based on the shortest size of the screen.
    final size = max(
        290.0,
        min((MediaQuery.of(context).size.shortestSide * 0.90).floorToDouble(),
            460.0));

    //Decide the size of the tile based on the size of the board minus the space between each tile.
    final sizePerTile = (size / 4).floorToDouble();
    final tileSize = sizePerTile - 12.0 - (12.0 / 4);
    final boardSize = sizePerTile * 4;
    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: Stack(
        children: [
          ...List.generate(board.tiles.length, (i) {
            var tile = board.tiles[i];

            return AnimatedTile(
              key: ValueKey(tile.id),
              tile: tile,
              moveAnimation: moveAnimation,
              scaleAnimation: scaleAnimation,
              size: tileSize,
              //In order to optimize performances and prevent unneeded re-rendering the actual tile is passed as child to the AnimatedTile
              //as the tile won't change for the duration of the movement (apart from it's position)
              child: Container(
                width: tileSize,
                height: tileSize,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(tileColors[tile.value]!.withAlpha(200).value),
                        Color(tileColors[tile.value]!.value),
                      ]),
                  borderRadius: BorderRadius.circular(tileSize),
                ),
                child: Center(
                    child: Text(
                  '${enToGeez[tile.value]}',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24.0,
                      color: backgroundColor),
                )),
              ),
            );
          }),
          if (board.over)
            Positioned.fill(
                child: Container(
              color: overlayColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    board.won ? 'አሸንፈዋል!' : 'አበቃለት!',
                    style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 64.0),
                  ),
                  ButtonWidget(
                    text: board.won ? 'አዲስ ጨዋታ' : 'እንደገና ይሞክሩ',
                    onPressed: () {
                      ref.read(boardManager.notifier).newGame();
                    },
                  ),
                ],
              ),
            ))
        ],
      ),
    );
  }
}
