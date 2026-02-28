// Developer Enrichment Model — Add-on module for developer background data.
//
// ── Limits & Compliance ──────────────────────────────────────────────
// • Respects robots.txt and website ToS.
// • No login scraping, no CAPTCHA bypass, no paywall bypass.
// • No direct Facebook scraping — only public URLs with "manual review" flag.
// • No full copyrighted articles stored — only title, publisher, date,
//   short snippet (if allowed), and canonical URL.
// • Every item includes: sourceUrl (url), sourceType (type), fetchedAt
//   (date), confidenceScore (confidence).
// ─────────────────────────────────────────────────────────────────────

/// Status of the developer enrichment data.
enum EnrichmentStatus { idle, loading, ready, limited, error }

/// The type of source providing developer information.
enum SourceType { official, filing, news, review, socialLink }

/// Sentiment assessment for a source item.
enum SourceSentiment { pos, neu, neg }

// ── Extensions ─────────────────────────────────────────────────────

extension EnrichmentStatusExt on EnrichmentStatus {
  String get label {
    switch (this) {
      case EnrichmentStatus.idle:
        return 'Not Loaded';
      case EnrichmentStatus.loading:
        return 'Loading…';
      case EnrichmentStatus.ready:
        return 'Ready';
      case EnrichmentStatus.limited:
        return 'Needs Manual Review';
      case EnrichmentStatus.error:
        return 'Error';
    }
  }
}

extension SourceTypeExt on SourceType {
  String get label {
    switch (this) {
      case SourceType.official:
        return 'Official';
      case SourceType.filing:
        return 'Filing';
      case SourceType.news:
        return 'News';
      case SourceType.review:
        return 'Review';
      case SourceType.socialLink:
        return 'Social Link';
    }
  }
}

extension SourceSentimentExt on SourceSentiment {
  String get label {
    switch (this) {
      case SourceSentiment.pos:
        return 'Positive';
      case SourceSentiment.neu:
        return 'Neutral';
      case SourceSentiment.neg:
        return 'Negative';
    }
  }
}

// ── DeveloperSourceItem ────────────────────────────────────────────

/// A single source of developer information.
/// Every item carries sourceUrl, sourceType, fetchedAt, and confidenceScore
/// per compliance rules.
class DeveloperSourceItem {
  final SourceType type;
  final String title;
  final DateTime? date;
  final String? snippet;
  final String url;
  final SourceSentiment? sentiment;

  /// Confidence score from 0.0 (no confidence) to 1.0 (fully verified).
  final double confidence;

  /// Additional notes, e.g. "Manual review required".
  final String? notes;

  /// Timestamp when this data was fetched / generated.
  final DateTime fetchedAt;

  DeveloperSourceItem({
    required this.type,
    required this.title,
    this.date,
    this.snippet,
    required this.url,
    this.sentiment,
    required this.confidence,
    this.notes,
    DateTime? fetchedAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  factory DeveloperSourceItem.fromJson(Map<String, dynamic> json) {
    return DeveloperSourceItem(
      type: SourceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SourceType.official,
      ),
      title: json['title'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      snippet: json['snippet'] as String?,
      url: json['url'] as String? ?? '',
      sentiment: json['sentiment'] != null
          ? SourceSentiment.values.firstWhere(
              (e) => e.name == json['sentiment'],
              orElse: () => SourceSentiment.neu,
            )
          : null,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'date': date?.toIso8601String(),
        'snippet': snippet,
        'url': url,
        'sentiment': sentiment?.name,
        'confidence': confidence,
        'notes': notes,
        'fetchedAt': fetchedAt.toIso8601String(),
      };
}

// ── DeveloperEnrichment ────────────────────────────────────────────

/// Aggregated enrichment data for a project's developer / agency.
class DeveloperEnrichment {
  EnrichmentStatus status;
  DateTime? lastUpdated;
  String summary;
  List<String> riskFlags;
  List<DeveloperSourceItem> sources;

  DeveloperEnrichment({
    this.status = EnrichmentStatus.idle,
    this.lastUpdated,
    this.summary = '',
    List<String>? riskFlags,
    List<DeveloperSourceItem>? sources,
  })  : riskFlags = riskFlags ?? [],
        sources = sources ?? [];

  factory DeveloperEnrichment.fromJson(Map<String, dynamic> json) {
    return DeveloperEnrichment(
      status: EnrichmentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EnrichmentStatus.idle,
      ),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'] as String)
          : null,
      summary: json['summary'] as String? ?? '',
      riskFlags: (json['riskFlags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sources: (json['sources'] as List<dynamic>?)
              ?.map((e) =>
                  DeveloperSourceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'lastUpdated': lastUpdated?.toIso8601String(),
        'summary': summary,
        'riskFlags': riskFlags,
        'sources': sources.map((s) => s.toJson()).toList(),
      };
}
