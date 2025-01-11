
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
    apiKey: 'AIzaSyCRo9JvPrIsjP90G4yQr8nMH-KCMTfkuuQ',
    appId: '1:881936989809:web:cc3291e9c73a65edd665d0',
    messagingSenderId: '881936989809',
    projectId: 'medical-emergency-38bb9',
    authDomain: 'medical-emergency-38bb9.firebaseapp.com',
    storageBucket: 'medical-emergency-38bb9.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFkPoQbskMVzhc5tQEuZKN2SyCvXLuUeA',
    appId: '1:881936989809:android:71d00ca1b4a24c1cd665d0',
    messagingSenderId: '881936989809',
    projectId: 'medical-emergency-38bb9',
    storageBucket: 'medical-emergency-38bb9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYKOwyNX40muIlwfQ6UT0FN3-CvAmJXXA',
    appId: '1:881936989809:ios:09c327368b9f5e3fd665d0',
    messagingSenderId: '881936989809',
    projectId: 'medical-emergency-38bb9',
    storageBucket: 'medical-emergency-38bb9.appspot.com',
    iosBundleId: 'com.example.emergencyconsultation',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAYKOwyNX40muIlwfQ6UT0FN3-CvAmJXXA',
    appId: '1:881936989809:ios:09c327368b9f5e3fd665d0',
    messagingSenderId: '881936989809',
    projectId: 'medical-emergency-38bb9',
    storageBucket: 'medical-emergency-38bb9.appspot.com',
    iosBundleId: 'com.example.emergencyconsultation',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCRo9JvPrIsjP90G4yQr8nMH-KCMTfkuuQ',
    appId: '1:881936989809:web:76ccef8eb90b0a5bd665d0',
    messagingSenderId: '881936989809',
    projectId: 'medical-emergency-38bb9',
    authDomain: 'medical-emergency-38bb9.firebaseapp.com',
    storageBucket: 'medical-emergency-38bb9.appspot.com',
  );

}