// ignore_for_file: use_build_context_synchronously

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:meteo_connect/core/constants/assets.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/features/home/home_viewmodel.dart';
import 'package:meteo_connect/features/providers/city_provider.dart';
import 'package:meteo_connect/services/geocoding_service.dart';
import 'package:meteo_connect/services/location_service.dart';

class AddCityBottomSheet extends ConsumerStatefulWidget {
  const AddCityBottomSheet({super.key});

  @override
  ConsumerState<AddCityBottomSheet> createState() => _AddCityBottomSheetState();
}

class _AddCityBottomSheetState extends ConsumerState<AddCityBottomSheet> {
  final GeocodingService geocodingService = GeocodingService();
  final LocationService locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCities(String query) async {
    if (query.length < 2) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cities = await geocodingService.searchCities(query);
      if (!mounted) return;

      // Add a new way of filter (we have Paris,Fr 3 times with diff lat, lng)
      setState(() {
        _suggestions = cities.toSet().toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching cities: $e'),
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _searchCities(query),
          ),
        ),
      );
    }
  }

  Future<void> _addCity(Map<String, dynamic> cityData) async {
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final values = ref.read(cityProvider).value;
    if (values == null) {
      return;
    }
    final cities = values.cities;

    try {
      if (!mounted) return;

      final CityModel city = CityModel(
        name: cityData['name'],
        latitude: cityData['lat'],
        longitude: cityData['lon'],
        country: cityData['country'],
      );

      final bool cityExists = cities.any((existingCity) =>
          existingCity.name == city.name &&
          existingCity.country == city.country);

      if (cityExists) {
        if (context.mounted) {
          Navigator.pop(context);
          _displayShowSnackBar(title: '${city.name} already exists !!');
        }
      } else {
        await homeViewModel.addCity(city);

        if (!mounted) return;
        Navigator.pop(context);
        _displayShowSnackBar(title: 'Added ${city.name} successfully');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      // Show error in showSnackBar instead of adding the city
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Unable to add city: Weather data not available'),
          backgroundColor: Theme.of(context).colorScheme.error,
          showCloseIcon: true,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: () => _addCity(cityData),
          ),
        ),
      );
    }
  }

  Future<void> _addCityUsingCurrentPosition() async {
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final cities = ref.read(cityProvider).value?.cities ?? [];

    try {
      final userLocationModel = await locationService.getCityAndCountry();
      final city = CityModel(
        name: userLocationModel.city ?? '',
        latitude: userLocationModel.latitude ?? 0,
        longitude: userLocationModel.longitude ?? 0,
        country: userLocationModel.country ?? '',
      );

      final bool cityExists = cities.any((existingCity) =>
          existingCity.name == city.name &&
          existingCity.country == city.country);

      if (cityExists) {
        Navigator.pop(context);
        if (context.mounted) {
          _displayShowSnackBar(title: '${city.name} already exists !!');
        }
      } else {
        await homeViewModel.addCity(city);
        await ref.read(cityProvider.notifier).addCity(city);
        if (!context.mounted) return;

        Navigator.pop(context);
        if (context.mounted) {
          _displayShowSnackBar(title: 'Added ${city.name} successfully');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _displayShowSnackBar(
            title: 'Error adding city using current position',
            error: e.toString());
      }
    }
  }

  // ScaffoldFeatureController<SnackBar, SnackBarClosedReason> is the type
  dynamic _displayShowSnackBar({required String title, String error = ''}) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
        content: error.isEmpty ? Text(title) : Text('$title : $error'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search for a city...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
              ),
              onChanged: _searchCities,
            ),
            TextButton(
                onPressed: () {
                  _addCityUsingCurrentPosition();
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.gps_not_fixed_rounded,
                      size: 18,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Add City Using Current Position'),
                  ],
                )),
            const SizedBox(height: 10),
            if (_isLoading)
              CustomMaterialIndicator(
                onRefresh: () {
                  return empty();
                },
                indicatorBuilder: (context, controller) {
                  return Lottie.asset(
                    AppAssets.loader,
                  );
                },
                child: const SizedBox(),
              )
            else
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return _itemLocation(suggestion);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _itemLocation(Map<String, dynamic> suggestion) {
    return ListTile(
      title: Row(
        children: [
          Text(
            suggestion['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            '.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            suggestion['country'],
            style: const TextStyle(
              fontSize: 14,
            ),
          )
        ],
      ),
      subtitle: Text(
        suggestion['state'] ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      leading: const Icon(
        Icons.fmd_good_sharp,
      ),
      onTap: () => _addCity(suggestion),
    );
  }

  Future<void> empty() async {}
}
