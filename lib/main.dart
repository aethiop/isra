import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isra/const/constants.dart';
import 'package:isra/home.dart';
import 'package:isra/tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/board_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  void startBgmMusic({double volume = 1}) {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('addis-ababa.mp3', volume: volume);
  }

  //Make sure Hive is initialized first and only after register the adapter.
  await Hive.initFlutter();
  Hive.registerAdapter(BoardAdapter());
  var prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool(firstTime) ?? true;
  bool isSoundEnabled = prefs.getBool(soundEnabled) ?? true;
  prefs.setBool(soundEnabled, isSoundEnabled);

  if (isSoundEnabled) {
    startBgmMusic();
  }
  // await MobileAds.instance.initialize();
  runApp(IsraApp(isFirstTime: isFirstTime, isSoundEnabled: isSoundEnabled));
}

class IsraApp extends StatelessWidget {
  final bool isFirstTime;
  final bool isSoundEnabled;
  const IsraApp({key, required this.isFirstTime, required this.isSoundEnabled})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: 'NotoSansEthiopic', primarySwatch: Colors.grey),
        title: 'ዕሥራ',
        home: isFirstTime
            ? Tutorial(firstTime: isFirstTime)
            : Home(), // Replace MainScreen() with your main screen widget
      ),
    );
  }
}
