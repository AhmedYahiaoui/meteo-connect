import 'package:hive_flutter/hive_flutter.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';

class CachingService {
  static const String weatherBox = 'weatherBox';
  static const String cityBox = 'cities';

  Future<void> cacheWeatherData(WeatherModel weather, CityModel city) async {
    final box = await Hive.openBox<WeatherModel>(weatherBox);
    // Create a unique key based on latitude and longitude
    final uniqueKey =
        '${city.latitude.toString()}_${city.longitude.toString()}';

    await box.put(uniqueKey, weather);
  }

  Future<WeatherModel?> getCachedWeather(CityModel city) async {
    final box = await Hive.openBox<WeatherModel>(weatherBox);

    // Create the unique key based on latitude and longitude of city
    final uniqueKey =
        '${city.latitude.toString()}_${city.longitude.toString()}';

    WeatherModel? weather = box.get(uniqueKey);

    return weather;
  }

  Future<List<CityModel>> getCachedCities() async {
    final box = await Hive.openBox<CityModel>(cityBox);
    List<CityModel> cities = box.values.toList();
    return cities;
  }

  Future<void> updateCachedWeather(
      CityModel city, WeatherModel newWeather) async {
    final box = await Hive.openBox<WeatherModel>(weatherBox);

    // Create a unique key based on city name and country
    final uniqueKey = '${city.latitude}_${city.longitude}';

    // Check if the weather data exists
    if (box.containsKey(uniqueKey)) {
      // Update the cached weather data
      await box.put(uniqueKey, newWeather);
    }
  }

  Future<void> clearCache() async {
    final box = await Hive.openBox<WeatherModel>(weatherBox);
    await box.clear();
  }
}
