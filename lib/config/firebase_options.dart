// ┌──────────────────────────────────────────────────────────────────────────┐
// │  PLACEHOLDER — run `flutterfire configure` to regenerate this file      │
// │  with your real Firebase project credentials.                           │
// │                                                                         │
// │  Until then the app defaults to DataMode.mock and never calls Firebase. │
// └──────────────────────────────────────────────────────────────────────────┘

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static bool get isConfigured => !_looksLikePlaceholder(currentPlatform);

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static bool _looksLikePlaceholder(FirebaseOptions options) {
    final apiKey = options.apiKey.trim();
    final projectId = options.projectId.trim().toLowerCase();
    final appId = options.appId.trim();
    return apiKey.isEmpty ||
        apiKey.startsWith('YOUR_') ||
        projectId == 'your-project-id' ||
        appId.contains('000000000000');
  }

  // ── Replace the values below after running `flutterfire configure` ──

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    iosBundleId: 'com.example.projekwatch',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'your-project-id',
    storageBucket: 'your-project-id.appspot.com',
    authDomain: 'your-project-id.firebaseapp.com',
  );
}
