import 'dart:math';
import 'package:flutter/material.dart';

import '../const/colors.dart';

class EmptyBoardWidget extends StatelessWidget {
  final int boardSize;
  const EmptyBoardWidget({Key? key, required this.boardSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = max(
        290.0,
        min((MediaQuery.of(context).size.shortestSide * 0.90).floorToDouble(),
            460.0));

    final sizePerTile = (size / this.boardSize).floorToDouble();
    final tileSize = sizePerTile - 12.0 - (12.0 / this.boardSize);
    final boardSize = sizePerTile * this.boardSize;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
      child: Stack(
        children: List.generate(this.boardSize * this.boardSize, (i) {
          var x = ((i + 1) / this.boardSize).ceil();
          var y = x - 1;

          var top = y * (tileSize) + (x * 12.0);
          var z = (i - (this.boardSize * y));
          var left = z * (tileSize) + ((z + 1) * 12.0);

          return Positioned(
            top: top,
            left: left,
            child: Container(
              width: tileSize,
              height: tileSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(emptyTileColor.withAlpha(200).value),
                      Color(emptyTileColor.withAlpha(180).value),
                    ]),
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
          );
        }),
      ),
    );
  }
}
