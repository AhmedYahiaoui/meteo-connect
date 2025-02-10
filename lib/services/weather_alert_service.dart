import 'package:meteo_connect/data/models/weather/currentWeather/current_weather_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/data/repositories/city_repository.dart';
import 'package:meteo_connect/data/repositories/weather_repository.dart';

class WeatherAlertService {
  final WeatherRepository _weatherRepository;
  final CityRepository _cityRepository;

  WeatherAlertService(this._weatherRepository, this._cityRepository);

  Future<bool> shouldSendAlert(String cityName) async {
    try {
      final city = await _cityRepository.findCityByName(cityName);
      if (city == null || city.name.isEmpty) {
        return false;
      }
      final WeatherModel? weatherModel =
          await _weatherRepository.getWeather(city);

      if (weatherModel == null) {
        return false;
      }
      // Check today's weather conditions
      final CurrentWeather currentWeather = weatherModel.current;

      // Alert conditions (you can customize these thresholds)
      return _checkAlertConditions(currentWeather);
    } catch (e) {
      print('Error checking weather alerts: $e');
      return false;
    }
  }

  bool _checkAlertConditions(CurrentWeather currentWeather) {
    // Example alert conditions
    return currentWeather.temp <= 0 || // Cold weather
            currentWeather.temp >= 35 || // Very hot weather
            currentWeather.windSpeed >= 50 || // Strong winds

            currentWeather.weather.id == 622 || // heavy shower snow

            currentWeather.weather.id == 522 || // heavy intensity shower rain
            currentWeather.weather.id == 504 || // extreme rain
            currentWeather.weather.id == 503 || // very heavy rain
            currentWeather.weather.id == 502 || // heavy intensity rain

            currentWeather.weather.id == 212 || // heavy thunderstorm

            currentWeather.weather.id == 314 || // heavy shower rain and drizzle
            currentWeather.weather.id == 312 // heavy intensity drizzle rain
        ;
  }
}
