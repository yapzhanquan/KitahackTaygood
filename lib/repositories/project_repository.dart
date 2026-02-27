import '../models/project_model.dart';
import '../services/firestore_service.dart';

/// Repository for project data access.
/// Provides a clean API for fetching / streaming projects.
class ProjectRepository {
  final FirestoreService _firestoreService;

  ProjectRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Stream all projects from Firestore.
  Stream<List<Project>> streamProjects() {
    return _firestoreService.streamProjects();
  }

  /// Get a single project by ID.
  Future<Project?> getProjectById(String projectId) {
    return _firestoreService.getProject(projectId);
  }

  /// Update project status and confidence after a new check-in.
  Future<void> updateProjectStatus(
    String projectId,
    ProjectStatus status,
    ConfidenceLevel confidence,
  ) {
    return _firestoreService.updateProjectStatus(
        projectId, status, confidence);
  }
}
