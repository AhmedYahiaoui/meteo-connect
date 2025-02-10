import 'package:hive_flutter/hive_flutter.dart';

part 'weather_description_model.g.dart';

@HiveType(typeId: 7)
class WeatherDescription {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String main;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String icon;

  WeatherDescription({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherDescription.fromJson(Map<String, dynamic> json) {
    return WeatherDescription(
      id: json['id'],
      main: json['main'],
      description: json['description'],
      icon: json['icon'],
    );
  }
}
