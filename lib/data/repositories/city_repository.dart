import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';

final cityRepositoryProvider = Provider((ref) => CityRepository());

class CityRepository {
  static const String citiesBoxName = 'cities';
  Box<CityModel>? _cityBox;

  Future<Box<CityModel>> getCityBox() async {
    _cityBox ??= Hive.box<CityModel>(citiesBoxName);
    return _cityBox!;
  }

  Future<List<CityModel>> getCities() async {
    final box = await getCityBox();
    final cities = box.values.toList();

    // Sort by order
    cities.sort((a, b) => a.order.compareTo(b.order));
    return cities;
  }

  Future<CityModel?> findCityByName(String cityName) async {
    final box = await getCityBox();
    final cities = box.values.toList();

    CityModel? city = cities.firstWhereOrNull((city) => city.name == cityName);
    return city;
  }

  Future<void> saveCities(List<CityModel> cities) async {
    final box = await getCityBox();

    // Clear existing data first
    await box.clear();

    // Save all cities with new orders
    for (int i = 0; i < cities.length; i++) {
      final city = cities[i].copyWith(order: i);
      await box.put(city.name, city);
    }

    // Force flush to disk
    await box.flush();
  }

  Future<void> saveCity(CityModel city) async {
    final box = await getCityBox();
    final cities = await getCities();

    // If it's a new city, add it to the end
    if (!box.containsKey(city.name)) {
      final newOrder = cities.isEmpty ? 0 : cities.last.order + 1;
      await box.put(city.name, city.copyWith(order: newOrder));
      await box.flush();
    }
  }

  Future<void> updateCitiesOrder(List<CityModel> cities) async {
    final box = await getCityBox();

    // Create a batch of operations
    final batch = <Future<void>>[];

    for (int i = 0; i < cities.length; i++) {
      final city = cities[i];
      // Only update if order has changed
      if (city.order != i) {
        batch.add(box.put(city.name, city.copyWith(order: i)));
      }
    }

    // Execute all operations
    if (batch.isNotEmpty) {
      await Future.wait(batch);
      await box.flush(); // Ensure changes are written to disk
    }
  }

  Future<void> removeCity(String cityName) async {
    final box = await getCityBox();
    await box.delete(cityName);
    // Reorder remaining cities
    final cities = await getCities();
    await updateCitiesOrder(cities);
    await box.flush();
  }

  Future<void> clearAllCities() async {
    final box = await getCityBox();
    await box.clear();
    await box.flush(); // Ensure changes are written to disk
  }
}
