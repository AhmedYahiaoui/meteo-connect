import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/services/api_service.dart';
import 'package:meteo_connect/services/caching_service.dart';
import 'package:mockito/mockito.dart';

import '../mock/weather_model_mock.dart';

class MockApiService extends Mock implements ApiService {
  @override
  Future<WeatherModel> getWeather(CityModel city) =>
      super.noSuchMethod(Invocation.method(#getWeather, [city]),
          returnValue: Future.value(mockWeatherModel));
}

class MockCachingService extends Mock implements CachingService {
  @override
  Future<WeatherModel?> getCachedWeather(CityModel city) =>
      super.noSuchMethod(Invocation.method(#getCachedWeather, [city]),
          returnValue: Future.value(null));

  @override
  Future<void> cacheWeatherData(WeatherModel weather, CityModel city) =>
      super.noSuchMethod(Invocation.method(#cacheWeatherData, [weather, city]),
          returnValue: Future.value());
}
