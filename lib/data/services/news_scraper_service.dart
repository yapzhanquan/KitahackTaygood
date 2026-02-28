import '../../models/project_model.dart';

/// Service that provides location-aware news for Malaysian construction projects
/// Uses pre-populated mock data simulating scraped headlines from Malaysian news sources
class NewsScraperService {
  static final NewsScraperService _instance = NewsScraperService._internal();
  factory NewsScraperService() => _instance;
  NewsScraperService._internal();

  /// Get news headlines relevant to a project's location
  List<NewsHeadline> getNewsForProject(Project project) {
    final location = project.location.toLowerCase();
    final category = project.category;
    
    // Return location-specific news
    if (location.contains('petaling jaya') || location.contains('pj')) {
      return _pjNews;
    } else if (location.contains('shah alam')) {
      return _shahAlamNews;
    } else if (location.contains('johor') || location.contains('jb')) {
      return _johorNews;
    } else if (location.contains('kuala lumpur') || location.contains('kl')) {
      return _klNews;
    } else if (location.contains('penang') || location.contains('georgetown')) {
      return _penangNews;
    } else if (location.contains('damansara')) {
      return _damansaraNews;
    } else if (location.contains('subang')) {
      return _subangNews;
    } else if (location.contains('cyberjaya') || location.contains('putrajaya')) {
      return _cyberjayaNews;
    }
    
    // Fallback to category-specific news
    switch (category) {
      case ProjectCategory.housing:
        return _generalHousingNews;
      case ProjectCategory.road:
        return _generalRoadNews;
      case ProjectCategory.drainage:
        return _generalDrainageNews;
      case ProjectCategory.school:
        return _generalSchoolNews;
    }
  }

  /// Get breaking/urgent news for the home feed
  List<NewsHeadline> getBreakingNews() => _breakingNews;

  // ─────────────────────────────────────────────────────────────────────────
  // Location-Specific News Headlines (simulating scraped data)
  // ─────────────────────────────────────────────────────────────────────────

  static final List<NewsHeadline> _pjNews = [
    NewsHeadline(
      id: 'news_pj_001',
      title: 'PR1MA Petaling Jaya project on track for 2027 handover',
      source: 'The Edge Malaysia',
      sourceLogoUrl: 'https://www.theedgemarkets.com/sites/all/themes/starter/images/logo.png',
      url: 'https://www.theedgemarkets.com/article/prima-pj-2027',
      publishedAt: DateTime(2026, 2, 20),
      snippet: 'PR1MA Corporation confirms structural work at 70% completion...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_pj_002',
      title: 'Traffic disruption expected along Jalan Universiti for next 3 months',
      source: 'Star Property',
      sourceLogoUrl: 'https://www.starproperty.my/images/logo.png',
      url: 'https://www.starproperty.my/news/pj-traffic-2026',
      publishedAt: DateTime(2026, 2, 18),
      snippet: 'Residents advised to use alternative routes as construction intensifies...',
      sentiment: NewsSentiment.neutral,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_pj_003',
      title: 'Selangor housing shortage: 50,000 units needed by 2028',
      source: 'NST Property',
      sourceLogoUrl: 'https://www.nst.com.my/sites/default/files/nst_logo.png',
      url: 'https://www.nst.com.my/property/selangor-shortage',
      publishedAt: DateTime(2026, 2, 15),
      snippet: 'State government fast-tracks affordable housing approvals...',
      sentiment: NewsSentiment.neutral,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _shahAlamNews = [
    NewsHeadline(
      id: 'news_sa_001',
      title: 'Bina Megah faces legal action from 127 homebuyers',
      source: 'EdgeProp',
      sourceLogoUrl: 'https://www.edgeprop.my/images/logo.png',
      url: 'https://www.edgeprop.my/content/bina-megah-lawsuit',
      publishedAt: DateTime(2025, 11, 20),
      snippet: 'Class action lawsuit filed citing project delays and breach of contract...',
      sentiment: NewsSentiment.negative,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_sa_002',
      title: 'MBSA to expedite abandoned project recovery',
      source: 'The Star',
      sourceLogoUrl: 'https://www.thestar.com.my/images/logo.png',
      url: 'https://www.thestar.com.my/metro/mbsa-abandoned-projects',
      publishedAt: DateTime(2026, 2, 10),
      snippet: 'City council identifies 8 stalled projects requiring intervention...',
      sentiment: NewsSentiment.neutral,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_sa_003',
      title: 'Taman Sri Muda flood mitigation Phase 2 begins',
      source: 'Bernama',
      sourceLogoUrl: 'https://www.bernama.com/images/logo.png',
      url: 'https://www.bernama.com/taman-sri-muda-drainage',
      publishedAt: DateTime(2026, 1, 28),
      snippet: 'RM45 million allocated for upgraded drainage infrastructure...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _johorNews = [
    NewsHeadline(
      id: 'news_jb_001',
      title: 'SPNB Johor projects ahead of schedule, minister says',
      source: 'The Edge Malaysia',
      sourceLogoUrl: 'https://www.theedgemarkets.com/sites/all/themes/starter/images/logo.png',
      url: 'https://www.theedgemarkets.com/article/spnb-johor-2026',
      publishedAt: DateTime(2026, 2, 19),
      snippet: 'Housing ministry praises SPNB for maintaining construction momentum...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_jb_002',
      title: 'JB-Singapore RTS Link construction 65% complete',
      source: 'NST',
      sourceLogoUrl: 'https://www.nst.com.my/sites/default/files/nst_logo.png',
      url: 'https://www.nst.com.my/news/rts-link-progress',
      publishedAt: DateTime(2026, 2, 15),
      snippet: 'Cross-border rail project on track for 2027 completion...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_jb_003',
      title: 'Iskandar Puteri sees surge in new launches',
      source: 'Star Property',
      sourceLogoUrl: 'https://www.starproperty.my/images/logo.png',
      url: 'https://www.starproperty.my/news/iskandar-launches',
      publishedAt: DateTime(2026, 2, 8),
      snippet: '12 new residential projects launched in Q1 2026...',
      sentiment: NewsSentiment.neutral,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _klNews = [
    NewsHeadline(
      id: 'news_kl_001',
      title: 'DBKL launches RM2 billion urban renewal programme',
      source: 'The Edge Malaysia',
      sourceLogoUrl: 'https://www.theedgemarkets.com/sites/all/themes/starter/images/logo.png',
      url: 'https://www.theedgemarkets.com/article/dbkl-urban-renewal',
      publishedAt: DateTime(2026, 2, 22),
      snippet: 'Programme targets 15 ageing public housing estates for redevelopment...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_kl_002',
      title: 'Kampung Baru infrastructure upgrade faces delays',
      source: 'Malay Mail',
      sourceLogoUrl: 'https://www.malaymail.com/images/logo.png',
      url: 'https://www.malaymail.com/news/kg-baru-delays',
      publishedAt: DateTime(2026, 2, 12),
      snippet: 'Utility relocation causing 3-month setback in drainage works...',
      sentiment: NewsSentiment.negative,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_kl_003',
      title: 'MRT3 Circle Line construction begins in Sentul',
      source: 'The Star',
      sourceLogoUrl: 'https://www.thestar.com.my/images/logo.png',
      url: 'https://www.thestar.com.my/metro/mrt3-sentul',
      publishedAt: DateTime(2026, 2, 5),
      snippet: 'First station site cleared for underground works...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _penangNews = [
    NewsHeadline(
      id: 'news_pg_001',
      title: 'Penang coastal flood wall 40% complete',
      source: 'Buletin Mutiara',
      sourceLogoUrl: 'https://www.buletinmutiara.com/images/logo.png',
      url: 'https://www.buletinmutiara.com/flood-wall-progress',
      publishedAt: DateTime(2026, 2, 20),
      snippet: 'Heritage protection project on schedule despite monsoon delays...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_pg_002',
      title: 'PSR project faces contractor disputes',
      source: 'The Star',
      sourceLogoUrl: 'https://www.thestar.com.my/images/logo.png',
      url: 'https://www.thestar.com.my/news/penang-psr-dispute',
      publishedAt: DateTime(2026, 2, 14),
      snippet: 'State government mediating between main contractor and subcontractors...',
      sentiment: NewsSentiment.negative,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _damansaraNews = [
    NewsHeadline(
      id: 'news_dm_001',
      title: 'Damansara road widening to ease SPRINT congestion',
      source: 'NST',
      sourceLogoUrl: 'https://www.nst.com.my/sites/default/files/nst_logo.png',
      url: 'https://www.nst.com.my/news/damansara-widening',
      publishedAt: DateTime(2026, 2, 21),
      snippet: 'JKR confirms 2 additional lanes by end of 2026...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_dm_002',
      title: 'Night works to minimize traffic impact in Damansara',
      source: 'The Star',
      sourceLogoUrl: 'https://www.thestar.com.my/images/logo.png',
      url: 'https://www.thestar.com.my/metro/damansara-night-works',
      publishedAt: DateTime(2026, 2, 15),
      snippet: 'Contractors shift to 10pm-6am schedule for heavy machinery...',
      sentiment: NewsSentiment.neutral,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _subangNews = [
    NewsHeadline(
      id: 'news_sb_001',
      title: 'MBSJ halts Persiaran Subang Permai road project',
      source: 'The Star',
      sourceLogoUrl: 'https://www.thestar.com.my/images/logo.png',
      url: 'https://www.thestar.com.my/metro/subang-road-halted',
      publishedAt: DateTime(2026, 1, 15),
      snippet: 'Funding cuts force suspension of RM12 million access road...',
      sentiment: NewsSentiment.negative,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_sb_002',
      title: 'Sunway pedestrian bridge nears completion',
      source: 'EdgeProp',
      sourceLogoUrl: 'https://www.edgeprop.my/images/logo.png',
      url: 'https://www.edgeprop.my/sunway-bridge',
      publishedAt: DateTime(2026, 2, 22),
      snippet: 'Steel structure now spans Federal Highway after milestone connection...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _cyberjayaNews = [
    NewsHeadline(
      id: 'news_cy_001',
      title: 'Putrajaya-Cyberjaya Expressway progressing well',
      source: 'Bernama',
      sourceLogoUrl: 'https://www.bernama.com/images/logo.png',
      url: 'https://www.bernama.com/putrajaya-expressway',
      publishedAt: DateTime(2026, 2, 18),
      snippet: 'Ministry of Works confirms elevated sections on schedule...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_cy_002',
      title: 'Cyberjaya tech hub expansion attracts global firms',
      source: 'The Edge Malaysia',
      sourceLogoUrl: 'https://www.theedgemarkets.com/sites/all/themes/starter/images/logo.png',
      url: 'https://www.theedgemarkets.com/cyberjaya-expansion',
      publishedAt: DateTime(2026, 2, 10),
      snippet: 'New commercial zones planned alongside residential developments...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // Category-Specific Fallback News
  // ─────────────────────────────────────────────────────────────────────────

  static final List<NewsHeadline> _generalHousingNews = [
    NewsHeadline(
      id: 'news_h_001',
      title: 'Malaysia housing starts hit 5-year high in 2026',
      source: 'The Edge Malaysia',
      sourceLogoUrl: 'https://www.theedgemarkets.com/sites/all/themes/starter/images/logo.png',
      url: 'https://www.theedgemarkets.com/housing-starts-2026',
      publishedAt: DateTime(2026, 2, 15),
      snippet: 'Government incentives drive affordable housing construction...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
    NewsHeadline(
      id: 'news_h_002',
      title: 'KPKT targets 500,000 affordable homes by 2028',
      source: 'NST',
      sourceLogoUrl: 'https://www.nst.com.my/sites/default/files/nst_logo.png',
      url: 'https://www.nst.com.my/kpkt-affordable-homes',
      publishedAt: DateTime(2026, 2, 8),
      snippet: 'Ministry outlines aggressive timeline for housing delivery...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _generalRoadNews = [
    NewsHeadline(
      id: 'news_r_001',
      title: 'RM15 billion allocated for road infrastructure in 2026',
      source: 'Bernama',
      sourceLogoUrl: 'https://www.bernama.com/images/logo.png',
      url: 'https://www.bernama.com/road-budget-2026',
      publishedAt: DateTime(2026, 1, 20),
      snippet: 'Budget includes expressway upgrades and rural road improvements...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _generalDrainageNews = [
    NewsHeadline(
      id: 'news_d_001',
      title: 'Climate adaptation: Malaysia invests in flood mitigation',
      source: 'The Star',
      sourceLogoUrl: 'https://www.thestar.com.my/images/logo.png',
      url: 'https://www.thestar.com.my/flood-mitigation',
      publishedAt: DateTime(2026, 2, 1),
      snippet: 'DID announces RM2 billion upgrade programme for urban drainage...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _generalSchoolNews = [
    NewsHeadline(
      id: 'news_s_001',
      title: 'KPM accelerates school modernisation programme',
      source: 'Bernama',
      sourceLogoUrl: 'https://www.bernama.com/images/logo.png',
      url: 'https://www.bernama.com/school-modernisation',
      publishedAt: DateTime(2026, 2, 12),
      snippet: '200 schools to receive upgrades under Phase 2...',
      sentiment: NewsSentiment.positive,
      isVerified: true,
    ),
  ];

  static final List<NewsHeadline> _breakingNews = [
    NewsHeadline(
      id: 'news_brk_001',
      title: 'BREAKING: Major contractor faces financial difficulties',
      source: 'The Edge Malaysia',
      sourceLogoUrl: 'https://www.theedgemarkets.com/sites/all/themes/starter/images/logo.png',
      url: 'https://www.theedgemarkets.com/contractor-troubles',
      publishedAt: DateTime(2026, 2, 24),
      snippet: 'Three housing projects at risk as developer seeks restructuring...',
      sentiment: NewsSentiment.negative,
      isVerified: true,
    ),
  ];
}

/// Represents a news headline from Malaysian property/construction news sources
class NewsHeadline {
  final String id;
  final String title;
  final String source;
  final String? sourceLogoUrl;
  final String url;
  final DateTime publishedAt;
  final String snippet;
  final NewsSentiment sentiment;
  final bool isVerified;

  const NewsHeadline({
    required this.id,
    required this.title,
    required this.source,
    this.sourceLogoUrl,
    required this.url,
    required this.publishedAt,
    required this.snippet,
    this.sentiment = NewsSentiment.neutral,
    this.isVerified = false,
  });

  String get sentimentLabel {
    switch (sentiment) {
      case NewsSentiment.positive:
        return 'Positive';
      case NewsSentiment.negative:
        return 'Negative';
      case NewsSentiment.neutral:
        return 'Neutral';
    }
  }

  String get sentimentIcon {
    switch (sentiment) {
      case NewsSentiment.positive:
        return '📈';
      case NewsSentiment.negative:
        return '📉';
      case NewsSentiment.neutral:
        return '📊';
    }
  }
}

enum NewsSentiment { positive, negative, neutral }
