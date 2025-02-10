import 'package:hive/hive.dart';

part 'user_location_model.g.dart';

@HiveType(typeId: 9)
class UserLocationModel extends HiveObject {
  @HiveField(0)
  final String? city;

  @HiveField(1)
  final String? country;

  @HiveField(2)
  final double? latitude;

  @HiveField(3)
  final double? longitude;

  UserLocationModel({
    this.city,
    this.country,
    required this.latitude,
    required this.longitude,
  });
}
