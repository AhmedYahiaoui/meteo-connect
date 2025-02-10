import 'package:hive/hive.dart';
import 'package:meteo_connect/core/utils/tools.dart';
import 'package:meteo_connect/data/models/weather/descriptionWeather/weather_description_model.dart';

part 'current_weather_model.g.dart';

@HiveType(typeId: 4)
class CurrentWeather {
  @HiveField(0)
  final double temp;

  @HiveField(1)
  final double feelsLike;

  @HiveField(2)
  final double pressure;

  @HiveField(3)
  final double humidity;

  @HiveField(4)
  final double windSpeed;

  @HiveField(5)
  final WeatherDescription weather;

  @HiveField(6)
  final int createAt;

  @HiveField(7)
  final int sunset;

  @HiveField(8)
  final int sunrise;

  @HiveField(9)
  final int clouds;

  @HiveField(10)
  final int uvi;

  CurrentWeather({
    required this.temp,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.weather,
    required this.createAt,
    required this.sunset,
    required this.sunrise,
    required this.clouds,
    required this.uvi,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      createAt: json['dt'],
      temp: convertToDouble(json['temp']) ?? 0,
      feelsLike: convertToDouble(json['feels_like']) ?? 0,
      pressure: convertToDouble(json['pressure']) ?? 0,
      humidity: convertToDouble(json['humidity']) ?? 0,
      windSpeed: convertToDouble(json['wind_speed']) ?? 0,
      weather: WeatherDescription.fromJson(json['weather'][0]),
      sunset: json['sunset'] ?? 0,
      sunrise: json['sunrise'] ?? 0,
      clouds: convertToInt(json['clouds']) ?? 0,
      uvi: convertToInt(json['uvi']) ?? 0,
    );
  }
}
