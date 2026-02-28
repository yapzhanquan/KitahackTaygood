import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

/// Thin wrapper around Firebase Auth + Google Sign-In.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Streams & getters ──────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  String? get currentUserId => _auth.currentUser?.uid;

  bool get isSignedIn => _auth.currentUser != null;

  // ── Google Sign-In ─────────────────────────────────────────

  Future<AppUser?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;
    if (firebaseUser == null) return null;

    // Create or update user document in Firestore
    final appUser = AppUser(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      avatarUrl: firebaseUser.photoURL,
      email: firebaseUser.email,
      role: 'user',
      createdAt: DateTime.now(),
    );

    await FirestoreService().upsertUser(appUser);
    return appUser;
  }

  // ── Sign Out ───────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
