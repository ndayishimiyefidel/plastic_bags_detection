import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardVideoAd {
  static RewardedAd? _rewardedAd;
   bool _isAdLoaded = false;

  void loadRewardAd() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-2864387622629553/7419194207',
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
         _isAdLoaded=true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          if (kDebugMode) {
            print('Reward ad failed to load: $error');
          }
        },
      ),
    );
  }
  bool isRewardVideoAdLoaded() {
    return _isAdLoaded;
  }

  bool showRewardAd() {
    if (_rewardedAd != null && _isAdLoaded) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) {},
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          loadRewardAd(); // Load a new ad after it's dismissed
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          loadRewardAd(); // Load a new ad after it fails to show
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          if (kDebugMode) {
            print('$ad with reward ${RewardItem(reward.amount, reward.type)}');
          }
        },
      );

      return true; // Ad was shown successfully
    } else {
      return false; // Ad is not loaded
    }
  }
}
