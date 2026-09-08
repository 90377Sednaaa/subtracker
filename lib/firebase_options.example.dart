// Template configuration for Firebase.
//
// To set up Firebase for your own project:
// 1. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
// 2. Run: `flutterfire configure` to generate `lib/firebase_options.dart` and `android/app/google-services.json`
//    OR copy this file to `lib/firebase_options.dart` and fill in your project values below.

// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] template for Subly.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_FIREBASE_API_KEY',
    appId: '1:000000000000:android:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.firebasestorage.app',
  );
}
