// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_gesture.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomGestureAdapter extends TypeAdapter<CustomGesture> {
  @override
  final int typeId = 0;

  @override
  CustomGesture read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomGesture(
      text: fields[0] as String,
      flexReadings: (fields[1] as List).cast<int>(),
      accelX: fields[2] as double,
      accelY: fields[3] as double,
      accelZ: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, CustomGesture obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.text)
      ..writeByte(1)
      ..write(obj.flexReadings)
      ..writeByte(2)
      ..write(obj.accelX)
      ..writeByte(3)
      ..write(obj.accelY)
      ..writeByte(4)
      ..write(obj.accelZ);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomGestureAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
