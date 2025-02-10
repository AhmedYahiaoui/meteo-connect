import 'package:hive/hive.dart';
import 'package:meteo_connect/core/utils/tools.dart';

import '../descriptionWeather/weather_description_model.dart';

part 'daily_weather_model.g.dart';

@HiveType(typeId: 5)
class DailyWeather {
  @HiveField(0)
  final int dt;

  @HiveField(1)
  final double tempDay;

  @HiveField(2)
  final double tempMin;

  @HiveField(3)
  final double tempMax;

  @HiveField(4)
  final double feelsLikeDay;

  @HiveField(5)
  final int pressure;

  @HiveField(6)
  final int humidity;

  @HiveField(7)
  final double windSpeed;

  @HiveField(8)
  final List<WeatherDescription> weather;

  @HiveField(9)
  final int clouds;

  @HiveField(10)
  final int uvi;

  DailyWeather({
    required this.dt,
    required this.tempDay,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLikeDay,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.weather,
    required this.clouds,
    required this.uvi,
  });

  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      dt: json['dt'],
      tempDay: convertToDouble(json['temp']['day']) ?? 0,
      tempMin: convertToDouble(json['temp']['min']) ?? 0,
      tempMax: convertToDouble(json['temp']['max']) ?? 0,
      feelsLikeDay: convertToDouble(json['feels_like']['day']) ?? 0,
      pressure: json['pressure'],
      humidity: json['humidity'],
      windSpeed: convertToDouble(json['wind_speed']) ?? 0,
      weather: List<WeatherDescription>.from(
        json['weather'].map(
          (x) => WeatherDescription.fromJson(x),
        ),
      ),
      clouds: convertToInt(json['clouds']) ?? 0,
      uvi: convertToInt(json['uvi']) ?? 0,
    );
  }
}
