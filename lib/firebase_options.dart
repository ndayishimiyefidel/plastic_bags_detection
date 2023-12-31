// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDl3Y84y40UuxlDSBLUyzRDeZAM2oJnpSs',
    appId: '1:259416750507:android:0833a31ff1dfa96a6dbaee',
    messagingSenderId: '259416750507',
    projectId: 'ulrick-plastic-detection',
    databaseURL: 'https://ulrick-plastic-detection-default-rtdb.firebaseio.com',
    storageBucket: 'ulrick-plastic-detection.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2kzzizozlahfHNIQ8wC_yfK2V__xdKkg',
    appId: '1:259416750507:ios:73ad5f7f8f1e1f6c6dbaee',
    messagingSenderId: '259416750507',
    projectId: 'ulrick-plastic-detection',
    databaseURL: 'https://ulrick-plastic-detection-default-rtdb.firebaseio.com',
    storageBucket: 'ulrick-plastic-detection.appspot.com',
    iosClientId: '259416750507-1l44f8b6u0sncd8j9ppgmquu6uhhbdas.apps.googleusercontent.com',
    iosBundleId: 'com.example.plasticBagsDetection',
  );
}
