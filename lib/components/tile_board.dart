import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isra/components/empy_board.dart';
import 'package:isra/components/score_board.dart';
import 'package:isra/models/board.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../const/colors.dart';
import '../managers/board.dart';
import 'animated_tile.dart';
import 'button.dart';

class TileBoardWidget extends ConsumerWidget {
  final CurvedAnimation moveAnimation;
  final CurvedAnimation scaleAnimation;
  final Board board;
  final int boardSize;
  final double tileSize;
  final GlobalKey boardKey;

  const TileBoardWidget(
      {Key? key,
      required this.moveAnimation,
      required this.scaleAnimation,
      required this.board,
      required this.boardSize,
      required this.tileSize,
      required this.boardKey})
      : super(key: key);

  Map<String, double> getTilePosition(int index) {
    final x = ((index + 1) / boardSize).ceil();
    final y = x - 1;

    final top = y * tileSize + (x * 12.0);
    final z = (index - (boardSize * y));
    final left = z * tileSize + ((z + 1) * 12.0);

    return {'top': top, 'left': left};
  }

  Future<ui.Image> _captureBoardImage() async {
    RenderRepaintBoundary boundary =
        boardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    return image;
  }

  Future<void> _shareBoard() async {
    ui.Image image = await _captureBoardImage();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer;
    final tempDir = await getTemporaryDirectory();
    final file = await File(
            '${tempDir.path}/isra_${DateTime.now().microsecondsSinceEpoch}.png')
        .create();
    await file.writeAsBytes(
        buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    await Share.shareXFiles([XFile(file.path)]);
  }

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

    final size = max(
        290.0,
        min((MediaQuery.of(context).size.shortestSide * 0.90).floorToDouble(),
            460.0));

    final sizePerTile = (size / boardSize).floorToDouble();
    final actualTileSize = sizePerTile - 12.0 - (12.0 / boardSize);
    final actualBoardSize = sizePerTile * boardSize;

    Widget buildBoard() {
      return Stack(children: [
        EmptyBoardWidget(boardSize: boardSize),
        SizedBox(
          width: actualBoardSize,
          height: actualBoardSize,
          child: Stack(
            children: board.tiles.map((tile) {
              return AnimatedTile(
                key: ValueKey(tile.id),
                tile: tile,
                moveAnimation: moveAnimation,
                scaleAnimation: scaleAnimation,
                size: actualTileSize,
                boardSize: boardSize,
                getPosition: getTilePosition,
                child: Container(
                  decoration: BoxDecoration(
                    color: tileColors[tile.value],
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Center(
                    child: Text(
                      '${enToGeez[tile.value]}',
                      style: TextStyle(
                        fontSize: tileSize *
                            0.4, //use the tile size to get the font size
                        color: tileTextColors[tile.value],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ]);
    }

    return Stack(
      children: [
        buildBoard(),
        if (board.over)
          GameOverScreen(
            board: board,
            boardSize: boardSize,
            buildBoard: buildBoard,
            onRestart: () {
              ref.read(boardManager(boardSize).notifier).newGame();
            },
            onShare: _shareBoard,
          ),
        if (board.won && !board.over)
          GameWonScreen(
            board: board,
            boardSize: boardSize,
            buildBoard: buildBoard,
            onContinue: () {
              ref.read(boardManager(boardSize).notifier).continuePlaying();
            },
            onRestart: () {
              ref.read(boardManager(boardSize).notifier).newGame();
            },
            onShare: _shareBoard,
          ),
      ],
    );
  }
}

class GameOverScreen extends StatelessWidget {
  final Board board;
  final int boardSize;
  final Widget Function() buildBoard;
  final VoidCallback onRestart;
  final VoidCallback onShare;

  const GameOverScreen({
    Key? key,
    required this.board,
    required this.boardSize,
    required this.buildBoard,
    required this.onRestart,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: overlayColor.withOpacity(1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'አበቃለት!',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 64.0,
            ),
          ),
          SizedBox(height: 20),
          ScoreBoard(boardSize: boardSize, gapSize: 20.0),
          SizedBox(height: 20),
          buildBoard(),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWidget(onPressed: onRestart, icon: Icons.refresh),
              SizedBox(width: 20),
              ButtonWidget(
                onPressed: onShare,
                icon: Icons.share,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GameWonScreen extends StatelessWidget {
  final Board board;
  final int boardSize;
  final Widget Function() buildBoard;
  final VoidCallback onContinue;
  final VoidCallback onRestart;
  final VoidCallback onShare;

  const GameWonScreen({
    Key? key,
    required this.board,
    required this.boardSize,
    required this.buildBoard,
    required this.onContinue,
    required this.onRestart,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: overlayColor.withOpacity(1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'እንኳን ድስ አላችሁ!',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 48.0,
            ),
          ),
          SizedBox(height: 20),
          buildBoard(),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWidget(onPressed: onContinue, icon: Icons.arrow_forward),
              SizedBox(width: 20),
              ButtonWidget(onPressed: onRestart, icon: Icons.refresh),
              SizedBox(width: 20),
              ButtonWidget(
                onPressed: onShare,
                icon: Icons.share,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
