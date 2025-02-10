// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 2;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      name: fields[0] as String,
      defaultCity: fields[1] as String,
      useDarkMode: fields[2] as bool,
      useFahrenheit: fields[3] as bool,
      city: fields[4] as String?,
      country: fields[5] as String?,
      latitude: fields[6] as double?,
      longitude: fields[7] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.defaultCity)
      ..writeByte(2)
      ..write(obj.useDarkMode)
      ..writeByte(3)
      ..write(obj.useFahrenheit)
      ..writeByte(4)
      ..write(obj.city)
      ..writeByte(5)
      ..write(obj.country)
      ..writeByte(6)
      ..write(obj.latitude)
      ..writeByte(7)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
