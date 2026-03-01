import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../mock_data.dart';
import '../models/checkin_model.dart';
import '../models/project_model.dart';

class BookmarkToggleResult {
  final bool success;
  final bool isSaved;
  final String? errorMessage;

  const BookmarkToggleResult({
    required this.success,
    required this.isSaved,
    this.errorMessage,
  });
}

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];
  final Set<String> _savedProjectIds = <String>{};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _bookmarkSubscription;
  bool _isBookmarkLoading = false;
  String? _bookmarkError;

  String _searchQuery = '';
  ProjectCategory? _categoryFilter;
  ProjectStatus? _statusFilter;

  ProjectProvider() {
    _projects = List.from(mockProjects);
    _authStateSubscription = _auth.authStateChanges().listen(
      _handleAuthStateChanged,
    );
    _handleAuthStateChanged(_auth.currentUser);
  }

  // Filters

  String get searchQuery => _searchQuery;
  ProjectCategory? get categoryFilter => _categoryFilter;
  ProjectStatus? get statusFilter => _statusFilter;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(ProjectCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setStatusFilter(ProjectStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  // Filtered list

  List<Project> get filteredProjects {
    return _projects.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !p.location.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_categoryFilter != null && p.category != _categoryFilter) {
        return false;
      }
      if (_statusFilter != null && p.status != _statusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  // Section-based getters

  List<Project> get activeProjects =>
      _projects.where((p) => p.status == ProjectStatus.active).toList();

  List<Project> get stalledProjects =>
      _projects.where((p) => p.status == ProjectStatus.stalled).toList();

  List<Project> get publicProjects =>
      _projects.where((p) => p.isPublic).toList();

  List<Project> get privateProjects =>
      _projects.where((p) => !p.isPublic).toList();

  // Single project

  Project getProjectById(String id) => _projects.firstWhere((p) => p.id == id);

  // Saved projects

  bool isProjectSaved(String projectId) => _savedProjectIds.contains(projectId);

  Set<String> get savedProjectIds => Set.unmodifiable(_savedProjectIds);

  List<Project> get savedProjects =>
      _projects.where((p) => _savedProjectIds.contains(p.id)).toList();

  List<Project> get savedActiveProjects =>
      savedProjects.where((p) => p.status == ProjectStatus.active).toList();

  List<Project> get savedStalledProjects =>
      savedProjects.where((p) => p.status == ProjectStatus.stalled).toList();

  List<Project> get savedPublicProjects =>
      savedProjects.where((p) => p.isPublic).toList();

  List<Project> get savedPrivateProjects =>
      savedProjects.where((p) => !p.isPublic).toList();

  bool get isBookmarkLoading => _isBookmarkLoading;
  String? get bookmarkError => _bookmarkError;

  Future<BookmarkToggleResult> toggleSavedProject(String projectId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return const BookmarkToggleResult(
        success: false,
        isSaved: false,
        errorMessage: 'Login required to save projects.',
      );
    }

    final wasSaved = _savedProjectIds.contains(projectId);
    final shouldSave = !wasSaved;

    if (shouldSave) {
      _savedProjectIds.add(projectId);
    } else {
      _savedProjectIds.remove(projectId);
    }
    _bookmarkError = null;
    notifyListeners();

    final bookmarkRef = _bookmarkCollectionForUser(user.uid).doc(projectId);

    try {
      if (shouldSave) {
        await bookmarkRef.set({
          'projectId': projectId,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        await bookmarkRef.delete();
      }

      return BookmarkToggleResult(success: true, isSaved: shouldSave);
    } catch (_) {
      if (wasSaved) {
        _savedProjectIds.add(projectId);
      } else {
        _savedProjectIds.remove(projectId);
      }
      _bookmarkError = 'Unable to update bookmark. Please try again.';
      notifyListeners();

      return BookmarkToggleResult(
        success: false,
        isSaved: wasSaved,
        errorMessage: _bookmarkError,
      );
    }
  }

  // Check-in management

  void addCheckIn(String projectId, CheckIn checkIn) {
    final project = _projects.firstWhere((p) => p.id == projectId);
    project.checkIns.insert(0, checkIn);
    project.status = checkIn.status;
    _recalculateConfidence(project);
    notifyListeners();
  }

  void _recalculateConfidence(Project project) {
    final recentCheckIns = project.checkIns.take(5).toList();
    if (recentCheckIns.isEmpty) {
      project.confidence = ConfidenceLevel.low;
      return;
    }

    if (recentCheckIns.length >= 3) {
      final statuses = recentCheckIns.map((c) => c.status).toSet();
      if (statuses.length == 1) {
        project.confidence = ConfidenceLevel.high;
      } else if (statuses.length == 2) {
        project.confidence = ConfidenceLevel.medium;
      } else {
        project.confidence = ConfidenceLevel.low;
      }
    } else {
      project.confidence = ConfidenceLevel.medium;
    }

    final now = DateTime.now();
    final latestCheckIn = recentCheckIns.first.timestamp;
    final daysSinceLastCheckIn = now.difference(latestCheckIn).inDays;
    if (daysSinceLastCheckIn > 60) {
      project.confidence = ConfidenceLevel.low;
    }
  }

  void _handleAuthStateChanged(User? user) {
    _bookmarkSubscription?.cancel();
    _bookmarkSubscription = null;

    if (user == null) {
      _savedProjectIds.clear();
      _isBookmarkLoading = false;
      _bookmarkError = null;
      notifyListeners();
      return;
    }

    _isBookmarkLoading = true;
    _bookmarkError = null;
    notifyListeners();

    _bookmarkSubscription = _bookmarkCollectionForUser(user.uid)
        .snapshots()
        .listen(
          (snapshot) {
            _savedProjectIds
              ..clear()
              ..addAll(
                snapshot.docs.map((doc) {
                  final data = doc.data();
                  final projectId = data['projectId'];
                  if (projectId is String && projectId.isNotEmpty) {
                    return projectId;
                  }
                  return doc.id;
                }),
              );
            _isBookmarkLoading = false;
            _bookmarkError = null;
            notifyListeners();
          },
          onError: (_) {
            _isBookmarkLoading = false;
            _bookmarkError = 'Unable to load saved projects.';
            notifyListeners();
          },
        );
  }

  CollectionReference<Map<String, dynamic>> _bookmarkCollectionForUser(
    String uid,
  ) {
    return _firestore.collection('users').doc(uid).collection('bookmarks');
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _bookmarkSubscription?.cancel();
    super.dispose();
  }
}
