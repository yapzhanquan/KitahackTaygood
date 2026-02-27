import 'package:flutter_test/flutter_test.dart';
import 'package:projekwatch/models/project_model.dart';
import 'package:projekwatch/models/checkin_model.dart';
import 'package:projekwatch/models/user_model.dart';

void main() {
  group('Project model serialization', () {
    test('toJson and fromJson round-trip', () {
      final original = Project(
        id: 'p1',
        name: 'Test Road',
        category: ProjectCategory.road,
        status: ProjectStatus.active,
        confidence: ConfidenceLevel.high,
        location: 'Jalan Test, KL',
        description: 'A test project.',
        imageUrl: '',
        expectedCompletion: DateTime(2026, 12, 31),
        agencyOrDeveloper: 'JKR',
        lastActivity: DateTime(2026, 1, 15),
        lastVerified: DateTime(2026, 1, 10),
        checkIns: [],
        latitude: 3.139,
        longitude: 101.6869,
        isPublic: true,
      );

      final json = original.toJson();
      final restored = Project.fromJson(json, docId: 'p1');

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.category, original.category);
      expect(restored.status, original.status);
      expect(restored.confidence, original.confidence);
      expect(restored.location, original.location);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.isPublic, original.isPublic);
      expect(restored.agencyOrDeveloper, original.agencyOrDeveloper);
    });

    test('fromJson handles missing fields gracefully', () {
      final project = Project.fromJson({});
      expect(project.id, '');
      expect(project.name, '');
      expect(project.category, ProjectCategory.housing); // default
      expect(project.status, ProjectStatus.unverified); // default
      expect(project.confidence, ConfidenceLevel.low); // default
      expect(project.isPublic, true); // default
    });
  });

  group('CheckIn model serialization', () {
    test('toJson and fromJson round-trip', () {
      final original = CheckIn(
        id: 'ci1',
        projectId: 'p1',
        status: ProjectStatus.slowing,
        note: 'Workers present but minimal activity.',
        photoUrl: 'https://example.com/photo.jpg',
        photoUrls: ['https://example.com/photo.jpg'],
        timestamp: DateTime(2026, 2, 20),
        reporterName: 'Ahmad',
        userId: 'u1',
      );

      final json = original.toJson();
      final restored = CheckIn.fromJson(json, docId: 'ci1');

      expect(restored.id, original.id);
      expect(restored.projectId, original.projectId);
      expect(restored.status, original.status);
      expect(restored.note, original.note);
      expect(restored.photoUrl, original.photoUrl);
      expect(restored.photoUrls, original.photoUrls);
      expect(restored.reporterName, original.reporterName);
      expect(restored.userId, original.userId);
    });

    test('fromJson handles missing fields gracefully', () {
      final ci = CheckIn.fromJson({});
      expect(ci.id, '');
      expect(ci.projectId, '');
      expect(ci.status, ProjectStatus.unverified);
      expect(ci.note, '');
      expect(ci.photoUrl, isNull);
      expect(ci.photoUrls, isEmpty);
      expect(ci.reporterName, 'Anonymous');
    });
  });

  group('AppUser model serialization', () {
    test('toJson and fromJson round-trip', () {
      final original = AppUser(
        id: 'u1',
        name: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
        email: 'test@example.com',
        role: 'mod',
        contributionCount: 42,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = original.toJson();
      final restored = AppUser.fromJson(json, docId: 'u1');

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.avatarUrl, original.avatarUrl);
      expect(restored.email, original.email);
      expect(restored.role, original.role);
      expect(restored.contributionCount, original.contributionCount);
    });

    test('fromJson handles missing fields gracefully', () {
      final user = AppUser.fromJson({});
      expect(user.name, '');
      expect(user.role, 'user');
      expect(user.contributionCount, 0);
    });
  });
}
