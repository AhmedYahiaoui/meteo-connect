import 'package:hive/hive.dart';
import 'package:meteo_connect/core/utils/tools.dart';

part 'city_model.g.dart';

@HiveType(typeId: 1)
class CityModel extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double latitude;

  @HiveField(2)
  final double longitude;

  @HiveField(3)
  final String country;

  @HiveField(4)
  final int order;

  CityModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.order = 0,
  });

  @override
  String toString() {
    return 'City: $name, latitude: $latitude, longitude: $longitude , country: $country, order: $order';
  }

  CityModel copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? country,
    int? order,
  }) {
    return CityModel(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      order: order ?? this.order,
    );
  }

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'],
      latitude: convertToDouble(json['latitude']) ?? 0,
      longitude: convertToDouble(json['longitude']) ?? 0,
      country: json['country'],
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'country': country,
      'order': order,
    };
  }
}
