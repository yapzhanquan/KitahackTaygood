import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

/// ChangeNotifier wrapping AuthService for use with Provider.
class AuthProvider extends ChangeNotifier {
  // Lazily created only when dataMode == firebase to avoid touching Firebase
  // SDK in mock mode (which would crash without Firebase.initializeApp).
  AuthService? _authService;
  FirestoreService? _firestoreService;
  final DataMode _dataMode;

  AuthService get _auth => _authService ??= AuthService();
  FirestoreService get _fs => _firestoreService ??= FirestoreService();

  AppUser? _currentUser;
  Set<String> _bookmarks = {};
  bool _isLoading = false;
  StreamSubscription? _authSub;
  StreamSubscription? _bookmarkSub;

  AuthProvider({DataMode? dataMode})
      : _dataMode = dataMode ?? AppConfig.runtimeDataMode {
    if (_dataMode == DataMode.firebase) {
      _authSub = _auth.authStateChanges.listen(_onAuthChanged);
    }
  }

  // ── Public getters ─────────────────────────────────────────

  AppUser? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  Set<String> get bookmarks => _bookmarks;

  bool isBookmarked(String projectId) => _bookmarks.contains(projectId);

  // ── Auth actions ───────────────────────────────────────────

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_dataMode != DataMode.firebase) {
        _currentUser ??= AppUser(
          id: 'mock-user',
          name: 'Demo User',
          email: 'demo@projekwatch.local',
          role: 'user',
          createdAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      }

      final user = await _auth.signInWithGoogle();
      if (user != null) {
        _currentUser = user;
        _listenToBookmarks(user.id);
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_dataMode == DataMode.firebase) {
      await _auth.signOut();
    }
    _currentUser = null;
    _bookmarks = {};
    _bookmarkSub?.cancel();
    notifyListeners();
  }

  // ── Bookmarks ──────────────────────────────────────────────

  Future<void> toggleBookmark(String projectId) async {
    final userId = _currentUser?.id;
    if (userId == null) return;

    if (_dataMode != DataMode.firebase) {
      if (_bookmarks.contains(projectId)) {
        _bookmarks.remove(projectId);
      } else {
        _bookmarks.add(projectId);
      }
      notifyListeners();
      return;
    }

    // Optimistic update
    if (_bookmarks.contains(projectId)) {
      _bookmarks.remove(projectId);
    } else {
      _bookmarks.add(projectId);
    }
    notifyListeners();

    // Persist
    try {
      final nowBookmarked = await _fs.isBookmarked(userId, projectId);
      if (nowBookmarked) {
        await _fs.removeBookmark(userId, projectId);
      } else {
        await _fs.addBookmark(userId, projectId);
      }
    } catch (_) {
      // Revert optimistic update on error
      if (_bookmarks.contains(projectId)) {
        _bookmarks.remove(projectId);
      } else {
        _bookmarks.add(projectId);
      }
      notifyListeners();
    }
  }

  // ── Private helpers ────────────────────────────────────────

  void _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      _currentUser = AppUser(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? 'User',
        avatarUrl: firebaseUser.photoURL,
        email: firebaseUser.email,
      );
      _listenToBookmarks(firebaseUser.uid);
    } else {
      _currentUser = null;
      _bookmarks = {};
      _bookmarkSub?.cancel();
    }
    notifyListeners();
  }

  void _listenToBookmarks(String userId) {
    if (_dataMode != DataMode.firebase) return;
    _bookmarkSub?.cancel();
    _bookmarkSub = _fs.streamBookmarks(userId).listen(
      (bookmarks) {
        _bookmarks = bookmarks;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _bookmarkSub?.cancel();
    super.dispose();
  }
}
