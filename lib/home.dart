import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:isra/const/constants.dart';
import 'package:isra/tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/button.dart';
import 'const/colors.dart';
import 'game.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSoundEnabled = false;

  getSoundStatus() async {
    var prefs = await SharedPreferences.getInstance();
    return prefs.getBool(soundEnabled) ?? true;
  }

  @override
  void initState() {
    super.initState();
  }

  void setSoundStatus(bool status) async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool(soundEnabled, status);
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
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(21.0)),
                    child: SvgPicture.asset(
                      'assets/icon.svg',
                      height: 100,
                      width: 100,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Text(
                      'ዕሥራ',
                      style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: textColor),
                    ),
                  ),
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
                                  builder: (context) => const Game()),
                            );
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
                              if (FlameAudio.bgm.isPlaying) {
                                FlameAudio.bgm.pause();
                                setState(() {
                                  isSoundEnabled = false;
                                  setSoundStatus(false);
                                });
                              } else {
                                FlameAudio.bgm.play(
                                  'addis-ababa.mp3',
                                );
                                setState(() {
                                  isSoundEnabled = true;
                                  setSoundStatus(true);
                                });
                              }
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
