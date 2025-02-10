import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/repositories/weather_repository.dart';
import 'package:meteo_connect/services/api_service.dart';
import 'package:meteo_connect/services/caching_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mock/weather_model_mock.dart';
import '../services/api&cache_service_test.dart';

@GenerateMocks([ApiService, CachingService])
void main() {
  late MockApiService mockApiService;
  late MockCachingService mockCachingService;
  late WeatherRepository weatherRepository;

  setUp(() {
    mockApiService = MockApiService();
    mockCachingService = MockCachingService();
    weatherRepository = WeatherRepository(
      apiService: mockApiService,
      cachingService: mockCachingService,
    );
  });

  group('WeatherRepository Tests', () {
    final testCity = CityModel(
      name: 'Paris',
      country: 'FR',
      latitude: 48.8566,
      longitude: 2.3522,
    );

    final testWeather = mockWeatherModel;

    test('getWeather returns cached weather when available', () async {
      when(mockCachingService.getCachedWeather(testCity))
          .thenAnswer((_) async => testWeather);

      final result = await weatherRepository.getWeather(testCity);

      expect(result, equals(testWeather));
      verify(mockCachingService.getCachedWeather(testCity)).called(1);
    });

    test('fetchWeather gets new data when cache is expired', () async {
      // Setup expired cache
      when(mockCachingService.getCachedWeather(testCity))
          .thenAnswer((_) async => null);
      when(mockApiService.getWeather(testCity))
          .thenAnswer((_) async => testWeather);

      final result = await weatherRepository.fetchWeather(testCity);

      expect(result, equals(testWeather));
      verify(mockApiService.getWeather(testCity)).called(1);
      verify(mockCachingService.cacheWeatherData(testWeather, testCity))
          .called(1);
    });

    test('fetchWeather throws exception on API error', () async {
      when(mockCachingService.getCachedWeather(testCity))
          .thenAnswer((_) async => null);
      when(mockApiService.getWeather(testCity))
          .thenThrow(Exception('API Error'));

      expect(
        () => weatherRepository.fetchWeather(testCity),
        throwsException,
      );
    });

    test('saveWeather throws exception when weather is null', () async {
      expect(
        () => weatherRepository.saveWeather(null, testCity),
        throwsException,
      );
    });

    test('saveWeather throws exception when city name is empty', () async {
      final emptyCity = CityModel(
        name: '',
        country: 'FR',
        latitude: 48.8566,
        longitude: 2.3522,
      );

      expect(
        () => weatherRepository.saveWeather(testWeather, emptyCity),
        throwsException,
      );
    });
  });
}
