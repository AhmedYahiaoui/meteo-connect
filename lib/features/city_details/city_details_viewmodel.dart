import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/core/utils/tools.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/user/user_model.dart';
import 'package:meteo_connect/data/models/weather/hourlyWeather/hourly_weather_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/features/providers/settings_provider.dart';
import 'package:meteo_connect/features/providers/user_provider.dart';
import 'package:meteo_connect/features/providers/weather_providers.dart';

class CityDetailsState {
  final WeatherModel? weather;
  final HourlyWeather? selectedHourlyWeather;
  final UserState? userState;

  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const CityDetailsState({
    this.weather,
    this.selectedHourlyWeather,
    this.userState,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  CityDetailsState copyWith({
    WeatherModel? weather,
    HourlyWeather? selectedHourlyWeather,
    UserState? userState,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CityDetailsState(
      weather: weather ?? this.weather,
      selectedHourlyWeather:
          selectedHourlyWeather ?? this.selectedHourlyWeather,
      userState: userState ?? this.userState,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

final cityDetailsViewModelProvider = StateNotifierProvider.family<
    CityDetailsViewModel, AsyncValue<CityDetailsState>, CityModel>(
  (ref, city) => CityDetailsViewModel(ref, city),
);

class CityDetailsViewModel extends StateNotifier<AsyncValue<CityDetailsState>> {
  final Ref _ref;
  final CityModel city;

  CityDetailsViewModel(this._ref, this.city)
      : super(
          const AsyncValue.data(
              CityDetailsState()), // Initialize with empty state
        ) {
    loadWeatherData();
  }

  Future<void> loadWeatherData() async {
    try {
      state = const AsyncValue.loading();

      // First try to get existing weather data
      final weatherState = _ref.read(weatherProvider).value;
      if (weatherState != null) {
        WeatherModel? existingWeather =
            weatherState.weatherData.firstWhereOrNull(
          (w) => compareCoordinates(
            weatherLat: w.lat,
            weatherLon: w.lon,
            cityLat: city.latitude,
            cityLon: city.longitude,
          ),
        );

        if (existingWeather != null) {
          state = AsyncValue.data(
            CityDetailsState(
              weather: existingWeather,
              selectedHourlyWeather: existingWeather.hourly.first,
              lastUpdated: DateTime.now(),
            ),
          );
          return;
        }
      }

      // If no existing weather data, fetch new data
      final weather =
          await _ref.read(weatherProvider.notifier).getWeatherForCity(city);
      final userState = _ref.read(userProvider).value;

      if (weather != null) {
        state = AsyncValue.data(
          CityDetailsState(
            weather: weather,
            selectedHourlyWeather: weather.hourly.first,
            userState: userState,
            lastUpdated: DateTime.now(),
          ),
        );
      }
      _setupStateListeners();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void _setupStateListeners() {
    _ref.listen(userProvider, (previous, next) {
      if (state.value != null && next.value != null) {
        state = AsyncValue.data(state.value!.copyWith(userState: next.value));
      }
    });
  }

  Future<void> refreshWeather() async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));

      await _ref.read(weatherProvider.notifier).refreshWeather(city);
      final weather =
          await _ref.read(weatherProvider.notifier).getWeatherForCity(city);

      if (weather != null) {
        state = AsyncValue.data(
          CityDetailsState(
            weather: weather,
            selectedHourlyWeather:
                state.value?.selectedHourlyWeather ?? weather.hourly.first,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void selectHourlyWeather(HourlyWeather hourlyWeather) {
    if (state.value != null) {
      state = AsyncValue.data(
        state.value!.copyWith(selectedHourlyWeather: hourlyWeather),
      );
    }
  }

  // Helper getters
  WeatherModel? get currentWeather => state.value?.weather;
  HourlyWeather? get selectedHourlyWeather =>
      state.value?.selectedHourlyWeather;
  bool get isLoading => state.value?.isLoading ?? false;
  String? get error => state.value?.error;
  DateTime? get lastUpdated => state.value?.lastUpdated;
  bool get isMetric => !_ref.watch(settingsProvider);
  UserModel? get user => _ref.watch(userProvider).value?.user;

  // Weather data getters
  double get currentTemp =>
      selectedHourlyWeather?.temp ?? currentWeather?.current.temp ?? 0;
  int get currentHumidity =>
      selectedHourlyWeather?.humidity ??
      currentWeather?.current.humidity.round() ??
      0;
  double get currentWindSpeed =>
      selectedHourlyWeather?.windSpeed ??
      currentWeather?.current.windSpeed ??
      0;
  int get currentClouds =>
      selectedHourlyWeather?.clouds ?? currentWeather?.current.clouds ?? 0;
  double get currentFeelsLike =>
      selectedHourlyWeather?.feelsLike ??
      currentWeather?.current.feelsLike ??
      0;
  int get currentUvi =>
      (selectedHourlyWeather?.uvi ?? currentWeather?.current.uvi ?? 0).round();

  List<HourlyWeather> get hourlyForecast => currentWeather?.hourly ?? [];
}
