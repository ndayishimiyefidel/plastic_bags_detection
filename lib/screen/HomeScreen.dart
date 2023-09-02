import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enume/user_state.dart';
import '../resources/user_state_methods.dart';
import '../utils/constants.dart';
import '../widgets/MainDrawer.dart';
import 'Welcome/home.dart';

class HomeScreen extends StatefulWidget {
  final String currentuserid;

  const HomeScreen({Key? key, required this.currentuserid}) : super(key: key);

  @override
  _HomeScreenState createState() =>
      _HomeScreenState(currentuserid: currentuserid);
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  _HomeScreenState({required this.currentuserid});
  String name = "";
  String email = "";
  String phone = "";
  late SharedPreferences preferences;

  getCurrUserData() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      name = preferences.getString("name")!;
      email = preferences.getString("email")!;
      phone = preferences.getString("phone")!;
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrUserData();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      UserStateMethods().setUserState(
        userId: currentuserid,
        userState: UserState.Online,
      );
    });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.Online,
              )
            : print("Resumed State");
        break;
      case AppLifecycleState.inactive:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.Offline,
              )
            : print("Inactive State");
        break;
      case AppLifecycleState.paused:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.Waiting,
              )
            : print("Paused State");
        break;
      case AppLifecycleState.detached:
        currentuserid != null
            ? UserStateMethods().setUserState(
                userId: currentuserid,
                userState: UserState.Offline,
              )
            : print("Detached State");
        break;
    }
  }

  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;
  final String currentuserid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyStatefulWidget(
        name: name,
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  final String name;
  MyStatefulWidget({
    Key? key,
    required this.name,
  }) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        elevation: 0,
        child: MainDrawer(),
      ),
      appBar: AppBar(
        title: const Text(
          "Home",
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
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'You are welcome, ${widget.name}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 60),
              Image.asset(
                'assets/plastic.jpg', // Replace with your own image asset
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 25),
              const Text(
                'WASTE DETECTION IN WATER BODIES',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 30.0),
              const ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Capture Images'),
                subtitle:
                    Text('Use the camera to capture images for detection'),
              ),
              const ListTile(
                leading: Icon(Icons.image),
                title: Text('Select Images'),
                subtitle: Text('Choose images from the gallery for detection'),
              ),
              const ListTile(
                leading: Icon(Icons.cloud_upload),
                title: Text('Store Results'),
                subtitle:
                    Text('Save detection results in the cloud for analysis'),
              ),
              const ListTile(
                leading: Icon(Icons.search),
                title: Text('Detect Plastic Bags'),
                subtitle: Text(
                    'Analyze images to identify the presence of plastic bags'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Handle button press to navigate to the next screen
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const Home();
                  }));
                },
                child: const Text('GET STARTED'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
