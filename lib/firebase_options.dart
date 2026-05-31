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
    apiKey: 'AIzaSyAbSTToQI9YLgkoPS9u08FEXTR_8FgQgik',
    appId: '1:911297546082:web:83b8a7c06709f109780e3b',
    messagingSenderId: '911297546082',
    projectId: 'tutormatch-cc970',
    authDomain: 'tutormatch-cc970.firebaseapp.com',
    storageBucket: 'tutormatch-cc970.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyARqLSkGZL-z8eYwavJJXoyO5DupIVXGUA',
    appId: '1:911297546082:android:8830197d97de6e50780e3b',
    messagingSenderId: '911297546082',
    projectId: 'tutormatch-cc970',
    storageBucket: 'tutormatch-cc970.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5dyYGbAWFLVuxWh-zBisUhlnxUhrvY14',
    appId: '1:911297546082:ios:22583d0361a8a9d5780e3b',
    messagingSenderId: '911297546082',
    projectId: 'tutormatch-cc970',
    storageBucket: 'tutormatch-cc970.firebasestorage.app',
    iosBundleId: 'com.example.tutorApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD5dyYGbAWFLVuxWh-zBisUhlnxUhrvY14',
    appId: '1:911297546082:ios:22583d0361a8a9d5780e3b',
    messagingSenderId: '911297546082',
    projectId: 'tutormatch-cc970',
    storageBucket: 'tutormatch-cc970.firebasestorage.app',
    iosBundleId: 'com.example.tutorApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAbSTToQI9YLgkoPS9u08FEXTR_8FgQgik',
    appId: '1:911297546082:web:a3b788e4c45aa831780e3b',
    messagingSenderId: '911297546082',
    projectId: 'tutormatch-cc970',
    authDomain: 'tutormatch-cc970.firebaseapp.com',
    storageBucket: 'tutormatch-cc970.firebasestorage.app',
  );
}
