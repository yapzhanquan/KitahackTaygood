import '../models/checkin_model.dart';
import '../services/firestore_service.dart';

/// Repository for check-in data access.
class CheckinRepository {
  final FirestoreService _firestoreService;

  CheckinRepository({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService();

  /// Stream check-ins for a project, ordered by most recent first.
  Stream<List<CheckIn>> streamCheckIns(String projectId) {
    return _firestoreService.streamCheckIns(projectId);
  }

  /// Add a new check-in to a project.
  Future<void> addCheckIn(String projectId, CheckIn checkIn) {
    return _firestoreService.addCheckIn(projectId, checkIn);
  }

  /// Delete a check-in (by the owning user).
  Future<void> deleteCheckIn(String projectId, String checkInId) {
    return _firestoreService.deleteCheckIn(projectId, checkInId);
  }
}
