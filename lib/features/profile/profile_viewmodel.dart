import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/user/user_model.dart';
import 'package:meteo_connect/features/providers/city_provider.dart';
import 'package:meteo_connect/features/providers/settings_provider.dart';
import 'package:meteo_connect/features/providers/theme_provider.dart';
import 'package:meteo_connect/features/providers/user_provider.dart';
import 'package:meteo_connect/features/providers/weather_providers.dart';
import 'package:meteo_connect/services/location_service.dart';

class ProfileState {
  final UserState? userState;
  final bool isLoading;
  final String? error;
  final bool isDarkMode;
  final bool useFahrenheit;

  const ProfileState({
    this.userState,
    this.isLoading = false,
    this.error,
    required this.isDarkMode,
    required this.useFahrenheit,
  });

  ProfileState copyWith({
    UserState? userState,
    bool? isLoading,
    String? error,
    bool? isDarkMode,
    bool? useFahrenheit,
  }) {
    return ProfileState(
      userState: userState ?? this.userState,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useFahrenheit: useFahrenheit ?? this.useFahrenheit,
    );
  }
}

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, AsyncValue<ProfileState>>((ref) {
  return ProfileViewModel(ref);
});

class ProfileViewModel extends StateNotifier<AsyncValue<ProfileState>> {
  final Ref _ref;
  final _locationService = LocationService();

  ProfileViewModel(this._ref)
      : super(
          const AsyncValue.data(
            ProfileState(
              isDarkMode: false,
              useFahrenheit: false,
            ),
          ),
        ) {
    _initializeState();
  }

  Future<void> _initializeState() async {
    try {
      final userState = _ref.read(userProvider).value;
      final isDarkMode = _ref.read(themeProvider);
      final useFahrenheit = _ref.read(settingsProvider);

      state = AsyncValue.data(ProfileState(
        userState: userState,
        isDarkMode: isDarkMode,
        useFahrenheit: useFahrenheit,
      ));

      _setupStateListeners();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _setupStateListeners() {
    _ref.listen(userProvider, (previous, next) {
      if (state.value != null && next.value != null) {
        state = AsyncValue.data(state.value!.copyWith(userState: next.value));
      }
    });

    _ref.listen(themeProvider, (previous, next) {
      if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(isDarkMode: next));
      }
    });

    _ref.listen(settingsProvider, (previous, next) {
      if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(useFahrenheit: next));
      }
    });
  }

  // User Profile Updates
  Future<void> updateUserName(String name) async {
    try {
      _setLoading(true);
      await _ref.read(userProvider.notifier).updateUser(name: name);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // defaultCity Updates
  Future<void> updateDefaultCity(String defaultCity) async {
    try {
      _setLoading(true);
      await _ref
          .read(userProvider.notifier)
          .updateUser(defaultCity: defaultCity);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // defaultCity Updates
  Future<void> updateWeatherNotifications(
      bool weatherNotificationsEnabled) async {
    try {
      _setLoading(true);
      await _ref
          .read(userProvider.notifier)
          .updateUser(weatherNotificationsEnabled: weatherNotificationsEnabled);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateLocation() async {
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

  // Settings Updates
  Future<void> toggleTheme({bool resetting = false}) async {
    try {
      final currentTheme = state.value?.isDarkMode ?? false;
      _ref.read(themeProvider.notifier).state =
          resetting ? false : !currentTheme;
      await _ref.read(userProvider.notifier).updateUser(
            useDarkMode: resetting ? false : !currentTheme,
          );
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> toggleTemperatureUnit({bool resetting = false}) async {
    try {
      final currentUnit = state.value?.useFahrenheit ?? false;
      _ref.read(settingsProvider.notifier).state =
          resetting ? false : !currentUnit;
      await _ref.read(userProvider.notifier).updateUser(
            useFahrenheit: resetting ? false : !currentUnit,
          );
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Reset the app settings + data
  Future<void> resetApp() async {
    try {
      _setLoading(true);
      deleteAllCities();
      deleteAllWeathers;

      await toggleTheme(resetting: true);
      await toggleTemperatureUnit(resetting: true);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Delete all cities + weathers
  Future<void> resetCities() async {
    try {
      _setLoading(true);
      deleteAllCities();
      deleteAllWeathers;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAllCities() async {
    try {
      await _ref.read(cityProvider.notifier).clearAllCities();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> deleteAllWeathers() async {
    try {
      await _ref.read(weatherProvider.notifier).clearAll();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // Helper Methods
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

  // Getters
  UserModel? get user => state.value?.userState?.user;
  List<CityModel> get cities => _ref.read(cityProvider.notifier).cities;
  bool get isLoading => state.value?.isLoading ?? false;
  String? get error => state.value?.error;
  bool get isDarkMode => state.value?.isDarkMode ?? false;
  bool get useFahrenheit => state.value?.useFahrenheit ?? false;
}
