class AppStrings {
  // API

  // static const String baseWeatherUrl = 'https://api.openweathermap.org/data/2.5'; // 2.5 version
  static const String baseWeatherUrl =
      'https://api.openweathermap.org/data/3.0/onecall?';
  static const String apiKey = 'a3838dc0ac4bbc9159c412714c98e6e8';
  static const String baseGeoUrl = 'http://api.openweathermap.org/geo/1.0';

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
