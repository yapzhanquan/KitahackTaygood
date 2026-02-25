import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:projekwatch/providers/project_provider.dart';
import 'package:projekwatch/providers/auth_provider.dart' as app_auth;
import 'package:projekwatch/config/app_config.dart';
import 'package:projekwatch/screens/main_page.dart';

void main() {
  // Helper to wrap a widget with the required providers.
  Widget buildTestApp(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(dataMode: DataMode.mock),
        ),
        ChangeNotifierProvider(
          create: (_) => app_auth.AuthProvider(),
        ),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('MainPage Widget Tests', () {
    testWidgets('renders app bar with ProjekWatch title', (tester) async {
      await tester.pumpWidget(buildTestApp(const MainPage()));
      expect(find.text('ProjekWatch'), findsOneWidget);
    });

    testWidgets('renders three tab buttons', (tester) async {
      await tester.pumpWidget(buildTestApp(const MainPage()));
      expect(find.text('Projects'), findsOneWidget);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Insights'), findsOneWidget);
    });

    testWidgets('renders Contribute button', (tester) async {
      await tester.pumpWidget(buildTestApp(const MainPage()));
      expect(find.text('Contribute'), findsOneWidget);
    });

    testWidgets('renders project section headers on Projects tab',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const MainPage()));
      // Default tab is Projects — should show section headers.
      expect(find.text('Active Projects Near You'), findsOneWidget);
      expect(find.text('Recently Flagged as Stalled'), findsOneWidget);
    });

    testWidgets('switching to Categories tab shows category sections',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const MainPage()));
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
      // Category view shows counts in section titles.
      expect(find.textContaining('Housing'), findsWidgets);
      expect(find.textContaining('Road'), findsWidgets);
    });

    testWidgets('switching to Insights tab shows insights view',
        (tester) async {
      await tester.pumpWidget(buildTestApp(const MainPage()));
      await tester.tap(find.text('Insights'));
      await tester.pumpAndSettle();
      expect(find.text('Project Insights'), findsOneWidget);
      expect(find.text('Status Breakdown'), findsOneWidget);
      expect(find.text('Confidence Levels'), findsOneWidget);
    });
  });
}
