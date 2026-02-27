import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/project_model.dart';
import '../models/checkin_model.dart';
import '../models/user_model.dart';

/// Typed Firestore helpers. Keeps raw Firestore API out of UI/Providers.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collection references ──────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _projectsCol =>
      _db.collection('projects');

  CollectionReference<Map<String, dynamic>> _checkInsCol(String projectId) =>
      _projectsCol.doc(projectId).collection('checkins');

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> _bookmarksCol(String userId) =>
      _usersCol.doc(userId).collection('bookmarks');

  // ── Projects ───────────────────────────────────────────────

  Stream<List<Project>> streamProjects() {
    return _projectsCol.snapshots().map((snap) => snap.docs
        .map((doc) => Project.fromJson(doc.data(), docId: doc.id))
        .toList());
  }

  Future<Project?> getProject(String projectId) async {
    final doc = await _projectsCol.doc(projectId).get();
    if (!doc.exists) return null;
    return Project.fromJson(doc.data()!, docId: doc.id);
  }

  Future<void> updateProjectStatus(
      String projectId, ProjectStatus status, ConfidenceLevel confidence) {
    return _projectsCol.doc(projectId).update({
      'status': status.name,
      'confidence': confidence.name,
      'lastActivity': DateTime.now().toIso8601String(),
      'lastVerified': DateTime.now().toIso8601String(),
    });
  }

  // ── Check-ins ──────────────────────────────────────────────

  Stream<List<CheckIn>> streamCheckIns(String projectId) {
    return _checkInsCol(projectId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CheckIn.fromJson(doc.data(), docId: doc.id))
            .toList());
  }

  Future<void> addCheckIn(String projectId, CheckIn checkIn) {
    return _checkInsCol(projectId).doc(checkIn.id).set(checkIn.toJson());
  }

  Future<void> deleteCheckIn(String projectId, String checkInId) {
    return _checkInsCol(projectId).doc(checkInId).delete();
  }

  // ── Users ──────────────────────────────────────────────────

  Future<AppUser?> getUser(String userId) async {
    final doc = await _usersCol.doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromJson(doc.data()!, docId: doc.id);
  }

  Future<void> upsertUser(AppUser user) {
    return _usersCol.doc(user.id).set(user.toJson(), SetOptions(merge: true));
  }

  // ── Bookmarks ──────────────────────────────────────────────

  Stream<Set<String>> streamBookmarks(String userId) {
    return _bookmarksCol(userId).snapshots().map(
        (snap) => snap.docs.map((doc) => doc.id).toSet());
  }

  Future<void> addBookmark(String userId, String projectId) {
    return _bookmarksCol(userId)
        .doc(projectId)
        .set({'createdAt': DateTime.now().toIso8601String()});
  }

  Future<void> removeBookmark(String userId, String projectId) {
    return _bookmarksCol(userId).doc(projectId).delete();
  }

  Future<bool> isBookmarked(String userId, String projectId) async {
    final doc = await _bookmarksCol(userId).doc(projectId).get();
    return doc.exists;
  }
}
