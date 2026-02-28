import 'project_model.dart';

class CheckIn {
  final String id;
  final String projectId;
  final ProjectStatus status;
  final String note;
  final String? photoUrl;
  final List<String> photoUrls;
  final DateTime timestamp;
  final String reporterName;
  final String? userId;

  CheckIn({
    required this.id,
    required this.projectId,
    required this.status,
    required this.note,
    this.photoUrl,
    this.photoUrls = const [],
    required this.timestamp,
    required this.reporterName,
    this.userId,
  });

  // ── Firestore serialization ─────────────────────────────────

  factory CheckIn.fromJson(Map<String, dynamic> json, {String? docId}) {
    return CheckIn(
      id: docId ?? json['id'] as String? ?? '',
      projectId: json['projectId'] as String? ?? '',
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.unverified,
      ),
      note: json['note'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      reporterName: json['reporterName'] as String? ?? 'Anonymous',
      userId: json['userId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'projectId': projectId,
        'status': status.name,
        'note': note,
        'photoUrl': photoUrl,
        'photoUrls': photoUrls,
        'timestamp': timestamp.toIso8601String(),
        'reporterName': reporterName,
        'userId': userId,
      };
}
