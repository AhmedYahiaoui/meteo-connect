import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppStrings {
  // API

  // static const String baseWeatherUrl = 'https://api.openweathermap.org/data/2.5'; // 2.5 version
  static String get baseWeatherUrl => dotenv.env['BASE_WEATHER_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
  static String get baseGeoUrl => dotenv.env['BASE_GEO_URL'] ?? '';

  // App
  static const String appName = 'MétéoConnect';
  static const String errorMessage = 'Something went wrong';
  static const String noInternetConnection = 'No internet connection';

  // Screens
  static const String home = 'Home';
  static const String profile = 'Profile';
  static const String addCity = 'Add City';

  // Weather
  static const String temperature = 'Temperature';
  static const String humidity = 'Humidity';
  static const String windSpeed = 'Wind Speed';
}
