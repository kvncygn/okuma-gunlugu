import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase yapılandırma dosyası.
/// Anahtarlar kaynak kodda tutulmaz; `--dart-define` veya
/// `--dart-define-from-file=env.json` üzerinden okunur.
/// Dilerseniz `flutterfire configure` komutuyla da üzerine yazabilirsiniz.
class DefaultFirebaseOptions {
  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'okuma-gunlugu-app',
  );
  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '000000000000',
  );
  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'okuma-gunlugu-app.appspot.com',
  );

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
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions bu platform için yapılandırılmadı.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: 'REPLACE_WITH_DART_DEFINE_ANDROID_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: '1:000000000000:android:0000000000000000',
    ),
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'REPLACE_WITH_DART_DEFINE_IOS_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: '1:000000000000:ios:0000000000000000',
    ),
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
    iosBundleId: String.fromEnvironment(
      'FIREBASE_IOS_BUNDLE_ID',
      defaultValue: 'com.example.okumaGunlugu',
    ),
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'REPLACE_WITH_DART_DEFINE_WEB_API_KEY',
    ),
    appId: String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: '1:000000000000:web:0000000000000000',
    ),
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    storageBucket: _storageBucket,
  );
}
