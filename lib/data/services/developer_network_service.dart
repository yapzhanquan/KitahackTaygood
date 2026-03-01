import '../../models/developer_network_model.dart';
import '../../models/project_model.dart';
import 'location_image_service.dart';

/// Service that scrapes and maps developer corporate networks, director histories,
/// and past project galleries from SSM, property portals, and community sources.
class DeveloperNetworkService {
  static final DeveloperNetworkService _instance = DeveloperNetworkService._internal();
  factory DeveloperNetworkService() => _instance;
  DeveloperNetworkService._internal();

  final _imageService = LocationImageService();

  /// Fetch complete developer network profile including directors and past projects
  Future<DeveloperNetwork> getDeveloperNetwork(String developerName) async {
    // Simulate API delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Return mock data based on developer name
    return _getMockDeveloperNetwork(developerName);
  }

  /// Check if a director has high-risk associations
  Future<List<CompanyAssociation>> checkDirectorHistory(String directorName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _getMockDirectorAssociations(directorName);
  }

  /// Fetch past projects for a developer
  Future<List<PastProject>> getPastProjects(String developerName) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _getMockPastProjects(developerName);
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // MOCK DATA GENERATORS - Simulating SSM scraper results
  // ─────────────────────────────────────────────────────────────────────────────

  DeveloperNetwork _getMockDeveloperNetwork(String developerName) {
    final normalizedName = developerName.toLowerCase();
    
    // PR1MA Corporation - Good developer
    if (normalizedName.contains('pr1ma') || normalizedName.contains('prima')) {
      return _createPR1MANetwork();
    }
    
    // Bina Megah - Bad developer with high-risk directors
    if (normalizedName.contains('bina megah')) {
      return _createBinaMegahNetwork();
    }
    
    // Mega Development Group - Medium risk
    if (normalizedName.contains('mega development')) {
      return _createMegaDevelopmentNetwork();
    }
    
    // SPNB - Government, low risk
    if (normalizedName.contains('spnb') || normalizedName.contains('perumahan negara')) {
      return _createSPNBNetwork();
    }
    
    // Default network for other developers
    return _createDefaultNetwork(developerName);
  }

  DeveloperNetwork _createPR1MANetwork() {
    return DeveloperNetwork(
      developerId: 'dev_pr1ma',
      companyName: 'PR1MA Corporation Malaysia',
      registrationNumber: '201001012345 (897456-X)',
      incorporationDate: DateTime(2010, 4, 1),
      companyStatus: 'Active',
      paidUpCapital: 500000000,
      businessAddress: 'Level 12, Menara PR1MA, Jalan Tun Razak, 50400 Kuala Lumpur',
      directors: [
        Director(
          id: 'dir_001',
          name: 'Dato\' Ahmad bin Hassan',
          icNumber: '******-**-5521',
          position: 'Managing Director',
          appointmentDate: DateTime(2015, 6, 1),
          riskLevel: DirectorRiskLevel.low,
          associations: [
            CompanyAssociation(
              companyId: 'comp_001',
              companyName: 'PR1MA Corporation Malaysia',
              registrationNumber: '897456-X',
              status: CompanyStatus.active,
              role: 'Managing Director',
              associationStart: DateTime(2015, 6, 1),
              sourceUrl: 'https://www.ssm.com.my/Pages/Register_Business/Company-SSM.aspx',
            ),
            CompanyAssociation(
              companyId: 'comp_002',
              companyName: 'Pembangunan Hartanah Berhad',
              registrationNumber: '456789-A',
              status: CompanyStatus.active,
              role: 'Independent Director',
              associationStart: DateTime(2018, 1, 15),
              sourceUrl: 'https://www.ssm.com.my/Pages/Register_Business/Company-SSM.aspx',
            ),
          ],
        ),
        Director(
          id: 'dir_002',
          name: 'Puan Siti Aminah binti Abdullah',
          icNumber: '******-**-6234',
          position: 'Executive Director',
          appointmentDate: DateTime(2016, 3, 15),
          riskLevel: DirectorRiskLevel.low,
          associations: [
            CompanyAssociation(
              companyId: 'comp_001',
              companyName: 'PR1MA Corporation Malaysia',
              registrationNumber: '897456-X',
              status: CompanyStatus.active,
              role: 'Executive Director',
              associationStart: DateTime(2016, 3, 15),
              sourceUrl: 'https://www.ssm.com.my/Pages/Register_Business/Company-SSM.aspx',
            ),
          ],
        ),
        Director(
          id: 'dir_003',
          name: 'Encik Rajesh a/l Krishnan',
          icNumber: '******-**-7891',
          position: 'Finance Director',
          appointmentDate: DateTime(2017, 8, 1),
          riskLevel: DirectorRiskLevel.low,
          associations: [
            CompanyAssociation(
              companyId: 'comp_001',
              companyName: 'PR1MA Corporation Malaysia',
              registrationNumber: '897456-X',
              status: CompanyStatus.active,
              role: 'Finance Director',
              associationStart: DateTime(2017, 8, 1),
              sourceUrl: 'https://www.ssm.com.my/Pages/Register_Business/Company-SSM.aspx',
            ),
          ],
        ),
      ],
      pastProjects: _getPR1MAPastProjects(),
      riskSummary: NetworkRiskSummary(
        overallRisk: DirectorRiskLevel.low,
        totalDirectors: 3,
        highRiskDirectors: 0,
        failedCompanyLinks: 0,
        blacklistedLinks: 0,
        aiAnalysis: 'PR1MA Corporation demonstrates a strong governance structure with experienced directors who have clean corporate histories. No associations with failed or blacklisted entities detected.',
        keyFindings: [
          '✓ All directors have clean corporate records',
          '✓ Government-backed entity with strong oversight',
          '✓ 42 out of 58 projects completed on time',
          '✓ No pending litigation or disputes',
        ],
      ),
      sourceUrls: [
        'https://www.ssm.com.my/company/897456-X',
        'https://www.pr1ma.my/corporate-info',
        'https://www.edgeprop.my/developer/pr1ma',
      ],
      lastUpdated: DateTime.now(),
    );
  }

  DeveloperNetwork _createBinaMegahNetwork() {
    return DeveloperNetwork(
      developerId: 'dev_bina_megah',
      companyName: 'Syarikat Bina Megah Sdn Bhd',
      registrationNumber: '201501045678 (1145678-M)',
      incorporationDate: DateTime(2015, 3, 12),
      companyStatus: 'Active (Under Scrutiny)',
      paidUpCapital: 5000000,
      businessAddress: 'No. 45, Jalan Industri 3/5, Seksyen 3, 40000 Shah Alam, Selangor',
      directors: [
        Director(
          id: 'dir_bm_001',
          name: 'Tan Sri Lim Kok Wee',
          icNumber: '******-**-4456',
          position: 'Managing Director',
          appointmentDate: DateTime(2015, 3, 12),
          riskLevel: DirectorRiskLevel.critical,
          alertMessage: 'Director linked to 5 failed/blacklisted companies',
          associations: [
            CompanyAssociation(
              companyId: 'comp_bm_001',
              companyName: 'Syarikat Bina Megah Sdn Bhd',
              registrationNumber: '1145678-M',
              status: CompanyStatus.underInvestigation,
              role: 'Managing Director',
              associationStart: DateTime(2015, 3, 12),
              sourceUrl: 'https://www.ssm.com.my/company/1145678-M',
            ),
            CompanyAssociation(
              companyId: 'comp_bm_002',
              companyName: 'Excellent Properties Sdn Bhd',
              registrationNumber: '876543-W',
              status: CompanyStatus.blacklisted,
              role: 'Director',
              associationStart: DateTime(2010, 5, 1),
              associationEnd: DateTime(2018, 12, 31),
              failureReason: 'Abandoned 3 housing projects in Selangor (2018). 450 buyers affected.',
              sourceUrl: 'https://www.kpkt.gov.my/senarai-hitam',
            ),
            CompanyAssociation(
              companyId: 'comp_bm_003',
              companyName: 'Golden Vista Development',
              registrationNumber: '654321-P',
              status: CompanyStatus.failed,
              role: 'Managing Director',
              associationStart: DateTime(2012, 1, 15),
              associationEnd: DateTime(2017, 6, 30),
              failureReason: 'Company wound up due to insolvency. RM45 million in buyer deposits unaccounted.',
              sourceUrl: 'https://www.ssm.com.my/company/654321-P',
            ),
            CompanyAssociation(
              companyId: 'comp_bm_004',
              companyName: 'Premium Homes Sdn Bhd',
              registrationNumber: '789012-K',
              status: CompanyStatus.failed,
              role: 'Director',
              associationStart: DateTime(2008, 4, 1),
              associationEnd: DateTime(2014, 9, 15),
              failureReason: 'Declared bankrupt. Taman Maju Jaya project abandoned at 30% completion.',
              sourceUrl: 'https://www.ssm.com.my/company/789012-K',
            ),
            CompanyAssociation(
              companyId: 'comp_bm_005',
              companyName: 'Sunrise Capital Holdings',
              registrationNumber: '345678-T',
              status: CompanyStatus.dissolved,
              role: 'Shareholder',
              associationStart: DateTime(2016, 2, 1),
              associationEnd: DateTime(2020, 11, 30),
              failureReason: 'Voluntarily wound up amid fraud allegations.',
              sourceUrl: 'https://www.ssm.com.my/company/345678-T',
            ),
            CompanyAssociation(
              companyId: 'comp_bm_006',
              companyName: 'Mega Build Construction',
              registrationNumber: '234567-H',
              status: CompanyStatus.blacklisted,
              role: 'Director',
              associationStart: DateTime(2013, 7, 1),
              associationEnd: DateTime(2019, 3, 31),
              failureReason: 'Blacklisted by CIDB for substandard work and safety violations.',
              sourceUrl: 'https://www.cidb.gov.my/senarai-hitam',
            ),
          ],
        ),
        Director(
          id: 'dir_bm_002',
          name: 'Encik Mohd Faizal bin Osman',
          icNumber: '******-**-7823',
          position: 'Executive Director',
          appointmentDate: DateTime(2015, 3, 12),
          riskLevel: DirectorRiskLevel.high,
          alertMessage: 'Director linked to 2 failed companies',
          associations: [
            CompanyAssociation(
              companyId: 'comp_bm_001',
              companyName: 'Syarikat Bina Megah Sdn Bhd',
              registrationNumber: '1145678-M',
              status: CompanyStatus.underInvestigation,
              role: 'Executive Director',
              associationStart: DateTime(2015, 3, 12),
              sourceUrl: 'https://www.ssm.com.my/company/1145678-M',
            ),
            CompanyAssociation(
              companyId: 'comp_bm_003',
              companyName: 'Golden Vista Development',
              registrationNumber: '654321-P',
              status: CompanyStatus.failed,
              role: 'Finance Director',
              associationStart: DateTime(2014, 1, 1),
              associationEnd: DateTime(2017, 6, 30),
              failureReason: 'Company wound up due to insolvency.',
              sourceUrl: 'https://www.ssm.com.my/company/654321-P',
            ),
            CompanyAssociation(
              companyId: 'comp_bm_007',
              companyName: 'Vista Heights Sdn Bhd',
              registrationNumber: '567890-J',
              status: CompanyStatus.failed,
              role: 'Director',
              associationStart: DateTime(2011, 8, 1),
              associationEnd: DateTime(2016, 4, 30),
              failureReason: 'Project abandoned. KPKT intervention required.',
              sourceUrl: 'https://www.ssm.com.my/company/567890-J',
            ),
          ],
        ),
        Director(
          id: 'dir_bm_003',
          name: 'Puan Wong Mei Ling',
          icNumber: '******-**-9012',
          position: 'Company Secretary',
          appointmentDate: DateTime(2015, 3, 12),
          riskLevel: DirectorRiskLevel.medium,
          associations: [
            CompanyAssociation(
              companyId: 'comp_bm_001',
              companyName: 'Syarikat Bina Megah Sdn Bhd',
              registrationNumber: '1145678-M',
              status: CompanyStatus.underInvestigation,
              role: 'Company Secretary',
              associationStart: DateTime(2015, 3, 12),
              sourceUrl: 'https://www.ssm.com.my/company/1145678-M',
            ),
          ],
        ),
      ],
      pastProjects: _getBinaMegahPastProjects(),
      riskSummary: NetworkRiskSummary(
        overallRisk: DirectorRiskLevel.critical,
        totalDirectors: 3,
        highRiskDirectors: 2,
        failedCompanyLinks: 5,
        blacklistedLinks: 2,
        aiAnalysis: 'CRITICAL ALERT: Syarikat Bina Megah\'s directors have extensive histories with failed and blacklisted entities. The Managing Director alone is linked to 5 problematic companies with combined buyer losses exceeding RM100 million. This pattern strongly suggests systemic governance issues.',
        keyFindings: [
          '⚠️ Managing Director linked to 5 failed/blacklisted companies',
          '⚠️ Executive Director associated with 2 failed entities',
          '⚠️ Combined buyer losses from associated companies: RM100M+',
          '⚠️ Current company under KPKT investigation',
          '⚠️ Class action lawsuit filed by 127 buyers (Nov 2025)',
          '⚠️ Negative cash flow reported in latest financials',
        ],
      ),
      sourceUrls: [
        'https://www.ssm.com.my/company/1145678-M',
        'https://www.kpkt.gov.my/projek-sakit/bina-megah',
        'https://www.cidb.gov.my/contractor/1145678-M',
        'https://forum.lowyat.net/topic/5234567',
      ],
      lastUpdated: DateTime.now(),
    );
  }

  DeveloperNetwork _createMegaDevelopmentNetwork() {
    return DeveloperNetwork(
      developerId: 'dev_mega',
      companyName: 'Mega Development Group Sdn Bhd',
      registrationNumber: '200801023456 (823456-D)',
      incorporationDate: DateTime(2008, 6, 15),
      companyStatus: 'Active',
      paidUpCapital: 25000000,
      businessAddress: 'Level 8, Menara Mega, Jalan Sultan Ismail, 50250 Kuala Lumpur',
      directors: [
        Director(
          id: 'dir_mega_001',
          name: 'Dato\' Chen Wei Ming',
          icNumber: '******-**-3345',
          position: 'Group Managing Director',
          appointmentDate: DateTime(2008, 6, 15),
          riskLevel: DirectorRiskLevel.medium,
          alertMessage: 'Director linked to 1 delayed project',
          associations: [
            CompanyAssociation(
              companyId: 'comp_mega_001',
              companyName: 'Mega Development Group Sdn Bhd',
              registrationNumber: '823456-D',
              status: CompanyStatus.active,
              role: 'Group Managing Director',
              associationStart: DateTime(2008, 6, 15),
              sourceUrl: 'https://www.ssm.com.my/company/823456-D',
            ),
            CompanyAssociation(
              companyId: 'comp_mega_002',
              companyName: 'City View Properties Sdn Bhd',
              registrationNumber: '912345-A',
              status: CompanyStatus.active,
              role: 'Director',
              associationStart: DateTime(2012, 3, 1),
              sourceUrl: 'https://www.ssm.com.my/company/912345-A',
            ),
          ],
        ),
        Director(
          id: 'dir_mega_002',
          name: 'Encik Tan Ah Kow',
          icNumber: '******-**-5567',
          position: 'Executive Director',
          appointmentDate: DateTime(2010, 1, 1),
          riskLevel: DirectorRiskLevel.low,
          associations: [
            CompanyAssociation(
              companyId: 'comp_mega_001',
              companyName: 'Mega Development Group Sdn Bhd',
              registrationNumber: '823456-D',
              status: CompanyStatus.active,
              role: 'Executive Director',
              associationStart: DateTime(2010, 1, 1),
              sourceUrl: 'https://www.ssm.com.my/company/823456-D',
            ),
          ],
        ),
      ],
      pastProjects: _getMegaDevelopmentPastProjects(),
      riskSummary: NetworkRiskSummary(
        overallRisk: DirectorRiskLevel.medium,
        totalDirectors: 2,
        highRiskDirectors: 0,
        failedCompanyLinks: 0,
        blacklistedLinks: 0,
        aiAnalysis: 'Mega Development Group shows a mixed track record. While no directors are linked to failed entities, the company has experienced delays in 2 out of 8 projects. Current Vista Kota project is showing signs of slowdown.',
        keyFindings: [
          '⚠️ 2 out of 8 projects experienced significant delays',
          '✓ No associations with failed or blacklisted companies',
          '⚠️ Current cash flow showing signs of strain',
          '✓ Generally positive buyer feedback on completed projects',
        ],
      ),
      sourceUrls: [
        'https://www.ssm.com.my/company/823456-D',
        'https://www.edgeprop.my/developer/mega-development',
      ],
      lastUpdated: DateTime.now(),
    );
  }

  DeveloperNetwork _createSPNBNetwork() {
    return DeveloperNetwork(
      developerId: 'dev_spnb',
      companyName: 'Syarikat Perumahan Negara Berhad (SPNB)',
      registrationNumber: '199701005678 (415638-K)',
      incorporationDate: DateTime(1997, 4, 7),
      companyStatus: 'Active',
      paidUpCapital: 1000000000,
      businessAddress: 'Level 21, Menara KPKT, Jalan Tun Razak, 50400 Kuala Lumpur',
      directors: [
        Director(
          id: 'dir_spnb_001',
          name: 'Tan Sri Dato\' Ir. Hj. Zaini bin Ujang',
          icNumber: '******-**-1122',
          position: 'Chairman',
          appointmentDate: DateTime(2020, 3, 1),
          riskLevel: DirectorRiskLevel.low,
          associations: [
            CompanyAssociation(
              companyId: 'comp_spnb_001',
              companyName: 'SPNB',
              registrationNumber: '415638-K',
              status: CompanyStatus.active,
              role: 'Chairman',
              associationStart: DateTime(2020, 3, 1),
              sourceUrl: 'https://www.ssm.com.my/company/415638-K',
            ),
          ],
        ),
        Director(
          id: 'dir_spnb_002',
          name: 'Dato\' Kamarul Rashid bin Mohd Amin',
          icNumber: '******-**-3344',
          position: 'Managing Director',
          appointmentDate: DateTime(2019, 7, 15),
          riskLevel: DirectorRiskLevel.low,
          associations: [
            CompanyAssociation(
              companyId: 'comp_spnb_001',
              companyName: 'SPNB',
              registrationNumber: '415638-K',
              status: CompanyStatus.active,
              role: 'Managing Director',
              associationStart: DateTime(2019, 7, 15),
              sourceUrl: 'https://www.ssm.com.my/company/415638-K',
            ),
          ],
        ),
      ],
      pastProjects: _getSPNBPastProjects(),
      riskSummary: NetworkRiskSummary(
        overallRisk: DirectorRiskLevel.low,
        totalDirectors: 2,
        highRiskDirectors: 0,
        failedCompanyLinks: 0,
        blacklistedLinks: 0,
        aiAnalysis: 'SPNB is a wholly government-owned company with strong oversight from KPKT. Directors are government appointees with clean corporate records. Track record shows consistent delivery of affordable housing projects.',
        keyFindings: [
          '✓ Government-owned with strong regulatory oversight',
          '✓ All directors have clean corporate records',
          '✓ 95% on-time delivery rate across 200+ projects',
          '✓ No pending litigation or disputes',
        ],
      ),
      sourceUrls: [
        'https://www.ssm.com.my/company/415638-K',
        'https://www.spnb.com.my/corporate',
        'https://www.kpkt.gov.my/agencies/spnb',
      ],
      lastUpdated: DateTime.now(),
    );
  }

  DeveloperNetwork _createDefaultNetwork(String developerName) {
    return DeveloperNetwork(
      developerId: 'dev_default',
      companyName: developerName,
      registrationNumber: 'Unknown',
      incorporationDate: DateTime(2015, 1, 1),
      companyStatus: 'Unknown',
      paidUpCapital: 0,
      businessAddress: 'Address not available',
      directors: [],
      pastProjects: [],
      riskSummary: NetworkRiskSummary(
        overallRisk: DirectorRiskLevel.medium,
        totalDirectors: 0,
        highRiskDirectors: 0,
        failedCompanyLinks: 0,
        blacklistedLinks: 0,
        aiAnalysis: 'Limited information available for this developer. Unable to perform comprehensive risk assessment.',
        keyFindings: [
          '⚠️ Company information not found in SSM database',
          '⚠️ Unable to verify director histories',
          '⚠️ Recommend manual verification before proceeding',
        ],
      ),
      sourceUrls: [],
      lastUpdated: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // PAST PROJECTS DATA
  // ─────────────────────────────────────────────────────────────────────────────

  List<PastProject> _getPR1MAPastProjects() {
    return [
      PastProject(
        id: 'pp_pr1ma_001',
        name: 'Residensi Wilayah Precinct 15',
        location: 'Putrajaya',
        type: 'Apartment',
        units: 800,
        completionDate: DateTime(2022, 6, 1),
        imageUrl: _imageService.getMarketingImage('Putrajaya', 'pp_pr1ma_001'),
        communityRating: 4.2,
        reviewCount: 156,
        reviewSnippet: 'Good quality finishing. Management responsive to complaints.',
        sourceUrl: 'https://www.pr1ma.my/projects/precinct15',
        status: PastProjectStatus.completed,
        communityPhotos: [
          CommunityPhoto(
            url: _imageService.getConstructionSiteImage('Putrajaya', 'photo_001'),
            caption: 'Current condition - well maintained',
            uploadedAt: DateTime(2025, 12, 15),
            uploaderName: 'Ahmad R.',
          ),
        ],
      ),
      PastProject(
        id: 'pp_pr1ma_002',
        name: 'Residensi Razak City',
        location: 'Kuala Lumpur',
        type: 'Apartment',
        units: 1200,
        completionDate: DateTime(2021, 3, 15),
        imageUrl: _imageService.getMarketingImage('Kuala Lumpur', 'pp_pr1ma_002'),
        communityRating: 4.0,
        reviewCount: 234,
        reviewSnippet: 'Affordable pricing. Some minor defects but developer addressed them.',
        sourceUrl: 'https://www.pr1ma.my/projects/razak-city',
        status: PastProjectStatus.completed,
        communityPhotos: [],
      ),
      PastProject(
        id: 'pp_pr1ma_003',
        name: 'Residensi Brickfields',
        location: 'Kuala Lumpur',
        type: 'Apartment',
        units: 600,
        completionDate: DateTime(2020, 9, 1),
        imageUrl: _imageService.getMarketingImage('Kuala Lumpur', 'pp_pr1ma_003'),
        communityRating: 3.8,
        reviewCount: 178,
        reviewSnippet: 'Strategic location. Parking could be better.',
        sourceUrl: 'https://www.pr1ma.my/projects/brickfields',
        status: PastProjectStatus.completed,
        communityPhotos: [],
      ),
      PastProject(
        id: 'pp_pr1ma_004',
        name: 'Residensi Alam Damai',
        location: 'Cheras, Kuala Lumpur',
        type: 'Apartment',
        units: 450,
        completionDate: DateTime(2023, 12, 1),
        imageUrl: _imageService.getMarketingImage('Kuala Lumpur', 'pp_pr1ma_004'),
        communityRating: 4.5,
        reviewCount: 89,
        reviewSnippet: 'Excellent finishing quality. Very satisfied with purchase.',
        sourceUrl: 'https://www.pr1ma.my/projects/alam-damai',
        status: PastProjectStatus.completed,
        communityPhotos: [],
      ),
    ];
  }

  List<PastProject> _getBinaMegahPastProjects() {
    return [
      PastProject(
        id: 'pp_bm_001',
        name: 'Taman Indah Permai',
        location: 'Klang, Selangor',
        type: 'Terrace House',
        units: 200,
        completionDate: DateTime(2019, 6, 1),
        imageUrl: _imageService.getMarketingImage('Klang, Selangor', 'pp_bm_001'),
        communityRating: 2.1,
        reviewCount: 67,
        reviewSnippet: 'Many defects. Developer unresponsive. Water leakage issues.',
        sourceUrl: 'https://forum.lowyat.net/topic/4567890',
        status: PastProjectStatus.problemsReported,
        communityPhotos: [
          CommunityPhoto(
            url: _imageService.getStalledSiteImage('Klang, Selangor', 'photo_bm_001'),
            caption: 'Cracked walls after 2 years',
            uploadedAt: DateTime(2021, 8, 10),
            uploaderName: 'Lee W.',
          ),
          CommunityPhoto(
            url: _imageService.getStalledSiteImage('Klang, Selangor', 'photo_bm_002'),
            caption: 'Water damage in common areas',
            uploadedAt: DateTime(2022, 1, 5),
            uploaderName: 'Farah Z.',
          ),
        ],
      ),
      PastProject(
        id: 'pp_bm_002',
        name: 'Vista Heights Shah Alam',
        location: 'Shah Alam, Selangor',
        type: 'Apartment',
        units: 350,
        completionDate: DateTime(2017, 12, 1),
        imageUrl: _imageService.getMarketingImage('Shah Alam, Selangor', 'pp_bm_002'),
        communityRating: 1.5,
        reviewCount: 145,
        reviewSnippet: 'AVOID! Project was delayed 3 years. Poor build quality.',
        sourceUrl: 'https://www.edgeprop.my/project/vista-heights-reviews',
        status: PastProjectStatus.delayed,
        communityPhotos: [
          CommunityPhoto(
            url: _imageService.getStalledSiteImage('Shah Alam, Selangor', 'photo_bm_003'),
            caption: 'Peeling paint after 1 year',
            uploadedAt: DateTime(2019, 3, 20),
            uploaderName: 'Kumar S.',
          ),
        ],
      ),
      PastProject(
        id: 'pp_bm_003',
        name: 'Taman Seri Bayu',
        location: 'Rawang, Selangor',
        type: 'Terrace House',
        units: 150,
        completionDate: DateTime(2016, 3, 1),
        imageUrl: _imageService.getMarketingImage('Rawang, Selangor', 'pp_bm_003'),
        communityRating: 0,
        reviewCount: 0,
        reviewSnippet: 'PROJECT ABANDONED at 45% completion. Buyers seeking legal action.',
        sourceUrl: 'https://www.kpkt.gov.my/projek-terbengkalai/seri-bayu',
        status: PastProjectStatus.abandoned,
        communityPhotos: [
          CommunityPhoto(
            url: _imageService.getStalledSiteImage('Rawang, Selangor', 'photo_bm_004'),
            caption: 'Abandoned site - overgrown vegetation',
            uploadedAt: DateTime(2020, 5, 12),
            uploaderName: 'Buyer Group Rep',
          ),
        ],
      ),
    ];
  }

  List<PastProject> _getMegaDevelopmentPastProjects() {
    return [
      PastProject(
        id: 'pp_mega_001',
        name: 'The Horizon KLCC',
        location: 'Kuala Lumpur',
        type: 'Condominium',
        units: 400,
        completionDate: DateTime(2020, 8, 1),
        imageUrl: _imageService.getMarketingImage('Kuala Lumpur', 'pp_mega_001'),
        communityRating: 3.8,
        reviewCount: 112,
        reviewSnippet: 'Good location and facilities. Some delays in completion.',
        sourceUrl: 'https://www.edgeprop.my/project/horizon-klcc',
        status: PastProjectStatus.delayed,
        communityPhotos: [],
      ),
      PastProject(
        id: 'pp_mega_002',
        name: 'Mega Residence Bangsar',
        location: 'Bangsar, Kuala Lumpur',
        type: 'Condominium',
        units: 250,
        completionDate: DateTime(2018, 12, 1),
        imageUrl: _imageService.getMarketingImage('Bangsar, Kuala Lumpur', 'pp_mega_002'),
        communityRating: 4.1,
        reviewCount: 89,
        reviewSnippet: 'Premium quality. Worth the price.',
        sourceUrl: 'https://www.propertyguru.com.my/project/mega-residence',
        status: PastProjectStatus.completed,
        communityPhotos: [],
      ),
    ];
  }

  List<PastProject> _getSPNBPastProjects() {
    return [
      PastProject(
        id: 'pp_spnb_001',
        name: 'Rumah Mampu Milik Johor',
        location: 'Johor Bahru, Johor',
        type: 'Apartment',
        units: 1000,
        completionDate: DateTime(2023, 3, 1),
        imageUrl: _imageService.getMarketingImage('Johor Bahru, Johor', 'pp_spnb_001'),
        communityRating: 4.3,
        reviewCount: 234,
        reviewSnippet: 'Affordable and good quality. Government projects improving.',
        sourceUrl: 'https://www.spnb.com.my/projects/rmm-johor',
        status: PastProjectStatus.completed,
        communityPhotos: [],
      ),
      PastProject(
        id: 'pp_spnb_002',
        name: 'PPR Lembah Subang 2',
        location: 'Subang Jaya, Selangor',
        type: 'Apartment',
        units: 800,
        completionDate: DateTime(2022, 6, 1),
        imageUrl: _imageService.getMarketingImage('Subang Jaya, Selangor', 'pp_spnb_002'),
        communityRating: 4.0,
        reviewCount: 178,
        reviewSnippet: 'Good for the price. Basic but functional.',
        sourceUrl: 'https://www.spnb.com.my/projects/ppr-subang',
        status: PastProjectStatus.completed,
        communityPhotos: [],
      ),
    ];
  }

  List<CompanyAssociation> _getMockDirectorAssociations(String directorName) {
    return [];
  }

  List<PastProject> _getMockPastProjects(String developerName) {
    return [];
  }
}
