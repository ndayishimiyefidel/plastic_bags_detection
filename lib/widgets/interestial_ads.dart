import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  Timer? _interstitialTimer;
 bool _isAdLoaded = false;
  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2864387622629553/2890041814',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          if (kDebugMode) {
            print('InterstitialAd failed to load: $error');
          }
        },
      ),
    );
  }
  void showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      if (kDebugMode) {
        print('InterstitialAd is not loaded yet.');
      }
    }
  }

  bool isInterstitialAdLoaded() {
    return _isAdLoaded;
  }

  void startInterstitialTimer(int minutes) {
    // Start the timer to show the interstitial ad every specified minutes
    _interstitialTimer = Timer.periodic(Duration(minutes: minutes), (timer) {
      if (isInterstitialAdLoaded()) {
        showInterstitialAd();
      } else {
        // Handle the case when the ad is not loaded yet
      }
    });
  }

  void dispose() {
    _interstitialAd?.dispose();
    _interstitialTimer?.cancel();
  }
}
