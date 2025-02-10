import 'package:intl/intl.dart';

double? convertToDouble(dynamic data) {
  if (data is double) {
    return data;
  } else if (data is int) {
    return data.toDouble();
  } else if (data is String) {
    return double.parse(data);
  }
  return data;
}

int? convertToInt(dynamic data) {
  if (data is int) {
    return data;
  } else if (data is double) {
    return data.toInt();
  } else if (data is String) {
    return int.parse(data);
  }
  return data;
}

String formatTemperature(double temp, bool useFahrenheit,
    {int decimalPlaces = 2}) {
  // Convert temperature based on the unit and format to specified decimal places
  double convertedTemp = useFahrenheit ? (temp * 9 / 5) + 32 : temp;
  return convertedTemp.toStringAsFixed(decimalPlaces);
}

// hourly
String formatHour(int dt) {
  final date = DateTime.fromMillisecondsSinceEpoch(dt * 1000);
  return DateFormat('HH a').format(date);
}

// ZonedDateTime hourly
String formatHourString(int dt) {
  final formatedDate = '${dt.toString().padLeft(2, '0')}:00';
  return formatedDate;
}

// Monday
String getDayFromTimezone(String timezone) {
  int timestamp = convertToInt(timezone) ?? 0;
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  if (DateTime.now().day == date.day) return 'Today';
  if (DateTime.now().day + 1 == date.day) return 'Tommorrow';
  return DateFormat('EEEE').format(date);
}

// 12 Apr
String getFormattedDate(String timezone) {
  int timestamp = convertToInt(timezone) ?? 0;
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  return DateFormat('dd MMM').format(date);
}

bool compareCoordinates({
  required double weatherLat,
  required double weatherLon,
  required double cityLat,
  required double cityLon,
}) {
  bool result = weatherLat.toStringAsFixed(2) == cityLat.toStringAsFixed(2) &&
      weatherLon.toStringAsFixed(2) == cityLon.toStringAsFixed(2);
  return result;
}
