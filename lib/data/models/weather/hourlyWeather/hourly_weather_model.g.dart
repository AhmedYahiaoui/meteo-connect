// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HourlyWeatherAdapter extends TypeAdapter<HourlyWeather> {
  @override
  final int typeId = 6;

  @override
  HourlyWeather read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HourlyWeather(
      dt: fields[0] as int,
      temp: fields[1] as double,
      feelsLike: fields[2] as double,
      pressure: fields[3] as int,
      humidity: fields[4] as int,
      windSpeed: fields[5] as double,
      weather: (fields[6] as List).cast<WeatherDescription>(),
      clouds: fields[7] as int,
      uvi: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HourlyWeather obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.dt)
      ..writeByte(1)
      ..write(obj.temp)
      ..writeByte(2)
      ..write(obj.feelsLike)
      ..writeByte(3)
      ..write(obj.pressure)
      ..writeByte(4)
      ..write(obj.humidity)
      ..writeByte(5)
      ..write(obj.windSpeed)
      ..writeByte(6)
      ..write(obj.weather)
      ..writeByte(7)
      ..write(obj.clouds)
      ..writeByte(8)
      ..write(obj.uvi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyWeatherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
