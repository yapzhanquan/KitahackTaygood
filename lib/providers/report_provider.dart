import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/intelligence_report_model.dart';
import '../data/services/intelligence_service.dart';
import '../data/services/report_generator.dart';

/// Report generation status
enum ReportStatus {
  idle,
  analyzing,
  generating,
  completed,
  error,
}

extension ReportStatusExt on ReportStatus {
  String get message {
    switch (this) {
      case ReportStatus.idle:
        return '';
      case ReportStatus.analyzing:
        return 'Gemini is analyzing community data...';
      case ReportStatus.generating:
        return 'Generating Reality Audit PDF...';
      case ReportStatus.completed:
        return 'Report ready!';
      case ReportStatus.error:
        return 'Failed to generate report';
    }
  }
}

/// Result object for report generation
class ReportResult {
  final String? filePath;
  final Uint8List pdfBytes;
  final String fileName;

  ReportResult({
    this.filePath,
    required this.pdfBytes,
    required this.fileName,
  });
}

/// ReportProvider - Manages intelligence report generation state
class ReportProvider extends ChangeNotifier {
  final IntelligenceService _intelligenceService = IntelligenceService();
  final ReportGenerator _reportGenerator = ReportGenerator();

  ReportStatus _status = ReportStatus.idle;
  IntelligenceReport? _currentReport;
  String? _errorMessage;
  double _progress = 0.0;
  Uint8List? _lastPdfBytes;
  String? _lastFileName;

  ReportStatus get status => _status;
  IntelligenceReport? get currentReport => _currentReport;
  String? get errorMessage => _errorMessage;
  double get progress => _progress;
  bool get isGenerating => _status == ReportStatus.analyzing || _status == ReportStatus.generating;
  Uint8List? get lastPdfBytes => _lastPdfBytes;
  String? get lastFileName => _lastFileName;

  /// Generate a complete intelligence report for a project
  /// Returns ReportResult with PDF bytes and optional file path (null on web)
  Future<ReportResult?> generateReport(Project project) async {
    _status = ReportStatus.analyzing;
    _progress = 0.1;
    _errorMessage = null;
    _lastPdfBytes = null;
    _lastFileName = null;
    notifyListeners();

    try {
      // Step 1: Generate AI summary with Reality Audit focus
      _progress = 0.2;
      notifyListeners();
      
      final aiSummary = await _intelligenceService.generateSummary(
        project: project,
        checkIns: project.checkIns,
        scrapedOfficialData: _generateMockOfficialData(project),
        developerNewsData: null,
      );
      
      _progress = 0.4;
      notifyListeners();

      // Step 2: Generate historical trend data
      final historicalTrend = _intelligenceService.generateHistoricalTrend(project.checkIns);
      _progress = 0.5;
      notifyListeners();

      // Step 3: Create developer background
      final developerBackground = _intelligenceService.createDeveloperBackground(project);
      _progress = 0.6;
      notifyListeners();

      // Step 4: Create the complete report object
      _currentReport = IntelligenceReport(
        projectId: project.id,
        projectName: project.name,
        currentStatus: project.status,
        confidenceLevel: project.confidence,
        aiSummary: aiSummary,
        developerBackground: developerBackground,
        historicalTrend: historicalTrend,
        generatedAt: DateTime.now(),
      );

      // Step 5: Generate PDF bytes
      _status = ReportStatus.generating;
      _progress = 0.7;
      notifyListeners();

      final pdfBytes = await _reportGenerator.generateReportBytes(_currentReport!, project);
      final fileName = 'ProjekWatch_RealityAudit_${project.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      
      _lastPdfBytes = pdfBytes;
      _lastFileName = fileName;

      // Step 6: Save to file (on native platforms)
      _progress = 0.9;
      notifyListeners();

      final filePath = await _reportGenerator.generateReport(_currentReport!, project);
      
      _progress = 1.0;
      _status = ReportStatus.completed;
      notifyListeners();

      return ReportResult(
        filePath: filePath,
        pdfBytes: pdfBytes,
        fileName: fileName,
      );
    } catch (e) {
      _status = ReportStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Reset the provider state
  void reset() {
    _status = ReportStatus.idle;
    _currentReport = null;
    _errorMessage = null;
    _progress = 0.0;
    notifyListeners();
  }

  /// Generate mock official data for demo purposes
  String _generateMockOfficialData(Project project) {
    final completionStr = project.expectedCompletion != null
        ? 'Expected completion: ${project.expectedCompletion.toString().split(' ')[0]}'
        : 'Completion date not specified';
    
    return '''
Official Developer Statement (${project.agencyOrDeveloper}):
- Project Name: ${project.name}
- Category: ${project.category.label}
- Location: ${project.location}
- $completionStr
- Status per developer website: "Project is progressing according to schedule"
- Last official update: ${project.lastActivity.toString().split(' ')[0]}
''';
  }
}
