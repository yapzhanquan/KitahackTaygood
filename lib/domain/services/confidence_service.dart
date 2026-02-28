import '../../models/project_model.dart';
import '../../models/checkin_model.dart';

/// Service to calculate project confidence levels based on check-in data
/// Part of the Domain layer - pure business logic, no UI dependencies
class ConfidenceService {
  ConfidenceService._();

  /// Calculate confidence level based on check-in history
  /// 
  /// Algorithm:
  /// 1. No check-ins → Low confidence
  /// 2. Recent check-ins with consistent status → High confidence
  /// 3. Recent check-ins with mixed statuses → Medium/Low confidence
  /// 4. Stale data (>60 days since last check-in) → Degrades confidence
  static ConfidenceLevel calculateConfidence(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return ConfidenceLevel.low;
    }

    // Take the most recent check-ins for analysis
    final recentCheckIns = checkIns.take(5).toList();
    
    // Check data freshness
    final now = DateTime.now();
    final latestCheckIn = recentCheckIns.first.timestamp;
    final daysSinceLastCheckIn = now.difference(latestCheckIn).inDays;
    
    // Stale data automatically gets low confidence
    if (daysSinceLastCheckIn > 60) {
      return ConfidenceLevel.low;
    }

    // Not enough data points
    if (recentCheckIns.length < 3) {
      // But if it's very recent (within 7 days), give medium
      if (daysSinceLastCheckIn <= 7) {
        return ConfidenceLevel.medium;
      }
      return ConfidenceLevel.low;
    }

    // Analyze status consistency
    final statuses = recentCheckIns.map((c) => c.status).toSet();
    
    if (statuses.length == 1) {
      // All check-ins agree - high confidence
      // But if data is somewhat old (30-60 days), downgrade to medium
      if (daysSinceLastCheckIn > 30) {
        return ConfidenceLevel.medium;
      }
      return ConfidenceLevel.high;
    } else if (statuses.length == 2) {
      // Two different statuses - medium confidence
      return ConfidenceLevel.medium;
    } else {
      // Many conflicting statuses - low confidence
      return ConfidenceLevel.low;
    }
  }

  /// Get a human-readable explanation of the confidence level
  static String getConfidenceExplanation(ConfidenceLevel level, List<CheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return 'No community check-ins yet. Be the first to verify!';
    }

    final recentCount = checkIns.take(5).length;
    final now = DateTime.now();
    final daysSince = now.difference(checkIns.first.timestamp).inDays;

    switch (level) {
      case ConfidenceLevel.high:
        return 'Based on $recentCount consistent recent reports';
      case ConfidenceLevel.medium:
        if (daysSince > 30) {
          return 'Data is $daysSince days old. New check-ins needed.';
        }
        return 'Based on $recentCount reports with some variation';
      case ConfidenceLevel.low:
        if (daysSince > 60) {
          return 'Last check-in was $daysSince days ago. Needs verification.';
        }
        return 'Reports show conflicting statuses. More data needed.';
    }
  }

  /// Determine the most likely current status based on recent check-ins
  static ProjectStatus determineLikelyStatus(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) {
      return ProjectStatus.unverified;
    }

    // Weight recent check-ins more heavily
    final recentCheckIns = checkIns.take(5).toList();
    
    // Count occurrences of each status
    final statusCounts = <ProjectStatus, int>{};
    for (var i = 0; i < recentCheckIns.length; i++) {
      final status = recentCheckIns[i].status;
      // More recent = higher weight
      final weight = recentCheckIns.length - i;
      statusCounts[status] = (statusCounts[status] ?? 0) + weight;
    }

    // Return the status with highest weighted count
    return statusCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Check if the project needs fresh verification
  static bool needsVerification(List<CheckIn> checkIns, {int thresholdDays = 30}) {
    if (checkIns.isEmpty) return true;
    
    final daysSinceLastCheckIn = 
        DateTime.now().difference(checkIns.first.timestamp).inDays;
    
    return daysSinceLastCheckIn > thresholdDays;
  }

  /// Get urgency level for verification (for UI highlighting)
  static VerificationUrgency getVerificationUrgency(List<CheckIn> checkIns) {
    if (checkIns.isEmpty) return VerificationUrgency.high;
    
    final daysSince = DateTime.now().difference(checkIns.first.timestamp).inDays;
    
    if (daysSince > 60) return VerificationUrgency.high;
    if (daysSince > 30) return VerificationUrgency.medium;
    if (daysSince > 14) return VerificationUrgency.low;
    return VerificationUrgency.none;
  }
}

/// Urgency levels for verification prompts
enum VerificationUrgency {
  none,   // Recently verified, no action needed
  low,    // Could use a fresh check-in
  medium, // Should be verified soon
  high,   // Needs immediate verification
}

extension VerificationUrgencyExt on VerificationUrgency {
  String get label {
    switch (this) {
      case VerificationUrgency.none:
        return 'Up to date';
      case VerificationUrgency.low:
        return 'Check-in welcome';
      case VerificationUrgency.medium:
        return 'Needs update';
      case VerificationUrgency.high:
        return 'Verification needed';
    }
  }
}
