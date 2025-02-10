// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrentWeatherAdapter extends TypeAdapter<CurrentWeather> {
  @override
  final int typeId = 4;

  @override
  CurrentWeather read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrentWeather(
      temp: fields[0] as double,
      feelsLike: fields[1] as double,
      pressure: fields[2] as double,
      humidity: fields[3] as double,
      windSpeed: fields[4] as double,
      weather: fields[5] as WeatherDescription,
      createAt: fields[6] as int,
      sunset: fields[7] as int,
      sunrise: fields[8] as int,
      clouds: fields[9] as int,
      uvi: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CurrentWeather obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.temp)
      ..writeByte(1)
      ..write(obj.feelsLike)
      ..writeByte(2)
      ..write(obj.pressure)
      ..writeByte(3)
      ..write(obj.humidity)
      ..writeByte(4)
      ..write(obj.windSpeed)
      ..writeByte(5)
      ..write(obj.weather)
      ..writeByte(6)
      ..write(obj.createAt)
      ..writeByte(7)
      ..write(obj.sunset)
      ..writeByte(8)
      ..write(obj.sunrise)
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
      other is CurrentWeatherAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
