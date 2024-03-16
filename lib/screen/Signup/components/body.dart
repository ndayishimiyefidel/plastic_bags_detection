import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_rice_analyser/widgets/banner_widget.dart';
import 'package:smart_rice_analyser/widgets/interestial_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/text_field_container.dart';
import '../../../utils/constants.dart';
import '../../../widgets/progress_widget.dart';
import '../../Login/login_screen.dart';
import '../../Signup/components/background.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final String defaultPhotoUrl =
      "https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg";
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController phoneNumberEditingController = TextEditingController();
  String name = "", phoneNumber = "", emailAddress = "", password = "";

  late SharedPreferences preferences;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isloading = false;
  late bool _passwordVisible;
  final userRole = "User";
  InterstitialAdManager interstitialAdManager = InterstitialAdManager();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    interstitialAdManager.loadInterstitialAd();
    if (interstitialAdManager.isInterstitialAdLoaded()) {
      interstitialAdManager.startInterstitialTimer(2);
    }
  }

  void _registerUser() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });

      try {
        // Creating user with email and password
        final UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: emailAddress.toString().trim(),
          password: password.toString().trim(),
        );

        // Accessing the user object
        final User? firebaseUser = userCredential.user;

        if (firebaseUser != null) {
          // Check if user exists in Firestore
          final QuerySnapshot result = await FirebaseFirestore.instance
              .collection("Users")
              .where("uid", isEqualTo: firebaseUser.uid)
              .get();

          final List<DocumentSnapshot> documents = result.docs;

          if (documents.isEmpty) {
            // Add user details to Firestore if not already present
            await FirebaseFirestore.instance
                .collection("Users")
                .doc(firebaseUser.uid)
                .set({
              "uid": firebaseUser.uid,
              "email": firebaseUser.email,
              "name": name.toString().trim(),
              "phone": phoneNumber.trim(),
              "userRole": "User",
              "password": password
                  .trim(), // Note: Storing passwords in plaintext is not recommended
              "photoUrl": defaultPhotoUrl,
              "createdAt": DateTime.now().millisecondsSinceEpoch.toString(),
              "state": 1,
            });

            // Save user details in SharedPreferences
            final SharedPreferences preferences =
                await SharedPreferences.getInstance();
            await preferences.setString("uid", firebaseUser.uid);
            await preferences.setString("name", name.toString().trim());
            await preferences.setString("photo", defaultPhotoUrl);
            await preferences.setString("phone", phoneNumber.trim());
            await preferences.setString("email", firebaseUser.email!);
            await preferences.setString("UserRole", "User");
          }

          // Navigate to LoginScreen after registration
          setState(() {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (c) => const LoginScreen()));
          });
        } else {
          // Handle registration failure
          Fluttertoast.showToast(msg: "Sign up Failed");
        }
      } catch (error) {
        // Handle errors
        if (kDebugMode) {
          print('Error registering user: $error');
        }
        setState(() {
          isloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration failed: $error")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "REGISTER NOW TO GET STARTED!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).primaryColor),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: size.height * 0.03),
                // SvgPicture.asset(
                //   "assets/icons/signup.svg",
                //   height: size.height * 0.35,
                // ),
                SizedBox(height: size.height * 0.03),

                TextFieldContainer(
                  child: TextFormField(
                    controller: nameEditingController,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      name = val;
                      if (kDebugMode) {
                        print(name);
                      }
                    },
                    validator: (nameValue) {
                      if (nameValue!.isEmpty) {
                        return 'This field is mandatory';
                      }
                      if (nameValue.length < 3) {
                        return 'name must be at least 3+ characters ';
                      }
                      const String p = "^[a-zA-Z\\s]+";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(nameValue)) {
                        // So, the email is valid
                        return null;
                      }

                      return 'This is not a valid name';
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.person,
                        color: kPrimaryColor,
                      ),
                      hintText: "Your Names",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: emailEditingController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      emailAddress = val;
                      if (kDebugMode) {
                        print(emailAddress);
                      }
                    },
                    validator: (emailValue) {
                      if (emailValue!.isEmpty) {
                        return 'This field is mandatory';
                      }
                      String p =
                          "[a-zA-Z0-9+._%-+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})+";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(emailValue)) {
                        // So, the email is valid
                        return null;
                      }

                      return 'This is not a valid email';
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.email,
                        color: kPrimaryColor,
                      ),
                      hintText: "Your Email",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: phoneNumberEditingController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      phoneNumber = val;
                      if (kDebugMode) {
                        print(phoneNumber);
                      }
                    },
                    validator: (phoneValue) {
                      if (phoneValue!.isEmpty) {
                        return 'This field is mandatory';
                      }

                      const String p = "^07[2,389]\\d{7}";
                      RegExp regExp = RegExp(p);

                      if (regExp.hasMatch(phoneValue)) {
                        // So, the email is valid
                        return null;
                      }

                      return 'This is not a valid phone number';
                    },
                    cursorColor: kPrimaryColor,
                    decoration: const InputDecoration(
                      icon: Icon(
                        Icons.phone_outlined,
                        color: kPrimaryColor,
                      ),
                      hintText: "Phone Number",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                TextFieldContainer(
                  child: TextFormField(
                    controller: passwordEditingController,
                    obscureText: !_passwordVisible,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (val) {
                      password = val;
                    },
                    validator: (pwValue) {
                      if (pwValue!.isEmpty) {
                        return 'This field is mandatory';
                      }
                      if (pwValue.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      hintText: "Password",
                      icon: const Icon(
                        Icons.lock,
                        color: kPrimaryColor,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: kPrimaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.4,
                  height: size.height * 0.06,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor),
                      onPressed: () {
                        if (interstitialAdManager.isInterstitialAdLoaded()) {
                          interstitialAdManager.showInterstitialAd();
                          _registerUser();
                        }
                        _registerUser();
                      },
                      child: const Text(
                        "REGISTER",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                isloading
                    ? oldcircularprogress()
                    : Container(
                        child: null,
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "Already have an account ? ",
                      style: TextStyle(color: Colors.black45),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const LoginScreen();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.1),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.1,
                ),
                const AdBannerWidget(),
              ]),
        ),
      ),
    );
  }
}
