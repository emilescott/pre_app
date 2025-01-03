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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyA5kPriHb0-GzVKJvxXOsZBvDfSIp1sklE',
    appId: '1:612806489108:web:3962eb0a9a00a78b1a2301',
    messagingSenderId: '612806489108',
    projectId: 'presence-1be85',
    authDomain: 'presence-1be85.firebaseapp.com',
    storageBucket: 'presence-1be85.appspot.com',
    measurementId: 'G-10JS7FMR67',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAEIb8ex9kcV-t0OjHcoxLJUpYK3pDh8AI',
    appId: '1:612806489108:android:bef20d10e8c8bae71a2301',
    messagingSenderId: '612806489108',
    projectId: 'presence-1be85',
    storageBucket: 'presence-1be85.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDQLDuxDX865lxo7Sjdx844nTou1dmoWtI',
    appId: '1:612806489108:ios:aebc19a852ddeb771a2301',
    messagingSenderId: '612806489108',
    projectId: 'presence-1be85',
    storageBucket: 'presence-1be85.appspot.com',
    iosBundleId: 'com.example.preapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDQLDuxDX865lxo7Sjdx844nTou1dmoWtI',
    appId: '1:612806489108:ios:aebc19a852ddeb771a2301',
    messagingSenderId: '612806489108',
    projectId: 'presence-1be85',
    storageBucket: 'presence-1be85.appspot.com',
    iosBundleId: 'com.example.preapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA5kPriHb0-GzVKJvxXOsZBvDfSIp1sklE',
    appId: '1:612806489108:web:17929f2dc1cbb10c1a2301',
    messagingSenderId: '612806489108',
    projectId: 'presence-1be85',
    authDomain: 'presence-1be85.firebaseapp.com',
    storageBucket: 'presence-1be85.appspot.com',
    measurementId: 'G-39GDLF0BTD',
  );

}