import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 2)
class UserModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String defaultCity;

  @HiveField(2)
  final bool useDarkMode;

  @HiveField(3)
  final bool useFahrenheit;

  @HiveField(4)
  final String? city;

  @HiveField(5)
  final String? country;

  @HiveField(6)
  final double? latitude;

  @HiveField(7)
  final double? longitude;

  @HiveField(8)
  final bool weatherNotificationsEnabled;

  UserModel({
    required this.name,
    required this.defaultCity,
    this.useDarkMode = false,
    this.useFahrenheit = false,
    this.city = '',
    this.country = '',
    this.latitude = 0,
    this.longitude = 0,
    this.weatherNotificationsEnabled = false,
  });

  UserModel copyWith({
    String? name,
    String? defaultCity,
    bool? useDarkMode,
    bool? useFahrenheit,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    bool? weatherNotificationsEnabled,
  }) {
    return UserModel(
      name: name ?? this.name,
      defaultCity: defaultCity ?? this.defaultCity,
      useDarkMode: useDarkMode ?? this.useDarkMode,
      useFahrenheit: useFahrenheit ?? this.useFahrenheit,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      weatherNotificationsEnabled:
          weatherNotificationsEnabled ?? this.weatherNotificationsEnabled,
    );
  }
}
