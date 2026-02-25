import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_model.dart';

class AiInsightResult {
  final String summary;
  final bool usedAi;
  final String? note;

  const AiInsightResult({
    required this.summary,
    required this.usedAi,
    this.note,
  });
}

class AiInsightService {
  static const String _apiKey =
      String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  Future<AiInsightResult> generatePortfolioInsights(
    List<Project> projects,
  ) async {
    final fallback = _buildHeuristicSummary(projects);

    if (_apiKey.isEmpty) {
      return AiInsightResult(
        summary: fallback,
        usedAi: false,
        note: 'No GEMINI_API_KEY provided. Showing local heuristic summary.',
      );
    }

    final prompt = _buildPrompt(projects);
    try {
      final response = await http.post(
        Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.2,
            'maxOutputTokens': 220,
          },
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AiInsightResult(
          summary: fallback,
          usedAi: false,
          note:
              'Gemini API error (${response.statusCode}). Showing local heuristic summary.',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return AiInsightResult(
          summary: fallback,
          usedAi: false,
          note: 'Gemini returned no candidates. Showing local heuristic summary.',
        );
      }

      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final text = parts?.isNotEmpty == true ? parts!.first['text'] as String? : null;
      if (text == null || text.trim().isEmpty) {
        return AiInsightResult(
          summary: fallback,
          usedAi: false,
          note: 'Gemini returned empty text. Showing local heuristic summary.',
        );
      }

      return AiInsightResult(summary: text.trim(), usedAi: true);
    } catch (_) {
      return AiInsightResult(
        summary: fallback,
        usedAi: false,
        note: 'Gemini request failed. Showing local heuristic summary.',
      );
    }
  }

  String _buildPrompt(List<Project> projects) {
    final active = projects.where((p) => p.status == ProjectStatus.active).length;
    final slowing =
        projects.where((p) => p.status == ProjectStatus.slowing).length;
    final stalled =
        projects.where((p) => p.status == ProjectStatus.stalled).length;
    final unverified =
        projects.where((p) => p.status == ProjectStatus.unverified).length;
    final totalCheckIns = projects.fold<int>(0, (sum, p) => sum + p.checkIns.length);

    final sample = projects.take(8).map((p) {
      return '- ${p.name} | ${p.location} | status=${p.status.label} | confidence=${p.confidence.label} | checkins=${p.checkIns.length}';
    }).join('\n');

    return '''
You are helping a civic-tech dashboard summarize construction project health.
Use concise language and avoid legal claims.

Dataset summary:
- total_projects: ${projects.length}
- total_checkins: $totalCheckIns
- active: $active
- slowing: $slowing
- stalled: $stalled
- unverified: $unverified

Sample projects:
$sample

Output exactly:
1) One-sentence overall health summary.
2) Three bullet points: risks, likely causes, immediate action priorities.
3) One sentence on data limitations.
Limit to 130 words total.
''';
  }

  String _buildHeuristicSummary(List<Project> projects) {
    final total = projects.length;
    if (total == 0) {
      return 'No projects available yet. Add project records and check-ins to generate actionable portfolio insights.';
    }

    final active = projects.where((p) => p.status == ProjectStatus.active).length;
    final slowing =
        projects.where((p) => p.status == ProjectStatus.slowing).length;
    final stalled =
        projects.where((p) => p.status == ProjectStatus.stalled).length;
    final unverified =
        projects.where((p) => p.status == ProjectStatus.unverified).length;
    final totalCheckIns = projects.fold<int>(0, (sum, p) => sum + p.checkIns.length);
    final stalledOrSlowing = stalled + slowing;
    final ratio = ((stalledOrSlowing / total) * 100).toStringAsFixed(1);

    return 'Portfolio health: $active of $total projects are active. '
        '$stalledOrSlowing projects ($ratio%) are slowing or stalled, and '
        '$unverified remain unverified. '
        'Risk focus: projects with low confidence and no recent check-ins. '
        'Immediate actions: prioritize verification visits on stalled/slowing sites, '
        'request updates from agencies for unverified projects, and increase community check-ins in weak-coverage areas. '
        'Data note: this summary is based on $totalCheckIns recorded check-ins and may not reflect all on-ground changes.';
  }
}
