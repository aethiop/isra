import 'package:flutter/material.dart';
import 'package:isra/about.dart';
import 'package:isra/onboarding.dart';

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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(cardColor.withAlpha(50).value),
                  Color(cardColor.withAlpha(600).value),
                ]),
            color: cardColor,
            borderRadius: BorderRadius.circular(21.0),
          ),
          padding: EdgeInsets.all(21),
          margin: EdgeInsets.all(21),
          // home page with a button to start the game
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Text(
                    'ዕሥራ (፳)',
                    style: TextStyle(
                        fontFamily: 'AdwaSansSerif',
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white),
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
                                builder: (context) => const OnboardingScreen()),
                          );
                        }),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
