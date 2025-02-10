import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meteo_connect/data/models/user/user_model.dart';

final userRepositoryProvider = Provider((ref) => UserRepository());

class UserRepository {
  static const String userBoxName = 'userbox';
  Box<UserModel>? _userBox;

  Future<Box<UserModel>> getUserBox() async {
    _userBox ??= Hive.box<UserModel>(userBoxName);
    return _userBox!;
  }

  Future<UserModel?> getUser() async {
    final box = await getUserBox();
    return box.get('current_user') ??
        UserModel(
          name: '',
          defaultCity: '',
          useDarkMode: false,
          useFahrenheit: false,
        );
  }

  Future<void> saveUser(UserModel user) async {
    final box = await getUserBox();
    await box.put('current_user', user);
    await box.flush();
  }

  // Reset Operations
  Future<void> resetUser() async {
    await saveUser(_createDefaultUser());
  }

  UserModel _createDefaultUser() {
    return UserModel(
      name: '',
      defaultCity: '',
      useDarkMode: false,
      useFahrenheit: false,
      city: '',
      country: '',
      latitude: null,
      longitude: null,
    );
  }

  Future<void> updateSettings({
    String? name,
    String? defaultCity,
    bool? useDarkMode,
    bool? useFahrenheit,
    bool? weatherNotificationsEnabled,
  }) async {
    final box = await getUserBox();
    final currentUser = await getUser();

    final updatedUser = currentUser?.copyWith(
          name: name,
          defaultCity: defaultCity,
          useDarkMode: useDarkMode,
          useFahrenheit: useFahrenheit,
          weatherNotificationsEnabled: weatherNotificationsEnabled,
        ) ??
        UserModel(
          name: name ?? '',
          defaultCity: defaultCity ?? '',
          useDarkMode: useDarkMode ?? false,
          useFahrenheit: useFahrenheit ?? false,
          weatherNotificationsEnabled: weatherNotificationsEnabled ?? false,
        );

    await box.put('current_user', updatedUser);
    await box.flush();
  }

  // Location Management
  Future<void> updateLocation({
    String? city,
    String? country,
    double? latitude,
    double? longitude,
  }) async {
    final currentUser = await getUser();

    final updatedUser = currentUser?.copyWith(
      city: city,
      country: country,
      latitude: latitude,
      longitude: longitude,
    );
    if (updatedUser != null) await saveUser(updatedUser);
  }
}
