// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mascot_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MascotSettingsAdapter extends TypeAdapter<MascotSettings> {
  @override
  final int typeId = 10;

  @override
  MascotSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MascotSettings(
      mascotType: fields[0] as String,
      isVisible: fields[1] as bool,
      customName: fields[2] as String?,
      lastInteraction: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, MascotSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.mascotType)
      ..writeByte(1)
      ..write(obj.isVisible)
      ..writeByte(2)
      ..write(obj.customName)
      ..writeByte(3)
      ..write(obj.lastInteraction);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MascotSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
