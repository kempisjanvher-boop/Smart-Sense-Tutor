import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'

    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDumJ3vrEePWOGbbQ6zM0B3CapuVf4_34U',
    appId: '1:982132430995:android:5bd3589122d173c02c5566',
    messagingSenderId: '982132430995',
    projectId: 'smart-sense-tutor',
    storageBucket: 'smart-sense-tutor.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDumJ3vrEePWOGbbQ6zM0B3CapuVf4_34U',
    appId: '1:982132430995:web:dummyappid12345678',
    messagingSenderId: '982132430995',
    projectId: 'smart-sense-tutor',
    authDomain: 'smart-sense-tutor.firebaseapp.com',
    storageBucket: 'smart-sense-tutor.firebasestorage.app',
  );
}