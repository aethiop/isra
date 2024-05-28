import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_detector/flutter_swipe_detector.dart';
import 'package:isra/home.dart';
import 'package:isra/managers/tutorial.dart';

import 'components/button.dart';
import 'components/empy_board.dart';
import 'components/tile_board.dart';
import 'const/colors.dart';

class Tutorial extends ConsumerStatefulWidget {
  const Tutorial({super.key, required this.firstTime});
  final bool firstTime;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TutorialState();
}

class _TutorialState extends ConsumerState<Tutorial>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  //The contoller used to move the the tiles
  late final AnimationController _moveController = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  )..addStatusListener((status) {
      //When the movement finishes merge the tiles and start the scale animation which gives the pop effect.
      if (status == AnimationStatus.completed) {
        ref.read(tutorialManager.notifier).merge();
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
        if (ref.read(tutorialManager.notifier).endRound()) {
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

  @override
  Widget build(BuildContext context) {
    final tutorialManagerNotifier = ref.read(tutorialManager.notifier);
    final tutorialBoard = ref.watch(tutorialManager);
    final isBoardLocked = tutorialManagerNotifier.isBoardLocked;
    final tutorialStep = tutorialManagerNotifier.tutorialStep;

    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (!isBoardLocked && tutorialManagerNotifier.onKey(event)) {
          if (tutorialStep == 1 || tutorialStep == 3) {
            tutorialManagerNotifier.nextTutorialStep();
          }
          _moveController.forward(from: 0.0);
        }
      },
      child: SwipeDetector(
        onSwipe: (direction, offset) {
          if (!isBoardLocked &&
              ref.read(tutorialManager.notifier).whenMove(direction)) {
            // Timeout and nextStep
            if (tutorialStep == 1) {
              tutorialManagerNotifier.nextTutorialStep();
            }
            _moveController.forward(from: 0.0);
          }
        },
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          'መመርያ',
                          style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      if (!widget.firstTime)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              icon: Icons.refresh,
                              onPressed: () {
                                //Restart the game
                                tutorialManagerNotifier.startTutorial();
                              },
                            ),
                          ],
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  tutorialDetail(tutorialStep),

                  const SizedBox(
                    height: 16.0,
                  ),
                  Expanded(
                    flex: 0,
                    child: Center(
                      child: Stack(
                        children: [
                          const EmptyBoardWidget(), // Display walls when reaching step 2
                          TileBoardWidget(
                            moveAnimation: _moveAnimation,
                            scaleAnimation: _scaleAnimation,
                            board: tutorialBoard,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //if tutorial step is 1 tell them to swipe anywhere to start
                  const SizedBox(
                    height: 32.0,
                  ),

                  if (tutorialStep == 3)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ButtonWidget(
                        text: 'ዝግጁ ነኝ',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Home()),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tutorialDetail(int step) {
    final tutorialDetails = [
      'ቁጥሮቹን (ንጣፎቹን) ለማንቀሳቀስ ወደ የትኛውም አቅጣጫ ያንሸራትቱ።',
      'ቁጥሮቹን (ንጣፎቹን) ወደ ግድግዳው በማጋጨት በአንድ ረድፍ ሲሆንላችሁ መቀላቀል ይቻላል።',
      'ቁጥሮቹ (ንጣፎቹ)  በሚንቀሳቀሱበት ጊዜ አዳዲስ ቁጥሮች ይፈጠራሉ። ( ፳ ) ከደረሱ ያሸንፋሉ።',
      ''
    ];
    final detail = tutorialDetails[step - 1];

    return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Text(
          detail,
          style: TextStyle(
            fontSize: 18.0,
            color: textColor,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Save current state when the app becomes inactive
    if (state == AppLifecycleState.inactive) {
      ref.read(tutorialManager.notifier).save();
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
