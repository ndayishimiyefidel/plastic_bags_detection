import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:smart_rice_analyser/screen/Welcome/detected_images.dart';
import 'package:smart_rice_analyser/screen/accounts/account_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../resources/user_state_methods.dart';
import '../screen/Welcome/about_us.dart';
import '../screen/Welcome/home.dart';
import '../screen/home_screen.dart';
import '../utils/constants.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  State createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? currentuserid;
  String? userRole;
  late SharedPreferences preferences;

  @override
  void initState() {
    super.initState();
    navigateuser();
  }

  void navigateuser() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      currentuserid = preferences.getString("uid");
      userRole = preferences.getString("userRole");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kPrimaryLightColor,
      ),
      child: ListView(
        children: [
          ListTile(
            onTap: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => HomeScreen(
                      currentuserid: FirebaseAuth.instance.currentUser!.uid,
                      userRole: userRole.toString(),
                    ),
                  ),
                );
              });
            },
            leading: const Icon(
              Icons.home,
              size: 30,
              weight: 100,
            ),
            contentPadding: const EdgeInsets.only(
              left: 70,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Home",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => DetectedImagesPage(
                      userRole: userRole.toString(),
                    ),
                  ),
                );
              });
            },
            leading: const Icon(
              Icons.insert_photo,
              size: 30,
              weight: 100,
            ),
            contentPadding: const EdgeInsets.only(
              left: 70,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Analyzed Rice",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const Home(),
                  ),
                );
              });
            },
            leading: const Icon(
              Icons.insert_photo_outlined,
              size: 30,
              weight: 100,
            ),
            contentPadding: const EdgeInsets.only(
              left: 70,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Analyse Rice",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const AboutUsScreen(),
                  ),
                );
              });
            },
            leading: const Icon(
              Icons.info_outline_rounded,
              size: 30,
              weight: 100,
            ),
            contentPadding: const EdgeInsets.only(
              left: 70,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "About Us",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => UserSettings(),
                  ),
                );
              });
            },
            leading: const Icon(
              Icons.personal_injury_outlined,
              size: 30,
              weight: 100,
            ),
            contentPadding: const EdgeInsets.only(
              left: 70,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            onTap: () => UserStateMethods().logoutuser(context),
            leading: IconButton(
              onPressed: () => UserStateMethods().logoutuser(context),
              icon: const Icon(
                Icons.logout,
                size: 30,
                color: Colors.redAccent,
              ),
            ),
            contentPadding: const EdgeInsets.only(
              left: 60,
              top: 5,
              bottom: 5,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> deleteUser(String docId) async {
    await auth.currentUser!.delete().then((value) => {
          FirebaseFirestore.instance
              .collection("Users")
              .doc(docId)
              .delete()
              .then((value) => {
                    UserStateMethods().logoutuser(context),
                  })
        });
  }
}
