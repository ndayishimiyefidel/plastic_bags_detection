import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/constants.dart';
import '../../Login/login_screen.dart';
import '../../Signup/signup_screen.dart';
import 'background.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
  }

  loginNavigator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ),
    );
  }

  signupNavigator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const SignUpScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provides the total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.1),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text(
                "WELCOME TO SMART RICE ANALYZER",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                "This system is designed to analyze rice grains based on color, length, and size to identify their type. You can either choose an image from your device's gallery or capture a new image using the camera. The system will then analyze the image using advanced algorithms and provide you with the type of rice grain detected or analysed.",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  wordSpacing: 5,
                  color: Colors.black45,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(10), // Adjust the radius as needed
              child: Image.asset(
                'assets/ricehome.jpg', // Replace with your own image asset
                height: size.height * 0.45,
                width: size.width * 0.95,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: size.width * 0.5,
              height: size.height * 0.06,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  onPressed: () {
                    // Handle button press action here
                    loginNavigator();
                  },
                  child: const Text(
                    "GET STARTED",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Add any additional widgets here
          ],
        ),
      ),
    );
  }
}
