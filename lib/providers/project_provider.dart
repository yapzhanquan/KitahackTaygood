import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/checkin_model.dart';
import '../mock_data.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];

  String _searchQuery = '';
  ProjectCategory? _categoryFilter;
  ProjectStatus? _statusFilter;

  ProjectProvider() {
    _projects = List.from(mockProjects);
  }

  // ── Filters ──

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

  // ── Filtered list ──

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

  // ── Section-based getters ──

  List<Project> get activeProjects =>
      _projects.where((p) => p.status == ProjectStatus.active).toList();

  List<Project> get stalledProjects =>
      _projects.where((p) => p.status == ProjectStatus.stalled).toList();

  List<Project> get publicProjects =>
      _projects.where((p) => p.isPublic).toList();

  List<Project> get privateProjects =>
      _projects.where((p) => !p.isPublic).toList();

  // ── Single project ──

  Project getProjectById(String id) =>
      _projects.firstWhere((p) => p.id == id);

  // ── Check-in management ──

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
}
