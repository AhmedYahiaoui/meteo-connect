import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/repositories/city_repository.dart';

class CityState {
  final List<CityModel> cities;
  final List<CityModel> filteredCities;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const CityState({
    this.cities = const [],
    this.filteredCities = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  CityState copyWith({
    List<CityModel>? cities,
    List<CityModel>? filteredCities,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return CityState(
      cities: cities ?? this.cities,
      filteredCities: filteredCities ?? this.filteredCities,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final cityProvider =
    StateNotifierProvider<CityNotifier, AsyncValue<CityState>>((ref) {
  final repository = ref.watch(cityRepositoryProvider);
  return CityNotifier(repository);
});

class CityNotifier extends StateNotifier<AsyncValue<CityState>> {
  final CityRepository _repository;

  CityNotifier(this._repository) : super(const AsyncValue.loading()) {
    _initializeCities();
  }

  Future<void> _initializeCities() async {
    try {
      final cities = await _repository.getCities();
      state = AsyncValue.data(CityState(
        cities: cities,
        filteredCities: cities,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addCity(CityModel city) async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));

      // Check if city already exists
      final currentCities = state.value?.cities ?? [];
      if (currentCities.any((c) => c.name == city.name)) {
        throw Exception('City already exists');
      }

      final updatedCities = [...currentCities, city];
      await _repository.saveCity(city);

      state = AsyncValue.data(CityState(
        cities: updatedCities,
        filteredCities: updatedCities,
        searchQuery: state.value!.searchQuery,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeCity(String cityName) async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));

      final currentCities = state.value?.cities ?? [];
      final updatedCities =
          currentCities.where((city) => city.name != cityName).toList();

      await _repository.removeCity(cityName);
      // add delete the weather bellongs to city

      state = AsyncValue.data(CityState(
        cities: updatedCities,
        filteredCities: updatedCities,
        searchQuery: state.value!.searchQuery,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> clearAllCities() async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));

      await _repository.clearAllCities();
      // add delete the weathers

      state = const AsyncValue.data(CityState(
        cities: [],
        filteredCities: [],
        searchQuery: '',
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> reorderCities(List<CityModel> newOrder) async {
    try {
      state = AsyncValue.data(state.value!.copyWith(isLoading: true));

      await _repository.saveCities(newOrder);

      state = AsyncValue.data(CityState(
        cities: newOrder,
        filteredCities: newOrder,
        searchQuery: state.value!.searchQuery,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void filterCities(String query) {
    if (state.value == null) return;

    final filteredCities = query.isEmpty
        ? state.value!.cities
        : state.value!.cities
            .where(
                (city) => city.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    state = AsyncValue.data(state.value!.copyWith(
      filteredCities: filteredCities,
      searchQuery: query,
    ));
  }

  void clearFilter() {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.copyWith(
        filteredCities: state.value!.cities,
        searchQuery: '',
      ));
    }
  }

  // Helper getters
  List<CityModel> get cities => state.value?.cities ?? [];
  List<CityModel> get filteredCities => state.value?.filteredCities ?? [];
  bool get isLoading => state.value?.isLoading ?? false;
  String? get error => state.value?.error;
  String get searchQuery => state.value?.searchQuery ?? '';
}
