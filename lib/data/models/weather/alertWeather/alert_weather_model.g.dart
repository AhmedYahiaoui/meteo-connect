// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AlertsWeatherAdapter extends TypeAdapter<AlertsWeather> {
  @override
  final int typeId = 8;

  @override
  AlertsWeather read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AlertsWeather(
      senderName: fields[0] as String,
      event: fields[1] as String,
      start: fields[2] as String,
      end: fields[3] as String,
      description: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AlertsWeather obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.senderName)
      ..writeByte(1)
      ..write(obj.event)
      ..writeByte(2)
      ..write(obj.start)
      ..writeByte(3)
      ..write(obj.end)
      ..writeByte(4)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertsWeatherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
