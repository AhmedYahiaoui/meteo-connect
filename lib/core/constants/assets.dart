import 'package:timezone/timezone.dart';

class AppAssets {
  // Paths
  static const actionPath = 'assets/actions/';
  static const animationPath = 'assets/animations/';
  static const imagePath = 'assets/images/';

  // Lotties
  static const String clearLight = '${animationPath}clear_light.json';
  static const String clearDark = '${animationPath}clear_dark.json';
  static const String cloudyLight = '${animationPath}cloudy_light.json';
  static const String cloudyDark = '${animationPath}cloudy_dark.json';
  static const String rainyLight = '${animationPath}rainy_light.json';
  static const String rainyDark = '${animationPath}rainy_dark.json';
  static const String snowLight = '${animationPath}snow_light.json';
  static const String snowDark = '${animationPath}snow_dark.json';
  static const String thunder = '${animationPath}thunder.json';
  static const String atmosphere = '${animationPath}atmosphere.json';
  static const String loader = '${animationPath}loader.json';

  // Rive - Weather
  static const String rain = '${animationPath}rive/rain.riv';
  // static const String rain = '${animationPath}rive/sky_rain.riv';
  static const String snow = '${animationPath}rive/snow.riv';
  static const String cloud = '${animationPath}rive/cloud.riv';

  // Rive - Actions
  static const String success = '${actionPath}success.riv';
  static const String failure = '${actionPath}failure.riv';

  // Images
  static const String sunriseBackground = '${imagePath}sunrise_bg.riv';
  static const String midDayBackground = '${imagePath}midday_bg.riv';
  static const String sunsetBackground = '${imagePath}sunset_bg.riv';
  static const String nightBackground = '${imagePath}night_bg.riv';

  // Helper method to get weather animation
  static String getWeatherAnimation(String condition, TZDateTime time,
      {TZDateTime? sunset, TZDateTime? sunrise}) {
    bool isAfterNoon = false;

    if (sunset != null && sunrise != null) {
      isAfterNoon = time.hour >= sunset.hour || time.hour <= sunrise.hour;
    } else {
      isAfterNoon = time.hour >= 18 || time.hour <= 6;
    }

    switch (condition.toLowerCase()) {
      case 'clear':
        return isAfterNoon ? AppAssets.clearDark : AppAssets.clearLight;
      case 'clouds':
        return isAfterNoon ? AppAssets.cloudyDark : AppAssets.cloudyLight;
      case 'atmosphere':
        return AppAssets.atmosphere;
      case 'snow':
        return isAfterNoon ? AppAssets.snowDark : AppAssets.snowLight;
      case 'rain':
        return isAfterNoon ? AppAssets.rainyDark : AppAssets.rainyLight;
      case 'drizzle':
        return AppAssets.atmosphere;
      case 'thunder':
        return AppAssets.thunder;
      default:
        return isAfterNoon ? AppAssets.cloudyDark : AppAssets.cloudyLight;
    }
  }

  // Helper method to get background weather animation
  static String getBackgroundTheme(TZDateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 10) {
      return AppAssets.sunriseBackground;
    } else if (hour >= 10 && hour < 17) {
      return AppAssets.midDayBackground;
    } else if (hour >= 17 && hour < 20) {
      return AppAssets.sunsetBackground;
    } else {
      return AppAssets.nightBackground;
    }
  }

  // Helper method to get background weather animation
  static String getWeatherState(String condition) {
    switch (condition.toLowerCase()) {
      case 'clouds':
        return AppAssets.cloud;
      case 'atmosphere':
        return AppAssets.cloud;
      case 'snow':
        return AppAssets.snow;
      case 'rain':
        return AppAssets.rain;
      case 'drizzle':
        return AppAssets.cloud;
      case 'thunder':
        return AppAssets.cloud;
      default:
        return '';
    }
  }
}
