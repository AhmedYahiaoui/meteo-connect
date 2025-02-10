import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meteo_connect/core/constants/strings.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';

class ApiService {
  Future<WeatherModel> getWeather(CityModel city) async {
    const String units = 'metric';
    const String lang = 'en';
    const String api = AppStrings.apiKey;
    const String url = AppStrings.baseWeatherUrl;

    double lat = city.latitude;
    double lon = city.longitude;

    try {
      String uri = '${url}lat=$lat&lon=$lon&appid=$api&units=$units&lang=$lang';
      final response = await http.get(
        Uri.parse(uri),
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server : $e');
    }
  }
}
