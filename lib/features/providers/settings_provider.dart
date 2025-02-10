import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/data/repositories/user_repository.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, bool>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return SettingsNotifier(userRepository);
});

class SettingsNotifier extends StateNotifier<bool> {
  final UserRepository _userRepository;

  SettingsNotifier(this._userRepository) : super(false) {
    _initSettings();
  }

  Future<void> _initSettings() async {
    final user = await _userRepository.getUser();
    state = user?.useFahrenheit ?? false;
  }

  Future<void> toggleUnit() async {
    final newState = !state;
    await _userRepository.updateSettings(useFahrenheit: newState);
    state = newState;
  }
}
