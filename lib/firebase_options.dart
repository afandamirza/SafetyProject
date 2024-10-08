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
    apiKey: 'AIzaSyButRSOg3ZLUxB43gTaFBNvwQi5mzY-VZs',
    appId: '1:54175991750:web:4e73f56e9d0a4a2caa54c7',
    messagingSenderId: '54175991750',
    projectId: 'safetyreportproject',
    authDomain: 'safetyreportproject.firebaseapp.com',
    storageBucket: 'safetyreportproject.appspot.com',
    measurementId: 'G-6H82ML31VZ',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqXYElPQuB8XXJ6iWsPQdrY2QT3Qq3RPQ',
    appId: '1:54175991750:ios:5849b137608f8334aa54c7',
    messagingSenderId: '54175991750',
    projectId: 'safetyreportproject',
    storageBucket: 'safetyreportproject.appspot.com',
    iosBundleId: 'com.example.safetyreport',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAqXYElPQuB8XXJ6iWsPQdrY2QT3Qq3RPQ',
    appId: '1:54175991750:ios:5849b137608f8334aa54c7',
    messagingSenderId: '54175991750',
    projectId: 'safetyreportproject',
    storageBucket: 'safetyreportproject.appspot.com',
    iosBundleId: 'com.example.safetyreport',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyButRSOg3ZLUxB43gTaFBNvwQi5mzY-VZs',
    appId: '1:54175991750:web:5c08d62cfe407eb6aa54c7',
    messagingSenderId: '54175991750',
    projectId: 'safetyreportproject',
    authDomain: 'safetyreportproject.firebaseapp.com',
    storageBucket: 'safetyreportproject.appspot.com',
    measurementId: 'G-P96Q6BDNJQ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBfwf9TFemxIZyKgFZ_NW-FcVXx4Dr0REE',
    appId: '1:54175991750:android:4a9efd567f0ca914aa54c7',
    messagingSenderId: '54175991750',
    projectId: 'safetyreportproject',
    storageBucket: 'safetyreportproject.appspot.com',
  );

}