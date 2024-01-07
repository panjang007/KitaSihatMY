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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAErUGShyZYBqTMz1v3Ct0rSSIojp45J78',
    appId: '1:280025324351:web:80de923cd251a3fd2c118a',
    messagingSenderId: '280025324351',
    projectId: 'kitasihatmy-f32dc',
    authDomain: 'kitasihatmy-f32dc.firebaseapp.com',
    storageBucket: 'kitasihatmy-f32dc.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGYsqFhV-DekBIOVPynWEacVOSAkt1vuc',
    appId: '1:280025324351:android:5d35ef2d28e9f0592c118a',
    messagingSenderId: '280025324351',
    projectId: 'kitasihatmy-f32dc',
    storageBucket: 'kitasihatmy-f32dc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_Z8FMn8JeR2CjpzBIxmzILxFkVvS0dGE',
    appId: '1:280025324351:ios:cd58d0841ffdc9c02c118a',
    messagingSenderId: '280025324351',
    projectId: 'kitasihatmy-f32dc',
    storageBucket: 'kitasihatmy-f32dc.appspot.com',
    iosBundleId: 'com.example.kitasihat',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB_Z8FMn8JeR2CjpzBIxmzILxFkVvS0dGE',
    appId: '1:280025324351:ios:4176cf878f24fe9a2c118a',
    messagingSenderId: '280025324351',
    projectId: 'kitasihatmy-f32dc',
    storageBucket: 'kitasihatmy-f32dc.appspot.com',
    iosBundleId: 'com.example.kitasihat.RunnerTests',
  );
}
