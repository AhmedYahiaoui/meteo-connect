// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeatherModelAdapter extends TypeAdapter<WeatherModel> {
  @override
  final int typeId = 0;

  @override
  WeatherModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherModel(
      lat: fields[0] as double,
      lon: fields[1] as double,
      timezone: fields[2] as String,
      timezoneOffset: fields[3] as int,
      current: fields[4] as CurrentWeather,
      hourly: (fields[5] as List).cast<HourlyWeather>(),
      daily: (fields[6] as List).cast<DailyWeather>(),
      id: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.lat)
      ..writeByte(1)
      ..write(obj.lon)
      ..writeByte(2)
      ..write(obj.timezone)
      ..writeByte(3)
      ..write(obj.timezoneOffset)
      ..writeByte(4)
      ..write(obj.current)
      ..writeByte(5)
      ..write(obj.hourly)
      ..writeByte(6)
      ..write(obj.daily)
      ..writeByte(7)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
