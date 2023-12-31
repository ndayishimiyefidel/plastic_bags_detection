import 'HomeScreen.dart';
import '../utils/constants.dart';
import 'Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SharedPreferences preferences;

  bool isAlreadyLoggedIn = false;
  String? currentuserid;
  String? userRole;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    precachePicture(
        ExactAssetPicture(
            SvgPicture.svgStringDecoderBuilder, 'assets/icons/signup.svg'),
        null);
    precachePicture(
        ExactAssetPicture(
            SvgPicture.svgStringDecoderBuilder, 'assets/icons/chat.svg'),
        null);
    precachePicture(
        ExactAssetPicture(
            SvgPicture.svgStringDecoderBuilder, 'assets/icons/login.svg'),
        null);
    navigateuser();
  }

  void navigateuser() async {
    preferences = await SharedPreferences.getInstance();
    currentuserid = preferences.getString("uid");
    userRole = preferences.getString("role");


    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      setState(() {
        isAlreadyLoggedIn = true;
      });

      Route route = MaterialPageRoute(
          builder: (c) => HomeScreen(
                currentuserid: preferences.getString("uid").toString(),
              ));
      Navigator.pushReplacement(context, route);
    } else {
      setState(() {
        isAlreadyLoggedIn = false;
      });
      Route route = MaterialPageRoute(builder: (c) => WelcomeScreen());
      Navigator.pushReplacement(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: isAlreadyLoggedIn
          ? HomeScreen(
              currentuserid: currentuserid.toString(),
            )
          : WelcomeScreen(),
      duration: 5500,
      text: "PLASTIC BAGS DETECTION APP",
      textType: TextType.ColorizeAnimationText,
      textStyle: const TextStyle(fontSize: 40.0, fontFamily: 'Courgette'),
      colors: const [
        kPrimaryColor,
        kPrimaryLightColor,
        kPrimaryColor,
      ],
      backgroundColor: Colors.white,
    );
  }
}
