import 'package:flutter/material.dart';

/// Represents a company director with their history and risk profile
class Director {
  final String id;
  final String name;
  final String icNumber; // Masked for privacy
  final String position;
  final DateTime appointmentDate;
  final List<CompanyAssociation> associations;
  final DirectorRiskLevel riskLevel;
  final String? alertMessage;

  Director({
    required this.id,
    required this.name,
    required this.icNumber,
    required this.position,
    required this.appointmentDate,
    required this.associations,
    required this.riskLevel,
    this.alertMessage,
  });

  int get failedCompaniesCount =>
      associations.where((a) => a.status == CompanyStatus.failed || a.status == CompanyStatus.blacklisted).length;

  int get activeCompaniesCount =>
      associations.where((a) => a.status == CompanyStatus.active).length;

  bool get hasHighRisk => riskLevel == DirectorRiskLevel.high || riskLevel == DirectorRiskLevel.critical || failedCompaniesCount >= 2;
}

/// Company association for a director
class CompanyAssociation {
  final String companyId;
  final String companyName;
  final String registrationNumber;
  final CompanyStatus status;
  final String? role;
  final DateTime? associationStart;
  final DateTime? associationEnd;
  final String? failureReason;
  final String sourceUrl;

  CompanyAssociation({
    required this.companyId,
    required this.companyName,
    required this.registrationNumber,
    required this.status,
    this.role,
    this.associationStart,
    this.associationEnd,
    this.failureReason,
    required this.sourceUrl,
  });
}

/// Company status enum
enum CompanyStatus {
  active,
  dormant,
  failed,
  blacklisted,
  underInvestigation,
  dissolved,
}

extension CompanyStatusExtension on CompanyStatus {
  String get label {
    switch (this) {
      case CompanyStatus.active:
        return 'Active';
      case CompanyStatus.dormant:
        return 'Dormant';
      case CompanyStatus.failed:
        return 'Failed';
      case CompanyStatus.blacklisted:
        return 'Blacklisted';
      case CompanyStatus.underInvestigation:
        return 'Under Investigation';
      case CompanyStatus.dissolved:
        return 'Dissolved';
    }
  }

  Color get color {
    switch (this) {
      case CompanyStatus.active:
        return const Color(0xFF10B981);
      case CompanyStatus.dormant:
        return const Color(0xFF6B7280);
      case CompanyStatus.failed:
        return const Color(0xFFEF4444);
      case CompanyStatus.blacklisted:
        return const Color(0xFF7F1D1D);
      case CompanyStatus.underInvestigation:
        return const Color(0xFFF59E0B);
      case CompanyStatus.dissolved:
        return const Color(0xFF9CA3AF);
    }
  }

  IconData get icon {
    switch (this) {
      case CompanyStatus.active:
        return Icons.check_circle_rounded;
      case CompanyStatus.dormant:
        return Icons.pause_circle_rounded;
      case CompanyStatus.failed:
        return Icons.error_rounded;
      case CompanyStatus.blacklisted:
        return Icons.block_rounded;
      case CompanyStatus.underInvestigation:
        return Icons.search_rounded;
      case CompanyStatus.dissolved:
        return Icons.cancel_rounded;
    }
  }
}

/// Risk level for directors (named differently to avoid conflict with project_model.dart)
enum DirectorRiskLevel {
  low,
  medium,
  high,
  critical,
}

extension DirectorRiskLevelExtension on DirectorRiskLevel {
  String get label {
    switch (this) {
      case DirectorRiskLevel.low:
        return 'Low Risk';
      case DirectorRiskLevel.medium:
        return 'Medium Risk';
      case DirectorRiskLevel.high:
        return 'High Risk';
      case DirectorRiskLevel.critical:
        return 'Critical Risk';
    }
  }

  Color get color {
    switch (this) {
      case DirectorRiskLevel.low:
        return const Color(0xFF10B981);
      case DirectorRiskLevel.medium:
        return const Color(0xFFF59E0B);
      case DirectorRiskLevel.high:
        return const Color(0xFFEF4444);
      case DirectorRiskLevel.critical:
        return const Color(0xFF7F1D1D);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case DirectorRiskLevel.low:
        return const Color(0xFFECFDF5);
      case DirectorRiskLevel.medium:
        return const Color(0xFFFFFBEB);
      case DirectorRiskLevel.high:
        return const Color(0xFFFEF2F2);
      case DirectorRiskLevel.critical:
        return const Color(0xFFFEF2F2);
    }
  }
}

/// Complete developer network profile
class DeveloperNetwork {
  final String developerId;
  final String companyName;
  final String registrationNumber;
  final DateTime incorporationDate;
  final String companyStatus;
  final double paidUpCapital;
  final String businessAddress;
  final List<Director> directors;
  final List<PastProject> pastProjects;
  final NetworkRiskSummary riskSummary;
  final List<String> sourceUrls;
  final DateTime lastUpdated;

  DeveloperNetwork({
    required this.developerId,
    required this.companyName,
    required this.registrationNumber,
    required this.incorporationDate,
    required this.companyStatus,
    required this.paidUpCapital,
    required this.businessAddress,
    required this.directors,
    required this.pastProjects,
    required this.riskSummary,
    required this.sourceUrls,
    required this.lastUpdated,
  });

  bool get hasHighRiskDirectors => directors.any((d) => d.hasHighRisk);
  
  int get totalFailedAssociations => 
      directors.fold(0, (sum, d) => sum + d.failedCompaniesCount);
}

/// Summary of network risk assessment
class NetworkRiskSummary {
  final DirectorRiskLevel overallRisk;
  final int totalDirectors;
  final int highRiskDirectors;
  final int failedCompanyLinks;
  final int blacklistedLinks;
  final String aiAnalysis;
  final List<String> keyFindings;

  NetworkRiskSummary({
    required this.overallRisk,
    required this.totalDirectors,
    required this.highRiskDirectors,
    required this.failedCompanyLinks,
    required this.blacklistedLinks,
    required this.aiAnalysis,
    required this.keyFindings,
  });
}

/// Past project completed by the developer
class PastProject {
  final String id;
  final String name;
  final String location;
  final String type;
  final int units;
  final DateTime completionDate;
  final String imageUrl;
  final double? communityRating;
  final int reviewCount;
  final String? reviewSnippet;
  final String sourceUrl;
  final PastProjectStatus status;
  final List<CommunityPhoto> communityPhotos;

  PastProject({
    required this.id,
    required this.name,
    required this.location,
    required this.type,
    required this.units,
    required this.completionDate,
    required this.imageUrl,
    this.communityRating,
    required this.reviewCount,
    this.reviewSnippet,
    required this.sourceUrl,
    required this.status,
    required this.communityPhotos,
  });
}

/// Status of a past project
enum PastProjectStatus {
  completed,
  delayed,
  problemsReported,
  abandoned,
}

extension PastProjectStatusExtension on PastProjectStatus {
  String get label {
    switch (this) {
      case PastProjectStatus.completed:
        return 'Completed';
      case PastProjectStatus.delayed:
        return 'Delayed';
      case PastProjectStatus.problemsReported:
        return 'Problems Reported';
      case PastProjectStatus.abandoned:
        return 'Abandoned';
    }
  }

  Color get color {
    switch (this) {
      case PastProjectStatus.completed:
        return const Color(0xFF10B981);
      case PastProjectStatus.delayed:
        return const Color(0xFFF59E0B);
      case PastProjectStatus.problemsReported:
        return const Color(0xFFEF4444);
      case PastProjectStatus.abandoned:
        return const Color(0xFF7F1D1D);
    }
  }
}

/// Community photo for past projects
class CommunityPhoto {
  final String url;
  final String caption;
  final DateTime uploadedAt;
  final String uploaderName;

  CommunityPhoto({
    required this.url,
    required this.caption,
    required this.uploadedAt,
    required this.uploaderName,
  });
}
