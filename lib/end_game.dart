import 'package:flutter/material.dart';
import 'const/colors.dart';

class EndGame extends StatelessWidget {
  const EndGame({Key? key}) : super(key: key);
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
                children: [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
