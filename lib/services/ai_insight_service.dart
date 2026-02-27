import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/project_model.dart';

class AiInsightResult {
  final String summary;
  final bool usedAi;
  final String? note;
  final String? modelUsed;

  const AiInsightResult({
    required this.summary,
    required this.usedAi,
    this.note,
    this.modelUsed,
  });
}

class AiInsightService {
  static const List<String> _defaultModels = <String>[
    'gemini-2.0-flash',
    'gemini-2.5-flash',
  ];
  static const int _statusNotFound = 404;
  static const int _statusTooManyRequests = 429;

  Future<AiInsightResult> generatePortfolioInsights(
    List<Project> projects,
  ) async {
    final fallback = _buildHeuristicSummary(projects);
    final apiKey = AppConfig.geminiApiKey.trim();

    if (apiKey.isEmpty) {
      return AiInsightResult(
        summary: fallback,
        usedAi: false,
        note: 'No GEMINI_API_KEY provided. Showing local heuristic summary.',
      );
    }

    final prompt = _buildPrompt(projects);
    String? lastError;

    for (final model in _candidateModels()) {
      final attempt = await _requestGemini(
        model: model,
        apiKey: apiKey,
        prompt: prompt,
      );

      if (attempt.text != null && attempt.text!.trim().isNotEmpty) {
        return AiInsightResult(
          summary: attempt.text!.trim(),
          usedAi: true,
          modelUsed: model,
        );
      }

      if (attempt.statusCode == _statusNotFound) {
        lastError = 'Gemini model "$model" was not found.';
        continue;
      }

      lastError = attempt.error ??
          (attempt.statusCode != null
              ? 'Gemini API error (${attempt.statusCode}).'
              : 'Gemini request failed.');
      if (attempt.statusCode == _statusTooManyRequests) {
        break;
      }
    }

    return AiInsightResult(
      summary: fallback,
      usedAi: false,
      note: '${lastError ?? 'Gemini request failed.'} Showing local heuristic summary.',
    );
  }

  List<String> _candidateModels() {
    final configured = AppConfig.geminiModel.trim();
    final seen = <String>{};
    return <String>[
      if (configured.isNotEmpty) configured,
      ..._defaultModels,
    ].where(seen.add).toList();
  }

  Future<_GeminiAttempt> _requestGemini({
    required String model,
    required String apiKey,
    required String prompt,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
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
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _GeminiAttempt(
          statusCode: response.statusCode,
          error: _extractErrorMessage(response.body),
        );
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        return const _GeminiAttempt(error: 'Gemini returned an invalid response format.');
      }

      final candidates = data['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        return const _GeminiAttempt(error: 'Gemini returned no candidates.');
      }

      for (final candidate in candidates) {
        if (candidate is! Map<String, dynamic>) continue;
        final content = candidate['content'];
        if (content is! Map<String, dynamic>) continue;
        final parts = content['parts'];
        if (parts is! List) continue;
        for (final part in parts) {
          if (part is! Map<String, dynamic>) continue;
          final text = part['text'];
          if (text is String && text.trim().isNotEmpty) {
            return _GeminiAttempt(text: text);
          }
        }
      }

      return const _GeminiAttempt(error: 'Gemini returned empty text.');
    } catch (error) {
      return _GeminiAttempt(error: error.toString());
    }
  }

  String _extractErrorMessage(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        final error = data['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
      }
    } catch (_) {
      // Ignore parse errors and return generic message below.
    }
    return 'Gemini request failed.';
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

class _GeminiAttempt {
  final String? text;
  final int? statusCode;
  final String? error;

  const _GeminiAttempt({
    this.text,
    this.statusCode,
    this.error,
  });
}
