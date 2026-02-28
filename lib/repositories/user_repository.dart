import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// Repository for user data and bookmarks.
class UserRepository {
  final FirestoreService _firestoreService;

  UserRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Get or create user document from Firebase user info.
  Future<AppUser> getOrCreateUser(AppUser user) async {
    final existing = await _firestoreService.getUser(user.id);
    if (existing != null) return existing;
    await _firestoreService.upsertUser(user);
    return user;
  }

  /// Stream the set of bookmarked project IDs for a user.
  Stream<Set<String>> streamBookmarks(String userId) {
    return _firestoreService.streamBookmarks(userId);
  }

  /// Toggle bookmark for a project.
  Future<bool> toggleBookmark(String userId, String projectId) async {
    final isCurrentlyBookmarked =
        await _firestoreService.isBookmarked(userId, projectId);
    if (isCurrentlyBookmarked) {
      await _firestoreService.removeBookmark(userId, projectId);
      return false;
    } else {
      await _firestoreService.addBookmark(userId, projectId);
      return true;
    }
  }
}
