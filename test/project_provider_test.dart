import 'package:flutter_test/flutter_test.dart';
import 'package:projekwatch/providers/project_provider.dart';
import 'package:projekwatch/models/project_model.dart';
import 'package:projekwatch/models/checkin_model.dart';
import 'package:projekwatch/config/app_config.dart';

void main() {
  late ProjectProvider provider;

  setUp(() {
    // Use mock data mode for all tests.
    provider = ProjectProvider(dataMode: DataMode.mock);
  });

  group('ProjectProvider — Initialisation', () {
    test('loads mock projects on construction', () {
      expect(provider.allProjects, isNotEmpty);
    });

    test('filteredProjects returns all projects when no filters set', () {
      expect(provider.filteredProjects.length, provider.allProjects.length);
    });

    test('searchQuery is initially empty', () {
      expect(provider.searchQuery, isEmpty);
    });

    test('categoryFilter is initially null', () {
      expect(provider.categoryFilter, isNull);
    });

    test('statusFilter is initially null', () {
      expect(provider.statusFilter, isNull);
    });
  });

  group('ProjectProvider — Filters', () {
    test('setSearchQuery filters by project name', () {
      // Pick the first project name.
      final firstName = provider.allProjects.first.name;
      provider.setSearchQuery(firstName);
      expect(provider.filteredProjects, isNotEmpty);
      for (final p in provider.filteredProjects) {
        expect(
          p.name.toLowerCase().contains(firstName.toLowerCase()) ||
              p.location.toLowerCase().contains(firstName.toLowerCase()),
          isTrue,
        );
      }
    });

    test('setSearchQuery with gibberish returns no results', () {
      provider.setSearchQuery('zzxxyy_no_match_999');
      expect(provider.filteredProjects, isEmpty);
    });

    test('setCategoryFilter filters by category', () {
      for (final cat in ProjectCategory.values) {
        provider.setCategoryFilter(cat);
        for (final p in provider.filteredProjects) {
          expect(p.category, cat);
        }
      }
    });

    test('setStatusFilter filters by status', () {
      for (final status in ProjectStatus.values) {
        provider.setStatusFilter(status);
        for (final p in provider.filteredProjects) {
          expect(p.status, status);
        }
      }
    });

    test('clearFilters resets all filters', () {
      provider.setSearchQuery('test');
      provider.setCategoryFilter(ProjectCategory.road);
      provider.setStatusFilter(ProjectStatus.stalled);

      provider.clearFilters();

      expect(provider.searchQuery, isEmpty);
      expect(provider.categoryFilter, isNull);
      expect(provider.statusFilter, isNull);
      expect(provider.filteredProjects.length, provider.allProjects.length);
    });
  });

  group('ProjectProvider — Section Getters', () {
    test('activeProjects returns only active projects', () {
      for (final p in provider.activeProjects) {
        expect(p.status, ProjectStatus.active);
      }
    });

    test('stalledProjects returns only stalled projects', () {
      for (final p in provider.stalledProjects) {
        expect(p.status, ProjectStatus.stalled);
      }
    });

    test('publicProjects returns only public projects', () {
      for (final p in provider.publicProjects) {
        expect(p.isPublic, isTrue);
      }
    });

    test('privateProjects returns only private projects', () {
      for (final p in provider.privateProjects) {
        expect(p.isPublic, isFalse);
      }
    });

    test('section getters cover all projects', () {
      final publicCount = provider.publicProjects.length;
      final privateCount = provider.privateProjects.length;
      expect(publicCount + privateCount, provider.allProjects.length);
    });
  });

  group('ProjectProvider — getProjectById', () {
    test('returns correct project by ID', () {
      final expected = provider.allProjects.first;
      final result = provider.getProjectById(expected.id);
      expect(result.id, expected.id);
      expect(result.name, expected.name);
    });

    test('throws on unknown ID', () {
      expect(
        () => provider.getProjectById('nonexistent-id-xyz'),
        throwsStateError,
      );
    });
  });

  group('ProjectProvider — addCheckIn', () {
    test('adds check-in to project optimistically', () {
      final project = provider.allProjects.first;
      final before = project.checkIns.length;

      final checkIn = CheckIn(
        id: 'test-ci-1',
        projectId: project.id,
        status: ProjectStatus.stalled,
        note: 'No workers on site today.',
        timestamp: DateTime.now(),
        reporterName: 'Test User',
      );

      provider.addCheckIn(project.id, checkIn);

      expect(project.checkIns.length, before + 1);
      expect(project.checkIns.first.id, 'test-ci-1');
    });

    test('updates project status to match new check-in', () {
      final project = provider.allProjects.first;

      final checkIn = CheckIn(
        id: 'test-ci-2',
        projectId: project.id,
        status: ProjectStatus.stalled,
        note: 'Everything stopped.',
        timestamp: DateTime.now(),
        reporterName: 'Test User',
      );

      provider.addCheckIn(project.id, checkIn);
      expect(project.status, ProjectStatus.stalled);
    });

    test('recalculates confidence after check-in', () {
      final project = provider.allProjects.first;
      // Clear existing mock check-ins for a clean calculation.
      project.checkIns.clear();

      // Add 3 identical-status check-ins => should set confidence to high.
      for (int i = 0; i < 3; i++) {
        provider.addCheckIn(
          project.id,
          CheckIn(
            id: 'conf-ci-$i',
            projectId: project.id,
            status: ProjectStatus.active,
            note: 'Still active ($i)',
            timestamp: DateTime.now(),
            reporterName: 'Tester',
          ),
        );
      }

      expect(project.confidence, ConfidenceLevel.high);
    });

    test('mixed statuses lower confidence', () {
      final project = provider.allProjects.first;
      // Clear existing check-ins for a fresh calculation.
      project.checkIns.clear();

      provider.addCheckIn(
        project.id,
        CheckIn(
          id: 'mix-1',
          projectId: project.id,
          status: ProjectStatus.active,
          note: 'Active',
          timestamp: DateTime.now(),
          reporterName: 'T',
        ),
      );
      provider.addCheckIn(
        project.id,
        CheckIn(
          id: 'mix-2',
          projectId: project.id,
          status: ProjectStatus.slowing,
          note: 'Slowing',
          timestamp: DateTime.now(),
          reporterName: 'T',
        ),
      );
      provider.addCheckIn(
        project.id,
        CheckIn(
          id: 'mix-3',
          projectId: project.id,
          status: ProjectStatus.stalled,
          note: 'Stalled',
          timestamp: DateTime.now(),
          reporterName: 'T',
        ),
      );

      expect(project.confidence, ConfidenceLevel.low);
    });
  });
}
