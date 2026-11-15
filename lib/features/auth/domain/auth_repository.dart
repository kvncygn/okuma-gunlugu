import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;

  bool get isAnonymous;

  Future<User?> ensureAnonymousSignIn();

  Future<User?> linkWithGoogle();

  Future<User?> linkWithApple();

  Future<void> signOutAndStartAnonymous();
}
