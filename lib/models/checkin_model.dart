import 'project_model.dart';

class CheckIn {
  final String id;
  final String projectId;
  final ProjectStatus status;
  final String note;
  final String? photoUrl;
  final DateTime timestamp;
  final String reporterName;

  CheckIn({
    required this.id,
    required this.projectId,
    required this.status,
    required this.note,
    this.photoUrl,
    required this.timestamp,
    required this.reporterName,
  });
}
