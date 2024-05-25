import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:isra/const/colors.dart';
import 'package:isra/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: backgroundColor,
      allowImplicitScrolling: true,
      autoScrollDuration: 300000,
      infiniteAutoScroll: true,
      pages: [
        PageViewModel(
          title: "",
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'ወደ የትኛውም አቅጣጫ በማንሸራተት የቁጥር ንጣፎችን ያንቅሳቅሱ።',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              SvgPicture.asset(
                'assets/step1.svg',
                height: 400,
              ),
            ],
          ),
        ),
        PageViewModel(
          title: "",
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'ሁለት ንጣፎች በአንድ ረድፍ ካሉ፣ ወደ አንድ በመቅላቀል ቀጣዩን ቁጥር ይሰጣሉ።',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 40),
              SvgPicture.asset(
                'assets/step2.svg',
                height: 400,
              ),
              const SizedBox(height: 40),
              Text('ሰሌዳው ከሞላ ጨዋታው ያልቃል።',
                  style: TextStyle(fontSize: 18, color: textColor))
            ],
          ),
        ),
        PageViewModel(
          title: "",
          bodyWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                'ቁጥሮቹን በማቀላቀል ዕስራ (ሃያ) ይድረሱ።',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 40),
              SvgPicture.asset(
                'assets/step3.svg',
                height: 400,
              ),
            ],
          ),
        ),
      ],
      skipOrBackFlex: 0,
      nextFlex: 0,
      next: const Icon(
        Icons.arrow_forward,
        color: textColor,
      ),
      done: Container(
        child: const Text(
          'ጀምር',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: textColor,
          ),
        ),
      ),
      onDone: () => _onIntroEnd(context),
      dotsDecorator: DotsDecorator(
        activeColor: Theme.of(context).primaryColor,
        color: Theme.of(context).primaryColor.withOpacity(0.5),
        size: const Size.square(10),
        activeSize: const Size.square(17),
      ),
    );
  }
}
