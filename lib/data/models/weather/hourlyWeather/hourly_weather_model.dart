import 'package:hive/hive.dart';
import 'package:meteo_connect/core/utils/tools.dart';
import 'package:meteo_connect/data/models/weather/descriptionWeather/weather_description_model.dart';

part 'hourly_weather_model.g.dart';

@HiveType(typeId: 6)
class HourlyWeather {
  @HiveField(0)
  final int dt;

  @HiveField(1)
  final double temp;

  @HiveField(2)
  final double feelsLike;

  @HiveField(3)
  final int pressure;

  @HiveField(4)
  final int humidity;

  @HiveField(5)
  final double windSpeed;

  @HiveField(6)
  final List<WeatherDescription> weather;

  @HiveField(7)
  final int clouds;

  @HiveField(8)
  final int uvi;

  HourlyWeather({
    required this.dt,
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.weather,
    required this.clouds,
    required this.uvi,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      dt: json['dt'],
      temp: convertToDouble(json['temp']) ?? 0,
      feelsLike: convertToDouble(json['feels_like']) ?? 0,
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
