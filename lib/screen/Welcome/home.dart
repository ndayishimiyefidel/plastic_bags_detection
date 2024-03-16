import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:smart_rice_analyser/widgets/interestial_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import '../../utils/constants.dart';
import 'detected_images.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _imageFile;
  bool _isPlasticDetected = false;
  bool _isUploading = false;
  late List _results = [];

  late SharedPreferences preferences;

  bool isAlreadyLoggedIn = false;
  String? currentuserid;
  String? userRole, name, email, phone;

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

  String? street;
  String? city;
  String? country;
  String? postalCode;
  String? state, streetName;
  double? latitudeValue;
  double? longitudeValue;
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();
  // Function to fetch the current location and address
  Future<void> getCurrentLocation() async {
    try {
      // Request permission to access the device's location
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case where the user denied location access
        return;
      }
      // Get the current position (latitude and longitude)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Use the geocoding package to convert coordinates into address information
      List<Placemark> placeMarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placeMarks.isNotEmpty) {
        latitudeValue = position.latitude;
        longitudeValue = position.longitude;
        Placemark placeMark = placeMarks[0];

        // Access address components
        streetName = placeMark.name;
        street = placeMark.street;
        city = placeMark.locality;
        state = placeMark.administrativeArea;
        country = placeMark.country;
        postalCode = placeMark.postalCode;
      }
    } catch (e) {
      // Handle errors such as no GPS signal, location services disabled, etc.
      if (kDebugMode) {
        print("Error getting location: $e");
      }
    }
  }

  // Load the TensorFlow Lite model
  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/files/model_rice_analyser.tflite",
        labels: "assets/files/labels.txt"))!;
    if (kDebugMode) {
      print("Models loading status: $res");
    }
  }

//pieck imaage
  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
        _isPlasticDetected = false; // Reset the plastic detection status
      });
    }
  }

  // Function to classify an image
  Future imageClassification(File image) async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = recognitions!;
      _imageFile = image;
    });
  }

  Future<void> _analyzeRiceGrain() async {
    setState(() {
      _isUploading = true;
    });
    if (interstitialAdManager.isInterstitialAdLoaded()) {
      interstitialAdManager.showInterstitialAd();
    }

    // Delay before classifying the image (for demonstration purposes)
    await Future.delayed(const Duration(seconds: 6));
    await imageClassification(_imageFile!);

    // Upload image to Firebase Storage
    String originalImageName = _imageFile!.path.split('/').last;
    String currentDateTime = DateTime.now().toString();
    String imageName = '$originalImageName-$currentDateTime';
    firebase_storage.Reference storageRef =
        firebase_storage.FirebaseStorage.instance.ref().child(imageName);
    await storageRef.putFile(_imageFile!);

    // Get the image URL from Firebase Storage
    String imageUrl = await storageRef.getDownloadURL();

    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;

    setState(() {
      _isPlasticDetected = true;
    });

    // Save image details to Cloud Firestore
    // ignore: unused_local_variable
    DocumentReference resultRef =
        await FirebaseFirestore.instance.collection('detectedResult').add({
      'userId': userId, // Save the user ID along with the image details
      'name': imageName,
      'imageUrl': imageUrl,
      'createdAt': currentDateTime,
      'isPlasticDetected':
          _isPlasticDetected, // Use the actual detection result
      'detectedValue': _results[0]['confidence'],
      'detectedLabel': _results[0]['label'],
      'street': street,
      'city': city,
      'country': country,
      "userName": name,
      "email": email,
      "phone": phone,
      "latitude": latitudeValue,
      "longitude": longitudeValue
    });
    setState(() {
      _isUploading = false;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetectedImagesPage(
            userRole: userRole.toString(),
          ),
        ),
      );
    });

    // Update the plastic detection status
  }

  Future<void> showLocationDisclosureDialog() async {
    // Show the custom location disclosure dialog
    bool? userAccepted = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return LocationDisclosureDialog(
          onPermissionChoice: (accepted) {
            Navigator.of(context)
                .pop(accepted); // Close the dialog and pass the choice
          },
        );
      },
    );

    if (userAccepted == true) {
      // User accepted location permission, call getCurrentLocation
      await getCurrentLocation();
    } else {
      // User closed the dialog without making a choice
      // Handle this case as needed

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission was denied or not granted.'),
          ),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    loadModel();
    interstitialAdManager.loadInterstitialAd(); //load inter
    Future.delayed(Duration.zero, () {
      showLocationDisclosureDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analyse Rice Grain",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.25,
            fontSize: 24,
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30.0),
              const Text(
                'SELECT AN IMAGE OF RICE GRAIN',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'To get started, click on the "Select Image" button to choose an image of rice grain from your gallery or click on the "Capture Image" button to take a new photo using your device\'s camera. Once the image is selected or captured, the system will process it and provide you with the result based on color, length, and size analysis to identify the type of rice grain.',
                style: TextStyle(fontSize: 14, color: Colors.black38),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 32.0),
              if (_imageFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    width: 250.0,
                    height: 200.0,
                    color: Colors.grey[300],
                    child: _imageFile != null
                        ? Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 50.0,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                ),
              const SizedBox(height: 16.0),
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Image from Gallery'),
              ),
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Image'),
              ),
              const SizedBox(height: 42.0),
              Center(
                child: ElevatedButton(
                  onPressed: _imageFile != null && !_isUploading
                      ? _analyzeRiceGrain
                      : null,
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Analyze Rice Grain',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationDisclosureDialog extends StatelessWidget {
  final Function(bool) onPermissionChoice;

  const LocationDisclosureDialog({super.key, required this.onPermissionChoice});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Location Access Required'),
      content: const Text(
        'Smart Rice Analyser App needs access to your location.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Navigator.of(context).pop(); // Close the dialog
            onPermissionChoice(true); // User accepted permission
          },
          child: const Text('Accept'),
        ),
        TextButton(
          onPressed: () {
            // Navigator.of(context).pop(); // Close the dialog
            onPermissionChoice(false); // User denied permission
          },
          child: const Text('Deny'),
        ),
      ],
    );
  }
}
