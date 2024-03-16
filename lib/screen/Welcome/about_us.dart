import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_rice_analyser/screen/home_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  Widget _buildRatingDialog(BuildContext context) {
    double rating = 0;
    String review = '';

    return AlertDialog(
      title: const Text('Rate Our App'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemSize: 30.0,
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (value) {
              rating = value;
            },
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (value) {
              review = value;
            },
            decoration: const InputDecoration(
              hintText: 'Write your review here...',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // You can handle the rating and review submission here
            if (kDebugMode) {
              print('Rating: $rating, Review: $review');
            }
            // Save rating and review to Firestore
            FirebaseFirestore.instance.collection('ratings').add({
              'rating': rating,
              'review': review,
              'timestamp': Timestamp.now(),
            }).then((value) {
              // Rating saved successfully
              if (kDebugMode) {
                print('Rating saved successfully');
              }
              Fluttertoast.showToast(msg: 'Rating saved successfully');
            }).catchError((error) {
              // Error occurred while saving rating
              if (kDebugMode) {
                Fluttertoast.showToast(msg: 'Error saving rating: $error');
                print('Error saving rating: $error');
              }
            });

            Navigator.pop(context);
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Smart Rice Analyzer'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Smart Rice Analyzer!',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Analyze rice grains based on color, length, and size to identify their type.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'How it Works:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12.0),
              const Text(
                '1. Select an image of rice grain from your device\'s gallery or capture a new image using the camera.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                '2. The system will analyze the image using advanced algorithms to determine the color, length, and size of the rice grain.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                '3. Based on the analysis, the system will provide you with the type of rice grain detected.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'Email: info@smartriceanalyzer.com',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Phone: 123-456-7890',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 48.0),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HomeScreen(
                                currentuserid:
                                    FirebaseAuth.instance.currentUser!.uid,
                                userRole: "User",
                              )),
                    );
                  },
                  child: const Text(
                    'Analyse Rice',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enjoying our app? Rate us!',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _buildRatingDialog(context),
                      );
                    },
                    child: const Text(
                      'Rate us',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
