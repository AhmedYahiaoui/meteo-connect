import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/core/utils/tools.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/data/repositories/weather_repository.dart';

// Weather state to handle loading and error states
class WeatherState {
  final List<WeatherModel> weatherData;
  final WeatherModel? selectedWeather;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const WeatherState({
    this.weatherData = const [],
    this.selectedWeather,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  WeatherState copyWith({
    List<WeatherModel>? weatherData,
    WeatherModel? selectedWeather,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return WeatherState(
      weatherData: weatherData ?? this.weatherData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final weatherProvider =
    StateNotifierProvider<WeatherNotifier, AsyncValue<WeatherState>>((ref) {
  final repository = ref.watch(weatherRepositoryProvider);

  return WeatherNotifier(repository);
});

class WeatherNotifier extends StateNotifier<AsyncValue<WeatherState>> {
  final WeatherRepository _weatherRepository;
  final List<CityModel> originalCityList = [];

  WeatherNotifier(this._weatherRepository)
      : super(const AsyncValue.data(WeatherState())) {
    _initializeWeather();
  }

  Future<void> _initializeWeather() async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));
      final weatherData = await _weatherRepository.getWeathers();
      state = AsyncValue.data(
        WeatherState(
          weatherData: weatherData,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<WeatherModel?> getWeatherForCity(CityModel city) async {
    try {
      if (state.value == null) {
        state = const AsyncValue.data(WeatherState());
      }

      state = AsyncValue.data(state.value!.copyWith(isLoading: true));

      final weather = await _weatherRepository.fetchWeather(city);

      final currentWeatherList =
          List<WeatherModel>.from(state.value?.weatherData ?? []);

      // Update or add new weather data
      final index = currentWeatherList.indexWhere(
        (w) => compareCoordinates(
            weatherLat: w.lat,
            weatherLon: w.lon,
            cityLat: city.latitude,
            cityLon: city.longitude),
      );

      if (index != -1) {
        currentWeatherList[index] = weather;
      } else {
        currentWeatherList.add(weather);
      }

      state = AsyncValue.data(WeatherState(
        weatherData: currentWeatherList,
        lastUpdated: DateTime.now(),
      ));

      return weather;
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
      return null;
    }
  }

  Future<void> refreshAllWeathers(List<CityModel> cities) async {
    try {
      await _weatherRepository.refreshAllWeather(cities);
      await _initializeWeather();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshWeather(CityModel city) async {
    try {
      await _weatherRepository.refreshWeather(city);
      await _initializeWeather();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearAll() async {
    await _weatherRepository.clearAllWeathers();
  }

  bool get isLoading => state.value?.isLoading ?? false;
  String? get error => state.value?.error;
  DateTime? get lastUpdated => state.value?.lastUpdated;
  List<WeatherModel> get weatherData => state.value?.weatherData ?? [];
}
