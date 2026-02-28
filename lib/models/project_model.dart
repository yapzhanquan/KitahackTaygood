import 'checkin_model.dart';
import 'developer_enrichment_model.dart';

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
  final String? developerWebsite;
  DeveloperEnrichment? developerEnrichment;

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
    this.developerWebsite,
    this.developerEnrichment,
  });

  // ── Firestore serialization ─────────────────────────────────

  factory Project.fromJson(Map<String, dynamic> json, {String? docId}) {
    return Project(
      id: docId ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: ProjectCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ProjectCategory.housing,
      ),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.unverified,
      ),
      confidence: ConfidenceLevel.values.firstWhere(
        (e) => e.name == json['confidence'],
        orElse: () => ConfidenceLevel.low,
      ),
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      expectedCompletion: json['expectedCompletion'] != null
          ? DateTime.tryParse(json['expectedCompletion'] as String)
          : null,
      agencyOrDeveloper: json['agencyOrDeveloper'] as String? ?? '',
      lastActivity: DateTime.tryParse(json['lastActivity'] as String? ?? '') ??
          DateTime.now(),
      lastVerified: DateTime.tryParse(json['lastVerified'] as String? ?? '') ??
          DateTime.now(),
      checkIns: [], // Check-ins loaded separately as a sub-collection
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isPublic: json['isPublic'] as bool? ?? true,
      developerWebsite: json['developerWebsite'] as String?,
      developerEnrichment: json['developerEnrichment'] != null
          ? DeveloperEnrichment.fromJson(
              json['developerEnrichment'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.name,
        'status': status.name,
        'confidence': confidence.name,
        'location': location,
        'description': description,
        'imageUrl': imageUrl,
        'expectedCompletion': expectedCompletion?.toIso8601String(),
        'agencyOrDeveloper': agencyOrDeveloper,
        'lastActivity': lastActivity.toIso8601String(),
        'lastVerified': lastVerified.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'isPublic': isPublic,
        'developerWebsite': developerWebsite,
        'developerEnrichment': developerEnrichment?.toJson(),
      };
}
