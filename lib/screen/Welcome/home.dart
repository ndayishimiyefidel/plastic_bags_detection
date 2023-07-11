import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
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
  // Load the TensorFlow Lite model
  Future loadModel()
  async {
    Tflite.close();
    String res;
    res=(await Tflite.loadModel(model: "assets/model_plastic_detection.tflite",labels: "assets/label.txt"))!;
    print("Models loading status: $res");
  }

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
  Future imageClassification(File image)
  async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results=recognitions!;
      _imageFile=image;

    });
  }
  Future<void> _detectPlastic() async {
    setState(() {
      _isUploading = true;
    });

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
    ///print detect value
    if(_results[0]['label']=="plastic" && _results[0]['confidence']>=0.5){
       setState(() {
         _isPlasticDetected=true;
       });
    }
    else if(_results[0]['label']=="non-plastic" &&_results[0]['confidence']>=0.5){
      setState(() {
        _isPlasticDetected=false;
      });
    }


    // Save image details to Cloud Firestore
    DocumentReference resultRef = await FirebaseFirestore.instance.collection('detectedResult').add({
      'userId': userId, // Save the user ID along with the image details
      'name': imageName,
      'imageUrl': imageUrl,
      'createdAt': currentDateTime,
      'isPlasticDetected': _isPlasticDetected, // Use the actual detection result
      'detectedValue': _results[0]['confidence'],
      'detectedLabel': _results[0]['label'],
    });
    setState(() {
      _isUploading = false;
    });

    // Update the plastic detection status


    // Navigate to the Detected Images page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetectedImagesPage(),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Images Detection",
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
                'SELECT AN IMAGE',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'To get started, click on the "Select Image" button to choose an image from your gallery or click on the "Capture Image" button to take a new photo using your device\'s camera. Once the image is selected or captured, the system will process it and provide you with the result of whether the image contains plastic bags or not.',
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
                label: const Text('Pick Image from Gallery'),
              ),
              TextButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Image'),
              ),
              const SizedBox(height: 42.0),
              Center(
                child: ElevatedButton(
                  onPressed:
                  _imageFile != null && !_isUploading ? _detectPlastic : null,
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text(
                    'Detect Plastic',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
             if(_isPlasticDetected)
                Text(
                'Detected ${_results[0]['label']}-${_results[0]['confidence']}',
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
