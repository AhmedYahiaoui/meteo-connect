import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/data/repositories/user_repository.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return ThemeNotifier(userRepository);
});

class ThemeNotifier extends StateNotifier<bool> {
  final UserRepository _userRepository;

  ThemeNotifier(this._userRepository) : super(false) {
    _initTheme();
  }

  Future<void> _initTheme() async {
    final user = await _userRepository.getUser();
    state = user?.useDarkMode ?? false;
  }

  Future<void> toggleTheme() async {
    final newState = !state;
    await _userRepository.updateSettings(useDarkMode: newState);
    state = newState;
  }
}
