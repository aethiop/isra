import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:isra/tutorial.dart';

import 'components/button.dart';
import 'const/colors.dart';
import 'game.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
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
                      ButtonWidget(
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
