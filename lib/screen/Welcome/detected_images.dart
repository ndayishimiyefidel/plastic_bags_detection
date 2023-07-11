import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/constants.dart';

class DetectedImagesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detected Images",
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
            // _scaffoldKey.currentState!.openDrawer();
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
        stream: FirebaseFirestore.instance
            .collection('detectedResult')
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error retrieving images'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No detected images found'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic> data = (document.data() as Map<String, dynamic>);
              String imageUrl = data['imageUrl'];
              String imageName = data['name'];
              bool isPlasticDetected = data['isPlasticDetected'];
              double confidence=data['detectedValue'];
              String confidencePercentage = (confidence * 100).toStringAsFixed(2);

              return GestureDetector(
                onTap: () {
                  // Navigate to the image details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageDetailsPage(
                        imageUrl: imageUrl,
                        imageName: imageName,
                        isPlasticDetected: isPlasticDetected,
                        documentId: document.id, // Pass the document ID
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
                        GestureDetector(
                          child: InteractiveViewer(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity, // Set the image width to the width of the card
                              height: 150.0,
                            ),
                          ),
                          onLongPress: () {
                            // Handle long press event if needed
                          },
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          imageName,
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Confidence Level:",
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
                                color: isPlasticDetected ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Conclusion:",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              isPlasticDetected ? 'Plastic found' : 'No Plastic found',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w300,
                                color: isPlasticDetected ? Colors.green : Colors.red,
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
}

class ImageDetailsPage extends StatelessWidget {
  final String imageUrl;
  final String imageName;
  final bool isPlasticDetected;
  final String documentId;

  ImageDetailsPage({
    required this.imageUrl,
    required this.imageName,
    required this.isPlasticDetected,
    required this.documentId,
  });
  Future<void> _deleteImage(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('detectedResult').doc(documentId).delete();
      Navigator.pop(context); // Go back to the previous page
    } catch (e) {
      // Handle the error if deletion fails
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error',style: TextStyle(color: Colors.red),),
            content: const Text('Failed to delete image.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Image.network(imageUrl),
                const SizedBox(height: 16.0),
                Text(
                  imageName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  isPlasticDetected ? 'Plastic Detected' : 'No Plastic Detected',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: isPlasticDetected ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _deleteImage(context),
                  child: const Text('Delete',style: TextStyle(color: Colors.red),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}