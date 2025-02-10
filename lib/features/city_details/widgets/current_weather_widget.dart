import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meteo_connect/core/constants/colors.dart';
import 'package:meteo_connect/core/utils/tools.dart';
import 'package:meteo_connect/core/utils/unit_converter.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/weather/hourlyWeather/hourly_weather_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/features/city_details/widgets/curved_line_chart_widget.dart';
import 'package:meteo_connect/widgets/meteo_connect_text.dart';
import 'package:meteo_connect/widgets/weather_background_widget.dart';
import 'package:timezone/timezone.dart' as tz;

class CurrentWeatherWidget extends StatelessWidget {
  final WeatherModel weather;
  final CityModel city;
  final HourlyWeather? selectedHourlyWeather;
  final bool useFahrenheit;
  final bool isDarkMode;

  const CurrentWeatherWidget({
    Key? key,
    required this.city,
    required this.weather,
    required this.useFahrenheit,
    this.selectedHourlyWeather,
    this.isDarkMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if selectedHourlyWeather is initialized
    if (selectedHourlyWeather == null) {
      return const Center(child: Text('Select an hour to see the details.'));
    }

    List<double> chartTemperatures = [
      weather.hourly[0].temp,
      weather.hourly[8].temp,
      weather.hourly[12].temp,
      weather.hourly[16].temp,
      weather.hourly[20].temp
    ];

    final location = tz.getLocation(weather.timezone);
    final now = tz.TZDateTime.now(location);

    return WeatherBackgroundWidget(
      timezone: weather.timezone,
      weatherCondition: weather.current.weather,
      height: MediaQuery.sizeOf(context).height * 0.6,
      width: MediaQuery.sizeOf(context).width,
      fit: BoxFit.fill,
      child: Container(
        color: Colors.transparent.withOpacity(0),
        margin: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 10,
          right: 10,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 22,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MeteoConnectText(text: city.name),
                          MeteoConnectText(text: city.country, fontSize: 14),
                        ],
                      ),
                    ],
                  ),
                  MeteoConnectText(
                    text:
                        '${DateFormat('HH a').format(now)}, ${getFormattedDate(selectedHourlyWeather!.dt.toString())}',
                    fontSize: 15,
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              MeteoConnectText(
                text: UnitConverter.formatTemperature(
                  selectedHourlyWeather!
                      .temp, // Use the selected hourly weather
                  useFahrenheit,
                  showMetrics: false,
                ),
                fontSize: 90,
              ),
              MeteoConnectText(
                text: weather.current.weather.description,
                fontSize: 18,
              ),
              const SizedBox(height: 20),
              _buildWeatherInfo(),
              const SizedBox(height: 20),
              _weatherChartWidget(context, chartTemperatures),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    // Check if selectedHourlyWeather is initialized
    if (selectedHourlyWeather == null) {
      return const Center(child: Text('Select an hour to see the details.'));
    }

    String pressureInHpa = selectedHourlyWeather!.pressure.toStringAsFixed(0);
    int humidity = selectedHourlyWeather!.humidity;
    double windSpeed = selectedHourlyWeather!.windSpeed;
    int currentClouds = selectedHourlyWeather!.clouds;
    int currentUvi = selectedHourlyWeather!.uvi;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _weatherInfoItem(Icons.water_drop_outlined, '$humidity%'),
            _weatherInfoItem(Icons.air, '$windSpeed m/s'),
            _weatherInfoItem(Icons.cloud_queue_rounded, '$pressureInHpa hPa'),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _weatherInfoItem(Icons.abc, '$currentClouds%',
                label: 'Cloud Coverage'),
            _weatherInfoItem(Icons.abc, '$currentUvi', label: 'UV Index'),
          ],
        ),
      ],
    );
  }

  Widget _weatherInfoItem(IconData icon, String value, {String? label}) {
    return Row(
      children: [
        label != null
            ? MeteoConnectText(
                text: label,
                fontSize: 14,
              )
            : Icon(icon),
        const SizedBox(
          width: 5,
        ),
        MeteoConnectText(
          text: value,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ],
    );
  }

  Widget _weatherChartWidget(
      BuildContext context, List<double> chartTemperatures) {
    return ClipRRect(
        child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.background.withOpacity(isDarkMode ? 0.08 : 0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 15,
                top: 15,
              ),
              child: MeteoConnectText(
                text: 'Temperature',
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Temperature Chart
            Container(
              padding: const EdgeInsets.only(left: 30, right: 20),
              width: MediaQuery.sizeOf(context).width,
              height: 150,
              child: CurvedLineChartWidget(
                temperatures: chartTemperatures,
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
