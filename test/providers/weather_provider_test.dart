import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_connect/data/repositories/weather_repository.dart';
import 'package:meteo_connect/features/providers/weather_providers.dart';
import 'package:mockito/mockito.dart';

import '../mock/city_model_mock.dart';
import '../mock/weather_model_mock.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late MockWeatherRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockWeatherRepository();
    container = ProviderContainer(
      overrides: [
        weatherRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('Initial state should be loading', () {
    final weatherState = container.read(weatherProvider);
    expect(weatherState.isLoading, true);
  });

  test('Should fetch weather data successfully', () async {
    when(mockRepository.getWeather(mockCityModel))
        .thenAnswer((_) async => mockWeatherModel);

    // Trigger the weather fetch
    await container
        .read(weatherProvider.notifier)
        .getWeatherForCity(mockCityModel);

    // Verify the state
    final weatherState = container.read(weatherProvider);
    expect(weatherState.hasValue, true);
    expect(weatherState.value?.weatherData.first.id, mockWeatherModel.id);
    verify(mockRepository.getWeather(mockCityModel)).called(1);
  });

  test('Should handle error when fetching weather', () async {
    when(mockRepository.getWeather(mockCityModel))
        .thenThrow(Exception('Failed to fetch weather'));

    // Trigger the weather fetch
    await container
        .read(weatherProvider.notifier)
        .getWeatherForCity(mockCityModel);

    // Verify the error state
    final weatherState = container.read(weatherProvider);
    expect(weatherState.hasError, true);
    verify(mockRepository.getWeather(mockCityModel)).called(1);
  });

  test('Should update loading state during fetch', () async {
    when(mockRepository.getWeather(mockCityModel)).thenAnswer((_) async {
      await Future.delayed(const Duration(milliseconds: 100));
      return mockWeatherModel;
    });

    // Start the fetch
    final future = container
        .read(weatherProvider.notifier)
        .getWeatherForCity(mockCityModel);

    // Verify loading state
    expect(container.read(weatherProvider).isLoading, true);

    // Wait for fetch to complete
    await future;

    // Verify loading is complete
    expect(container.read(weatherProvider).isLoading, false);
  });
}
