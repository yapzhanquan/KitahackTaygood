import 'checkin_model.dart';

enum ProjectCategory { housing, road, drainage, school }

enum ProjectStatus { active, slowing, stalled, unverified }

enum ConfidenceLevel { high, medium, low }

extension ProjectCategoryExt on ProjectCategory {
  String get label {
    switch (this) {
      case ProjectCategory.housing:
        return 'Housing';
      case ProjectCategory.road:
        return 'Road';
      case ProjectCategory.drainage:
        return 'Drainage';
      case ProjectCategory.school:
        return 'School';
    }
  }
}

extension ProjectStatusExt on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.slowing:
        return 'Slowing';
      case ProjectStatus.stalled:
        return 'Stalled';
      case ProjectStatus.unverified:
        return 'Unverified';
    }
  }
}

extension ConfidenceLevelExt on ConfidenceLevel {
  String get label {
    switch (this) {
      case ConfidenceLevel.high:
        return 'High';
      case ConfidenceLevel.medium:
        return 'Medium';
      case ConfidenceLevel.low:
        return 'Low';
    }
  }
}

class Project {
  final String id;
  final String name;
  final ProjectCategory category;
  ProjectStatus status;
  ConfidenceLevel confidence;
  final String location;
  final String description;
  final String imageUrl;
  final DateTime? expectedCompletion;
  final String agencyOrDeveloper;
  final DateTime lastActivity;
  final DateTime lastVerified;
  final List<CheckIn> checkIns;
  final double latitude;
  final double longitude;
  final bool isPublic;

  Project({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.confidence,
    required this.location,
    required this.description,
    required this.imageUrl,
    this.expectedCompletion,
    required this.agencyOrDeveloper,
    required this.lastActivity,
    required this.lastVerified,
    required this.checkIns,
    required this.latitude,
    required this.longitude,
    required this.isPublic,
  });
}
