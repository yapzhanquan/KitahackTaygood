import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/checkin_model.dart';
import '../config/app_config.dart';
import '../mock_data.dart';
import '../repositories/project_repository.dart';
import '../repositories/checkin_repository.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];

  String _searchQuery = '';
  ProjectCategory? _categoryFilter;
  ProjectStatus? _statusFilter;

  final DataMode _dataMode;
  StreamSubscription? _projectsSub;
  // Lazily initialised — only created when dataMode == firebase.
  late final ProjectRepository _projectRepo;
  late final CheckinRepository _checkinRepo;

  ProjectProvider({DataMode? dataMode})
      : _dataMode = dataMode ?? AppConfig.dataMode {
    if (_dataMode == DataMode.firebase) {
      _projectRepo = ProjectRepository();
      _checkinRepo = CheckinRepository();
      _loadFromFirestore();
    } else {
      _projects = List.from(mockProjects);
    }
  }

  // ── Firestore loading ──────────────────────────────────────

  void _loadFromFirestore() {
    _projectsSub = _projectRepo.streamProjects().listen(
      (projects) {
        _projects = projects;
        // Load check-ins for each project
        for (final project in _projects) {
          _loadCheckInsForProject(project);
        }
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error streaming projects: $e');
        // Fallback to mock data if Firestore fails
        _projects = List.from(mockProjects);
        notifyListeners();
      },
    );
  }

  void _loadCheckInsForProject(Project project) {
    _checkinRepo.streamCheckIns(project.id).listen(
      (checkIns) {
        project.checkIns.clear();
        project.checkIns.addAll(checkIns);
        _recalculateConfidence(project);
        notifyListeners();
      },
    );
  }

  // ── Filters ──────────────────────────────────────────────

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

  // ── Filtered list ──────────────────────────────────────────

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

  // ── Section-based getters ──────────────────────────────────

  List<Project> get activeProjects =>
      _projects.where((p) => p.status == ProjectStatus.active).toList();

  List<Project> get stalledProjects =>
      _projects.where((p) => p.status == ProjectStatus.stalled).toList();

  List<Project> get publicProjects =>
      _projects.where((p) => p.isPublic).toList();

  List<Project> get privateProjects =>
      _projects.where((p) => !p.isPublic).toList();

  // ── All projects (for map) ─────────────────────────────────

  List<Project> get allProjects => List.unmodifiable(_projects);

  // ── Single project ─────────────────────────────────────────

  Project getProjectById(String id) =>
      _projects.firstWhere((p) => p.id == id);

  // ── Check-in management ────────────────────────────────────

  void addCheckIn(String projectId, CheckIn checkIn) {
    final project = _projects.firstWhere((p) => p.id == projectId);

    // Optimistic local update
    project.checkIns.insert(0, checkIn);
    project.status = checkIn.status;
    _recalculateConfidence(project);
    notifyListeners();

    // Persist to Firestore if in firebase mode
    if (_dataMode == DataMode.firebase) {
      _checkinRepo.addCheckIn(projectId, checkIn).then((_) {
        // Update project status in Firestore
        _projectRepo.updateProjectStatus(
            projectId, project.status, project.confidence);
      }).catchError((e) {
        debugPrint('Error persisting check-in: $e');
      });
    }
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

  @override
  void dispose() {
    _projectsSub?.cancel();
    super.dispose();
  }
}
