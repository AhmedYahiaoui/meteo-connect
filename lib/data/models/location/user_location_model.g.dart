// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_location_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserLocationModelAdapter extends TypeAdapter<UserLocationModel> {
  @override
  final int typeId = 9;

  @override
  UserLocationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserLocationModel(
      city: fields[0] as String?,
      country: fields[1] as String?,
      latitude: fields[2] as double?,
      longitude: fields[3] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, UserLocationModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.city)
      ..writeByte(1)
      ..write(obj.country)
      ..writeByte(2)
      ..write(obj.latitude)
      ..writeByte(3)
      ..write(obj.longitude);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserLocationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
