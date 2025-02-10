import 'package:hive/hive.dart';
import 'package:meteo_connect/core/utils/tools.dart';
import 'package:meteo_connect/data/models/weather/currentWeather/current_weather_model.dart';
import 'package:meteo_connect/data/models/weather/dailyWeather/daily_weather_model.dart';
import 'package:meteo_connect/data/models/weather/hourlyWeather/hourly_weather_model.dart';

part 'weather_model.g.dart';

@HiveType(typeId: 0)
class WeatherModel extends HiveObject {
  @HiveField(0)
  final double lat;

  @HiveField(1)
  final double lon;

  @HiveField(2)
  final String timezone;

  @HiveField(3)
  final int timezoneOffset;

  @HiveField(4)
  final CurrentWeather current;

  @HiveField(5)
  final List<HourlyWeather> hourly;

  @HiveField(6)
  final List<DailyWeather> daily;

  @HiveField(7)
  final String id;

  WeatherModel({
    required this.lat,
    required this.lon,
    required this.timezone,
    required this.timezoneOffset,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.id,
  });

  @override
  String toString() {
    return 'lat: $lat, lon: $lon, timezone: $timezone, timezoneOffset: $timezoneOffset ';
  }

  WeatherModel copyWith({
    double? lat,
    double? lon,
    String? timezone,
    int? timezoneOffset,
    CurrentWeather? current,
    List<DailyWeather>? daily,
    List<HourlyWeather>? hourly,
    String? id,
  }) {
    return WeatherModel(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      timezone: timezone ?? this.timezone,
      timezoneOffset: timezoneOffset ?? this.timezoneOffset,
      current: current ?? this.current,
      hourly: hourly ?? this.hourly,
      daily: daily ?? this.daily,
      id: id ?? this.id,
    );
  }

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      lat: convertToDouble(json['lat']) ?? 0,
      lon: convertToDouble(json['lon']) ?? 0,
      timezone: json['timezone'],
      timezoneOffset: json['timezone_offset'],
      current: CurrentWeather.fromJson(json['current']),
      daily: List<DailyWeather>.from(
        json['daily'].map(
          (x) => DailyWeather.fromJson(x),
        ),
      ),
      hourly: List<HourlyWeather>.from(
        json['hourly'].map(
          (x) => HourlyWeather.fromJson(x),
        ),
      ),
      id: json['id'] ?? '',
    );
  }
}
