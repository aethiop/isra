import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1683107150413775/2129146645';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1683107150413775/2491559985';
    }
    return null;
  }

  static String? get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1683107150413775/2930543682';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1683107150413775/1617462013';
    }
    return null;
  }

  static String? get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-1683107150413775/7197091752';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-1683107150413775/8510173429';
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
