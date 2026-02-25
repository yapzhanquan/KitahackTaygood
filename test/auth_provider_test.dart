import 'package:flutter_test/flutter_test.dart';
import 'package:projekwatch/config/app_config.dart';
import 'package:projekwatch/providers/auth_provider.dart';

void main() {
  group('AuthProvider (mock mode)', () {
    late AuthProvider provider;

    setUp(() {
      provider = AuthProvider(dataMode: DataMode.mock);
    });

    test('signInWithGoogle creates a demo user', () async {
      expect(provider.isSignedIn, isFalse);

      final success = await provider.signInWithGoogle();

      expect(success, isTrue);
      expect(provider.isSignedIn, isTrue);
      expect(provider.currentUser, isNotNull);
      expect(provider.currentUser!.id, 'mock-user');
    });

    test('toggleBookmark updates local bookmark state', () async {
      await provider.signInWithGoogle();
      const projectId = 'project-123';

      expect(provider.isBookmarked(projectId), isFalse);

      await provider.toggleBookmark(projectId);
      expect(provider.isBookmarked(projectId), isTrue);

      await provider.toggleBookmark(projectId);
      expect(provider.isBookmarked(projectId), isFalse);
    });

    test('signOut clears local auth and bookmarks', () async {
      await provider.signInWithGoogle();
      await provider.toggleBookmark('project-1');
      expect(provider.isSignedIn, isTrue);
      expect(provider.bookmarks, isNotEmpty);

      await provider.signOut();

      expect(provider.isSignedIn, isFalse);
      expect(provider.currentUser, isNull);
      expect(provider.bookmarks, isEmpty);
    });
  });
}
