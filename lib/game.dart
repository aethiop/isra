import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:isra/const/constants.dart';
import 'package:isra/helpers/ad_mob_service.dart';
import 'package:isra/home.dart';

import 'components/button.dart';
import 'components/score_board.dart';
import 'components/tile_board.dart';
import 'const/colors.dart';
import 'managers/board.dart';

class Game extends ConsumerStatefulWidget {
  final int boardSize;
  const Game({Key? key, required this.boardSize}) : super(key: key);

  @override
  ConsumerState<Game> createState() => _GameState();
}

class _GameState extends ConsumerState<Game>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  BannerAd? _bannerAd;
  AnimationController? _moveController;
  CurvedAnimation? _moveAnimation;
  AnimationController? _scaleController;
  CurvedAnimation? _scaleAnimation;

  //The contoller used to move the the tiles
  final GlobalKey _boardKey = GlobalKey();
  void _initializeAnimations() {
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          ref.read(boardManager(widget.boardSize).notifier).merge();
          _scaleController!.forward(from: 0.0);
        }
      });
    _moveAnimation = CurvedAnimation(
      parent: _moveController!,
      curve: Curves.easeIn,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (ref.read(boardManager(widget.boardSize).notifier).endRound()) {
            _moveController!.forward(from: 0.0);
          }
        }
      });
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController!,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void initState() {
    //Add an Observer for the Lifecycles of the App
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _initializeAnimations();
    _createBannerAd();
  }

  void _createBannerAd() {
    _bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerAdListener,
        request: const AdRequest())
      ..load();
  }

  @override
  Widget build(BuildContext context) {
    final board = ref.watch(boardManager(widget.boardSize));

    final size = max(
        290.0,
        min((MediaQuery.of(context).size.shortestSide * 0.90).floorToDouble(),
            460.0));

    final sizePerTile = (size / widget.boardSize).floorToDouble();
    final tileSize = sizePerTile - 12.0 - (12.0 / widget.boardSize);

    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        //Move the tile with the arrows on the keyboard on Desktop
        if (ref.read(boardManager(widget.boardSize).notifier).onKey(event)) {
          _moveController!.forward(from: 0.0);
        }
      },
      child: SwipeDetector(
        onSwipe: (direction, offset) {
          if (ref
              .read(boardManager(widget.boardSize).notifier)
              .whenMove(direction)) {
            _moveController!.forward(from: 0.0);
          }
        },
        child: Scaffold(
            backgroundColor: backgroundColor,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!board.over && !board.won)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final board =
                                ref.watch(boardManager(widget.boardSize));
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
                                          Color(
                                              tileColors[highestValue]!.value),
                                        ]),
                                    borderRadius: BorderRadius.circular(18.0),
                                  ),
                                  child: Center(
                                      child: Text(
                                    '${geezSymbols[highestValue]}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 48.0,
                                        color: tileTextColors[highestValue]),
                                  )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    geezWords[highestValue]!,
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
                            ScoreBoard(boardSize: widget.boardSize),
                            const SizedBox(
                              height: 32.0,
                            ),
                            Row(
                              children: [
                                ButtonWidget(
                                  icon: Icons.home,
                                  onPressed: () {
                                    // Go to about
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Home()),
                                    );
                                  },
                                ),
                                const SizedBox(
                                  width: 16.0,
                                ),
                                ButtonWidget(
                                  icon: Icons.undo,
                                  onPressed: () {
                                    //Undo the round.
                                    ref
                                        .read(boardManager(widget.boardSize)
                                            .notifier)
                                        .undo();
                                  },
                                ),
                                const SizedBox(
                                  width: 16.0,
                                ),
                                ButtonWidget(
                                  icon: Icons.refresh,
                                  onPressed: () {
                                    //Restart the game
                                    ref
                                        .read(boardManager(widget.boardSize)
                                            .notifier)
                                        .newGame();
                                  },
                                ),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  const SizedBox(
                    height: 32.0,
                  ),
                  RepaintBoundary(
                    key: _boardKey,
                    child: TileBoardWidget(
                        boardKey: _boardKey,
                        moveAnimation: _moveAnimation!,
                        scaleAnimation: _scaleAnimation!,
                        board: board,
                        boardSize: widget.boardSize,
                        tileSize: tileSize),
                  )
                ],
              )),
            ),
            bottomNavigationBar: _bannerAd == null
                ? null
                : Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    height: 52,
                    child: AdWidget(ad: _bannerAd!),
                  )),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Save current state when the app becomes inactive
    if (state == AppLifecycleState.inactive) {
      ref.read(boardManager(widget.boardSize).notifier).save();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    //Remove the Observer for the Lifecycles of the App
    WidgetsBinding.instance.removeObserver(this);

    //Dispose the animations.
    _moveAnimation!.dispose();
    _scaleAnimation!.dispose();
    _moveController!.dispose();
    _scaleController!.dispose();
    super.dispose();
  }
}
