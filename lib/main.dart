import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/location/user_location_model.dart';
import 'package:meteo_connect/data/models/user/user_model.dart';
import 'package:meteo_connect/data/models/weather/alertWeather/alert_weather_model.dart';
import 'package:meteo_connect/data/models/weather/currentWeather/current_weather_model.dart';
import 'package:meteo_connect/data/models/weather/dailyWeather/daily_weather_model.dart';
import 'package:meteo_connect/data/models/weather/descriptionWeather/weather_description_model.dart';
import 'package:meteo_connect/data/models/weather/hourlyWeather/hourly_weather_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/features/home/boarding_screen.dart';
import 'package:meteo_connect/features/providers/user_provider.dart';
import 'package:meteo_connect/services/location_service.dart';
import 'package:meteo_connect/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Create a ProviderContainer
  final container = ProviderContainer();

  // Register adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(CityModelAdapter());
  Hive.registerAdapter(WeatherModelAdapter());
  Hive.registerAdapter(CurrentWeatherAdapter());
  Hive.registerAdapter(DailyWeatherAdapter());
  Hive.registerAdapter(HourlyWeatherAdapter());
  Hive.registerAdapter(WeatherDescriptionAdapter());
  Hive.registerAdapter(AlertsWeatherAdapter());
  Hive.registerAdapter(UserLocationModelAdapter());

  // Open boxes
  await Hive.openBox<UserModel>('userbox');
  await Hive.openBox<CityModel>('cities');
  await Hive.openBox<WeatherModel>('weatherBox');
  await Hive.openBox<CurrentWeather>('currentWeatherBox');
  await Hive.openBox<DailyWeather>('dailyWeatherBox');
  await Hive.openBox<HourlyWeather>('hourlyWeatherBox');
  await Hive.openBox<WeatherDescription>('descriptionWeatherBox');
  await Hive.openBox<AlertsWeather>('alertsWeatherBox');
  await Hive.openBox<UserLocationModel>('userLocationBox');

  // Initialize NotificationService
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.scheduleWeatherCheck();

  // Get current location and update user
  final userNotifier = container.read(userProvider.notifier);
  final locationService = LocationService();

  try {
    // Get the city and country
    final UserLocationModel userLocationModel =
        await locationService.getCityAndCountry();

    // Update the user with the location data
    await userNotifier.updateUserLocation(
      city: userLocationModel.city,
      country: userLocationModel.country,
      lat: userLocationModel.latitude,
      lng: userLocationModel.longitude,
    );
  } catch (e) {
    // Handle error
  }

  // Show the boarding screen while refreshing weather data
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Montserrat'),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: const BoardingScreen(), // Show the boarding screen first
      ),
    ),
  );
}
