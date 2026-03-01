import 'models/project_model.dart';
import 'models/checkin_model.dart';
import 'data/services/location_image_service.dart';

// Location Image Service instance for generating area-specific imagery
final _imageService = LocationImageService();

// ─────────────────────────────────────────────────────────────────────────────
// MOCK SCRAPED SOURCES - Simulated data from various platforms
// ─────────────────────────────────────────────────────────────────────────────

final _sourcePropertyGuru = ScrapedSource(
  id: 'src_pg_001',
  title: 'Residensi Harmoni Review Thread',
  url: 'https://www.propertyguru.com.my/property-news/residensi-harmoni-2026',
  type: SourceType.forum,
  scrapedAt: DateTime(2026, 2, 15),
  snippet: '14 user reviews collected, avg rating 4.2/5',
  domain: 'propertyguru.com.my',
);

final _sourceLowyat = ScrapedSource(
  id: 'src_ly_001',
  title: 'PR1MA Projects Discussion',
  url: 'https://forum.lowyat.net/topic/5234567/prima-harmoni-progress',
  type: SourceType.forum,
  scrapedAt: DateTime(2026, 2, 10),
  snippet: 'Active discussion thread with 47 pages',
  domain: 'lowyat.net',
);

final _sourceNST = ScrapedSource(
  id: 'src_nst_001',
  title: 'PR1MA On Track for 2027 Delivery',
  url: 'https://www.nst.com.my/property/2026/01/prima-harmoni-delivery',
  type: SourceType.news,
  scrapedAt: DateTime(2026, 1, 28),
  snippet: 'Official press release confirms structural completion at 70%',
  domain: 'nst.com.my',
);

final _sourceMOF = ScrapedSource(
  id: 'src_mof_001',
  title: 'Housing Project Database Entry',
  url: 'https://www.mof.gov.my/arkib/perumahan/pr1ma-2026',
  type: SourceType.government,
  scrapedAt: DateTime(2026, 2, 1),
  snippet: 'Ministry of Finance project registry',
  domain: 'mof.gov.my',
);

final _sourceBinaMegah = ScrapedSource(
  id: 'src_bm_001',
  title: 'Taman Melati Official Launch',
  url: 'https://binamegah.com.my/projects/taman-melati',
  type: SourceType.developer,
  scrapedAt: DateTime(2025, 6, 1),
  snippet: 'Developer claims 85% completion - OUTDATED',
  domain: 'binamegah.com.my',
);

final _sourceEdgeProp = ScrapedSource(
  id: 'src_ep_001',
  title: 'Bina Megah faces legal action',
  url: 'https://www.edgeprop.my/content/bina-megah-lawsuit-2025',
  type: SourceType.news,
  scrapedAt: DateTime(2025, 11, 20),
  snippet: 'Buyers file class action lawsuit for project delays',
  domain: 'edgeprop.my',
);

final _sourceSSM = ScrapedSource(
  id: 'src_ssm_001',
  title: 'Company Registry - Bina Megah',
  url: 'https://www.ssm.com.my/company/bina-megah-123456',
  type: SourceType.government,
  scrapedAt: DateTime(2026, 1, 5),
  snippet: 'Financial statements show negative cash flow',
  domain: 'ssm.com.my',
);

// Helper to generate location-based images
String _getMarketingImg(String location, String id) =>
    _imageService.getMarketingImage(location, id);
String _getConstructionImg(String location, String id) =>
    _imageService.getConstructionSiteImage(location, id);
String _getStalledImg(String location, String id) =>
    _imageService.getStalledSiteImage(location, id);

final List<Project> mockProjects = [
  // ── Housing Projects ──
  Project(
    id: 'p1',
    name: 'Residensi Harmoni Phase 2',
    category: ProjectCategory.housing,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Petaling Jaya, Selangor',
    description:
        'A 30-storey affordable housing project under RUMAWIP, featuring 450 units ranging from 800–1000 sq ft. '
        'Amenities include a swimming pool, gymnasium, surau, and playground. '
        'Currently in structural phase with columns rising on floors 18–22.',
    // Location-based marketing image for Petaling Jaya
    imageUrl:
        'https://my1-cdn.pgimgs.com/listing/40711954/UPHO.239620945.V350/Residensi-Harmoni-2-Segambut-Malaysia.jpg',
    expectedCompletion: DateTime(2027, 6, 15),
    agencyOrDeveloper: 'PR1MA Corporation',
    developerWebsite: 'https://www.pr1ma.my',
    lastActivity: DateTime(2026, 2, 20),
    lastVerified: DateTime(2026, 2, 18),
    checkIns: [
      // Check-ins use PJ area construction site photos
      CheckIn(
        id: 'CHK-P1-2026-0218',
        projectId: 'p1',
        status: ProjectStatus.active,
        note: 'Crane active, workers on site, floor 20 being poured.',
        timestamp: DateTime(2026, 2, 18),
        reporterName: 'Ahmad R.',
        photoUrl: _getConstructionImg(
          'Petaling Jaya, Selangor',
          'CHK-P1-2026-0218',
        ),
      ),
      CheckIn(
        id: 'CHK-P1-2026-0210',
        projectId: 'p1',
        status: ProjectStatus.active,
        note: 'Concrete trucks delivering since morning. Good pace.',
        timestamp: DateTime(2026, 2, 10),
        reporterName: 'Siti N.',
        photoUrl: _getConstructionImg(
          'Petaling Jaya, Selangor',
          'CHK-P1-2026-0210',
        ),
      ),
      CheckIn(
        id: 'CHK-P1-2026-0128',
        projectId: 'p1',
        status: ProjectStatus.active,
        note: 'Scaffolding going up on east wing.',
        timestamp: DateTime(2026, 1, 28),
        reporterName: 'Raj K.',
        photoUrl: _getConstructionImg(
          'Petaling Jaya, Selangor',
          'CHK-P1-2026-0128',
        ),
      ),
    ],
    latitude: 3.1073,
    longitude: 101.6067,
    isPublic: false,
    progressPercentage: 72,
    riskLevel: RiskLevel.low,
    developerScore: 4.2,
    sentimentScore: 0.85,
    scrapedSources: [
      _sourcePropertyGuru,
      _sourceLowyat,
      _sourceNST,
      _sourceMOF,
    ],
    officialMilestones: [
      OfficialMilestone(
        description: 'Structural work floor 20 completed',
        claimedProgress: 77,
        date: DateTime(2026, 1, 15),
        source: _sourceNST,
      ),
      OfficialMilestone(
        description: 'M&E rough-in 50% done',
        claimedProgress: 68,
        date: DateTime(2025, 12, 20),
        source: _sourceMOF,
      ),
      OfficialMilestone(
        description: 'Foundation and basement complete',
        claimedProgress: 45,
        date: DateTime(2025, 8, 1),
        source: _sourceNST,
      ),
    ],
    developerProfile: DeveloperProfile(
      name: 'PR1MA Corporation',
      yearsActive: 12,
      totalProjects: 58,
      completedProjects: 42,
      delayedProjects: 8,
      rating: 4.2,
      sources: [_sourceMOF, _sourcePropertyGuru],
      litigationNote: null,
    ),
    sentimentAnalysis: SentimentAnalysis(
      score: 0.85,
      totalReviews: 47,
      sources: [_sourcePropertyGuru, _sourceLowyat],
      summary:
          'Mostly positive sentiment. Buyers report good communication from developer.',
    ),
  ),
  Project(
    id: 'p2',
    name: 'Taman Melati Affordable Homes',
    category: ProjectCategory.housing,
    status: ProjectStatus.stalled,
    confidence: ConfidenceLevel.high,
    location: 'Shah Alam, Selangor',
    description:
        'A low-cost housing project promising 300 terrace houses for B40 families. '
        'Construction halted at foundation stage. Site appears abandoned with overgrown vegetation.',
    // Location-based marketing image for Shah Alam
    imageUrl:
        "https://www.mega3.com.my/getattachment/Blog/May-2022/Memperkenalkan-Taman-Melati-1/Taman-Melati-Shah-Alam-2-1.jpg.aspx",
    expectedCompletion: DateTime(2025, 12, 1),
    agencyOrDeveloper: 'Syarikat Bina Megah Sdn Bhd',
    lastActivity: DateTime(2025, 8, 15),
    lastVerified: DateTime(2026, 2, 15),
    checkIns: [
      // Check-ins show Shah Alam stalled/abandoned site images
      CheckIn(
        id: 'CHK-P2-2026-0215',
        projectId: 'p2',
        status: ProjectStatus.stalled,
        note: 'No workers, no machinery. Site locked. Grass overgrown.',
        timestamp: DateTime(2026, 2, 15),
        reporterName: 'Lee W.',
        photoUrl: _getStalledImg('Shah Alam, Selangor', 'CHK-P2-2026-0215'),
      ),
      CheckIn(
        id: 'CHK-P2-2026-0120',
        projectId: 'p2',
        status: ProjectStatus.stalled,
        note: 'Same as last month. Completely abandoned look.',
        timestamp: DateTime(2026, 1, 20),
        reporterName: 'Farah Z.',
        photoUrl: _getStalledImg('Shah Alam, Selangor', 'CHK-P2-2026-0120'),
      ),
      CheckIn(
        id: 'CHK-P2-2025-1005',
        projectId: 'p2',
        status: ProjectStatus.slowing,
        note: 'Only 2 workers seen. Very little progress.',
        timestamp: DateTime(2025, 10, 5),
        reporterName: 'Ahmad R.',
        photoUrl: _getStalledImg('Shah Alam, Selangor', 'CHK-P2-2025-1005'),
      ),
    ],
    latitude: 3.0733,
    longitude: 101.5185,
    isPublic: false,
    progressPercentage: 12,
    riskLevel: RiskLevel.high,
    developerScore: 1.8,
    sentimentScore: -0.72,
    scrapedSources: [_sourceBinaMegah, _sourceEdgeProp, _sourceSSM],
    officialMilestones: [
      OfficialMilestone(
        description: 'Foundation work "85% complete"',
        claimedProgress: 85,
        date: DateTime(2025, 6, 1),
        source: _sourceBinaMegah,
      ),
      OfficialMilestone(
        description: 'Earthwork and piling done',
        claimedProgress: 40,
        date: DateTime(2025, 3, 15),
        source: _sourceBinaMegah,
      ),
    ],
    developerProfile: DeveloperProfile(
      name: 'Syarikat Bina Megah Sdn Bhd',
      yearsActive: 8,
      totalProjects: 12,
      completedProjects: 5,
      delayedProjects: 6,
      rating: 1.8,
      sources: [_sourceSSM, _sourceEdgeProp],
      litigationNote: 'Class action lawsuit filed by 127 buyers (Nov 2025)',
    ),
    sentimentAnalysis: SentimentAnalysis(
      score: -0.72,
      totalReviews: 89,
      sources: [_sourceEdgeProp, _sourceLowyat],
      summary:
          'Highly negative sentiment. Buyers report no response from developer. Legal action pending.',
    ),
  ),
  Project(
    id: 'p3',
    name: 'Kondominium Vista Kota',
    category: ProjectCategory.housing,
    status: ProjectStatus.slowing,
    confidence: ConfidenceLevel.medium,
    location: 'Kuala Lumpur',
    description:
        'A mid-range condominium with 600 units across two 40-storey towers. '
        'Progress has slowed considerably with only intermittent work observed over the past 3 months.',
    // Location-based marketing image for Kuala Lumpur
    imageUrl: "https://sg1-cdn.pgimgs.com/projectnet-project/2400/ZPPHO.95764048.R800X800.jpg",
    expectedCompletion: DateTime(2027, 3, 1),
    agencyOrDeveloper: 'Mega Development Group',
    developerWebsite: 'https://www.megadevelopment.com.my',
    lastActivity: DateTime(2026, 2, 5),
    lastVerified: DateTime(2026, 2, 12),
    checkIns: [
      CheckIn(
        id: 'c3a',
        projectId: 'p3',
        status: ProjectStatus.slowing,
        note: 'Some workers present but barely any visible progress this week.',
        timestamp: DateTime(2026, 2, 12),
        reporterName: 'Nabilah S.',
        photoUrl: _getConstructionImg('Kuala Lumpur', 'c3a'),
      ),
      CheckIn(
        id: 'c3b',
        projectId: 'p3',
        status: ProjectStatus.active,
        note: 'Concrete work resumed after CNY break.',
        timestamp: DateTime(2026, 1, 30),
        reporterName: 'James T.',
        photoUrl: _getConstructionImg('Kuala Lumpur', 'c3b'),
      ),
    ],
    latitude: 3.1390,
    longitude: 101.6869,
    isPublic: false,
    // Comparison data - MEDIUM RISK: Developer claims 65%, community verifies 38%
    progressPercentage: 38,
    riskLevel: RiskLevel.medium,
    developerScore: 2.9,
    sentimentScore: 0.15,
  ),
  Project(
    id: 'p4',
    name: 'Pangsapuri Seri Kasturi',
    category: ProjectCategory.housing,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Johor Bahru, Johor',
    description:
        'Government-funded apartment complex with 800 units for civil servants. '
        'Construction on track, currently finishing interior works on lower floors.',
    // Location-based marketing image for Johor Bahru
    imageUrl: "https://sg1-cdn.pgimgs.com/projectnet-project/3352/ZPPHO.123788603.V800/Seri-Kasturi-Apartments-Setia-Alam-Malaysia.jpg",
    expectedCompletion: DateTime(2026, 9, 30),
    agencyOrDeveloper: 'SPNB (Syarikat Perumahan Negara)',
    developerWebsite: 'https://www.spnb.com.my',
    lastActivity: DateTime(2026, 2, 21),
    lastVerified: DateTime(2026, 2, 21),
    checkIns: [
      CheckIn(
        id: 'c4a',
        projectId: 'p4',
        status: ProjectStatus.active,
        note: 'Tiling work on floors 1-5, painting on ground floor.',
        timestamp: DateTime(2026, 2, 21),
        reporterName: 'Haris M.',
        photoUrl: _getConstructionImg('Johor Bahru, Johor', 'c4a'),
      ),
      CheckIn(
        id: 'c4b',
        projectId: 'p4',
        status: ProjectStatus.active,
        note: 'Electrical wiring being installed. Steady progress.',
        timestamp: DateTime(2026, 2, 14),
        reporterName: 'Azman B.',
        photoUrl: _getConstructionImg('Johor Bahru, Johor', 'c4b'),
      ),
      CheckIn(
        id: 'c4c',
        projectId: 'p4',
        status: ProjectStatus.active,
        note: 'Lift installation started this week.',
        timestamp: DateTime(2026, 2, 7),
        reporterName: 'Priya D.',
        photoUrl: _getConstructionImg('Johor Bahru, Johor', 'c4c'),
      ),
    ],
    latitude: 1.4927,
    longitude: 103.7414,
    isPublic: false,
    // Comparison data - LOW RISK: Developer claims 88%, community verifies 91%
    progressPercentage: 91,
    riskLevel: RiskLevel.low,
    developerScore: 4.5,
    sentimentScore: 0.92,
  ),
  Project(
    id: 'p5',
    name: 'Residensi Cyberjaya Gateway',
    category: ProjectCategory.housing,
    status: ProjectStatus.unverified,
    confidence: ConfidenceLevel.low,
    location: 'Cyberjaya, Selangor',
    description:
        'Mixed-use development featuring serviced apartments and retail lots. '
        'No recent community reports available.',
    imageUrl: "https://prs.pr1ma.my/storage/photos/shares/1/Property/RESIDENSI_CYBERJAYA2.jpg",
    expectedCompletion: DateTime(2028, 1, 1),
    agencyOrDeveloper: 'Setia Haruman Sdn Bhd',
    developerWebsite: 'https://www.setiaharuman.com',
    lastActivity: DateTime(2025, 11, 1),
    lastVerified: DateTime(2025, 11, 1),
    checkIns: [
      CheckIn(
        id: 'c5a',
        projectId: 'p5',
        status: ProjectStatus.active,
        note: 'Piling work in progress. Early stage.',
        timestamp: DateTime(2025, 11, 1),
        reporterName: 'Unknown',
        photoUrl: _getConstructionImg('Cyberjaya, Selangor', 'c5a'),
      ),
    ],
    latitude: 2.9213,
    longitude: 101.6559,
    isPublic: false,
  ),

  // ── Road Projects ──
  Project(
    id: 'p6',
    name: 'Jalan Damansara–SPRINT Widening',
    category: ProjectCategory.road,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Damansara, Kuala Lumpur',
    description:
        'Road widening project adding 2 lanes to the existing Jalan Damansara corridor to ease congestion. '
        'Includes new drainage, sidewalks, and traffic light upgrades.',
    imageUrl: "https://www.businesstoday.com.my/wp-content/uploads/2022/10/sprint-02.jpg",
    expectedCompletion: DateTime(2026, 12, 1),
    agencyOrDeveloper: 'JKR (Jabatan Kerja Raya)',
    lastActivity: DateTime(2026, 2, 22),
    lastVerified: DateTime(2026, 2, 22),
    checkIns: [
      CheckIn(
        id: 'c6a',
        projectId: 'p6',
        status: ProjectStatus.active,
        note:
            'Lane closure in effect. Heavy machinery working on east section.',
        timestamp: DateTime(2026, 2, 22),
        reporterName: 'Kamal A.',
        photoUrl: _getConstructionImg('Damansara, Kuala Lumpur', 'c6a'),
      ),
      CheckIn(
        id: 'c6b',
        projectId: 'p6',
        status: ProjectStatus.active,
        note: 'New curb being laid along 500m stretch.',
        timestamp: DateTime(2026, 2, 15),
        reporterName: 'Mei L.',
        photoUrl: _getConstructionImg('Damansara, Kuala Lumpur', 'c6b'),
      ),
    ],
    latitude: 3.1350,
    longitude: 101.6250,
    isPublic: true,
  ),
  Project(
    id: 'p7',
    name: 'Lebuhraya Pantai Timur Phase 3',
    category: ProjectCategory.road,
    status: ProjectStatus.slowing,
    confidence: ConfidenceLevel.medium,
    location: 'Kuantan, Pahang',
    description:
        'Extension of the East Coast Expressway connecting Kuantan to Kuala Terengganu. '
        'Some sections experiencing delays due to land acquisition issues.',
    imageUrl: "https://cergasmurni.com.my/wp-content/uploads/2024/01/lp3-8.jpg",
    expectedCompletion: DateTime(2028, 6, 1),
    agencyOrDeveloper: 'ANIH Berhad',
    lastActivity: DateTime(2026, 1, 28),
    lastVerified: DateTime(2026, 2, 10),
    checkIns: [
      CheckIn(
        id: 'c7a',
        projectId: 'p7',
        status: ProjectStatus.slowing,
        note:
            'Work on KM 45-50 section paused. Land dispute with orang asli settlement.',
        timestamp: DateTime(2026, 2, 10),
        reporterName: 'Zul I.',
        photoUrl: _getConstructionImg('Kuantan, Pahang', 'c7a'),
      ),
      CheckIn(
        id: 'c7b',
        projectId: 'p7',
        status: ProjectStatus.active,
        note:
            'Bridge construction at Sungai Lembing crossing progressing well.',
        timestamp: DateTime(2026, 1, 20),
        reporterName: 'Hassan O.',
        photoUrl: _getConstructionImg('Kuantan, Pahang', 'c7b'),
      ),
    ],
    latitude: 3.8077,
    longitude: 103.3260,
    isPublic: true,
  ),
  Project(
    id: 'p8',
    name: 'Jalan Genting Highlands Upgrade',
    category: ProjectCategory.road,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Genting Highlands, Pahang',
    description:
        'Safety upgrade project including slope stabilisation, guardrail replacement, '
        'and road resurfacing along the winding route to Genting Highlands.',
    imageUrl: "https://www.lowyat.net/wp-content/uploads/2025/11/genting-malaysia-plans-road-charges-to-highlands-resort-1.jpg",
    expectedCompletion: DateTime(2026, 8, 1),
    agencyOrDeveloper: 'JKR (Jabatan Kerja Raya)',
    lastActivity: DateTime(2026, 2, 19),
    lastVerified: DateTime(2026, 2, 19),
    checkIns: [
      CheckIn(
        id: 'c8a',
        projectId: 'p8',
        status: ProjectStatus.active,
        note: 'Guardrails installed along hairpin bends at KM 12-15.',
        timestamp: DateTime(2026, 2, 19),
        reporterName: 'Ravi S.',
        photoUrl: _getConstructionImg('Genting Highlands, Pahang', 'c8a'),
      ),
      CheckIn(
        id: 'c8b',
        projectId: 'p8',
        status: ProjectStatus.active,
        note: 'Slope netting completed on dangerous cliff section.',
        timestamp: DateTime(2026, 2, 8),
        reporterName: 'Anis F.',
        photoUrl: _getConstructionImg('Genting Highlands, Pahang', 'c8b'),
      ),
      CheckIn(
        id: 'c8c',
        projectId: 'p8',
        status: ProjectStatus.active,
        note: 'Road resurfacing in progress. One lane closed.',
        timestamp: DateTime(2026, 1, 25),
        reporterName: 'Kelvin C.',
        photoUrl: _getConstructionImg('Genting Highlands, Pahang', 'c8c'),
      ),
    ],
    latitude: 3.4236,
    longitude: 101.7932,
    isPublic: true,
  ),
  Project(
    id: 'p9',
    name: 'Persiaran Subang Permai Access Road',
    category: ProjectCategory.road,
    status: ProjectStatus.stalled,
    confidence: ConfidenceLevel.high,
    location: 'Subang Jaya, Selangor',
    description:
        'New 2km access road to connect residential areas to the Federal Highway. '
        'Project stalled due to funding cuts.',
    imageUrl: "https://jemerlang.com/wp-content/uploads/2023/09/03-01-Persiaran-Teknologi-Subang-1.png",
    expectedCompletion: DateTime(2026, 3, 1),
    agencyOrDeveloper: 'MBSJ (Majlis Bandaraya Subang Jaya)',
    lastActivity: DateTime(2025, 9, 10),
    lastVerified: DateTime(2026, 2, 8),
    checkIns: [
      CheckIn(
        id: 'c9a',
        projectId: 'p9',
        status: ProjectStatus.stalled,
        note: 'No activity. Machinery removed from site.',
        timestamp: DateTime(2026, 2, 8),
        reporterName: 'Izzat N.',
        photoUrl: _getStalledImg('Subang Jaya, Selangor', 'c9a'),
      ),
      CheckIn(
        id: 'c9b',
        projectId: 'p9',
        status: ProjectStatus.stalled,
        note: 'Still no progress. Barricades rusting.',
        timestamp: DateTime(2026, 1, 5),
        reporterName: 'Sarah L.',
      ),
    ],
    latitude: 3.0565,
    longitude: 101.5851,
    isPublic: true,
  ),

  // ── Drainage Projects ──
  Project(
    id: 'p10',
    name: 'Sungai Klang Flood Mitigation',
    category: ProjectCategory.drainage,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Klang, Selangor',
    description:
        'Major flood mitigation project involving river deepening, retention ponds, '
        'and upgraded pump stations along Sungai Klang.',
    imageUrl: "https://www.freemalaysiatoday.com/cdn-cgi/image/width=3840,quality=80,format=auto,fit=scale-down,metadata=none,dpr=1,onerror=redirect/https://media.freemalaysiatoday.com/wp-content/uploads/2022/11/taman-sri-muda-banjir-bernama.jpg",
    expectedCompletion: DateTime(2027, 12, 1),
    agencyOrDeveloper: 'DID (Jabatan Pengairan dan Saliran)',
    lastActivity: DateTime(2026, 2, 20),
    lastVerified: DateTime(2026, 2, 20),
    checkIns: [
      CheckIn(
        id: 'c10a',
        projectId: 'p10',
        status: ProjectStatus.active,
        note: 'Excavators deepening river channel near Jambatan Kota.',
        timestamp: DateTime(2026, 2, 20),
        reporterName: 'Hafiz R.',
      ),
      CheckIn(
        id: 'c10b',
        projectId: 'p10',
        status: ProjectStatus.active,
        note: 'New pump station foundation being laid at Section 7.',
        timestamp: DateTime(2026, 2, 12),
        reporterName: 'Aida M.',
      ),
    ],
    latitude: 3.0449,
    longitude: 101.4455,
    isPublic: true,
  ),
  Project(
    id: 'p11',
    name: 'Taman Sri Muda Drainage Upgrade',
    category: ProjectCategory.drainage,
    status: ProjectStatus.slowing,
    confidence: ConfidenceLevel.medium,
    location: 'Shah Alam, Selangor',
    description:
        'Upgrade of drainage infrastructure in flood-prone Taman Sri Muda area. '
        'Includes larger culverts and a new detention pond.',
    imageUrl: "https://i.ncdn.xyz/publisher-c1a3f893382d2b2f8a9aa22a654d9c97/2021/12/17668e66521e12be4219ca7c6bd3ac6e.jpg=s600",
    expectedCompletion: DateTime(2026, 6, 1),
    agencyOrDeveloper: 'MBSA (Majlis Bandaraya Shah Alam)',
    lastActivity: DateTime(2026, 1, 30),
    lastVerified: DateTime(2026, 2, 14),
    checkIns: [
      CheckIn(
        id: 'c11a',
        projectId: 'p11',
        status: ProjectStatus.slowing,
        note: 'Work intermittent. Culvert installation at 60% only.',
        timestamp: DateTime(2026, 2, 14),
        reporterName: 'Zainab K.',
      ),
      CheckIn(
        id: 'c11b',
        projectId: 'p11',
        status: ProjectStatus.active,
        note: 'Detention pond excavation progressing.',
        timestamp: DateTime(2026, 1, 20),
        reporterName: 'Ramesh P.',
      ),
    ],
    latitude: 3.0600,
    longitude: 101.5300,
    isPublic: true,
  ),
  Project(
    id: 'p12',
    name: 'Monsoon Drain Kampung Baru',
    category: ProjectCategory.drainage,
    status: ProjectStatus.stalled,
    confidence: ConfidenceLevel.medium,
    location: 'Kuala Lumpur',
    description:
        'Construction of a new covered monsoon drain to replace aging open drains '
        'in the Kampung Baru area. Stalled due to utility relocation delays.',
    imageUrl: "https://apicms.thestar.com.my/uploads/images/2019/09/28/296694.jpg",
    expectedCompletion: DateTime(2026, 4, 1),
    agencyOrDeveloper: 'DBKL (Dewan Bandaraya Kuala Lumpur)',
    lastActivity: DateTime(2025, 12, 15),
    lastVerified: DateTime(2026, 2, 5),
    checkIns: [
      CheckIn(
        id: 'c12a',
        projectId: 'p12',
        status: ProjectStatus.stalled,
        note: 'Waiting for TNB to relocate cables. No construction.',
        timestamp: DateTime(2026, 2, 5),
        reporterName: 'Farid H.',
      ),
      CheckIn(
        id: 'c12b',
        projectId: 'p12',
        status: ProjectStatus.stalled,
        note: 'Site idle. Only security guard present.',
        timestamp: DateTime(2026, 1, 15),
        reporterName: 'Nurul A.',
      ),
    ],
    latitude: 3.1600,
    longitude: 101.7000,
    isPublic: true,
  ),
  Project(
    id: 'p13',
    name: 'Pasir Gudang Industrial Drain',
    category: ProjectCategory.drainage,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.medium,
    location: 'Pasir Gudang, Johor',
    description:
        'New industrial drainage system to prevent chemical runoff into nearby waterways. '
        'Critical environmental infrastructure project.',
    imageUrl: "https://pages.malaysiakini.com/johorriver/img/sg-buluh-1080x1080.jpg",
    expectedCompletion: DateTime(2026, 11, 1),
    agencyOrDeveloper: 'DOE / JKR Johor',
    lastActivity: DateTime(2026, 2, 18),
    lastVerified: DateTime(2026, 2, 18),
    checkIns: [
      CheckIn(
        id: 'c13a',
        projectId: 'p13',
        status: ProjectStatus.active,
        note: 'Pipe laying along Jalan Perindustrian 3.',
        timestamp: DateTime(2026, 2, 18),
        reporterName: 'Daniel W.',
      ),
      CheckIn(
        id: 'c13b',
        projectId: 'p13',
        status: ProjectStatus.active,
        note: 'Treatment tank foundation poured successfully.',
        timestamp: DateTime(2026, 2, 2),
        reporterName: 'Lina T.',
      ),
    ],
    latitude: 1.4700,
    longitude: 103.8900,
    isPublic: true,
  ),

  // ── School Projects ──
  Project(
    id: 'p14',
    name: 'SK Taman Universiti Expansion',
    category: ProjectCategory.school,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Skudai, Johor',
    description:
        'Expansion of existing primary school including a new 3-storey classroom block, '
        'canteen upgrade, and covered sports court.',
    imageUrl: "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj0HHIxs9k3jNezSufN6FuHoDu0uldS5OfpTDvVbQVspvE0oSrXIkYvoXezSGJ4DmxWZtwwd9QjNR5AqRgVeYKlIncvTkWXLFrC1kAuZMpxR61rV-mtb1nRjRSgRY7sA3AUCmmjo5IJkYE/s400/header.jpg",
    expectedCompletion: DateTime(2026, 7, 1),
    agencyOrDeveloper: 'KPM (Kementerian Pendidikan Malaysia)',
    lastActivity: DateTime(2026, 2, 20),
    lastVerified: DateTime(2026, 2, 20),
    checkIns: [
      CheckIn(
        id: 'c14a',
        projectId: 'p14',
        status: ProjectStatus.active,
        note: 'Classroom block at 2nd floor. Roofing next month.',
        timestamp: DateTime(2026, 2, 20),
        reporterName: 'Cikgu Aminah',
      ),
      CheckIn(
        id: 'c14b',
        projectId: 'p14',
        status: ProjectStatus.active,
        note: 'Canteen demolition completed. New foundation laid.',
        timestamp: DateTime(2026, 2, 5),
        reporterName: 'En. Razak',
      ),
    ],
    latitude: 1.5360,
    longitude: 103.6350,
    isPublic: true,
  ),
  Project(
    id: 'p15',
    name: 'SMK Presint 16 New Campus',
    category: ProjectCategory.school,
    status: ProjectStatus.stalled,
    confidence: ConfidenceLevel.high,
    location: 'Putrajaya',
    description:
        'New secondary school campus to serve the growing Presint 16 population. '
        'Construction stopped at ground floor due to contractor financial issues.',
    imageUrl: "https://assets.change.org/photos/0/mi/dp/plMIdPIBvsVztdF-800x450-noPad.jpg?1563804815",
    expectedCompletion: DateTime(2026, 1, 1),
    agencyOrDeveloper: 'KPM / Perbadanan Putrajaya',
    lastActivity: DateTime(2025, 7, 20),
    lastVerified: DateTime(2026, 2, 10),
    checkIns: [
      CheckIn(
        id: 'c15a',
        projectId: 'p15',
        status: ProjectStatus.stalled,
        note: 'No work for months. Contractor reportedly in financial trouble.',
        timestamp: DateTime(2026, 2, 10),
        reporterName: 'Puan Ros',
      ),
      CheckIn(
        id: 'c15b',
        projectId: 'p15',
        status: ProjectStatus.stalled,
        note: 'Parents complaining about overcrowding at existing school.',
        timestamp: DateTime(2026, 1, 15),
        reporterName: 'Hafiz A.',
      ),
      CheckIn(
        id: 'c15c',
        projectId: 'p15',
        status: ProjectStatus.slowing,
        note: 'Only a handful of workers. Ground floor columns incomplete.',
        timestamp: DateTime(2025, 9, 20),
        reporterName: 'Rizal M.',
      ),
    ],
    latitude: 2.9264,
    longitude: 101.6964,
    isPublic: true,
  ),
  Project(
    id: 'p16',
    name: 'Sekolah Jenis Kebangsaan (C) Kepong',
    category: ProjectCategory.school,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.medium,
    location: 'Kepong, Kuala Lumpur',
    description:
        'Renovation and modernisation of existing Chinese-medium primary school. '
        'Includes new science lab, ICT room, and accessibility ramps.',
    imageUrl:"https://sekolah2u.com/storage/2023/04/Screenshot-2024-01-10-111716.png",
    expectedCompletion: DateTime(2026, 5, 1),
    agencyOrDeveloper: 'KPM / DBKL',
    lastActivity: DateTime(2026, 2, 17),
    lastVerified: DateTime(2026, 2, 17),
    checkIns: [
      CheckIn(
        id: 'c16a',
        projectId: 'p16',
        status: ProjectStatus.active,
        note: 'Science lab equipment being installed. Painting underway.',
        timestamp: DateTime(2026, 2, 17),
        reporterName: 'Mr. Tan',
      ),
      CheckIn(
        id: 'c16b',
        projectId: 'p16',
        status: ProjectStatus.active,
        note: 'ICT room wiring completed. Furniture arriving next week.',
        timestamp: DateTime(2026, 2, 3),
        reporterName: 'Ms. Wong',
      ),
    ],
    latitude: 3.2100,
    longitude: 101.6330,
    isPublic: true,
  ),

  // ── More Housing ──
  Project(
    id: 'p17',
    name: 'Apartment Seri Pinang',
    category: ProjectCategory.housing,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.medium,
    location: 'Ipoh, Perak',
    description:
        'Mid-rise apartment project with 200 units across 5 blocks. '
        'Targeted at young professionals and first-time home buyers.',
    imageUrl: "https://my1-cdn.pgimgs.com/listing/500588694/UPHO.282777289.V800/Seri-Pinang-Setia-Alam-Malaysia.jpg",
    expectedCompletion: DateTime(2027, 1, 1),
    agencyOrDeveloper: 'Perak State Development Corp',
    lastActivity: DateTime(2026, 2, 15),
    lastVerified: DateTime(2026, 2, 15),
    checkIns: [
      CheckIn(
        id: 'c17a',
        projectId: 'p17',
        status: ProjectStatus.active,
        note: 'Block A structural work at 7th floor. Blocks B-C at 4th floor.',
        timestamp: DateTime(2026, 2, 15),
        reporterName: 'Kumar V.',
      ),
      CheckIn(
        id: 'c17b',
        projectId: 'p17',
        status: ProjectStatus.active,
        note: 'Foundation piling for Block D completed.',
        timestamp: DateTime(2026, 1, 28),
        reporterName: 'Faizal R.',
      ),
    ],
    latitude: 4.5975,
    longitude: 101.0901,
    isPublic: false,
  ),
  Project(
    id: 'p18',
    name: 'Taman Impian Emas Villas',
    category: ProjectCategory.housing,
    status: ProjectStatus.slowing,
    confidence: ConfidenceLevel.low,
    location: 'Skudai, Johor',
    description:
        'Gated villa community with 50 luxury units. Progress has slowed '
        'with intermittent work and supply chain issues reported.',
    imageUrl: "https://my1-cdn.pgimgs.com/listing/500719704/UPHO.284436639.V550/Taman-Impian-Emas-Skudai-Malaysia.jpg",
    expectedCompletion: DateTime(2027, 6, 1),
    agencyOrDeveloper: 'Golden Land Properties',
    lastActivity: DateTime(2026, 1, 10),
    lastVerified: DateTime(2026, 2, 1),
    checkIns: [
      CheckIn(
        id: 'c18a',
        projectId: 'p18',
        status: ProjectStatus.slowing,
        note: 'Only 3 units under construction. Show house abandoned look.',
        timestamp: DateTime(2026, 2, 1),
        reporterName: 'Mira J.',
      ),
    ],
    latitude: 1.5480,
    longitude: 103.6700,
    isPublic: false,
  ),
  Project(
    id: 'p19',
    name: 'PPR Kerinchi Replacement Blocks',
    category: ProjectCategory.housing,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Bangsar South, Kuala Lumpur',
    description:
        'Replacement public housing project for displaced PPR Kerinchi residents. '
        '4 blocks of 17 storeys each with modern facilities.',
    imageUrl: "https://www.mudah.my/29/2961753848359814843.jpg",
    expectedCompletion: DateTime(2026, 12, 1),
    agencyOrDeveloper: 'DBKL / Federal Government',
    lastActivity: DateTime(2026, 2, 21),
    lastVerified: DateTime(2026, 2, 21),
    checkIns: [
      CheckIn(
        id: 'c19a',
        projectId: 'p19',
        status: ProjectStatus.active,
        note: 'Block 1 topping off ceremony held. Finishing works starting.',
        timestamp: DateTime(2026, 2, 21),
        reporterName: 'Encik Salleh',
      ),
      CheckIn(
        id: 'c19b',
        projectId: 'p19',
        status: ProjectStatus.active,
        note: 'Block 2 at floor 14. Block 3 at floor 11.',
        timestamp: DateTime(2026, 2, 10),
        reporterName: 'Anita S.',
      ),
      CheckIn(
        id: 'c19c',
        projectId: 'p19',
        status: ProjectStatus.active,
        note: 'All cranes operational. Night shift work ongoing.',
        timestamp: DateTime(2026, 1, 28),
        reporterName: 'Yusof K.',
      ),
    ],
    latitude: 3.1100,
    longitude: 101.6700,
    isPublic: true,
  ),

  // ── More Road ──
  Project(
    id: 'p20',
    name: 'Putrajaya–Cyberjaya Expressway',
    category: ProjectCategory.road,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.medium,
    location: 'Putrajaya–Cyberjaya',
    description:
        'New 8km elevated expressway linking Putrajaya Sentral to Cyberjaya. '
        'Includes 3 interchanges and dedicated bus lanes.',
    imageUrl: "https://www.mymrt.com.my/wp-content/uploads/2019/08/MRT-Corp-SSP-Line-July-Putrajaya-Cyberjaya-Expressway-1.jpg",
    expectedCompletion: DateTime(2028, 3, 1),
    agencyOrDeveloper: 'MoW (Ministry of Works)',
    lastActivity: DateTime(2026, 2, 18),
    lastVerified: DateTime(2026, 2, 18),
    checkIns: [
      CheckIn(
        id: 'c20a',
        projectId: 'p20',
        status: ProjectStatus.active,
        note:
            'Pier columns rising at interchange 2. Steel reinforcement ongoing.',
        timestamp: DateTime(2026, 2, 18),
        reporterName: 'Chong W.',
      ),
      CheckIn(
        id: 'c20b',
        projectId: 'p20',
        status: ProjectStatus.active,
        note: 'Approach road earthwork 70% complete.',
        timestamp: DateTime(2026, 2, 5),
        reporterName: 'Bala R.',
      ),
    ],
    latitude: 2.9350,
    longitude: 101.6800,
    isPublic: true,
  ),
  Project(
    id: 'p21',
    name: 'Jalan Ipoh Resurfacing Phase 2',
    category: ProjectCategory.road,
    status: ProjectStatus.stalled,
    confidence: ConfidenceLevel.medium,
    location: 'Sentul, Kuala Lumpur',
    description:
        'Phase 2 of the Jalan Ipoh road resurfacing project. '
        'Work stopped after the monsoon season and has not resumed.',
    imageUrl: "https://www.mymrt.com.my/wp-content/uploads/2020/09/MRT-Corp-SSP-Line-July-Jalan-Ipoh-Jalan-Ipoh-1-Large.jpg",
    expectedCompletion: DateTime(2026, 2, 1),
    agencyOrDeveloper: 'DBKL',
    lastActivity: DateTime(2025, 11, 30),
    lastVerified: DateTime(2026, 2, 7),
    checkIns: [
      CheckIn(
        id: 'c21a',
        projectId: 'p21',
        status: ProjectStatus.stalled,
        note:
            'Unfinished roadwork causing dangerous potholes. Needs attention.',
        timestamp: DateTime(2026, 2, 7),
        reporterName: 'Muthu R.',
      ),
      CheckIn(
        id: 'c21b',
        projectId: 'p21',
        status: ProjectStatus.stalled,
        note: 'Half-paved stretch near Sentul Pasar. Very hazardous.',
        timestamp: DateTime(2026, 1, 18),
        reporterName: 'Lisa C.',
      ),
    ],
    latitude: 3.1800,
    longitude: 101.6900,
    isPublic: true,
  ),

  // ── More Drainage ──
  Project(
    id: 'p22',
    name: 'Penang Coastal Flood Wall',
    category: ProjectCategory.drainage,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Georgetown, Penang',
    description:
        'Construction of a 2km coastal flood wall to protect heritage areas from rising tides and storm surges.',
    imageUrl: "https://img3.penangpropertytalk.com/wp-content/uploads/2022/03/esplanade-seewall-project-e1648019889265.jpg",
    expectedCompletion: DateTime(2027, 8, 1),
    agencyOrDeveloper: 'DID Penang / Federal Govt',
    lastActivity: DateTime(2026, 2, 19),
    lastVerified: DateTime(2026, 2, 19),
    checkIns: [
      CheckIn(
        id: 'c22a',
        projectId: 'p22',
        status: ProjectStatus.active,
        note:
            'Sheet piling along Weld Quay completed. Concrete pouring started.',
        timestamp: DateTime(2026, 2, 19),
        reporterName: 'Ah Hock',
      ),
      CheckIn(
        id: 'c22b',
        projectId: 'p22',
        status: ProjectStatus.active,
        note: 'Excellent progress despite rain. Workers on double shift.',
        timestamp: DateTime(2026, 2, 8),
        reporterName: 'Ranjit S.',
      ),
    ],
    latitude: 5.4141,
    longitude: 100.3288,
    isPublic: true,
  ),
  Project(
    id: 'p23',
    name: 'Sungai Pinang Rehabilitation',
    category: ProjectCategory.drainage,
    status: ProjectStatus.slowing,
    confidence: ConfidenceLevel.low,
    location: 'Penang',
    description:
        'Comprehensive rehabilitation of Sungai Pinang including river cleaning, '
        'bank strengthening, and stormwater detention basins.',
    imageUrl: "https://www.buletinmutiara.com/wp-content/uploads/2022/04/WhatsApp-Image-2022-04-11-at-6.45.31-PM.jpeg",
    expectedCompletion: DateTime(2027, 5, 1),
    agencyOrDeveloper: 'Penang State Government',
    lastActivity: DateTime(2026, 1, 25),
    lastVerified: DateTime(2026, 2, 3),
    checkIns: [
      CheckIn(
        id: 'c23a',
        projectId: 'p23',
        status: ProjectStatus.slowing,
        note: 'Bank strengthening paused. Material shortage cited.',
        timestamp: DateTime(2026, 2, 3),
        reporterName: 'Gopal N.',
      ),
    ],
    latitude: 5.3950,
    longitude: 100.3100,
    isPublic: true,
  ),

  // ── More Schools ──
  Project(
    id: 'p24',
    name: 'MRSM Langkawi New Wing',
    category: ProjectCategory.school,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Langkawi, Kedah',
    description:
        'New academic wing for MRSM Langkawi with 12 classrooms, '
        '2 science labs, and a multimedia centre.',
    imageUrl: "https://pbs.twimg.com/media/DfK6S-LU8AA16Xb.jpg",
    expectedCompletion: DateTime(2026, 8, 1),
    agencyOrDeveloper: 'MARA / KPM',
    lastActivity: DateTime(2026, 2, 17),
    lastVerified: DateTime(2026, 2, 17),
    checkIns: [
      CheckIn(
        id: 'c24a',
        projectId: 'p24',
        status: ProjectStatus.active,
        note: 'Roofing completed. Interior partition walls going up.',
        timestamp: DateTime(2026, 2, 17),
        reporterName: 'Ustaz Hamid',
      ),
      CheckIn(
        id: 'c24b',
        projectId: 'p24',
        status: ProjectStatus.active,
        note: 'M&E works in progress. AC ductwork being installed.',
        timestamp: DateTime(2026, 2, 1),
        reporterName: 'Pn. Azizah',
      ),
    ],
    latitude: 6.3500,
    longitude: 99.7800,
    isPublic: true,
  ),
  Project(
    id: 'p25',
    name: 'Tadika Kemas Taman Melawati',
    category: ProjectCategory.school,
    status: ProjectStatus.unverified,
    confidence: ConfidenceLevel.low,
    location: 'Taman Melawati, KL',
    description:
        'New KEMAS kindergarten building to replace a temporary structure. '
        'Project announced but no recent verification.',
    imageUrl: "https://apicms.majoriti.com.my/uploads/images/2024/10/15/2965113.jpeg",
    expectedCompletion: DateTime(2026, 12, 1),
    agencyOrDeveloper: 'KEMAS',
    lastActivity: DateTime(2025, 10, 1),
    lastVerified: DateTime(2025, 10, 1),
    checkIns: [
      CheckIn(
        id: 'c25a',
        projectId: 'p25',
        status: ProjectStatus.unverified,
        note: 'Signboard erected but no construction visible yet.',
        timestamp: DateTime(2025, 10, 1),
        reporterName: 'Puan Haslinda',
      ),
    ],
    latitude: 3.2100,
    longitude: 101.7500,
    isPublic: true,
  ),

  // ── Additional variety ──
  Project(
    id: 'p26',
    name: 'Malacca Heritage Walk Restoration',
    category: ProjectCategory.road,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Malacca City, Malacca',
    description:
        'Pedestrianisation and heritage restoration of Jonker Street area sidewalks '
        'and access roads. Includes cobblestone paving and heritage lighting.',
    imageUrl: "https://klonfoot.com/wp-content/uploads/2020/01/Mel-16.jpg?d50288&d50288",
    expectedCompletion: DateTime(2026, 10, 1),
    agencyOrDeveloper: 'MBMB (Majlis Bandaraya Melaka Bersejarah)',
    lastActivity: DateTime(2026, 2, 22),
    lastVerified: DateTime(2026, 2, 22),
    checkIns: [
      CheckIn(
        id: 'c26a',
        projectId: 'p26',
        status: ProjectStatus.active,
        note: 'Cobblestone laying near Christ Church square. Beautiful work.',
        timestamp: DateTime(2026, 2, 22),
        reporterName: 'Mei Lin',
      ),
      CheckIn(
        id: 'c26b',
        projectId: 'p26',
        status: ProjectStatus.active,
        note: 'Heritage lamp posts installed along Heeren Street.',
        timestamp: DateTime(2026, 2, 10),
        reporterName: 'Rajen K.',
      ),
    ],
    latitude: 2.1946,
    longitude: 102.2505,
    isPublic: true,
  ),
  Project(
    id: 'p27',
    name: 'Kota Kinabalu Waterfront Drain',
    category: ProjectCategory.drainage,
    status: ProjectStatus.unverified,
    confidence: ConfidenceLevel.low,
    location: 'Kota Kinabalu, Sabah',
    description:
        'Upgrade of stormwater drainage along the KK waterfront to prevent '
        'flooding during heavy monsoon rains.',
    imageUrl: "https://assets.nst.com.my/images/articles/435291465_805336058299631_4338413372486955184_n_1712219433.jpg",
    expectedCompletion: DateTime(2027, 4, 1),
    agencyOrDeveloper: 'JKR Sabah',
    lastActivity: DateTime(2025, 12, 1),
    lastVerified: DateTime(2025, 12, 1),
    checkIns: [
      CheckIn(
        id: 'c27a',
        projectId: 'p27',
        status: ProjectStatus.active,
        note: 'Initial excavation near Jesselton Point. Early stage.',
        timestamp: DateTime(2025, 12, 1),
        reporterName: 'John L.',
      ),
    ],
    latitude: 5.9804,
    longitude: 116.0735,
    isPublic: true,
  ),
  Project(
    id: 'p28',
    name: 'Eco Grandeur Phase 5 Terraces',
    category: ProjectCategory.housing,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Puncak Alam, Selangor',
    description:
        'Phase 5 of the Eco Grandeur township featuring 120 double-storey terrace houses '
        'with smart home features and solar panels.',
    imageUrl: "https://ecoworld.my/ecograndeur/wp-content/uploads/2024/11/c899d495-c008-4588-a90f-84a891f3822e-1-1024x576.jpeg",
    expectedCompletion: DateTime(2026, 11, 1),
    agencyOrDeveloper: 'EcoWorld Development',
    developerWebsite: 'https://ecoworld.my',
    lastActivity: DateTime(2026, 2, 21),
    lastVerified: DateTime(2026, 2, 21),
    checkIns: [
      CheckIn(
        id: 'c28a',
        projectId: 'p28',
        status: ProjectStatus.active,
        note: 'Row 1-3 roofing complete. Interior plastering started.',
        timestamp: DateTime(2026, 2, 21),
        reporterName: 'Lim KW',
      ),
      CheckIn(
        id: 'c28b',
        projectId: 'p28',
        status: ProjectStatus.active,
        note: 'Road infrastructure within the phase nearly done.',
        timestamp: DateTime(2026, 2, 8),
        reporterName: 'Rizwan A.',
      ),
      CheckIn(
        id: 'c28c',
        projectId: 'p28',
        status: ProjectStatus.active,
        note: 'Solar panel framework on display units installed.',
        timestamp: DateTime(2026, 1, 25),
        reporterName: 'Samantha T.',
      ),
    ],
    latitude: 3.3900,
    longitude: 101.4600,
    isPublic: false,
  ),
  Project(
    id: 'p29',
    name: 'SK Bukit Jalil 2 New Block',
    category: ProjectCategory.school,
    status: ProjectStatus.slowing,
    confidence: ConfidenceLevel.medium,
    location: 'Bukit Jalil, Kuala Lumpur',
    description:
        'Additional classroom block for the overcrowded SK Bukit Jalil 2. '
        'Progress slower than expected due to material cost increases.',
    imageUrl: "https://sekolah2u.com/storage/2023/04/exterior-1-36.jpg",
    expectedCompletion: DateTime(2026, 7, 1),
    agencyOrDeveloper: 'KPM',
    lastActivity: DateTime(2026, 2, 10),
    lastVerified: DateTime(2026, 2, 10),
    checkIns: [
      CheckIn(
        id: 'c29a',
        projectId: 'p29',
        status: ProjectStatus.slowing,
        note:
            'Structure at 3rd floor but work pace has dropped. Fewer workers.',
        timestamp: DateTime(2026, 2, 10),
        reporterName: 'Cikgu Nora',
      ),
      CheckIn(
        id: 'c29b',
        projectId: 'p29',
        status: ProjectStatus.active,
        note: '2nd floor slab poured. Looking good.',
        timestamp: DateTime(2026, 1, 15),
        reporterName: 'En. Razali',
      ),
    ],
    latitude: 3.0580,
    longitude: 101.6800,
    isPublic: true,
  ),
  Project(
    id: 'p30',
    name: 'Bandar Sunway Pedestrian Bridge',
    category: ProjectCategory.road,
    status: ProjectStatus.active,
    confidence: ConfidenceLevel.high,
    location: 'Sunway, Selangor',
    description:
        'Covered pedestrian bridge connecting Sunway Pyramid to Sunway University '
        'across the Federal Highway. Includes elevator access.',
    imageUrl: "https://stories.sunway.com.my/wp-content/uploads/2019/07/sunway-ecowalk_nchc.jpg",
    expectedCompletion: DateTime(2026, 6, 1),
    agencyOrDeveloper: 'Sunway Group / MBSJ',
    lastActivity: DateTime(2026, 2, 22),
    lastVerified: DateTime(2026, 2, 22),
    checkIns: [
      CheckIn(
        id: 'c30a',
        projectId: 'p30',
        status: ProjectStatus.active,
        note: 'Steel structure spanning the highway now connected! Milestone!',
        timestamp: DateTime(2026, 2, 22),
        reporterName: 'Ahmad Z.',
      ),
      CheckIn(
        id: 'c30b',
        projectId: 'p30',
        status: ProjectStatus.active,
        note: 'Elevator shaft on university side at 80%.',
        timestamp: DateTime(2026, 2, 12),
        reporterName: 'Carmen L.',
      ),
      CheckIn(
        id: 'c30c',
        projectId: 'p30',
        status: ProjectStatus.active,
        note: 'Roof canopy installation beginning on south section.',
        timestamp: DateTime(2026, 2, 1),
        reporterName: 'Kevin O.',
      ),
    ],
    latitude: 3.0700,
    longitude: 101.6070,
    isPublic: true,
  ),
];

