import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../firebase_options.dart';

/// Uygulama genelinde kullanılan SharedPreferences örneği.
/// main() içinde overrideWithValue ile başlatılır.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider main() içinde başlatılmalıdır.');
});

/// Firebase API anahtarlarının gerçek değerlerle yapılandırılıp yapılandırılmadığını kontrol eder.
/// Kullanıcı henüz `env.json` veya `flutterfire configure` ile gerçek API anahtarı bağlamadıysa
/// uygulama otomatik olarak yerel (Local/SharedPreferences) modda tam etkileşimli çalışır.
final isFirebaseConfiguredProvider = Provider<bool>((ref) {
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    return !options.apiKey.startsWith('REPLACE_WITH_') &&
        options.projectId != 'okuma-gunlugu-app';
  } catch (_) {
    return false;
  }
});

/// FirebaseAuth sağlayıcısı.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Cloud Firestore sağlayıcısı (Offline Persistence açık).
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Aktif oturum açmış kullanıcı akışı.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final isConfigured = ref.watch(isFirebaseConfiguredProvider);
  if (!isConfigured) {
    return Stream.value(null);
  }
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

/// Aktif kullanıcı UID sağlayıcısı.
/// Firebase bağlanmadan önce yerel test yapılabilmesi için `'local_user'` döner.
final currentUserIdProvider = Provider<String?>((ref) {
  final isConfigured = ref.watch(isFirebaseConfiguredProvider);
  if (!isConfigured) {
    return 'local_user';
  }
  return ref.watch(authStateChangesProvider).valueOrNull?.uid ??
      ref.watch(firebaseAuthProvider).currentUser?.uid ??
      'local_user';
});
