import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../utils/constants.dart';
import '../../Login/login_screen.dart';
import '../../Signup/signup_screen.dart';
import 'background.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    //isSignedIn();
  }

  loginNavigator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return LoginScreen();
        },
      ),
    );
  }

  signupNavigator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return SignUpScreen();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Text(
                "WELCOME TO WASTE DETECTION IN WATER BODIES",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Text(
                "This system is designed to detect whether an image contains plastic bags or not. You can either choose an image from your device's gallery or capture a new image using the camera. The system will then analyze the image using a convolutional neural network (CNN) model trained on a dataset of images containing plastic bags and images without plastic bags.",
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                    color: Colors.black45),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            // SvgPicture.asset(
            //   "assets/icons/chat.svg",
            //   height: size.height * 0.45,
            // ),
            Image.asset(
              'assets/plastic.jpg', // Replace with your own image asset
              height: size.height * 0.45,
              width: size.width * 0.8,
              fit: BoxFit.fill,
            ),
            SizedBox(height: size.height * 0.02),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: size.width * 0.5,
              height: size.height * 0.06,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                  onPressed: () {
                    loginNavigator();
                  },
                  child: const Text(
                    "GET STARTED",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
