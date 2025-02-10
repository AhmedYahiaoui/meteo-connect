import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/core/utils/tools.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/user/user_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/features/providers/city_provider.dart';
import 'package:meteo_connect/features/providers/user_provider.dart';
import 'package:meteo_connect/features/providers/weather_providers.dart';
import 'package:meteo_connect/services/location_service.dart';

final homeViewModelProvider =
    StateNotifierProvider<HomeViewModel, AsyncValue<HomeState>>((ref) {
  return HomeViewModel(ref);
});

class HomeState {
  final CityState cityState;
  final UserState? userState;
  final WeatherState? weatherState;
  final bool isLoading;
  final String? error;

  const HomeState({
    required this.cityState,
    this.userState,
    this.weatherState,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    CityState? cityState,
    UserState? userState,
    WeatherState? weatherState,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      cityState: cityState ?? this.cityState,
      userState: userState ?? this.userState,
      weatherState: weatherState ?? this.weatherState,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeViewModel extends StateNotifier<AsyncValue<HomeState>> {
  final Ref _ref;
  final _locationService = LocationService();

  HomeViewModel(this._ref) : super(const AsyncValue.loading()) {
    _initializeState();
  }

  Future<void> _initializeState() async {
    try {
      final cityState = _ref.read(cityProvider).value ??
          const CityState(cities: [], filteredCities: []);
      final userState = _ref.read(userProvider).value;
      final weatherState = _ref.read(weatherProvider).value;

      state = AsyncValue.data(HomeState(
        cityState: cityState,
        userState: userState,
        weatherState: weatherState,
      ));

      // If we have cities, fetch their weather data
      if (cityState.cities.isNotEmpty) {
        await _fetchWeatherForAllCities();
      }

      _setupStateListeners();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _setupStateListeners() {
    _ref.listen(cityProvider, (previous, next) {
      if (state.value != null && next.value != null) {
        state = AsyncValue.data(state.value!.copyWith(
          cityState:
              next.value ?? const CityState(cities: [], filteredCities: []),
        ));
      }
    });

    _ref.listen(userProvider, (previous, next) {
      if (state.value != null && next.value != null) {
        state = AsyncValue.data(state.value!.copyWith(userState: next.value));
      }
    });

    _ref.listen(weatherProvider, (previous, next) {
      if (state.value != null && next.value != null) {
        try {
          state =
              AsyncValue.data(state.value!.copyWith(weatherState: next.value));
        } catch (e) {
          print('Error updating weather state: $e');
          // Don't update state if there's an error
        }
      }
    });
  }

  Future<void> _fetchWeatherForAllCities() async {
    try {
      final cities = state.value?.cityState.cities ?? [];
      if (cities.isEmpty) return;

      _setLoading(true);
      final weatherNotifier = _ref.read(weatherProvider.notifier);
      await weatherNotifier.refreshAllWeathers(cities);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCity(CityModel city) async {
    try {
      _setLoading(true);

      // Add city first
      await _ref.read(cityProvider.notifier).addCity(city);

      // Then fetch weather
      await _ref.read(weatherProvider.notifier).getWeatherForCity(city);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeCity(String cityName) async {
    try {
      _setLoading(true);
      await _ref.read(cityProvider.notifier).removeCity(cityName);

      // Update user's default city if needed
      if (state.value?.userState?.user?.defaultCity == cityName) {
        await _ref.read(userProvider.notifier).updateUser(defaultCity: '');
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reorderCities(List<CityModel> newOrder) async {
    try {
      _setLoading(true);
      await _ref.read(cityProvider.notifier).reorderCities(newOrder);

      // Refresh weather data for the new order
      await refreshWeather();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshWeather() async {
    try {
      final cities = state.value?.cityState.cities ?? [];
      if (cities.isEmpty) {
        return;
      }

      _setLoading(true);
      await _fetchWeatherForAllCities();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Search Functionality
  void searchCities(String query) {
    _ref.read(cityProvider.notifier).filterCities(query);
  }

  // Location Services
  Future<void> updateUserLocation() async {
    try {
      _setLoading(true);
      final location = await _locationService.getCityAndCountry();
      await _ref.read(userProvider.notifier).updateUserLocation(
            city: location.city,
            country: location.country,
            lat: location.latitude,
            lng: location.longitude,
          );
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Helper Methods for weather state

  void _setLoading(bool loading) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(isLoading: loading));
    }
  }

  void _setError(String error) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(error: error));
    }
  }

  void clearError() {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(error: null));
    }
  }

  // Helper getters for weather/city.
  WeatherModel? getWeatherForCity(CityModel city) {
    try {
      final weatherData = state.value?.weatherState?.weatherData;
      if (weatherData == null || weatherData.isEmpty) {
        return null;
      }
      WeatherModel result = weatherData.firstWhere(
        (weather) => compareCoordinates(
          weatherLat: weather.lat,
          weatherLon: weather.lon,
          cityLat: city.latitude,
          cityLon: city.longitude,
        ),
      );
      // print(" MV : result ${result}");
      return result;
    } catch (e) {
      // print('Weather not found for city: ${city.name}');
      return null;
    }
  }

  // Helper getters for weather state
  List<WeatherModel> get weatherData =>
      state.value?.weatherState?.weatherData ?? [];
  bool get isWeatherLoading => state.value?.weatherState?.isLoading ?? false;
  String? get weatherError => state.value?.weatherState?.error;
  DateTime? get lastWeatherUpdate => state.value?.weatherState?.lastUpdated;

  UserModel? get user => state.value?.userState?.user;
}
