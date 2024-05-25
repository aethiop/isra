import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:isra/about.dart';

import 'components/button.dart';
import 'components/empy_board.dart';
import 'components/score_board.dart';
import 'components/tile_board.dart';
import 'const/colors.dart';
import 'managers/board.dart';

class Game extends ConsumerStatefulWidget {
  const Game({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GameState();
}

class _GameState extends ConsumerState<Game>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  //The contoller used to move the the tiles
  late final AnimationController _moveController = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  )..addStatusListener((status) {
      //When the movement finishes merge the tiles and start the scale animation which gives the pop effect.
      if (status == AnimationStatus.completed) {
        ref.read(boardManager.notifier).merge();
        _scaleController.forward(from: 0.0);
      }
    });

  //The curve animation for the move animation controller.
  late final CurvedAnimation _moveAnimation = CurvedAnimation(
    parent: _moveController,
    curve: Curves.easeIn,
  );

  //The contoller used to show a popup effect when the tiles get merged
  late final AnimationController _scaleController = AnimationController(
    duration: const Duration(milliseconds: 350),
    vsync: this,
  )..addStatusListener((status) {
      //When the scale animation finishes end the round and if there is a queued movement start the move controller again for the next direction.
      if (status == AnimationStatus.completed) {
        if (ref.read(boardManager.notifier).endRound()) {
          _moveController.forward(from: 0.0);
        }
      }
    });

  //The curve animation for the scale animation controller.
  late final CurvedAnimation _scaleAnimation = CurvedAnimation(
    parent: _scaleController,
    curve: Curves.easeInOutSine,
  );

  @override
  void initState() {
    //Add an Observer for the Lifecycles of the App
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  String _getAmharicWord(int value) {
    final amharicWords = {
      2: 'አሐዱ',
      4: 'ክልኤቱ',
      8: 'ሠለስቱ',
      16: 'አርባዕቱ',
      32: 'ኀምስቱ',
      64: 'ስድስቱ',
      128: 'ሰብዐቱ',
      256: 'ሰማንቱ',
      512: 'ተስዐቱ',
      1024: 'ዐሠርቱ',
      2048: 'እስራ',
    };
    return amharicWords[value] ?? '';
  }

  String? _latinToGeez(int value) {
    print(value);
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
    print(enToGeez[value]);
    return enToGeez[value];
  }

  @override
  Widget build(BuildContext context) {
    const String assetName = 'assets/icon.svg';

    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        //Move the tile with the arrows on the keyboard on Desktop
        if (ref.read(boardManager.notifier).onKey(event)) {
          _moveController.forward(from: 0.0);
        }
      },
      child: SwipeDetector(
        onSwipe: (direction, offset) {
          if (ref.read(boardManager.notifier).move(direction)) {
            _moveController.forward(from: 0.0);
          }
        },
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final board = ref.watch(boardManager);
                        final highestTile = board.tiles
                            .reduce((a, b) => a.value > b.value ? a : b);
                        final highestValue = highestTile.value;
                        final size = max(
                            290.0,
                            min(
                                (MediaQuery.of(context).size.shortestSide *
                                        0.90)
                                    .floorToDouble(),
                                460.0));

                        //Decide the size of the tile based on the size of the board minus the space between each tile.
                        final sizePerTile = (size / 4).floorToDouble();
                        final tileSize = sizePerTile - 12.0 - (12.0 / 4);
                        final geezNumber = _latinToGeez(highestValue);
                        print(geezNumber);
                        return Column(
                          children: [
                            Container(
                              width: tileSize,
                              height: tileSize,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(tileColors[highestValue]!
                                          .withAlpha(200)
                                          .value),
                                      Color(tileColors[highestValue]!.value),
                                    ]),
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              child: Center(
                                  child: Text(
                                '${_latinToGeez(highestValue)}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 48.0,
                                    color: tileTextColors[highestValue]),
                              )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                _getAmharicWord(highestValue),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: textColor),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const ScoreBoard(),
                        const SizedBox(
                          height: 32.0,
                        ),
                        Row(
                          children: [
                            ButtonWidget(
                              icon: Icons.undo,
                              onPressed: () {
                                //Undo the round.
                                ref.read(boardManager.notifier).undo();
                              },
                            ),
                            const SizedBox(
                              width: 16.0,
                            ),
                            ButtonWidget(
                              icon: Icons.refresh,
                              onPressed: () {
                                //Restart the game
                                ref.read(boardManager.notifier).newGame();
                              },
                            ),
                            const SizedBox(
                              width: 16.0,
                            ),
                            ButtonWidget(
                              icon: Icons.info_outline_rounded,
                              onPressed: () {
                                // Go to about
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const About()),
                                );
                              },
                            )
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 32.0,
              ),
              Stack(
                children: [
                  const EmptyBoardWidget(),
                  TileBoardWidget(
                      moveAnimation: _moveAnimation,
                      scaleAnimation: _scaleAnimation)
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Save current state when the app becomes inactive
    if (state == AppLifecycleState.inactive) {
      ref.read(boardManager.notifier).save();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    //Remove the Observer for the Lifecycles of the App
    WidgetsBinding.instance.removeObserver(this);

    //Dispose the animations.
    _moveAnimation.dispose();
    _scaleAnimation.dispose();
    _moveController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}
