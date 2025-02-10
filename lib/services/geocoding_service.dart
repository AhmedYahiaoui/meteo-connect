import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/strings.dart';

class GeocodingService {
  final String baseUrl = AppStrings.baseGeoUrl;
  final String apiKey = AppStrings.apiKey;

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/direct?q=$query&limit=5&appid=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((city) => {
                  'name': city['name'],
                  'country': city['country'],
                  'state': city['state'],
                  'lat': city['lat'],
                  'lon': city['lon'],
                })
            .toList();
      } else {
        throw Exception('Failed to search cities');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }
}
