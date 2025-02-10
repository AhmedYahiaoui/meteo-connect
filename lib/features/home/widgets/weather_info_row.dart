import 'package:flutter/material.dart';
import 'package:meteo_connect/widgets/meteo_connect_text.dart';

class WeatherInfoRow extends StatelessWidget {
  final double humidity;
  final double windSpeed;
  final double pressure;

  const WeatherInfoRow({
    super.key,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem(
          context,
          Icons.water_drop,
          '${humidity.round()}%',
          'Humidity',
        ),
        _buildInfoItem(
          context,
          Icons.air,
          '$windSpeed m/s',
          'Wind',
        ),
        _buildInfoItem(
          context,
          Icons.air,
          '$pressure hPa',
          'Pressure',
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        MeteoConnectText(
          text: label,
          fontSize: 13,
        ),
        const SizedBox(height: 4),
        MeteoConnectText(
          text: value,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
