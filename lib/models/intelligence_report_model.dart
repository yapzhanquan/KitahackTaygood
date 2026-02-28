import 'project_model.dart';

// RiskLevel enum is now in project_model.dart - use export for convenience
export 'project_model.dart' show RiskLevel, RiskLevelExt;

/// AI-generated intelligence summary
class IntelligenceSummary {
  final String projectHealthSummary;
  final String officialVsReality;
  final String inactivityAnalysis;
  final String riskScoreJustification;
  final RiskLevel riskLevel;
  final List<String> mitigationAdvice;
  final DateTime generatedAt;

  IntelligenceSummary({
    required this.projectHealthSummary,
    required this.officialVsReality,
    required this.inactivityAnalysis,
    required this.riskScoreJustification,
    required this.riskLevel,
    required this.mitigationAdvice,
    required this.generatedAt,
  });

  factory IntelligenceSummary.fromJson(Map<String, dynamic> json) {
    return IntelligenceSummary(
      projectHealthSummary: json['projectHealthSummary'] ?? '',
      officialVsReality: json['officialVsReality'] ?? '',
      inactivityAnalysis: json['inactivityAnalysis'] ?? '',
      riskScoreJustification: json['riskScoreJustification'] ?? '',
      riskLevel: _parseRiskLevel(json['riskLevel']),
      mitigationAdvice: List<String>.from(json['mitigationAdvice'] ?? []),
      generatedAt: DateTime.now(),
    );
  }

  static RiskLevel _parseRiskLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'low':
        return RiskLevel.low;
      case 'high':
        return RiskLevel.high;
      default:
        return RiskLevel.medium;
    }
  }

  Map<String, dynamic> toJson() => {
        'projectHealthSummary': projectHealthSummary,
        'officialVsReality': officialVsReality,
        'inactivityAnalysis': inactivityAnalysis,
        'riskScoreJustification': riskScoreJustification,
        'riskLevel': riskLevel.name,
        'mitigationAdvice': mitigationAdvice,
        'generatedAt': generatedAt.toIso8601String(),
      };
}

/// Developer background information (scraped data)
class DeveloperBackground {
  final String name;
  final String websiteUrl;
  final String status;
  final DateTime lastUpdated;
  final List<SourceLink> officialSources;
  final List<SourceLink> filings;
  final List<SourceLink> newsCoverage;
  final String? riskFlags;

  DeveloperBackground({
    required this.name,
    required this.websiteUrl,
    required this.status,
    required this.lastUpdated,
    required this.officialSources,
    required this.filings,
    required this.newsCoverage,
    this.riskFlags,
  });
}

/// Source link with confidence score
class SourceLink {
  final String title;
  final String url;
  final String type;
  final int confidencePercent;
  final String? description;

  SourceLink({
    required this.title,
    required this.url,
    required this.type,
    required this.confidencePercent,
    this.description,
  });
}

/// Historical trend data point
class TrendDataPoint {
  final DateTime date;
  final ProjectStatus status;
  final int activeCount;
  final int stalledCount;

  TrendDataPoint({
    required this.date,
    required this.status,
    required this.activeCount,
    required this.stalledCount,
  });
}

/// Complete Intelligence Report
class IntelligenceReport {
  final String projectId;
  final String projectName;
  final ProjectStatus currentStatus;
  final ConfidenceLevel confidenceLevel;
  final IntelligenceSummary aiSummary;
  final DeveloperBackground developerBackground;
  final List<TrendDataPoint> historicalTrend;
  final DateTime generatedAt;
  final String? pdfPath;

  IntelligenceReport({
    required this.projectId,
    required this.projectName,
    required this.currentStatus,
    required this.confidenceLevel,
    required this.aiSummary,
    required this.developerBackground,
    required this.historicalTrend,
    required this.generatedAt,
    this.pdfPath,
  });
}
