// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialSettingsAdapter extends TypeAdapter<SocialSettings> {
  @override
  final int typeId = 15;

  @override
  SocialSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialSettings(
      isEnabled: fields[0] as bool,
      invisibleMode: fields[1] as bool,
      maxConnections: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SocialSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.invisibleMode)
      ..writeByte(2)
      ..write(obj.maxConnections);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConnectionAdapter extends TypeAdapter<Connection> {
  @override
  final int typeId = 16;

  @override
  Connection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Connection(
      userId: fields[0] as String,
      friendId: fields[1] as String,
      pseudo: fields[2] as String,
      mascotType: fields[3] as String,
      createdAt: fields[4] as DateTime,
      isActive: fields[5] as bool,
      isDeleted: fields[6] as bool,
      deletedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Connection obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.friendId)
      ..writeByte(2)
      ..write(obj.pseudo)
      ..writeByte(3)
      ..write(obj.mascotType)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isActive)
      ..writeByte(6)
      ..write(obj.isDeleted)
      ..writeByte(7)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConnectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
