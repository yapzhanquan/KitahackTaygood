import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<User?> authStateChanges() => _auth.authStateChanges();

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  static Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    final trimmedName = name.trim();
    final normalizedName = trimmedName.isNotEmpty ? trimmedName : 'User';

    await user?.updateDisplayName(normalizedName);
    await user?.reload();

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': normalizedName,
        'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return credential;
  }

  // Backward-compatible wrapper for existing call sites.
  static Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return login(email: email, password: password);
  }

  // Backward-compatible wrapper for existing call sites.
  static Future<UserCredential> registerWithEmailPassword({
    String? name,
    required String email,
    required String password,
  }) {
    final normalizedName = (name ?? '').trim();
    return register(
      name: normalizedName.isEmpty ? 'User' : normalizedName,
      email: email,
      password: password,
    );
  }

  static Future<void> resetPassword({required String email}) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> logout() {
    return _auth.signOut();
  }

  // Backward-compatible wrapper for existing call sites.
  static Future<void> signOut() => logout();

  static String mapFirebaseAuthError(Object error) {
    if (error is FirebaseException && error.plugin == 'cloud_firestore') {
      return 'Unable to save profile data. Please try again.';
    }

    if (error is! FirebaseAuthException) {
      return 'Authentication failed. Please try again.';
    }

    switch (error.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
