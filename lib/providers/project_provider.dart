import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/checkin_model.dart';
import '../models/developer_enrichment_model.dart';
import '../config/app_config.dart';
import '../mock_data.dart';
import '../repositories/project_repository.dart';
import '../repositories/checkin_repository.dart';

class ProjectProvider extends ChangeNotifier {
  List<Project> _projects = [];

  String _searchQuery = '';
  ProjectCategory? _categoryFilter;
  ProjectStatus? _statusFilter;

  final DataMode _dataMode;
  StreamSubscription? _projectsSub;
  // Lazily initialised — only created when dataMode == firebase.
  late final ProjectRepository _projectRepo;
  late final CheckinRepository _checkinRepo;

  ProjectProvider({DataMode? dataMode})
      : _dataMode = dataMode ?? AppConfig.runtimeDataMode {
    if (_dataMode == DataMode.firebase) {
      _projectRepo = ProjectRepository();
      _checkinRepo = CheckinRepository();
      _loadFromFirestore();
    } else {
      _projects = List.from(mockProjects);
    }
  }

  // ── Firestore loading ──────────────────────────────────────

  void _loadFromFirestore() {
    _projectsSub = _projectRepo.streamProjects().listen(
      (projects) {
        _projects = projects;
        // Load check-ins for each project
        for (final project in _projects) {
          _loadCheckInsForProject(project);
        }
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error streaming projects: $e');
        // Fallback to mock data if Firestore fails
        _projects = List.from(mockProjects);
        notifyListeners();
      },
    );
  }

  void _loadCheckInsForProject(Project project) {
    _checkinRepo.streamCheckIns(project.id).listen(
      (checkIns) {
        project.checkIns.clear();
        project.checkIns.addAll(checkIns);
        _recalculateConfidence(project);
        notifyListeners();
      },
    );
  }

  // ── Filters ──────────────────────────────────────────────

  String get searchQuery => _searchQuery;
  ProjectCategory? get categoryFilter => _categoryFilter;
  ProjectStatus? get statusFilter => _statusFilter;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(ProjectCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setStatusFilter(ProjectStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _categoryFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  // ── Filtered list ──────────────────────────────────────────

  List<Project> get filteredProjects {
    return _projects.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!p.name.toLowerCase().contains(q) &&
            !p.location.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_categoryFilter != null && p.category != _categoryFilter) {
        return false;
      }
      if (_statusFilter != null && p.status != _statusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  // ── Section-based getters ──────────────────────────────────

  List<Project> get activeProjects =>
      _projects.where((p) => p.status == ProjectStatus.active).toList();

  List<Project> get stalledProjects =>
      _projects.where((p) => p.status == ProjectStatus.stalled).toList();

  List<Project> get publicProjects =>
      _projects.where((p) => p.isPublic).toList();

  List<Project> get privateProjects =>
      _projects.where((p) => !p.isPublic).toList();

  // ── All projects (for map) ─────────────────────────────────

  List<Project> get allProjects => List.unmodifiable(_projects);

  // ── Single project ─────────────────────────────────────────

  Project getProjectById(String id) =>
      _projects.firstWhere((p) => p.id == id);

  // ── Check-in management ────────────────────────────────────

  void addCheckIn(String projectId, CheckIn checkIn) {
    final project = _projects.firstWhere((p) => p.id == projectId);

    // Optimistic local update
    project.checkIns.insert(0, checkIn);
    project.status = checkIn.status;
    _recalculateConfidence(project);
    notifyListeners();

    // Persist to Firestore if in firebase mode
    if (_dataMode == DataMode.firebase) {
      _checkinRepo.addCheckIn(projectId, checkIn).then((_) {
        // Update project status in Firestore
        _projectRepo.updateProjectStatus(
            projectId, project.status, project.confidence);
      }).catchError((e) {
        debugPrint('Error persisting check-in: $e');
      });
    }
  }

  void _recalculateConfidence(Project project) {
    final recentCheckIns = project.checkIns.take(5).toList();
    if (recentCheckIns.isEmpty) {
      project.confidence = ConfidenceLevel.low;
      return;
    }

    if (recentCheckIns.length >= 3) {
      final statuses = recentCheckIns.map((c) => c.status).toSet();
      if (statuses.length == 1) {
        project.confidence = ConfidenceLevel.high;
      } else if (statuses.length == 2) {
        project.confidence = ConfidenceLevel.medium;
      } else {
        project.confidence = ConfidenceLevel.low;
      }
    } else {
      project.confidence = ConfidenceLevel.medium;
    }

    final now = DateTime.now();
    final latestCheckIn = recentCheckIns.first.timestamp;
    final daysSinceLastCheckIn = now.difference(latestCheckIn).inDays;
    if (daysSinceLastCheckIn > 60) {
      project.confidence = ConfidenceLevel.low;
    }
  }

  // ── Developer Enrichment ─────────────────────────────────────
  //
  // Limits & Compliance:
  // • Link-first approach: generates search URLs only, no scraping.
  // • Respects robots.txt / ToS — no login, CAPTCHA, or paywall bypass.
  // • No copyrighted article storage — only title + canonical URL.
  // • Every source includes: url (sourceUrl), type (sourceType),
  //   fetchedAt, confidence (confidenceScore).

  /// Enriches developer background data for the given project.
  /// Uses a 7-day cache — will not refetch unless [forceRefresh] is true.
  Future<void> enrichDeveloperForProject(
    String projectId, {
    bool forceRefresh = false,
  }) async {
    final project = _projects.firstWhere(
      (p) => p.id == projectId,
      orElse: () => throw StateError('Project $projectId not found'),
    );

    final devName = project.agencyOrDeveloper;

    // No developer name → mark limited and exit gracefully.
    if (devName.isEmpty) {
      debugPrint('[DevEnrich] No developer name for project $projectId');
      project.developerEnrichment = DeveloperEnrichment(
        status: EnrichmentStatus.limited,
        lastUpdated: DateTime.now(),
        summary: 'No developer/agency name available.',
        riskFlags: ['No developer information on record'],
      );
      notifyListeners();
      return;
    }

    // 7-day cache check.
    final existing = project.developerEnrichment;
    if (!forceRefresh &&
        existing != null &&
        existing.lastUpdated != null &&
        DateTime.now().difference(existing.lastUpdated!).inDays < 7 &&
        existing.status != EnrichmentStatus.error) {
      debugPrint('[DevEnrich] Cache still valid for "$devName" — skipping.');
      return;
    }

    // Set loading state.
    project.developerEnrichment = DeveloperEnrichment(
      status: EnrichmentStatus.loading,
      lastUpdated: existing?.lastUpdated,
      summary: existing?.summary ?? '',
      riskFlags: existing?.riskFlags,
      sources: existing?.sources,
    );
    notifyListeners();

    try {
      // Simulate async work (network delay in a real implementation).
      await Future.delayed(const Duration(milliseconds: 300));

      final now = DateTime.now();
      final encodedName = Uri.encodeComponent(devName);
      final sources = <DeveloperSourceItem>[];

      // 1. Official website (if available).
      if (project.developerWebsite != null &&
          project.developerWebsite!.isNotEmpty) {
        sources.add(DeveloperSourceItem(
          type: SourceType.official,
          title: '$devName — Official Website',
          url: project.developerWebsite!,
          confidence: 0.9,
          fetchedAt: now,
          notes: 'Developer-provided URL.',
        ));
      }

      // 2. Google search for the developer.
      sources.add(DeveloperSourceItem(
        type: SourceType.official,
        title: 'Google Search: $devName',
        url: 'https://www.google.com/search?q=$encodedName+Malaysia+developer',
        confidence: 0.5,
        fetchedAt: now,
        notes: 'Generated search link — manual review recommended.',
      ));

      // 3. SSM (Companies Commission of Malaysia) search.
      sources.add(DeveloperSourceItem(
        type: SourceType.filing,
        title: 'SSM Company Search: $devName',
        url: 'https://www.ssm.com.my/Pages/e-Search.aspx',
        confidence: 0.6,
        fetchedAt: now,
        notes: 'Search SSM portal for company filings. Manual review required.',
      ));

      // 4. Google News search.
      sources.add(DeveloperSourceItem(
        type: SourceType.news,
        title: 'Recent News: $devName',
        url:
            'https://news.google.com/search?q=$encodedName+Malaysia&hl=en-MY',
        confidence: 0.5,
        sentiment: SourceSentiment.neu,
        fetchedAt: now,
        notes: 'Google News results — review for positive/negative coverage.',
      ));

      // 5. Google search for quarterly/annual reports.
      sources.add(DeveloperSourceItem(
        type: SourceType.filing,
        title: 'Public Reports: $devName',
        url:
            'https://www.google.com/search?q=$encodedName+annual+report+filetype:pdf',
        confidence: 0.4,
        fetchedAt: now,
        notes: 'Search for publicly available PDF reports.',
      ));

      // 6. Public review signals (Google Reviews).
      sources.add(DeveloperSourceItem(
        type: SourceType.review,
        title: 'Google Reviews: $devName',
        url: 'https://www.google.com/search?q=$encodedName+reviews',
        confidence: 0.4,
        sentiment: SourceSentiment.neu,
        fetchedAt: now,
        notes: 'Public search link — no ToS-restricted scraping.',
      ));

      // ── Generate risk flags from project heuristics ──
      final riskFlags = <String>[];

      if (project.status == ProjectStatus.stalled) {
        riskFlags.add(
            '⚠️ Project currently stalled — investigate developer capacity');
      }

      if (project.expectedCompletion != null &&
          project.expectedCompletion!.isBefore(now)) {
        final overdueDays =
            now.difference(project.expectedCompletion!).inDays;
        riskFlags.add(
            '⏰ Project overdue by $overdueDays days — review timeline commitment');
      }

      final daysSinceActivity = now.difference(project.lastActivity).inDays;
      if (daysSinceActivity > 30) {
        riskFlags.add(
            '📅 No activity for $daysSinceActivity days — consider reaching out');
      }

      if (project.confidence == ConfidenceLevel.low) {
        riskFlags.add(
            '🔍 Low verification confidence — more community check-ins needed');
      }

      if (project.developerWebsite == null ||
          project.developerWebsite!.isEmpty) {
        riskFlags.add(
            '🌐 No official website on file — limited online presence data');
      }

      final summary = riskFlags.isEmpty
          ? '$devName — no significant risk flags detected from available data.'
          : '$devName — ${riskFlags.length} risk flag(s) identified. Review sources for details.';

      project.developerEnrichment = DeveloperEnrichment(
        status: riskFlags.isEmpty
            ? EnrichmentStatus.ready
            : EnrichmentStatus.limited,
        lastUpdated: now,
        summary: summary,
        riskFlags: riskFlags,
        sources: sources,
      );

      debugPrint(
          '[DevEnrich] Enrichment complete for "$devName" — '
          '${sources.length} sources, ${riskFlags.length} risk flags.');
    } catch (e) {
      debugPrint('[DevEnrich] Error enriching "$devName": $e');
      project.developerEnrichment = DeveloperEnrichment(
        status: EnrichmentStatus.error,
        lastUpdated: DateTime.now(),
        summary: 'Failed to generate enrichment data: $e',
        riskFlags: ['❌ Enrichment failed — try again later'],
      );
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _projectsSub?.cancel();
    super.dispose();
  }
}
