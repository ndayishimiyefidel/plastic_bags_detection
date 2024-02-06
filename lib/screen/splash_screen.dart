import 'package:splash_screen_view/SplashScreenView.dart';
import 'home_screen.dart';
import '../utils/constants.dart';
import 'Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late SharedPreferences preferences;

  bool isAlreadyLoggedIn = false;
  String? currentuserid;
  String? userRole;

  @override
  void initState() {
    super.initState();
    navigateuser();
  }

  void navigateuser() async {
    preferences = await SharedPreferences.getInstance();
    currentuserid = preferences.getString("uid");
    userRole = preferences.getString("userRole");


    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      setState(() {
        isAlreadyLoggedIn = true;
      });

      Route route = MaterialPageRoute(
          builder: (c) => HomeScreen(
                currentuserid: preferences.getString("uid").toString(),
                userRole: userRole.toString(),
              ));
              setState(() {
                Navigator.pushReplacement(context, route);
              });
    } else {
      setState(() {
        isAlreadyLoggedIn = false;
      });
      Route route = MaterialPageRoute(builder: (c) => const WelcomeScreen());
      setState(() {
              Navigator.pushReplacement(context, route);

      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: isAlreadyLoggedIn
          ? HomeScreen(
              currentuserid: currentuserid.toString(),
              userRole: userRole.toString(),
            )
          : const WelcomeScreen(),
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
