import 'checkin_model.dart';
import 'developer_enrichment_model.dart';

enum ProjectCategory { housing, road, drainage, school }

enum ProjectStatus { active, slowing, stalled, unverified }

enum ConfidenceLevel { high, medium, low }

enum RiskLevel { low, medium, high }

enum SourceType { news, forum, government, developer, community }

/// Represents a scraped source link with metadata
class ScrapedSource {
  final String id;
  final String title;
  final String url;
  final SourceType type;
  final DateTime scrapedAt;
  final String? snippet;
  final String domain;

  const ScrapedSource({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
    required this.scrapedAt,
    this.snippet,
    required this.domain,
  });

  String get typeLabel {
    switch (type) {
      case SourceType.news:
        return 'News';
      case SourceType.forum:
        return 'Forum';
      case SourceType.government:
        return 'Gov';
      case SourceType.developer:
        return 'Dev';
      case SourceType.community:
        return 'Community';
    }
  }

  String get typeIcon {
    switch (type) {
      case SourceType.news:
        return '📰';
      case SourceType.forum:
        return '💬';
      case SourceType.government:
        return '🏛️';
      case SourceType.developer:
        return '🏗️';
      case SourceType.community:
        return '👥';
    }
  }
}

/// Official milestone claimed by developer
class OfficialMilestone {
  final String description;
  final int claimedProgress;
  final DateTime date;
  final ScrapedSource source;

  const OfficialMilestone({
    required this.description,
    required this.claimedProgress,
    required this.date,
    required this.source,
  });
}

/// Developer background with source citations
class DeveloperProfile {
  final String name;
  final int yearsActive;
  final int totalProjects;
  final int completedProjects;
  final int delayedProjects;
  final double rating;
  final List<ScrapedSource> sources;
  final String? litigationNote;

  const DeveloperProfile({
    required this.name,
    required this.yearsActive,
    required this.totalProjects,
    required this.completedProjects,
    required this.delayedProjects,
    required this.rating,
    required this.sources,
    this.litigationNote,
  });

  double get completionRate => totalProjects > 0 ? completedProjects / totalProjects : 0;
  double get delayRate => totalProjects > 0 ? delayedProjects / totalProjects : 0;
}

/// Sentiment analysis result with source attribution
class SentimentAnalysis {
  final double score; // -1 to 1
  final int totalReviews;
  final List<ScrapedSource> sources;
  final String summary;

  const SentimentAnalysis({
    required this.score,
    required this.totalReviews,
    required this.sources,
    required this.summary,
  });

  String get label {
    if (score > 0.3) return 'Positive';
    if (score < -0.3) return 'Negative';
    return 'Neutral';
  }
}

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

extension RiskLevelExt on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }

  String get riskLabel {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  String get emoji {
    switch (this) {
      case RiskLevel.low:
        return '🟢';
      case RiskLevel.medium:
        return '🟡';
      case RiskLevel.high:
        return '🔴';
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
  
  // Comparison fields
  final int progressPercentage;
  final RiskLevel riskLevel;
  final double developerScore;
  final double sentimentScore;

  // Source-grounded data
  final List<OfficialMilestone> officialMilestones;
  final DeveloperProfile? developerProfile;
  final SentimentAnalysis? sentimentAnalysis;
  final List<ScrapedSource> scrapedSources;

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
    this.progressPercentage = 0,
    this.riskLevel = RiskLevel.medium,
    this.developerScore = 3.0,
    this.sentimentScore = 0.5,
    this.officialMilestones = const [],
    this.developerProfile,
    this.sentimentAnalysis,
    this.scrapedSources = const [],
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

  /// Calculate risk level based on status and check-ins
  RiskLevel get calculatedRiskLevel {
    switch (status) {
      case ProjectStatus.active:
        return RiskLevel.low;
      case ProjectStatus.slowing:
        return RiskLevel.medium;
      case ProjectStatus.stalled:
        return RiskLevel.high;
      case ProjectStatus.unverified:
        return confidence == ConfidenceLevel.low ? RiskLevel.high : RiskLevel.medium;
    }
  }

  /// Calculate sentiment score from check-ins (-1 to 1)
  double get calculatedSentiment {
    if (checkIns.isEmpty) return 0.0;
    int positiveCount = checkIns.where((c) => c.status == ProjectStatus.active).length;
    int negativeCount = checkIns.where((c) => c.status == ProjectStatus.stalled).length;
    int total = checkIns.length;
    return (positiveCount - negativeCount) / total;
  }

  /// Days since last activity
  int get daysSinceActivity => DateTime.now().difference(lastActivity).inDays;

  /// Days until expected completion (negative if overdue)
  int? get daysUntilCompletion {
    if (expectedCompletion == null) return null;
    return expectedCompletion!.difference(DateTime.now()).inDays;
  }

  /// Check-in frequency (average days between check-ins)
  double get checkInFrequency {
    if (checkIns.length < 2) return 0;
    final sortedCheckIns = checkIns.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    int totalDays = sortedCheckIns.first.timestamp.difference(sortedCheckIns.last.timestamp).inDays;
    return totalDays / (checkIns.length - 1);
  }
}
