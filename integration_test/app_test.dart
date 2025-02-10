import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meteo_connect/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('add and remove city flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify initial empty state
      expect(find.text('No cities added yet. Tap + to add a city.'), findsOneWidget);

      // Tap FAB to open bottom sheet
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter city name
      await tester.enterText(find.byType(TextField), 'London');
      await tester.pumpAndSettle();

      // Wait for search results
      await tester.pump(const Duration(seconds: 2));

      // Tap first result
      await tester.tap(find.text('London').first);
      await tester.pumpAndSettle();

      // Verify city was added
      expect(find.text('London'), findsOneWidget);

      // Swipe to delete
      await tester.drag(find.text('London'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // Verify city was removed
      expect(find.text('No cities added yet. Tap + to add a city.'), findsOneWidget);
    });

    testWidgets('theme switching', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Toggle theme
      await tester.tap(find.text('Dark Mode').last);
      await tester.pumpAndSettle();

      // Update the MaterialApp type check
      final materialApp = tester.firstWidget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.dark));
    });
  });
} 