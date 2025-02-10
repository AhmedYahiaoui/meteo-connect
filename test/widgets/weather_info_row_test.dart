import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_connect/features/home/widgets/weather_info_row.dart';

void main() {
  group('WeatherInfoRow Widget Test', () {
    testWidgets('should display correct weather information',
        (WidgetTester tester) async {
      // Arrange
      const humidity = 75.0;
      const windSpeed = 5.0;
      const pressure = 1013.0;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherInfoRow(
              humidity: humidity,
              windSpeed: windSpeed,
              pressure: pressure,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('5.0 m/s'), findsOneWidget);
      expect(find.text('1013.0 hPa'), findsOneWidget);
      expect(find.text('Humidity'), findsOneWidget);
      expect(find.text('Wind'), findsOneWidget);
      expect(find.text('Pressure'), findsOneWidget);
    });
  });
}
