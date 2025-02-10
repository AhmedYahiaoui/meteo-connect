import 'package:hive/hive.dart';

part 'alert_weather_model.g.dart';

@HiveType(typeId: 8)
class AlertsWeather {
  @HiveField(0)
  final String senderName;

  @HiveField(1)
  final String event;

  @HiveField(2)
  final String start;

  @HiveField(3)
  final String end;

  @HiveField(4)
  final String description;

  AlertsWeather({
    required this.senderName,
    required this.event,
    required this.start,
    required this.end,
    required this.description,
  });

  factory AlertsWeather.fromJson(Map<String, dynamic> json) {
    return AlertsWeather(
      senderName: json['sender_name'],
      event: json['event'],
      start: json['start'],
      end: json['end'],
      description: json['description'],
    );
  }
}
