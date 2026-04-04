import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Manages Google Sign-In and Firebase Authentication.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// The currently signed-in user, or null.
  static User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  static bool get isSignedIn => _auth.currentUser != null;

  /// Stream of auth state changes for reactive UI.
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in with Google. Returns the [User] on success, null on failure.
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      debugPrint('Google Sign-In failed: $e');
      return null;
    }
  }

  /// Signs out of both Google and Firebase.
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign-out failed: $e');
    }
  }
}
