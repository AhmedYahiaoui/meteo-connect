// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyWeatherAdapter extends TypeAdapter<DailyWeather> {
  @override
  final int typeId = 5;

  @override
  DailyWeather read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyWeather(
      dt: fields[0] as int,
      tempDay: fields[1] as double,
      tempMin: fields[2] as double,
      tempMax: fields[3] as double,
      feelsLikeDay: fields[4] as double,
      pressure: fields[5] as int,
      humidity: fields[6] as int,
      windSpeed: fields[7] as double,
      weather: (fields[8] as List).cast<WeatherDescription>(),
      clouds: fields[9] as int,
      uvi: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DailyWeather obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.dt)
      ..writeByte(1)
      ..write(obj.tempDay)
      ..writeByte(2)
      ..write(obj.tempMin)
      ..writeByte(3)
      ..write(obj.tempMax)
      ..writeByte(4)
      ..write(obj.feelsLikeDay)
      ..writeByte(5)
      ..write(obj.pressure)
      ..writeByte(6)
      ..write(obj.humidity)
      ..writeByte(7)
      ..write(obj.windSpeed)
      ..writeByte(8)
      ..write(obj.weather)
      ..writeByte(9)
      ..write(obj.clouds)
      ..writeByte(10)
      ..write(obj.uvi);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyWeatherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
