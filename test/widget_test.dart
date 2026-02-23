import 'package:flutter_test/flutter_test.dart';
import 'package:projekwatch/main.dart';

void main() {
  testWidgets('App renders main page', (WidgetTester tester) async {
    await tester.pumpWidget(const ProjekWatchApp());
    expect(find.text('ProjekWatch'), findsOneWidget);
  });
}
