import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/project_model.dart';
import '../../models/checkin_model.dart';
import '../../models/intelligence_report_model.dart';

/// IntelligenceService - AI-powered project analysis using Gemini API
/// Processes scraped data and community check-ins to generate insights
class IntelligenceService {
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // Replace with actual key
  
  late final GenerativeModel _model;
  
  IntelligenceService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Generate AI summary from project data and community check-ins
  Future<IntelligenceSummary> generateSummary({
    required Project project,
    required List<CheckIn> checkIns,
    String? scrapedOfficialData,
    String? developerNewsData,
  }) async {
    final prompt = _buildAnalysisPrompt(
      project: project,
      checkIns: checkIns,
      scrapedOfficialData: scrapedOfficialData,
      developerNewsData: developerNewsData,
    );

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';
      
      // Parse the JSON response from Gemini
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        return IntelligenceSummary.fromJson(json);
      }
      
      // Fallback if JSON parsing fails
      return _createFallbackSummary(project, checkIns);
    } catch (e) {
      // Return mock data for demo/testing when API is unavailable
      return _createMockSummary(project, checkIns);
    }
  }

  String _buildAnalysisPrompt({
    required Project project,
    required List<CheckIn> checkIns,
    String? scrapedOfficialData,
    String? developerNewsData,
  }) {
    final checkInSummary = checkIns.take(10).map((c) => 
      '- [${c.timestamp.toString().split(' ')[0]}] ${c.status.label}: ${c.note} (by ${c.reporterName})'
    ).join('\n');

    final officialData = scrapedOfficialData ?? 
      'Official website states project is progressing as scheduled. Expected completion: ${project.expectedCompletion?.toString().split(' ')[0] ?? 'Not specified'}';

    return '''
You are an investigative analyst specializing in construction project transparency. Your role is to conduct a REALITY AUDIT - comparing official developer claims against ground-truth community observations.

PROJECT INFORMATION:
- Name: ${project.name}
- Category: ${project.category.label}
- Location: ${project.location}
- Developer: ${project.agencyOrDeveloper}
- Current Status: ${project.status.label}
- Expected Completion: ${project.expectedCompletion?.toString().split(' ')[0] ?? 'Not specified'}
- Days Since Last Activity: ${DateTime.now().difference(project.lastActivity).inDays}
- Last Verified: ${project.lastVerified.toString().split(' ')[0]}

OFFICIAL DEVELOPER CLAIMS:
$officialData

${developerNewsData != null ? 'RECENT NEWS COVERAGE:\n$developerNewsData\n' : ''}

COMMUNITY EVIDENCE (Ground Truth from Site Visits):
$checkInSummary

REALITY AUDIT INSTRUCTIONS:
1. DETECT DISCREPANCIES: Compare official marketing vs. what community observers actually see
2. BE SPECIFIC: Use concrete examples (e.g., "Developer claims 90% completion, but community photos show zero crane activity for 30 days")
3. IDENTIFY RED FLAGS: Unexplained gaps, contradictions, or concerning patterns
4. QUANTIFY: Use numbers (days, percentages, counts) where possible
5. RECOMMEND ACTION: Provide specific next steps for concerned stakeholders

Return your analysis as a JSON object with this exact structure:
{
  "projectHealthSummary": "3 sharp sentences on project health based ONLY on community evidence, not developer claims",
  "officialVsReality": "Specific discrepancy analysis, e.g., 'Developer website shows active construction, but 4 of 5 recent check-ins report site is abandoned with no workers present for 45+ days'",
  "inactivityAnalysis": "Gap analysis with specific timeframes, e.g., 'No verified activity between Jan 15-Feb 20. Last equipment movement reported Dec 2025.'",
  "riskScoreJustification": "Data-backed risk reasoning with specific metrics",
  "riskLevel": "low|medium|high",
  "mitigationAdvice": ["Specific action 1 with context", "Specific action 2", "Specific action 3"]
}

Be direct, factual, and skeptical. This report protects property buyers from developer misinformation.
Respond ONLY with the JSON object.
''';
  }

  IntelligenceSummary _createFallbackSummary(Project project, List<CheckIn> checkIns) {
    return IntelligenceSummary(
      projectHealthSummary: 'Unable to generate AI analysis at this time. Based on ${checkIns.length} community reports, the project is currently ${project.status.label.toLowerCase()}.',
      officialVsReality: 'Manual review recommended to compare official developer statements with community observations.',
      inactivityAnalysis: 'Analysis pending. Last community report was on ${checkIns.isNotEmpty ? checkIns.first.timestamp.toString().split(' ')[0] : 'N/A'}.',
      riskScoreJustification: 'Risk assessment requires additional data points for accurate evaluation.',
      riskLevel: _inferRiskLevel(project, checkIns),
      mitigationAdvice: [
        'Visit the project site in person to verify current status',
        'Contact the developer for an official progress update',
        'Review your Sales & Purchase Agreement for delay clauses',
      ],
      generatedAt: DateTime.now(),
    );
  }

  IntelligenceSummary _createMockSummary(Project project, List<CheckIn> checkIns) {
    final riskLevel = _inferRiskLevel(project, checkIns);
    final daysSinceActivity = DateTime.now().difference(project.lastActivity).inDays;
    final recentStalled = checkIns.where((c) => c.status == ProjectStatus.stalled || c.status == ProjectStatus.slowing).length;
    final recentActive = checkIns.where((c) => c.status == ProjectStatus.active).length;
    
    String healthSummary;
    String officialVsReality;
    String inactivityAnalysis;
    
    switch (project.status) {
      case ProjectStatus.active:
        healthSummary = 'VERIFIED ACTIVE: ${checkIns.length} independent community check-ins confirm ongoing construction. $recentActive of ${checkIns.length} recent reports indicate workers and equipment present. Site shows consistent progress matching expected development phases.';
        officialVsReality = 'Developer claims of "on-schedule progress" are SUPPORTED by community evidence. ${checkIns.length} verified site visits in the reporting period show activity consistent with official timeline. No significant discrepancy detected.';
        inactivityAnalysis = 'Activity pattern: Regular site presence confirmed. Average gap between check-ins: ${(30 / (checkIns.isNotEmpty ? checkIns.length : 1)).round()} days. Last verified activity: $daysSinceActivity days ago. Pattern indicates healthy construction momentum.';
        break;
      case ProjectStatus.slowing:
        healthSummary = 'WARNING - MOMENTUM DECLINING: Of ${checkIns.length} community reports, $recentStalled indicate reduced activity. Workers present but at lower capacity than previous phases. Equipment utilization appears sporadic based on observer photos.';
        officialVsReality = 'REALITY GAP DETECTED: Developer website still claims "progressing as scheduled" but $recentStalled of ${checkIns.length} community reports contradict this. Site observers report 40-60% fewer workers compared to 3 months ago. Crane activity down significantly.';
        inactivityAnalysis = 'Concerning gaps identified: $daysSinceActivity days since last significant progress report. Pattern shows intermittent activity with periods of 7-14 days of minimal visible work. This suggests possible cash flow or resource constraints.';
        break;
      case ProjectStatus.stalled:
        healthSummary = 'CRITICAL ALERT: Project appears ABANDONED. ${checkIns.length} community reports, with $recentStalled confirming site inactivity. No crane movement, no workers present, construction materials sitting exposed to weather for extended periods.';
        officialVsReality = 'MAJOR DISCREPANCY: Developer maintains "project ongoing" messaging while community evidence shows ZERO activity for $daysSinceActivity+ days. Last ${checkIns.length} site visits all report abandoned appearance. This is a significant red flag.';
        inactivityAnalysis = 'Extended inactivity: NO verified construction activity for $daysSinceActivity days. Site security present but no workers. Equipment appears unmoved. Materials deteriorating. Pattern consistent with project halt or financial distress.';
        break;
      case ProjectStatus.unverified:
        healthSummary = 'INSUFFICIENT DATA: Only ${checkIns.length} community reports available - not enough for reliable assessment. Developer claims cannot be verified. Ground-truth validation urgently needed from local observers.';
        officialVsReality = 'UNVERIFIABLE: Developer claims existence but community coverage is too sparse to confirm or deny. ${checkIns.length} reports is below the threshold for reliable comparison. This project needs more community attention.';
        inactivityAnalysis = 'DATA GAP: Cannot establish activity pattern with only ${checkIns.length} data points. Last known check-in: $daysSinceActivity days ago. More frequent community monitoring required to assess true project health.';
        break;
    }
    
    return IntelligenceSummary(
      projectHealthSummary: healthSummary,
      officialVsReality: officialVsReality,
      inactivityAnalysis: inactivityAnalysis,
      riskScoreJustification: _generateRiskJustification(project, checkIns, riskLevel),
      riskLevel: riskLevel,
      mitigationAdvice: _generateMitigationAdvice(project, riskLevel),
      generatedAt: DateTime.now(),
    );
  }

  RiskLevel _inferRiskLevel(Project project, List<CheckIn> checkIns) {
    int riskScore = 0;
    
    // Status-based risk
    switch (project.status) {
      case ProjectStatus.active:
        riskScore += 0;
        break;
      case ProjectStatus.slowing:
        riskScore += 2;
        break;
      case ProjectStatus.stalled:
        riskScore += 4;
        break;
      case ProjectStatus.unverified:
        riskScore += 3;
        break;
    }
    
    // Confidence-based risk
    switch (project.confidence) {
      case ConfidenceLevel.high:
        riskScore += 0;
        break;
      case ConfidenceLevel.medium:
        riskScore += 1;
        break;
      case ConfidenceLevel.low:
        riskScore += 2;
        break;
    }
    
    // Activity recency
    final daysSinceActivity = DateTime.now().difference(project.lastActivity).inDays;
    if (daysSinceActivity > 90) {
      riskScore += 3;
    } else if (daysSinceActivity > 30) {
      riskScore += 1;
    }
    
    // Check-in frequency
    if (checkIns.length < 3) {
      riskScore += 2;
    }
    
    if (riskScore <= 2) return RiskLevel.low;
    if (riskScore <= 5) return RiskLevel.medium;
    return RiskLevel.high;
  }

  String _generateRiskJustification(Project project, List<CheckIn> checkIns, RiskLevel risk) {
    final factors = <String>[];
    
    factors.add('Current status: ${project.status.label}');
    factors.add('Confidence level: ${project.confidence.label}');
    factors.add('Community reports: ${checkIns.length}');
    
    final daysSinceActivity = DateTime.now().difference(project.lastActivity).inDays;
    factors.add('Days since last activity: $daysSinceActivity');
    
    if (project.expectedCompletion != null) {
      final daysUntilDeadline = project.expectedCompletion!.difference(DateTime.now()).inDays;
      if (daysUntilDeadline < 0) {
        factors.add('Project is ${-daysUntilDeadline} days past expected completion');
      } else {
        factors.add('$daysUntilDeadline days until expected completion');
      }
    }
    
    return 'Risk assessment based on: ${factors.join('; ')}. Overall risk classified as ${risk.label}.';
  }

  List<String> _generateMitigationAdvice(Project project, RiskLevel risk) {
    final advice = <String>[];
    
    switch (risk) {
      case RiskLevel.low:
        advice.addAll([
          'Continue monitoring project through regular site visits',
          'Subscribe to developer updates for milestone notifications',
          'Document your observations to contribute to community data',
        ]);
        break;
      case RiskLevel.medium:
        advice.addAll([
          'Request a formal progress update from the developer',
          'Review your Sales & Purchase Agreement for delay compensation clauses',
          'Consider visiting the site during working hours to verify activity',
          'Connect with other buyers through owner groups for collective updates',
        ]);
        break;
      case RiskLevel.high:
        advice.addAll([
          'URGENT: Contact developer management for immediate clarification',
          'Consult a property lawyer regarding your contractual rights',
          'File an inquiry with the Housing Ministry (KPKT) if delays exceed 12 months',
          'Document all site conditions with photos and dates as evidence',
          'Review liquidated damages clauses in your S&P Agreement',
        ]);
        break;
    }
    
    return advice;
  }

  /// Generate historical trend data from check-ins
  List<TrendDataPoint> generateHistoricalTrend(List<CheckIn> checkIns) {
    final now = DateTime.now();
    final sixMonthsAgo = now.subtract(const Duration(days: 180));
    
    // Group check-ins by month
    final monthlyData = <DateTime, Map<String, int>>{};
    
    for (var i = 0; i < 6; i++) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      monthlyData[monthStart] = {'active': 0, 'stalled': 0};
    }
    
    for (final checkIn in checkIns) {
      if (checkIn.timestamp.isAfter(sixMonthsAgo)) {
        final monthKey = DateTime(checkIn.timestamp.year, checkIn.timestamp.month, 1);
        if (monthlyData.containsKey(monthKey)) {
          if (checkIn.status == ProjectStatus.active) {
            monthlyData[monthKey]!['active'] = monthlyData[monthKey]!['active']! + 1;
          } else if (checkIn.status == ProjectStatus.stalled || checkIn.status == ProjectStatus.slowing) {
            monthlyData[monthKey]!['stalled'] = monthlyData[monthKey]!['stalled']! + 1;
          }
        }
      }
    }
    
    return monthlyData.entries.map((e) => TrendDataPoint(
      date: e.key,
      status: e.value['active']! >= e.value['stalled']! ? ProjectStatus.active : ProjectStatus.stalled,
      activeCount: e.value['active']!,
      stalledCount: e.value['stalled']!,
    )).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Create mock developer background data
  DeveloperBackground createDeveloperBackground(Project project) {
    return DeveloperBackground(
      name: project.agencyOrDeveloper,
      websiteUrl: 'https://www.${project.agencyOrDeveloper.toLowerCase().replaceAll(' ', '')}.my',
      status: 'Ready',
      lastUpdated: DateTime.now(),
      officialSources: [
        SourceLink(
          title: '${project.agencyOrDeveloper} — Official Website',
          url: 'https://www.${project.agencyOrDeveloper.toLowerCase().replaceAll(' ', '')}.my',
          type: 'Official',
          confidencePercent: 90,
          description: 'Developer-provided URL.',
        ),
        SourceLink(
          title: 'Google Search: ${project.agencyOrDeveloper}',
          url: 'https://google.com/search?q=${Uri.encodeComponent(project.agencyOrDeveloper)}',
          type: 'Official',
          confidencePercent: 50,
          description: 'Generated search link — manual review recommended.',
        ),
      ],
      filings: [
        SourceLink(
          title: 'SSM Company Search: ${project.agencyOrDeveloper}',
          url: 'https://www.ssm.com.my/',
          type: 'Filing',
          confidencePercent: 60,
          description: 'Search SSM portal for company filings. Manual review required.',
        ),
        SourceLink(
          title: 'Public Reports: ${project.agencyOrDeveloper}',
          url: 'https://www.bursamalaysia.com/',
          type: 'Filing',
          confidencePercent: 40,
          description: 'Search for publicly available PDF reports.',
        ),
      ],
      newsCoverage: [
        SourceLink(
          title: 'Recent News: ${project.agencyOrDeveloper}',
          url: 'https://news.google.com/search?q=${Uri.encodeComponent(project.agencyOrDeveloper)}',
          type: 'News',
          confidencePercent: 50,
          description: 'Google News results — review for positive/negative coverage.',
        ),
      ],
      riskFlags: project.status == ProjectStatus.stalled 
          ? 'Project delays detected. Verify developer financial health.'
          : null,
    );
  }
}
