// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCi-8-n-RzXY8dQHwLO3MZuAWdJ_CHJHGA',
    appId: '1:553701081355:web:66ff548c7c803d3b7da20e',
    messagingSenderId: '553701081355',
    projectId: 'basic-8dee0',
    authDomain: 'basic-8dee0.firebaseapp.com',
    storageBucket: 'basic-8dee0.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDO8YCnQzqL815ITGlNCD9tGsOOyT92PFY',
    appId: '1:553701081355:android:07c390f1571957ec7da20e',
    messagingSenderId: '553701081355',
    projectId: 'basic-8dee0',
    storageBucket: 'basic-8dee0.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCi-8-n-RzXY8dQHwLO3MZuAWdJ_CHJHGA',
    appId: '1:553701081355:web:d6394624464dcce57da20e',
    messagingSenderId: '553701081355',
    projectId: 'basic-8dee0',
    authDomain: 'basic-8dee0.firebaseapp.com',
    storageBucket: 'basic-8dee0.appspot.com',
  );

}