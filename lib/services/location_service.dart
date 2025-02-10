import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meteo_connect/data/models/location/user_location_model.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Ask for permission again if denied
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
    }

    if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
      throw Exception('Location permissions are permanently denied.');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<UserLocationModel> getCityAndCountry() async {
    Position position = await getCurrentLocation();
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      return UserLocationModel(
        city: placemark.locality,
        country: placemark.country,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    }
    return UserLocationModel(
        latitude: position.latitude, longitude: position.longitude);
  }
}
