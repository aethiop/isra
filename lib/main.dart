import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:isra/home.dart';
import 'package:isra/tutorial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/board_adapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  //Make sure Hive is initialized first and only after register the adapter.
  await Hive.initFlutter();
  Hive.registerAdapter(BoardAdapter());

  var prefs = await SharedPreferences.getInstance();
  bool isFirstTime = prefs.getBool('first_time_1') ?? true;
  // await MobileAds.instance.initialize();
  runApp(IsraApp(isFirstTime: isFirstTime));
}

class IsraApp extends StatelessWidget {
  final bool isFirstTime;
  const IsraApp({key, required this.isFirstTime}) : super(key: key);

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
