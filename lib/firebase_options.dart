// File generated for Firebase project shatbha-7f85c.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not configured for Firebase.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAh2QRPgDss41_uA7gvB-Rh71lc9zKoCTc',
    appId: '1:904767862527:android:3c19ca791742186150beca',
    messagingSenderId: '904767862527',
    projectId: 'shatbha-7f85c',
    storageBucket: 'shatbha-7f85c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDrkH9A5nGc0cAIK2Rhf8sFs-G2IjZhVRA',
    appId: '1:904767862527:ios:3a741041c33e443a50beca',
    messagingSenderId: '904767862527',
    projectId: 'shatbha-7f85c',
    storageBucket: 'shatbha-7f85c.firebasestorage.app',
    iosBundleId: 'com.shatbha.shatbha',
  );
}
