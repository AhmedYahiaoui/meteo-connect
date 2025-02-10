import 'package:flutter/material.dart';
import 'package:meteo_connect/core/constants/assets.dart';
import 'package:meteo_connect/data/models/weather/descriptionWeather/weather_description_model.dart';
import 'package:rive/rive.dart';
import 'package:timezone/timezone.dart' as tz;

class WeatherBackgroundWidget extends StatefulWidget {
  final String timezone;
  final WeatherDescription weatherCondition;
  final double? width;
  final double? height;
  final Widget child;
  final BoxFit fit;
  final Alignment alignment;

  const WeatherBackgroundWidget({
    super.key,
    required this.timezone,
    required this.weatherCondition,
    required this.child,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  @override
  State<WeatherBackgroundWidget> createState() =>
      _WeatherBackgroundWidgetState();
}

class _WeatherBackgroundWidgetState extends State<WeatherBackgroundWidget> {
  late tz.TZDateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    final location = tz.getLocation(widget.timezone);
    _currentTime = tz.TZDateTime.now(location);
  }

  @override
  void didUpdateWidget(WeatherBackgroundWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timezone != widget.timezone) {
      _updateTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background time-based animation
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: RiveAnimation.asset(
              AppAssets.getBackgroundTheme(_currentTime),
              fit: widget.fit,
              alignment: widget.alignment,
            ),
          ),
        ),

        // Weather state animation
        if (AppAssets.getWeatherState(widget.weatherCondition.main).isNotEmpty)
          _weatherStateAnimation(),

        // Child widget
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }

  // Weather state animation
  Widget _weatherStateAnimation() {
    if (widget.weatherCondition.main == "Clouds") {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 200,
          child: Stack(
            children: [
              Positioned.fill(
                child: RiveAnimation.asset(
                  AppAssets.getWeatherState(widget.weatherCondition.main),
                  fit: BoxFit.cover,
                  alignment: widget.alignment,
                  onInit: (artboard) {
                    final controllers = [
                      SimpleAnimation('Cloud 1'),
                      SimpleAnimation('Cloud 2'),
                      SimpleAnimation('Cloud 3'),
                      SimpleAnimation('Cloud 4'),
                    ];
                    controllers.forEach(artboard.addController);
                    final cloudCount = {
                      'few clouds': 1,
                      'scattered clouds': 2,
                      'broken clouds': 3,
                      'overcast clouds': 4,
                    }[widget.weatherCondition.description.toLowerCase()];
                    if (cloudCount != null) {
                      for (int i = 0; i < cloudCount; i++) {
                        // controllers[i].reset();
                        controllers[i].isActive = true;
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Positioned.fill(
        child: RiveAnimation.asset(
          AppAssets.getWeatherState(widget.weatherCondition.main),
          fit: BoxFit.cover,
          alignment: widget.alignment,
        ),
      );
    }
  }
}
