import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:isra/const/constants.dart';
import 'package:isra/tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/board_size_selector.dart';
import 'components/button.dart';
import 'const/colors.dart';
import 'game.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSoundEnabled = false; // Default to true
  int selectedBoardSize = 4; // Default to 4x4

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      isSoundEnabled = prefs.getBool(soundEnabled) ?? true;
      selectedBoardSize = prefs.getInt(boardSizeKey) ?? 4;
    });
  }

  Future<void> toggleSound() async {
    setState(() {
      isSoundEnabled = !isSoundEnabled;
    });
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool(soundEnabled, isSoundEnabled);

    if (isSoundEnabled) {
      FlameAudio.bgm.play('addis-ababa.mp3', volume: 1);
    } else {
      FlameAudio.bgm.stop();
    }
  }

  Future<void> setBoardSize(int size) async {
    setState(() {
      selectedBoardSize = size;
    });
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt(boardSizeKey, size);
  }

  @override
  Widget build(BuildContext context) {
    IconData soundIcon = isSoundEnabled ? Icons.volume_up : Icons.volume_off;
    return Scaffold(
      backgroundColor: backgroundColor,
      // swipable cards for other games currently shows coming soon no app bar

      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(tileColors[targetScores[selectedBoardSize]]!
                                .withAlpha(200)
                                .value),
                            Color(tileColors[targetScores[selectedBoardSize]]!
                                .value),
                          ]),
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    child: Center(
                        child: Text(
                      '${geezSymbols[targetScores[selectedBoardSize]]}',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 48.0,
                          color:
                              tileTextColors[targetScores[selectedBoardSize]]),
                    )),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    geezWords[targetScores[selectedBoardSize]]!,
                    style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: textColor),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                      height: 180, // Adjust this height as needed
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: boardSizes
                            .map((size) => BoardSizeSelector(
                                  size: size,
                                  isSelected: size == selectedBoardSize,
                                  onTap: () => setBoardSize(size),
                                ))
                            .toList(),
                      )),
                  const SizedBox(height: 40),
                  // select the game mode
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ButtonWidget(
                          text: 'ጨዋታ',
                          icon: Icons.play_arrow,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Game(boardSize: selectedBoardSize)));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ButtonWidget(
                            text: 'About',
                            icon: Icons.info,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Tutorial(
                                          firstTime: false,
                                        )),
                              );
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ButtonWidget(
                            text: 'About',
                            icon: soundIcon,
                            onPressed: () {
                              toggleSound();
                            }),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
