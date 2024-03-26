// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class AdBannerWidget extends StatefulWidget {
//   const AdBannerWidget({super.key});

//   @override
//   State createState() => _AdBannerWidgetState();
// }

// class _AdBannerWidgetState extends State<AdBannerWidget> {
//   BannerAd? _bannerAd;
//   bool _isAdLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _bannerAd = BannerAd(
//       adUnitId: 'ca-app-pub-2864387622629553/3130549113',
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (Ad ad) {
//           if (kDebugMode) {
//             print('Ad loaded: ${ad.adUnitId}');
//           }
//           setState(() {
//             _isAdLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (Ad ad, LoadAdError error) {
//           if (kDebugMode) {
//             print('Ad failed to load: ${ad.adUnitId}, $error');
//           }
//           ad.dispose(); // Dispose the ad to avoid memory leaks.
//           setState(() {
//             _isAdLoaded = false;
//           });
//         },
//         // ignore: avoid_print
//         onAdOpened: (Ad ad) => print('Ad opened: ${ad.adUnitId}'),
//         // ignore: avoid_print
//         onAdClosed: (Ad ad) => print('Ad closed: ${ad.adUnitId}'),
//       ),
//     );

//     _bannerAd?.load();
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Visibility(
//       visible: _isAdLoaded,
//       child: Container(
//         alignment: Alignment.bottomCenter,
//         width: _bannerAd?.size.width.toDouble(),
//         height: _bannerAd?.size.height.toDouble(),
//         child: AdWidget(ad: _bannerAd!),
//       ),
//     );
//   }
// }
