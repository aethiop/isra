import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static bool development = false;
  static String? get bannerAdUnitId {
    if (development) {
      return 'ca-app-pub-3940256099942544/9214589741';
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-1683107150413775/2129146645';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1683107150413775/2491559985';
    }
    return null;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
      onAdLoaded: (Ad ad) => print('Ad loaded: ${ad.adUnitId}.'),
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
        print('Ad failed to load: ${ad.adUnitId}, $error');
      },
      onAdOpened: (Ad ad) => print('Ad opened: ${ad.adUnitId}.'),
      onAdClosed: (Ad ad) => print('Ad closed: ${ad.adUnitId}.'),
      onAdImpression: (Ad ad) => print('Ad impression: ${ad.adUnitId}.'),
      onAdClicked: (Ad ad) => print('Ad clicked: ${ad.adUnitId}.'));
}
