import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:meteo_connect/core/utils/tools.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/weather/currentWeather/current_weather_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/services/api_service.dart';
import 'package:meteo_connect/services/caching_service.dart';

final weatherRepositoryProvider = Provider(
  (ref) => WeatherRepository(
    apiService: ApiService(),
    cachingService: CachingService(),
  ),
);

class WeatherRepository {
  final ApiService apiService;
  final CachingService cachingService;
  static const String weatherBoxName = 'weatherBox';
  Box<WeatherModel>? _weatherBox;

  WeatherRepository({
    required this.apiService,
    required this.cachingService,
  });

  Future<Box<WeatherModel>> getWeatherBox() async {
    if (_weatherBox == null || !_weatherBox!.isOpen) {
      try {
        _weatherBox = await Hive.openBox<WeatherModel>(weatherBoxName);
      } catch (e) {
        throw Exception('Failed to open weather storage: $e');
      }
    }
    return _weatherBox!;
  }

  Future<WeatherModel?> getWeather(CityModel city) async {
    try {
      // Check if the city model has the required fields
      if (city.name.isEmpty) {
        throw Exception('City name is empty');
      }
      return await cachingService.getCachedWeather(city);
    } catch (e) {
      return null;
    }
  }

  Future<List<WeatherModel>> getWeathers() async {
    try {
      List<WeatherModel> weathers = [];
      List<CityModel> cachedCities = await cachingService.getCachedCities();
      for (CityModel city in cachedCities) {
        weathers.add(await fetchWeather(city));
      }

      return weathers;
    } catch (e) {
      throw Exception('Failed to get weather : $e');
    }
  }

  Future<void> saveWeather(WeatherModel? weather, CityModel city) async {
    try {
      // Check if the city model has the required fields
      if (city.name.isEmpty) {
        throw Exception('City name is empty');
      }
      // Check if the city model has the required fields
      if (weather == null) {
        throw Exception('weather is null');
      }
      // Cache the new data
      await cachingService.cacheWeatherData(weather, city);
    } catch (e) {
      throw Exception('Failed to save weather : $e');
    }
  }

  Future<WeatherModel> fetchWeather(CityModel city,
      {bool forceRefresh = false}) async {
    try {
      // Try to get cached data from Hive first if not forcing a refresh
      if (!forceRefresh) {
        final cachedWeather = await getWeather(city);
        // Addination checek for expiration
        if (cachedWeather != null && !_isCacheExpired(cachedWeather)) {
          return cachedWeather;
        }
      }
      // Fetch weather data using the updated API service
      final weather = await apiService.getWeather(city);

      // Cache the new data
      await saveWeather(weather, city);

      return weather;
    } catch (e) {
      throw Exception('Failed to get weather data: $e');
    }
  }

  Future<void> updateWeatherData(
      CityModel city, WeatherModel newWeather) async {
    try {
      await cachingService.updateCachedWeather(city, newWeather);
    } catch (e) {
      throw Exception('Failed to udpate weather : $e');
    }
  }

  Future<void> clearAllWeathers() async {
    final box = await getWeatherBox();
    await box.clear();
    await box.flush();
  }

  Future<void> refreshAllWeather(List<CityModel> cities) async {
    for (final city in cities) {
      try {
        await refreshWeather(city);
      } catch (e) {
        return;
      }
    }
  }

  Future<void> refreshWeather(CityModel city) async {
    WeatherModel? weather = await getWeather(city);

    weather ??= await apiService.getWeather(city);

    try {
      // Check if the current weather data is outdated (1hour)
      if (!_isCacheExpired(weather, diff: 60)) {
        // Find the next available hourly weather data
        final now = DateTime.now();

        final currentHourlyWeather = weather.hourly.firstWhere(
          (hour) =>
              DateTime.fromMillisecondsSinceEpoch(hour.dt * 1000).hour ==
              now.hour,
          // fallback to the first hourly data if not found
          orElse: () => weather!.hourly[0],
        );

        // Update the current weather
        weather = weather.copyWith(
          current: CurrentWeather(
            temp: currentHourlyWeather.temp,
            feelsLike: currentHourlyWeather.feelsLike,
            pressure: convertToDouble(currentHourlyWeather.pressure) ?? 0,
            humidity: convertToDouble(currentHourlyWeather.humidity) ?? 0,
            windSpeed: currentHourlyWeather.windSpeed,
            weather: currentHourlyWeather.weather.first,
            createAt: currentHourlyWeather.dt,
            sunrise: weather.current.sunrise,
            sunset: weather.current.sunset,
            clouds: currentHourlyWeather.clouds,
            uvi: currentHourlyWeather.uvi,
          ),
        );

        // Save the updated weather back to the state and cache
        await updateWeatherData(city, weather);
      }

      // Check if a full day has passed since the last update
      if (_isCacheExpired(weather, diff: 1440)) {
        // Make an API call to fetch the latest weather data
        WeatherModel newWeather = await fetchWeather(city, forceRefresh: true);
        await updateWeatherData(city, newWeather);
      }
    } catch (e) {
      throw Exception('Failed refreshing weather : $e');
    }
  }

  bool _isCacheExpired(WeatherModel weather, {int diff = 60}) {
    final now = DateTime.now();
    final cacheTime =
        DateTime.fromMillisecondsSinceEpoch(weather.current.createAt * 1000);

    final difference = now.difference(cacheTime);
    return difference.inMinutes > diff;
  }
}
