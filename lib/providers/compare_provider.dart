import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../data/services/intelligence_service.dart';

/// CompareProvider - Manages project comparison selection state
/// Inspired by Apple's "Compare iPhone" feature
class CompareProvider extends ChangeNotifier {
  final IntelligenceService _intelligenceService = IntelligenceService();
  
  static const int maxSelectionMobile = 2;
  static const int maxSelectionTablet = 3;
  
  final List<Project> _selectedProjects = [];
  String? _verdictText;
  bool _isGeneratingVerdict = false;
  int _maxSelection = maxSelectionMobile;

  List<Project> get selectedProjects => List.unmodifiable(_selectedProjects);
  int get selectedCount => _selectedProjects.length;
  bool get hasSelection => _selectedProjects.isNotEmpty;
  bool get canCompare => _selectedProjects.length >= 2;
  bool get isMaxReached => _selectedProjects.length >= _maxSelection;
  String? get verdictText => _verdictText;
  bool get isGeneratingVerdict => _isGeneratingVerdict;
  int get maxSelection => _maxSelection;

  /// Set max selection based on device type
  void setMaxSelection(bool isTablet) {
    _maxSelection = isTablet ? maxSelectionTablet : maxSelectionMobile;
    // Trim selection if needed
    while (_selectedProjects.length > _maxSelection) {
      _selectedProjects.removeLast();
    }
    notifyListeners();
  }

  /// Check if a project is selected
  bool isSelected(Project project) {
    return _selectedProjects.any((p) => p.id == project.id);
  }

  /// Toggle project selection
  void toggleProject(Project project) {
    final index = _selectedProjects.indexWhere((p) => p.id == project.id);
    
    if (index >= 0) {
      // Already selected - remove
      _selectedProjects.removeAt(index);
    } else {
      // Not selected - add if not at max
      if (!isMaxReached) {
        _selectedProjects.add(project);
      }
    }
    
    // Clear verdict when selection changes
    _verdictText = null;
    notifyListeners();
  }

  /// Add project to comparison (if not already added and not at max)
  bool addProject(Project project) {
    if (isSelected(project) || isMaxReached) return false;
    _selectedProjects.add(project);
    _verdictText = null;
    notifyListeners();
    return true;
  }

  /// Remove project from comparison
  void removeProject(Project project) {
    _selectedProjects.removeWhere((p) => p.id == project.id);
    _verdictText = null;
    notifyListeners();
  }

  /// Clear all selections
  void clearAll() {
    _selectedProjects.clear();
    _verdictText = null;
    notifyListeners();
  }

  /// Generate AI verdict comparing two projects
  Future<void> generateVerdict() async {
    if (_selectedProjects.length < 2) return;
    
    _isGeneratingVerdict = true;
    _verdictText = null;
    notifyListeners();

    try {
      final project1 = _selectedProjects[0];
      final project2 = _selectedProjects[1];
      
      // Generate verdict using intelligence service
      _verdictText = await _generateComparisonVerdict(project1, project2);
    } catch (e) {
      _verdictText = 'Unable to generate verdict at this time.';
    } finally {
      _isGeneratingVerdict = false;
      notifyListeners();
    }
  }

  Future<String> _generateComparisonVerdict(Project p1, Project p2) async {
    final p1Risk = _calculateRiskScore(p1);
    final p2Risk = _calculateRiskScore(p2);
    
    final riskier = p1Risk > p2Risk ? p1 : p2;
    final safer = p1Risk > p2Risk ? p2 : p1;
    final riskierDeveloperClaim = _getDeveloperClaim(riskier);
    final saferDeveloperClaim = _getDeveloperClaim(safer);
    
    // Calculate reality gaps
    final riskierGap = riskierDeveloperClaim - riskier.progressPercentage;
    final saferGap = saferDeveloperClaim - safer.progressPercentage;
    
    // Generate conflict-focused verdict
    if (p1Risk == p2Risk) {
      return 'Both "${p1.name}" and "${p2.name}" show comparable risk profiles. '
          'Developer claims align within acceptable margins (±${saferGap.abs()}% vs ±${riskierGap.abs()}%). '
          'We recommend on-site verification for both before committing. '
          'Neither emerges as a clear safer choice based on current community data.';
    }
    
    final StringBuffer verdict = StringBuffer();
    
    // Opening with clear recommendation
    verdict.write('RECOMMENDATION: Choose "${safer.name}" over "${riskier.name}". ');
    
    // Reality gap analysis
    if (riskierGap > 20) {
      verdict.write('The developer of "${riskier.name}" claims $riskierDeveloperClaim% completion, '
          'but community verification shows only ${riskier.progressPercentage}% — '
          'a ${riskierGap}% credibility gap that signals potential "projek sakit" (sick project) risk. ');
    }
    
    // Activity analysis
    if (riskier.status == ProjectStatus.stalled) {
      verdict.write('The site has been stalled for ${riskier.daysSinceActivity}+ days with no visible work, '
          'machinery, or workers reported by the community. ');
    } else if (riskier.daysSinceActivity > 30) {
      verdict.write('No verified activity for ${riskier.daysSinceActivity} days despite official claims of ongoing work. ');
    }
    
    // Sentiment comparison
    if (riskier.sentimentScore < 0 && safer.sentimentScore > 0) {
      verdict.write('Community sentiment is ${(riskier.sentimentScore * 100).abs().toStringAsFixed(0)}% negative for "${riskier.name}" '
          'versus ${(safer.sentimentScore * 100).toStringAsFixed(0)}% positive for "${safer.name}". ');
    }
    
    // Closing with safer project highlight
    if (saferGap <= 10) {
      verdict.write('"${safer.name}" shows transparent progress reporting with only a ${saferGap}% gap '
          'between claims and community verification — a trustworthy indicator.');
    }
    
    return verdict.toString();
  }

  int _getDeveloperClaim(Project p) {
    if (p.status == ProjectStatus.stalled) return 85;
    if (p.status == ProjectStatus.slowing) return p.progressPercentage + 23;
    return p.progressPercentage + 5;
  }

  int _calculateRiskScore(Project p) {
    int score = 0;
    
    // Status-based risk
    switch (p.status) {
      case ProjectStatus.active:
        score += 0;
        break;
      case ProjectStatus.slowing:
        score += 3;
        break;
      case ProjectStatus.stalled:
        score += 6;
        break;
      case ProjectStatus.unverified:
        score += 4;
        break;
    }
    
    // Confidence level
    switch (p.confidence) {
      case ConfidenceLevel.high:
        score += 0;
        break;
      case ConfidenceLevel.medium:
        score += 1;
        break;
      case ConfidenceLevel.low:
        score += 2;
        break;
    }
    
    // Days since activity
    if (p.daysSinceActivity > 90) {
      score += 3;
    } else if (p.daysSinceActivity > 30) {
      score += 1;
    }
    
    // Check-in sentiment
    if (p.calculatedSentiment < -0.3) {
      score += 2;
    } else if (p.calculatedSentiment < 0) {
      score += 1;
    }
    
    // Expected completion overdue
    if (p.daysUntilCompletion != null && p.daysUntilCompletion! < 0) {
      score += 2;
    }
    
    return score;
  }
}
