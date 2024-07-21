import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isra/const/constants.dart';
import 'package:isra/home.dart';
import 'package:isra/tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/board_adapter.dart';

void toggleSound() async {
  var prefs = await SharedPreferences.getInstance();
  bool isSoundEnabled = !(prefs.getBool(soundEnabled) ?? true);
  prefs.setBool(soundEnabled, isSoundEnabled);

  if (isSoundEnabled) {
    FlameAudio.bgm.play('addis-ababa.mp3', volume: 1);
  } else {
    FlameAudio.bgm.stop();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  await Hive.initFlutter();
  Hive.registerAdapter(BoardAdapter());
  var prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool(firstTime) ?? true;
  bool isSoundEnabled = prefs.getBool(soundEnabled) ?? true;

  runApp(IsraApp(isFirstTime: isFirstTime, isSoundEnabled: isSoundEnabled));
}

class IsraApp extends StatefulWidget {
  final bool isFirstTime;
  final bool isSoundEnabled;
  const IsraApp(
      {Key? key, required this.isFirstTime, required this.isSoundEnabled})
      : super(key: key);

  @override
  _IsraAppState createState() => _IsraAppState();
}

class _IsraAppState extends State<IsraApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isSoundEnabled) {
      FlameAudio.bgm.play('addis-ababa.mp3', volume: 1);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlameAudio.bgm.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      FlameAudio.bgm.pause();
    } else if (state == AppLifecycleState.resumed) {
      var prefs = await SharedPreferences.getInstance();
      bool isSoundEnabled = prefs.getBool(soundEnabled) ?? true;
      if (isSoundEnabled) {
        FlameAudio.bgm.resume();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: 'NotoSansEthiopic', primarySwatch: Colors.grey),
        title: 'ዕሥራ',
        home: widget.isFirstTime
            ? Tutorial(firstTime: widget.isFirstTime)
            : Home(),
      ),
    );
  }
}
