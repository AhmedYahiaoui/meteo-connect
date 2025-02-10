import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_connect/features/city_details/widgets/curved_line_chart_widget.dart';

void main() {
  group('CurvedLineChartWidget Test', () {
    testWidgets('should render with 5 temperature values',
        (WidgetTester tester) async {
      // Arrange
      final temperatures = [20.0, 22.0, 25.0, 23.0, 21.0];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: CurvedLineChartWidget(
                temperatures: temperatures,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets(
        'should throw assertion error with wrong number of temperatures',
        (WidgetTester tester) async {
      // Arrange
      final temperatures = [20.0, 22.0, 25.0]; // Only 3 values

      // Assert
      expect(
        () async => await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CurvedLineChartWidget(
                temperatures: temperatures,
              ),
            ),
          ),
        ),
        throwsAssertionError,
      );
    });
  });
}
