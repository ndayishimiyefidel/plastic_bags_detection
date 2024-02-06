import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plastic_bags_detection/screen/home_screen.dart';
class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key}); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to Waste Detection in Lake Kivu!',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Discover waste in lake kivu',
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Email: info@example.com',
              // style: TextStyle(fontSize: 16.0),
            ),
            const Text(
              'Phone: 123-456-7890',
              // style: TextStyle(fontSize: 16.0),
            ),
            ElevatedButton(
              child: const Text('Go Home'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(currentuserid: FirebaseAuth.instance.currentUser!.uid,userRole: "User",)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AnotherScreen extends StatelessWidget {
  const AnotherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Another Screen'),
      ),
      body: const Center(
        child: Text('This is another screen.'),
      ),
    );
  }
}