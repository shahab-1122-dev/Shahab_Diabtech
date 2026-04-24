// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glucose_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GlucoseModelAdapter extends TypeAdapter<GlucoseModel> {
  @override
  final int typeId = 0;

  @override
  GlucoseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GlucoseModel(
      value: fields[0] as double,
      dateTime: fields[1] as DateTime,
      readingType: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, GlucoseModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.value)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.readingType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GlucoseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
