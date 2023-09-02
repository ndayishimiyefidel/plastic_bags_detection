import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/text_field_container.dart';
import '../../../utils/constants.dart';
import '../../../widgets/ProgressWidget.dart';
import '../../HomeScreen.dart';
import '../../Signup/components/background.dart';
import '../../Signup/signup_screen.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  late SharedPreferences preferences;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  String emailAddress = "", password = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late bool _passwordVisible;
  bool isloading = false;

  String? deviceId;
  bool checkedValue = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    //save email and [
  }

  Future<void> signupNavigator() async {
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
    return Background(
      child: SingleChildScrollView(
        child: Form(
          key: _formkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "WELCOME TO WASTE DETECTION IN WATER BODIES",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).primaryColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: size.height * 0.03),
              TextFieldContainer(
                child: TextFormField(
                  controller: emailEditingController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: true,
                  autofocus: true,
                  onChanged: (val) {
                    emailAddress = val;
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
                    hintText: "Your email",
                    border: InputBorder.none,
                  ),
                ),
              ),
              TextFieldContainer(
                child: TextFormField(
                  controller: passwordEditingController,
                  obscureText: !_passwordVisible,
                  keyboardType: TextInputType.text,
                  autocorrect: true,
                  autofocus: true,
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
                    hintText: "Your password",
                    icon: const Icon(
                      Icons.lock_outlined,
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
                height: size.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: CheckboxListTile(
                  title: const Text("Remember Me"),
                  value: checkedValue,
                  onChanged: (newValue) {
                    setState(() {
                      checkedValue = newValue!;
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 45, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    const Text(
                      "Forgot password?",
                      style: TextStyle(color: kPrimaryColor),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) {
                        //       return const ForgotScreen();
                        //     },
                        //   ),
                        // );
                      },
                      child: const Text(
                        "Reset it",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              SizedBox(
                // margin: const EdgeInsets.symmetric(vertical: 10),
                width: size.width * 0.4,
                height: size.height * 0.06,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor),
                    onPressed: () {
                      loginUser();
                    },
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              isloading
                  ? oldcircularprogress()
                  : Container(
                      child: null,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Don't have an account ?  ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SignUpScreen();
                          },
                        ),
                      );
                    },
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: size.height * 0.06,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void loginUser() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      // if(checkedValue){
      //   box1.put('email', emailEditingController.value.text);
      //   box1.put('pass', passwordEditingController.value.text);
      // }
      preferences = await SharedPreferences.getInstance();

      var user = FirebaseAuth.instance.currentUser;

      await _auth
          .signInWithEmailAndPassword(
              email: emailAddress.toString().trim(), password: password.trim())
          .then((auth) {
        user = auth.user;
      }).catchError((err) {
        setState(() {
          isloading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(err.message)));
      });

      if (user != null) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(user!.uid)
            .update({"state": 1});

        FirebaseFirestore.instance
            .collection("Users")
            .doc(user!.uid)
            .get()
            .then((datasnapshot) async {
          await preferences.setString("uid", datasnapshot.data()!["uid"]);
          await preferences.setString("name", datasnapshot.data()!["name"]);
          await preferences.setString(
              "photo", datasnapshot.data()!["photoUrl"]);
          await preferences.setString("email", datasnapshot.data()!["email"]);
          await preferences.setString("phone", datasnapshot.data()!["phone"]);

          setState(() {
            isloading = false;
          });
          Route route = MaterialPageRoute(
              builder: (c) => HomeScreen(
                    currentuserid: user!.uid,
                  ));
          Navigator.push(context, route);
        });
      } else {
        setState(() {
          isloading = false;
        });
        Fluttertoast.showToast(
            msg: "Login Failed,No such user matching with your credentials",
            textColor: Colors.red,
            fontSize: 18);
      }
    }
  }
}
