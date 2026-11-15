import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository(
    this._firebaseAuth, {
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  bool get isAnonymous => _firebaseAuth.currentUser?.isAnonymous ?? true;

  @override
  Future<User?> ensureAnonymousSignIn() async {
    if (_firebaseAuth.currentUser != null) {
      return _firebaseAuth.currentUser;
    }
    final cred = await _firebaseAuth.signInAnonymously();
    return cred.user;
  }

  @override
  Future<User?> linkWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final user = _firebaseAuth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        final linked = await user.linkWithCredential(credential);
        return linked.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          final signedIn = await _firebaseAuth.signInWithCredential(credential);
          return signedIn.user;
        }
        rethrow;
      }
    } else {
      final signedIn = await _firebaseAuth.signInWithCredential(credential);
      return signedIn.user;
    }
  }

  @override
  Future<User?> linkWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final OAuthCredential credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final user = _firebaseAuth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        final linked = await user.linkWithCredential(credential);
        return linked.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          final signedIn = await _firebaseAuth.signInWithCredential(credential);
          return signedIn.user;
        }
        rethrow;
      }
    } else {
      final signedIn = await _firebaseAuth.signInWithCredential(credential);
      return signedIn.user;
    }
  }

  @override
  Future<void> signOutAndStartAnonymous() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
    await _firebaseAuth.signInAnonymously();
  }
}
