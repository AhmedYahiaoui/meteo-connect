import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/data/models/user/user_model.dart';
import 'package:meteo_connect/data/repositories/user_repository.dart';

class UserState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final userProvider =
    StateNotifierProvider<UserNotifier, AsyncValue<UserState>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserNotifier(userRepository);
});

class UserNotifier extends StateNotifier<AsyncValue<UserState>> {
  final UserRepository _userRepository;

  UserNotifier(this._userRepository)
      : super(const AsyncValue.data(UserState())) {
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));
      final user = await _userRepository.getUser();
      state = AsyncValue.data(UserState(user: user));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateUser({
    String? name,
    String? defaultCity,
    bool? useDarkMode,
    bool? useFahrenheit,
    bool? weatherNotificationsEnabled,
  }) async {
    try {
      await _userRepository.updateSettings(
        name: name,
        defaultCity: defaultCity,
        useDarkMode: useDarkMode,
        useFahrenheit: useFahrenheit,
        weatherNotificationsEnabled: weatherNotificationsEnabled,
      );
      await loadUser(); // Reload user data after update
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> resetUser() async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));
      await _userRepository.resetUser();
      await loadUser();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateUserLocation({
    String? city,
    String? country,
    double? lat,
    double? lng,
  }) async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));

      await _userRepository.updateLocation(
        city: city,
        country: country,
        latitude: lat,
        longitude: lng,
      );

      await loadUser();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateUserField({
    String? name,
    String? defaultCity,
    bool? useDarkMode,
    bool? useFahrenheit,
  }) async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));

      await _userRepository.updateSettings(
        name: name,
        defaultCity: defaultCity,
        useDarkMode: useDarkMode,
        useFahrenheit: useFahrenheit,
      );

      await loadUser();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
