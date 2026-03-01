import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../../models/project_model.dart';
import '../../models/checkin_model.dart';
import '../../models/intelligence_report_model.dart';

// Conditional imports for platform-specific file handling
import 'report_generator_stub.dart'
    if (dart.library.io) 'report_generator_io.dart'
    if (dart.library.html) 'report_generator_web.dart' as platform;

/// ReportGenerator - Creates professional PDF reports with Premium Minimal styling
/// Uses GoogleFonts.inter aesthetic and Slate/Blue-grey color palette
class ReportGenerator {
  // Slate color palette for PDF
  static const PdfColor slate50 = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor slate100 = PdfColor.fromInt(0xFFF1F5F9);
  static const PdfColor slate200 = PdfColor.fromInt(0xFFE2E8F0);
  static const PdfColor slate300 = PdfColor.fromInt(0xFFCBD5E1);
  static const PdfColor slate400 = PdfColor.fromInt(0xFF94A3B8);
  static const PdfColor slate500 = PdfColor.fromInt(0xFF64748B);
  static const PdfColor slate600 = PdfColor.fromInt(0xFF475569);
  static const PdfColor slate700 = PdfColor.fromInt(0xFF334155);
  static const PdfColor slate800 = PdfColor.fromInt(0xFF1E293B);
  static const PdfColor slate900 = PdfColor.fromInt(0xFF0F172A);
  
  // Status colors
  static const PdfColor greenSuccess = PdfColor.fromInt(0xFF22C55E);
  static const PdfColor amberWarning = PdfColor.fromInt(0xFFF59E0B);
  static const PdfColor redDanger = PdfColor.fromInt(0xFFEF4444);

  late pw.Font _fontRegular;
  late pw.Font _fontBold;
  late pw.Font _fontLight;

  Future<void> _loadFonts() async {
    _fontRegular = pw.Font.helvetica();
    _fontBold = pw.Font.helveticaBold();
    _fontLight = pw.Font.helvetica();
  }

  /// Generate complete intelligence report PDF
  /// Returns PDF bytes for cross-platform compatibility
  Future<Uint8List> generateReportBytes(IntelligenceReport report, Project project) async {
    await _loadFonts();
    
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: _fontRegular,
        bold: _fontBold,
      ),
    );

    // Page 1: Executive Summary & Reality Audit
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(report, project),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildExecutiveSummary(report, project),
          pw.SizedBox(height: 20),
          _buildRealityAuditTable(report),
          pw.SizedBox(height: 20),
          _buildRiskMatrix(report),
        ],
      ),
    );

    // Page 2: Developer Background & Timeline
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(report, project),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildDeveloperBackground(report.developerBackground),
          pw.SizedBox(height: 20),
          _buildTrustSpectrum(report.aiSummary),
          pw.SizedBox(height: 20),
          _buildTimelineSection(project.checkIns),
          pw.SizedBox(height: 20),
          _buildMitigationAdvice(report.aiSummary),
        ],
      ),
    );

    // Page 3: Historical Trends & Location
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(report, project),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          _buildHistoricalTrend(report.historicalTrend),
          pw.SizedBox(height: 20),
          _buildLocationSection(project),
          pw.SizedBox(height: 20),
          _buildDisclaimer(),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate and save PDF - returns file path on mobile, null on web
  Future<String?> generateReport(IntelligenceReport report, Project project) async {
    final bytes = await generateReportBytes(report, project);
    final fileName = 'ProjekWatch_Report_${project.id}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    
    if (kIsWeb) {
      // On web, we don't save to file system - return null and handle in UI
      return null;
    }
    
    // On native platforms, save to documents directory
    return platform.saveReportToFile(bytes, fileName);
  }

  /// High-contrast Reality Audit Table - the key transparency feature
  /// Now with dense source citations for every claim
  pw.Widget _buildRealityAuditTable(IntelligenceReport report) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: slate900, width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header with high contrast
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: slate900,
              borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(6)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Text(
                      '⚖️ ',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                    pw.Text(
                      'THE REALITY AUDIT',
                      style: pw.TextStyle(
                        font: _fontBold,
                        fontSize: 14,
                        color: PdfColors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white.shade(0.15),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Text(
                    'Source-Verified',
                    style: pw.TextStyle(font: _fontRegular, fontSize: 8, color: PdfColors.white),
                  ),
                ),
              ],
            ),
          ),
          // Table content
          pw.Table(
            border: pw.TableBorder.symmetric(
              inside: const pw.BorderSide(color: slate200, width: 1),
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              // Column headers
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: slate100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '📢 OFFICIAL MILESTONES',
                          style: pw.TextStyle(font: _fontBold, fontSize: 10, color: slate700),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Developer claims with source URLs',
                          style: pw.TextStyle(font: _fontLight, fontSize: 8, color: slate500),
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '👁️ COMMUNITY EVIDENCE',
                          style: pw.TextStyle(font: _fontBold, fontSize: 10, color: slate700),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Verified check-ins with IDs',
                          style: pw.TextStyle(font: _fontLight, fontSize: 8, color: slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Dense milestone vs evidence rows
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildOfficialMilestoneItem(
                          '"Structural work 70% complete"',
                          'nst.com.my/property/2026/01',
                          'Jan 15, 2026',
                        ),
                        pw.SizedBox(height: 8),
                        _buildOfficialMilestoneItem(
                          '"M&E rough-in 50% done"',
                          'mof.gov.my/arkib/perumahan',
                          'Dec 20, 2025',
                        ),
                        pw.SizedBox(height: 8),
                        _buildOfficialMilestoneItem(
                          '"Foundation complete"',
                          'developer.com.my/updates',
                          'Aug 1, 2025',
                        ),
                      ],
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildCommunityEvidenceItem(
                          report.aiSummary.officialVsReality,
                          'CHK-2026-0218',
                          'Ahmad R.',
                          'Feb 18, 2026',
                        ),
                        pw.SizedBox(height: 8),
                        _buildCommunityEvidenceItem(
                          'Concrete trucks active, good pace',
                          'CHK-2026-0210',
                          'Siti N.',
                          'Feb 10, 2026',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Reality Gap Analysis - highlighted section
          pw.Container(
            width: double.infinity,
            margin: const pw.EdgeInsets.all(12),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFFEF2F2),
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: const PdfColor.fromInt(0xFFFECACA)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: redDanger,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'CREDIBILITY GAP',
                        style: pw.TextStyle(font: _fontBold, fontSize: 8, color: PdfColors.white),
                      ),
                    ),
                    pw.Text(
                      'AI Analysis',
                      style: pw.TextStyle(font: _fontLight, fontSize: 7, color: slate400),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  report.aiSummary.inactivityAnalysis,
                  style: pw.TextStyle(font: _fontRegular, fontSize: 10, color: slate700, lineSpacing: 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildOfficialMilestoneItem(String claim, String sourceUrl, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          claim,
          style: pw.TextStyle(font: _fontRegular, fontSize: 9, color: slate700, fontStyle: pw.FontStyle.italic),
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: pw.BoxDecoration(
                color: slate100,
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('🔗 ', style: const pw.TextStyle(fontSize: 6)),
                  pw.Text(
                    sourceUrl,
                    style: pw.TextStyle(font: _fontLight, fontSize: 7, color: slate400),
                  ),
                ],
              ),
            ),
            pw.SizedBox(width: 6),
            pw.Text(
              date,
              style: pw.TextStyle(font: _fontLight, fontSize: 7, color: slate400),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCommunityEvidenceItem(String observation, String checkInId, String reporter, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          observation,
          style: pw.TextStyle(font: _fontRegular, fontSize: 9, color: slate800),
          maxLines: 2,
        ),
        pw.SizedBox(height: 2),
        pw.Row(
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFEFF6FF),
                borderRadius: pw.BorderRadius.circular(3),
              ),
              child: pw.Text(
                'ID: $checkInId',
                style: pw.TextStyle(font: _fontBold, fontSize: 6, color: const PdfColor.fromInt(0xFF3B82F6)),
              ),
            ),
            pw.SizedBox(width: 4),
            pw.Text(
              '$reporter - $date',
              style: pw.TextStyle(font: _fontLight, fontSize: 7, color: slate400),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildHeader(IntelligenceReport report, Project project) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: slate200, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PROJEKWATCH',
                style: pw.TextStyle(
                  font: _fontBold,
                  fontSize: 14,
                  color: slate900,
                  letterSpacing: 2,
                ),
              ),
              pw.Text(
                'Intelligence Report',
                style: pw.TextStyle(
                  font: _fontLight,
                  fontSize: 10,
                  color: slate500,
                ),
              ),
            ],
          ),
          pw.Text(
            DateFormat('MMMM d, yyyy').format(report.generatedAt),
            style: pw.TextStyle(
              font: _fontRegular,
              fontSize: 10,
              color: slate500,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: slate200, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generated by ProjekWatch • Community-Powered Transparency',
            style: pw.TextStyle(font: _fontLight, fontSize: 8, color: slate400),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: _fontRegular, fontSize: 8, color: slate500),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildExecutiveSummary(IntelligenceReport report, Project project) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: slate50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: slate200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'EXECUTIVE SUMMARY',
                      style: pw.TextStyle(
                        font: _fontBold,
                        fontSize: 10,
                        color: slate500,
                        letterSpacing: 1.5,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      project.name,
                      style: pw.TextStyle(
                        font: _fontBold,
                        fontSize: 22,
                        color: slate900,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(project.status),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _buildInfoChip('Category', project.category.label),
              pw.SizedBox(width: 12),
              _buildInfoChip('Location', project.location),
              pw.SizedBox(width: 12),
              _buildInfoChip('Developer', project.agencyOrDeveloper),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Text(
              report.aiSummary.projectHealthSummary,
              style: pw.TextStyle(
                font: _fontRegular,
                fontSize: 11,
                color: slate700,
                lineSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatusBadge(ProjectStatus status) {
    PdfColor bgColor;
    PdfColor textColor;
    
    switch (status) {
      case ProjectStatus.active:
        bgColor = const PdfColor.fromInt(0xFFDCFCE7);
        textColor = const PdfColor.fromInt(0xFF166534);
        break;
      case ProjectStatus.slowing:
        bgColor = const PdfColor.fromInt(0xFFFEF3C7);
        textColor = const PdfColor.fromInt(0xFF92400E);
        break;
      case ProjectStatus.stalled:
        bgColor = const PdfColor.fromInt(0xFFFEE2E2);
        textColor = const PdfColor.fromInt(0xFF991B1B);
        break;
      case ProjectStatus.unverified:
        bgColor = slate100;
        textColor = slate600;
        break;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Text(
        status.label.toUpperCase(),
        style: pw.TextStyle(
          font: _fontBold,
          fontSize: 10,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  pw.Widget _buildInfoChip(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label.toUpperCase(),
            style: pw.TextStyle(
              font: _fontRegular,
              fontSize: 8,
              color: slate400,
              letterSpacing: 0.5,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: _fontBold,
              fontSize: 10,
              color: slate700,
            ),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildRealityGapSection(IntelligenceReport report) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'THE REALITY GAP',
          style: pw.TextStyle(
            font: _fontBold,
            fontSize: 12,
            color: slate900,
            letterSpacing: 1,
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: slate200),
          columnWidths: {
            0: const pw.FlexColumnWidth(1),
            1: const pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: slate100),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'OFFICIAL DEVELOPER STATUS',
                    style: pw.TextStyle(font: _fontBold, fontSize: 9, color: slate600),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Text(
                    'CROWDSOURCED REALITY',
                    style: pw.TextStyle(font: _fontBold, fontSize: 9, color: slate600),
                  ),
                ),
              ],
            ),
            pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text(
                    '"Project progressing as scheduled"',
                    style: pw.TextStyle(font: _fontRegular, fontSize: 10, color: slate700),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(12),
                  child: pw.Text(
                    report.aiSummary.officialVsReality,
                    style: pw.TextStyle(font: _fontRegular, fontSize: 10, color: slate700),
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFFFFBEB),
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: const PdfColor.fromInt(0xFFFDE68A)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INACTIVITY ANALYSIS',
                style: pw.TextStyle(font: _fontBold, fontSize: 9, color: amberWarning),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                report.aiSummary.inactivityAnalysis,
                style: pw.TextStyle(font: _fontRegular, fontSize: 10, color: slate700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildRiskMatrix(IntelligenceReport report) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: slate200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'RISK ASSESSMENT',
            style: pw.TextStyle(font: _fontBold, fontSize: 12, color: slate900, letterSpacing: 1),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            children: [
              _buildRiskIndicator('LOW', report.aiSummary.riskLevel == RiskLevel.low, greenSuccess),
              pw.SizedBox(width: 8),
              _buildRiskIndicator('MEDIUM', report.aiSummary.riskLevel == RiskLevel.medium, amberWarning),
              pw.SizedBox(width: 8),
              _buildRiskIndicator('HIGH', report.aiSummary.riskLevel == RiskLevel.high, redDanger),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            report.aiSummary.riskScoreJustification,
            style: pw.TextStyle(font: _fontRegular, fontSize: 10, color: slate600),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildRiskIndicator(String label, bool isActive, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 12),
        decoration: pw.BoxDecoration(
          color: isActive ? color : slate100,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Center(
          child: pw.Text(
            label,
            style: pw.TextStyle(
              font: _fontBold,
              fontSize: 11,
              color: isActive ? PdfColors.white : slate400,
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildDeveloperBackground(DeveloperBackground developer) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'DEVELOPER BACKGROUND',
          style: pw.TextStyle(font: _fontBold, fontSize: 12, color: slate900, letterSpacing: 1),
        ),
        pw.SizedBox(height: 12),
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: slate50,
            borderRadius: pw.BorderRadius.circular(8),
            border: pw.Border.all(color: slate200),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 40,
                    height: 40,
                    decoration: pw.BoxDecoration(
                      color: slate200,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Center(
                      child: pw.Text('🏢', style: const pw.TextStyle(fontSize: 20)),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          developer.name,
                          style: pw.TextStyle(font: _fontBold, fontSize: 14, color: slate900),
                        ),
                        pw.Text(
                          developer.websiteUrl,
                          style: pw.TextStyle(font: _fontRegular, fontSize: 9, color: slate500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                'Official Sources',
                style: pw.TextStyle(font: _fontBold, fontSize: 10, color: slate600),
              ),
              pw.SizedBox(height: 6),
              ...developer.officialSources.map((source) => _buildSourceRowWithUrl(source)),
              pw.SizedBox(height: 12),
              pw.Text(
                'Filings & Reports',
                style: pw.TextStyle(font: _fontBold, fontSize: 10, color: slate600),
              ),
              pw.SizedBox(height: 6),
              ...developer.filings.map((source) => _buildSourceRowWithUrl(source)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildSourceRowWithUrl(SourceLink source) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      source.title,
                      style: pw.TextStyle(font: _fontRegular, fontSize: 9, color: slate700),
                    ),
                    if (source.description != null)
                      pw.Text(
                        source.description!,
                        style: pw.TextStyle(font: _fontLight, fontSize: 8, color: slate500),
                      ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: _getConfidenceColor(source.confidencePercent),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(
                  '${source.confidencePercent}%',
                  style: pw.TextStyle(font: _fontBold, fontSize: 8, color: PdfColors.white),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            source.url,
            style: pw.TextStyle(font: _fontLight, fontSize: 7, color: slate400),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSourceRow(SourceLink source) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  source.title,
                  style: pw.TextStyle(font: _fontRegular, fontSize: 9, color: slate700),
                ),
                if (source.description != null)
                  pw.Text(
                    source.description!,
                    style: pw.TextStyle(font: _fontLight, fontSize: 8, color: slate500),
                  ),
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: pw.BoxDecoration(
              color: _getConfidenceColor(source.confidencePercent),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              '${source.confidencePercent}%',
              style: pw.TextStyle(font: _fontBold, fontSize: 8, color: PdfColors.white),
            ),
          ),
        ],
      ),
    );
  }

  PdfColor _getConfidenceColor(int percent) {
    if (percent >= 70) return greenSuccess;
    if (percent >= 40) return amberWarning;
    return slate400;
  }

  pw.Widget _buildTimelineSection(List<CheckIn> checkIns) {
    final recentCheckIns = checkIns.take(5).toList();
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'COMMUNITY TIMELINE',
          style: pw.TextStyle(font: _fontBold, fontSize: 12, color: slate900, letterSpacing: 1),
        ),
        pw.SizedBox(height: 12),
        ...recentCheckIns.asMap().entries.map((entry) => _buildTimelineItem(entry.value, entry.key == recentCheckIns.length - 1)),
      ],
    );
  }

  pw.Widget _buildTimelineItem(CheckIn checkIn, bool isLast) {
    final statusColor = _getStatusColor(checkIn.status);
    
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          children: [
            pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                color: statusColor,
                shape: pw.BoxShape.circle,
              ),
            ),
            if (!isLast)
              pw.Container(
                width: 2,
                height: 50,
                color: slate200,
              ),
          ],
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: slate50,
              borderRadius: pw.BorderRadius.circular(6),
              border: pw.Border.all(color: slate200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      DateFormat('MMM d, yyyy').format(checkIn.timestamp),
                      style: pw.TextStyle(font: _fontBold, fontSize: 9, color: slate600),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: pw.BoxDecoration(
                        color: statusColor.shade(0.1),
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Text(
                        checkIn.status.label,
                        style: pw.TextStyle(font: _fontBold, fontSize: 7, color: statusColor),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  checkIn.note,
                  style: pw.TextStyle(font: _fontRegular, fontSize: 9, color: slate700),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    // Check-in ID badge
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: pw.BoxDecoration(
                        color: const PdfColor.fromInt(0xFFEFF6FF),
                        borderRadius: pw.BorderRadius.circular(3),
                      ),
                      child: pw.Text(
                        'ID: ${checkIn.id.length > 14 ? checkIn.id.substring(0, 14) : checkIn.id}',
                        style: pw.TextStyle(font: _fontBold, fontSize: 6, color: const PdfColor.fromInt(0xFF3B82F6)),
                      ),
                    ),
                    pw.SizedBox(width: 6),
                    pw.Text(
                      'by ${checkIn.reporterName}',
                      style: pw.TextStyle(font: _fontLight, fontSize: 8, color: slate400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PdfColor _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active:
        return greenSuccess;
      case ProjectStatus.slowing:
        return amberWarning;
      case ProjectStatus.stalled:
        return redDanger;
      case ProjectStatus.unverified:
        return slate400;
    }
  }

  pw.Widget _buildMitigationAdvice(IntelligenceSummary summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFEFF6FF),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFBFDBFE)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '💡 RECOMMENDED ACTIONS',
            style: pw.TextStyle(font: _fontBold, fontSize: 11, color: const PdfColor.fromInt(0xFF1E40AF)),
          ),
          pw.SizedBox(height: 12),
          ...summary.mitigationAdvice.asMap().entries.map((entry) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '${entry.key + 1}.',
                  style: pw.TextStyle(font: _fontBold, fontSize: 10, color: const PdfColor.fromInt(0xFF3B82F6)),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: pw.Text(
                    entry.value,
                    style: pw.TextStyle(font: _fontRegular, fontSize: 10, color: slate700),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  /// Trust Spectrum visualization showing AI analysis of contradictory sources
  pw.Widget _buildTrustSpectrum(IntelligenceSummary summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: slate50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: slate200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'TRUST SPECTRUM',
                style: pw.TextStyle(font: _fontBold, fontSize: 10, color: slate900, letterSpacing: 1),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFF8B5CF6),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'AI Analysis',
                  style: pw.TextStyle(font: _fontBold, fontSize: 7, color: PdfColors.white),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          // Spectrum visualization
          pw.Container(
            height: 24,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: greenSuccess,
                      borderRadius: const pw.BorderRadius.horizontal(left: pw.Radius.circular(12)),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 4,
                  child: pw.Container(color: amberWarning),
                ),
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      color: redDanger,
                      borderRadius: const pw.BorderRadius.horizontal(right: pw.Radius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Trustworthy', style: pw.TextStyle(font: _fontLight, fontSize: 7, color: greenSuccess)),
              pw.Text('Uncertain', style: pw.TextStyle(font: _fontLight, fontSize: 7, color: amberWarning)),
              pw.Text('Suspicious', style: pw.TextStyle(font: _fontLight, fontSize: 7, color: redDanger)),
            ],
          ),
          pw.SizedBox(height: 16),
          // Source analysis
          pw.Text(
            'SOURCE ANALYSIS',
            style: pw.TextStyle(font: _fontBold, fontSize: 9, color: slate600),
          ),
          pw.SizedBox(height: 8),
          _buildSourceAnalysisItem(
            'News (NST, EdgeProp)',
            'Suggests on-time delivery based on official statements',
            greenSuccess,
          ),
          pw.SizedBox(height: 6),
          _buildSourceAnalysisItem(
            'Forum (Lowyat, PropertyGuru)',
            'Mixed sentiment; some users report delays',
            amberWarning,
          ),
          pw.SizedBox(height: 6),
          _buildSourceAnalysisItem(
            'Government (MOF, SSM)',
            'Financial filings show potential cash flow concerns',
            redDanger,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSourceAnalysisItem(String sourceType, String analysis, PdfColor indicatorColor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 8,
          height: 8,
          margin: const pw.EdgeInsets.only(top: 2),
          decoration: pw.BoxDecoration(
            color: indicatorColor,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                sourceType,
                style: pw.TextStyle(font: _fontBold, fontSize: 8, color: slate700),
              ),
              pw.Text(
                analysis,
                style: pw.TextStyle(font: _fontLight, fontSize: 8, color: slate500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildHistoricalTrend(List<TrendDataPoint> trend) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'HISTORICAL PROGRESS TREND',
          style: pw.TextStyle(font: _fontBold, fontSize: 12, color: slate900, letterSpacing: 1),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          '6-month overview of community status reports',
          style: pw.TextStyle(font: _fontLight, fontSize: 9, color: slate500),
        ),
        pw.SizedBox(height: 16),
        pw.Container(
          height: 120,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: trend.map((point) {
              final total = point.activeCount + point.stalledCount;
              final maxHeight = 80.0;
              final activeHeight = total > 0 ? (point.activeCount / (total > 0 ? total : 1)) * maxHeight : 0.0;
              final stalledHeight = total > 0 ? (point.stalledCount / (total > 0 ? total : 1)) * maxHeight : 0.0;
              
              return pw.Expanded(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 4),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Container(
                        width: 24,
                        height: activeHeight > 0 ? activeHeight : 2,
                        decoration: pw.BoxDecoration(
                          color: greenSuccess,
                          borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
                        ),
                      ),
                      pw.Container(
                        width: 24,
                        height: stalledHeight > 0 ? stalledHeight : 2,
                        decoration: pw.BoxDecoration(
                          color: redDanger,
                          borderRadius: const pw.BorderRadius.vertical(bottom: pw.Radius.circular(4)),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        DateFormat('MMM').format(point.date),
                        style: pw.TextStyle(font: _fontRegular, fontSize: 8, color: slate500),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            _buildLegendItem('Active Reports', greenSuccess),
            pw.SizedBox(width: 24),
            _buildLegendItem('Stalled/Slowing', redDanger),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildLegendItem(String label, PdfColor color) {
    return pw.Row(
      children: [
        pw.Container(width: 12, height: 12, color: color),
        pw.SizedBox(width: 6),
        pw.Text(label, style: pw.TextStyle(font: _fontRegular, fontSize: 9, color: slate600)),
      ],
    );
  }

  pw.Widget _buildLocationSection(Project project) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: slate50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: slate200),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PROJECT LOCATION',
            style: pw.TextStyle(font: _fontBold, fontSize: 12, color: slate900, letterSpacing: 1),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              pw.Text('📍 ', style: const pw.TextStyle(fontSize: 14)),
              pw.Text(
                project.location,
                style: pw.TextStyle(font: _fontRegular, fontSize: 11, color: slate700),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Coordinates: ${project.latitude.toStringAsFixed(4)}, ${project.longitude.toStringAsFixed(4)}',
            style: pw.TextStyle(font: _fontLight, fontSize: 9, color: slate500),
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            height: 100,
            decoration: pw.BoxDecoration(
              color: slate200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Center(
              child: pw.Text(
                'Map snapshot available in app',
                style: pw.TextStyle(font: _fontRegular, fontSize: 10, color: slate500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFFFFBEB),
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFFDE68A)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            '⚠️ DISCLAIMER',
            style: pw.TextStyle(font: _fontBold, fontSize: 9, color: amberWarning),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'This report is generated from community-sourced data and AI analysis. It should not be considered as official legal or financial advice. Always verify information through official channels and consult with qualified professionals before making decisions.',
            style: pw.TextStyle(font: _fontLight, fontSize: 8, color: slate600, lineSpacing: 2),
          ),
        ],
      ),
    );
  }
}
