// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_rice_analyser/screen/Welcome/home.dart';
import 'package:smart_rice_analyser/widgets/banner_widget.dart';
import 'package:smart_rice_analyser/widgets/interestial_ads.dart';
import 'package:smart_rice_analyser/widgets/reward_video_ad.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/constants.dart';

class DetectedImagesPage extends StatefulWidget {
  final String userRole;

  const DetectedImagesPage({Key? key, required this.userRole})
      : super(key: key);

  @override
  State createState() => _DetectedImagesPageState();
}

class _DetectedImagesPageState extends State<DetectedImagesPage> {
  late User user;
  late String userId;
  late RewardVideoAd rewardVideoAd;

  late SharedPreferences preferences;

  String? currentuserid;
  String? userRole, name, email, phone;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    userId = user.uid;
    rewardVideoAd = RewardVideoAd();
    getCurrentUser();
  }

  void getCurrentUser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid");
      userRole = preferences.getString("userRole");
      name = preferences.getString("name");
      email = preferences.getString("email");
      phone = preferences.getString("phone");
    });
  }

/*
0 pakistan
1 red gold
2 Pishori Rice
3 broken rice
4 person
5 unclassfied
*/
  Widget buildLabelWidget(String label) {
    switch (label) {
      case "pakistan":
        return Column(
          children: [
            const SizedBox(height: 8.0),
            Text(
              "This is : $label",
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        );
      case "person":
        return Column(
          children: [
            const SizedBox(height: 8.0),
            Text(
              "This  $label,not a rice",
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        );
      case "unclassfied":
        return const Column(
          children: [
            SizedBox(height: 8.0),
            Text(
              "This is unclassfied objects",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        );
      case "red gold":
        return Column(
          children: [
            const SizedBox(height: 8.0),
            Text(
              "This is $label rice",
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        );
      case "Pishori Rice":
        return Column(children: [
          const SizedBox(height: 8.0),
          Text(
            "This is $label",
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ]);
      case "broken rice":
        return Column(children: [
          const SizedBox(height: 8.0),
          Text(
            "This is : $label",
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ]);
      default:
        return const SizedBox.shrink(); // Hide the widget for unknown labels
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analyzed Rice Grain",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.userRole != "Admin"
            ? FirebaseFirestore.instance
                .collection('detectedResult')
                .where('userId', isEqualTo: userId)
                .orderBy('createdAt', descending: true)
                .snapshots()
            : FirebaseFirestore.instance
                .collection('detectedResult')
                .orderBy('createdAt', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error retrieving analysed image rice'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                children: [
                  const Text('No analysed rice grain imagesfound'),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Home(),
                          ),
                        );
                      },
                      child: const Text("Analyse Rice"))
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data =
                  (document.data() as Map<String, dynamic>);
              String imageUrl = data['imageUrl'];
              String imageName = data['name'];
              String label = data['detectedLabel'];
              bool isPlasticDetected = data['isPlasticDetected'];
              double confidence = data['detectedValue'];
              String? city = data['city'];
              String? country = data['country'];
              String? name = data['userName'];
              String? email = data['email'];
              String? phone = data['phone'];
              String confidencePercentage =
                  (confidence * 100).toStringAsFixed(2);
              double? latitude = data['latitude'];
              double? longitude = data['longitude'];
              String realCity = '';
              if (city != null && city.isNotEmpty && city != "") {
                realCity = "in $city";
              }

              bool hasLocation = latitude != null && longitude != null;

              return GestureDetector(
                onTap: () {
                  rewardVideoAd.loadRewardAd();

                  if (rewardVideoAd.isRewardVideoAdLoaded()) {
                    rewardVideoAd.showRewardAd();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailsPage(
                          imageUrl: imageUrl,
                          imageName: imageName,
                          isPlasticDetected: isPlasticDetected,
                          documentId: document.id,
                        ),
                      ),
                    );
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageDetailsPage(
                        imageUrl: imageUrl,
                        imageName: imageName,
                        isPlasticDetected: isPlasticDetected,
                        documentId: document.id,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.white,
                  elevation: 3.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        userRole != "User"
                            ? Text(
                                "Names: $name",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 8.0),
                        userRole != "User"
                            ? Text(
                                "Telephone: $phone",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 8.0),
                        userRole != "User"
                            ? Text(
                                "Email: $email",
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 8.0),
                        GestureDetector(
                          child: InteractiveViewer(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 150.0,
                              ),
                            ),
                          ),
                          onLongPress: () {
                            // Handle long press event if needed
                          },
                        ),
                        const SizedBox(height: 8.0),
                        (label == "person" || label == "unclassfied")
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Rice Quality:",
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    '$confidencePercentage %',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w300,
                                      color: isPlasticDetected
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox(),
                        buildLabelWidget(label),
                        country != null
                            ? Text(
                                "Analysed at  $country $realCity",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w300,
                                  color: isPlasticDetected
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              )
                            : const SizedBox(),
                        if (hasLocation) // Check if latitude and longitude exist
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  openLocationOnMap(latitude, longitude);
                                },
                                child: const Text(
                                  "To view location map",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                onTap: () {
                                  openLocationOnMap(latitude, longitude);
                                },
                                child: const Icon(
                                  Icons
                                      .location_on, // Add your preferred location icon
                                  color: Colors.blue,
                                  size: 30.0,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void openLocationOnMap(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not open the map with the provided coordinates: $latitude, $longitude';
    }
  }
}

class ImageDetailsPage extends StatefulWidget {
  final String imageUrl;
  final String imageName;
  final bool isPlasticDetected;
  final String documentId;

  const ImageDetailsPage({
    Key? key,
    required this.imageUrl,
    required this.imageName,
    required this.isPlasticDetected,
    required this.documentId,
  }) : super(key: key);

  @override
  State createState() => _ImageDetailsPageState();
}

class _ImageDetailsPageState extends State<ImageDetailsPage> {
  bool _isDeleting = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();

  @override
  void initState() {
    super.initState();
    interstitialAdManager.loadInterstitialAd(); //load inter
  }

  Future<void> _deleteImage(BuildContext context) async {
    try {
      setState(() {
        _isDeleting = true;
      });

      await FirebaseFirestore.instance
          .collection('detectedResult')
          .doc(widget.documentId)
          .delete();
      setState(() {
        // Go back to the previous page
        Navigator.pop(context);
        // Show a success message using a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('data deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    } catch (e) {
      // Handle the error if deletion fails
      setState(() {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Error',
                style: TextStyle(color: Colors.red),
              ),
              content: const Text('Failed to delete data.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (interstitialAdManager.isInterstitialAdLoaded()) {
                      interstitialAdManager.showInterstitialAd();
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      });
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Image Details'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // Open a zoomable view of the image
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ZoomableImage(imageUrl: widget.imageUrl),
                      ),
                    );
                  },
                  child: Hero(
                    tag: widget.imageUrl, // Unique tag for the Hero widget
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(
                          20.0), // Adjust this margin as needed
                      minScale: 1.0,
                      maxScale: 4.0, // Adjust the maximum zoom level as needed
                      scaleEnabled: true,
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  widget.imageName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 16.0),
                _isDeleting
                    ? const CircularProgressIndicator() // Show a loading indicator while deleting
                    : ElevatedButton(
                        onPressed: () => {
                          if (interstitialAdManager.isInterstitialAdLoaded())
                            {
                              interstitialAdManager.showInterstitialAd(),
                              _deleteImage(context),
                            },
                          _deleteImage(context),
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                const AdBannerWidget(),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ZoomableImage extends StatelessWidget {
  final String imageUrl;

  const ZoomableImage({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zoomable Image'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Hero(
            tag: imageUrl, // Use the same tag as in ImageDetailsPage
            child: InteractiveViewer(
              boundaryMargin:
                  const EdgeInsets.all(20.0), // Adjust this margin as needed
              minScale: 1.0,
              maxScale: 4.0, // Adjust the maximum zoom level as needed
              scaleEnabled: true,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
