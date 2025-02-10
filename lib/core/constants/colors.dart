import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color background = Color(0xFFF5F5F5);
  static const Color error = Color(0xFFD32F2F);
  static const Color text = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color dateTimeColorLight = Colors.blue;
  static const Color sunsetColor = Colors.orange;
  static const Color sunriseColor = Colors.yellow;

  static Color getBackgroundColor(
      String weatherDescription, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final weather = weatherDescription.toLowerCase();

    switch (weather) {
      case 'clear':
        return isDarkMode ? Colors.black : const Color(0xFFC4E2FE);
      case 'clouds':
        return isDarkMode
            ? Colors.black
            : const Color.fromARGB(255, 187, 197, 204);

      case 'rain':
      case 'drizzle':
      case 'thunder':
      case 'atmosphere':
        return isDarkMode
            ? Colors.black
            : const Color.fromARGB(255, 142, 197, 237);

      case 'snow':
        return isDarkMode ? Colors.black : Colors.blue.withOpacity(0.1);
      default:
        return Colors.white; // Default background color
    }
  }
}
