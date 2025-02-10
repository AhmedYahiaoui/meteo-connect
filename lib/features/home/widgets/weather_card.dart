import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:meteo_connect/core/constants/colors.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/user/user_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/features/home/widgets/weather_info_row.dart';
import 'package:meteo_connect/widgets/meteo_connect_text.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/constants/assets.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../widgets/weather_background_widget.dart';

class WeatherCard extends StatefulWidget {
  final WeatherModel weather;
  final CityModel city;
  final UserModel user;
  final VoidCallback? onTap;
  final int? index;
  final bool showDragHandle;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.city,
    required this.user,
    this.onTap,
    this.index,
    this.showDragHandle = false,
  });

  @override
  WeatherCardState createState() => WeatherCardState();
}

class WeatherCardState extends State<WeatherCard> {
  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    double highestTemp = widget.weather.hourly
        .map((e) => e.temp)
        .reduce((a, b) => a > b ? a : b);
    double lowestTemp = widget.weather.hourly
        .map((e) => e.temp)
        .reduce((a, b) => a < b ? a : b);

    final location = tz.getLocation(widget.weather.timezone);
    final now = tz.TZDateTime.now(location);
    final isCurrentCity = widget.user.city?.toLowerCase() ==
            widget.city.name.toLowerCase() &&
        widget.user.country?.toLowerCase() == widget.city.country.toLowerCase();

    return WeatherBackgroundWidget(
      timezone: widget.weather.timezone,
      weatherCondition: widget.weather.current.weather,
      height: 220,
      width: MediaQuery.sizeOf(context).width,
      fit: BoxFit.cover,
      child: _buildMainContainer(
          context, now, isCurrentCity, highestTemp, lowestTemp),
    );
  }

  Widget _buildMainContainer(BuildContext context, tz.TZDateTime now,
      bool isCurrentCity, double highestTemp, double lowestTemp) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textLight.withOpacity(0.1)),
      ),
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          _buildBackgroundContainer(),
          _buildContentPadding(now, isCurrentCity, highestTemp, lowestTemp),
          if (widget.showDragHandle && widget.index != null) _buildDragHandle(),
        ],
      ),
    );
  }

  Widget _buildBackgroundContainer() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildContentPadding(tz.TZDateTime now, bool isCurrentCity,
      double highestTemp, double lowestTemp) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildGestureDetector(
                now, isCurrentCity, highestTemp, lowestTemp),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureDetector(tz.TZDateTime now, bool isCurrentCity,
      double highestTemp, double lowestTemp) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildWeatherInfo(
                    now, isCurrentCity, highestTemp, lowestTemp),
              ),
              _buildWeatherAnimation(now),
            ],
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
            child: Divider(),
          ),
          WeatherInfoRow(
            humidity: widget.weather.current.humidity,
            windSpeed: widget.weather.current.windSpeed,
            pressure: widget.weather.current.pressure,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(tz.TZDateTime now, bool isCurrentCity,
      double highestTemp, double lowestTemp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationHeader(now, isCurrentCity),
        const SizedBox(height: 10),
        _buildTemperatureInfo(highestTemp, lowestTemp),
        const SizedBox(height: 5),
        _buildWeatherCondition(),
      ],
    );
  }

  Widget _buildLocationHeader(tz.TZDateTime now, bool isCurrentCity) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCityInfo(),
          _buildTimeAndHomeInfo(now, isCurrentCity),
        ],
      ),
    );
  }

  Widget _buildCityInfo() {
    return Row(
      children: [
        const Icon(Icons.location_on_rounded, size: 22),
        const SizedBox(width: 5),
        MeteoConnectText(text: widget.city.name, fontSize: 18),
        MeteoConnectText(text: ', ${widget.city.country}', fontSize: 14),
      ],
    );
  }

  Widget _buildTimeAndHomeInfo(tz.TZDateTime now, bool isCurrentCity) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 20),
      child: Row(
        children: [
          MeteoConnectText(
            text: '${DateFormat('HH:mm').format(now)} • ',
            fontSize: 13,
          ),
          if (isCurrentCity) ...[
            const SizedBox(width: 5),
            const Icon(Icons.other_houses_rounded, size: 12),
            const SizedBox(width: 5),
            const MeteoConnectText(text: ' Domicile', fontSize: 13),
          ]
        ],
      ),
    );
  }

  Widget _buildTemperatureInfo(double highestTemp, double lowestTemp) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        MeteoConnectText(
          text: UnitConverter.formatTemperature(
            widget.weather.current.temp,
            widget.user.useFahrenheit,
          ),
          fontSize: 32,
        ),
        MeteoConnectText(
          text: '/ ${UnitConverter.formatTemperature(
            widget.weather.current.feelsLike,
            widget.user.useFahrenheit,
          )}',
          fontSize: 20,
          color: AppColors.background,
        ),
        const SizedBox(width: 50),
        _buildHighLowTemperature(highestTemp, lowestTemp),
      ],
    );
  }

  Widget _buildHighLowTemperature(double highestTemp, double lowestTemp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MeteoConnectText(
          text: 'H: ${UnitConverter.formatTemperature(
            highestTemp,
            widget.user.useFahrenheit,
          )}',
          fontSize: 14,
          color: Colors.grey.shade300,
        ),
        MeteoConnectText(
          text: 'L: ${UnitConverter.formatTemperature(
            lowestTemp,
            widget.user.useFahrenheit,
          )}',
          fontSize: 14,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  Widget _buildWeatherCondition() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.textLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        widget.weather.current.weather.main,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.background,
        ),
      ),
    );
  }

  Widget _buildWeatherAnimation(tz.TZDateTime now) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Lottie.asset(
        AppAssets.getWeatherAnimation(
          widget.weather.current.weather.main,
          now,
        ),
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildDragHandle() {
    return Positioned(
      top: 0,
      left: 0,
      child: ReorderableDragStartListener(
        index: widget.index!,
        child: const Padding(
          padding: EdgeInsets.all(12.0),
          child: RotatedBox(
            quarterTurns: 1,
            child: Icon(Icons.drag_indicator_rounded),
          ),
        ),
      ),
    );
  }
}
