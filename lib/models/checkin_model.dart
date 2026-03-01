import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory CheckIn.fromFirestore(String id, Map<String, dynamic> data) {
    final createdAt = data['createdAt'];
    final timestamp = createdAt is Timestamp
        ? createdAt.toDate()
        : createdAt is DateTime
            ? createdAt
            : DateTime.now();

    final rawPhotoUrl = (data['photoUrl'] as String?)?.trim();
    final photoUrl = (rawPhotoUrl != null && rawPhotoUrl.isNotEmpty)
        ? rawPhotoUrl
        : null;

    final reporterName = (data['userName'] as String?)?.trim().isNotEmpty == true
        ? (data['userName'] as String).trim()
        : (data['reporterName'] as String?)?.trim().isNotEmpty == true
            ? (data['reporterName'] as String).trim()
            : 'Community User';

    return CheckIn(
      id: id,
      projectId: (data['projectId'] as String?)?.trim() ?? '',
      status: _parseStatus(
        statusKey: data['statusKey'] as String?,
        statusLabel: data['status'] as String?,
      ),
      note: (data['note'] as String?)?.trim() ?? '',
      photoUrl: photoUrl,
      timestamp: timestamp,
      reporterName: reporterName,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'statusKey': status.name,
      'status': status.label,
      'note': note,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(timestamp),
      'userName': reporterName,
    };
  }

  static ProjectStatus _parseStatus({
    String? statusKey,
    String? statusLabel,
  }) {
    final normalizedKey = statusKey?.trim().toLowerCase();
    switch (normalizedKey) {
      case 'active':
        return ProjectStatus.active;
      case 'slowing':
        return ProjectStatus.slowing;
      case 'stalled':
        return ProjectStatus.stalled;
      case 'unverified':
        return ProjectStatus.unverified;
    }

    final normalizedLabel = statusLabel?.trim().toLowerCase();
    switch (normalizedLabel) {
      case 'active':
        return ProjectStatus.active;
      case 'slowing':
        return ProjectStatus.slowing;
      case 'stalled':
        return ProjectStatus.stalled;
      default:
        return ProjectStatus.unverified;
    }
  }
}
