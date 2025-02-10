import 'package:meteo_connect/data/models/weather/currentWeather/current_weather_model.dart';
import 'package:meteo_connect/data/models/weather/descriptionWeather/weather_description_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';

final mockWeatherDescription = WeatherDescription(
  id: 800,
  main: "Clear",
  description: "clear sky",
  icon: "01d",
);

final mockCurrentWeather = CurrentWeather(
  clouds: 20,
  uvi: 20,
  temp: 20,
  feelsLike: 22,
  pressure: 1013,
  humidity: 75,
  windSpeed: 5,
  weather: mockWeatherDescription,
  createAt: DateTime.now().millisecondsSinceEpoch,
  sunrise: DateTime.now().millisecondsSinceEpoch,
  sunset: DateTime.now().millisecondsSinceEpoch,
);

final mockWeatherModel = WeatherModel(
  id: "test-id-1",
  lat: 48.8566,
  lon: 2.3522,
  timezone: "UTC",
  timezoneOffset: 0,
  current: mockCurrentWeather,
  hourly: [],
  daily: [],
);
