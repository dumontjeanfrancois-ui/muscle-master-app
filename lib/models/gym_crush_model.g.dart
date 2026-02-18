// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_crush_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GymCrushSettingsAdapter extends TypeAdapter<GymCrushSettings> {
  @override
  final int typeId = 11;

  @override
  GymCrushSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GymCrushSettings(
      isEnabled: fields[0] as bool,
      maxDistance: fields[1] as int,
      maxActiveCrushes: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GymCrushSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isEnabled)
      ..writeByte(1)
      ..write(obj.maxDistance)
      ..writeByte(2)
      ..write(obj.maxActiveCrushes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymCrushSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GymCrushUserAdapter extends TypeAdapter<GymCrushUser> {
  @override
  final int typeId = 12;

  @override
  GymCrushUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GymCrushUser(
      userId: fields[0] as String,
      pseudo: fields[1] as String,
      mascotType: fields[2] as String,
      mascotName: fields[3] as String?,
      lastActivity: fields[4] as DateTime,
      gymId: fields[5] as String?,
      isActive: fields[6] as bool,
      expiresAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GymCrushUser obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.pseudo)
      ..writeByte(2)
      ..write(obj.mascotType)
      ..writeByte(3)
      ..write(obj.mascotName)
      ..writeByte(4)
      ..write(obj.lastActivity)
      ..writeByte(5)
      ..write(obj.gymId)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.expiresAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymCrushUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GymCrushInteractionAdapter extends TypeAdapter<GymCrushInteraction> {
  @override
  final int typeId = 13;

  @override
  GymCrushInteraction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GymCrushInteraction(
      interactionId: fields[0] as String,
      targetUserId: fields[1] as String,
      targetPseudo: fields[2] as String,
      targetMascotType: fields[3] as String,
      status: fields[4] as GymCrushStatus,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      chatUnlocked: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GymCrushInteraction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.interactionId)
      ..writeByte(1)
      ..write(obj.targetUserId)
      ..writeByte(2)
      ..write(obj.targetPseudo)
      ..writeByte(3)
      ..write(obj.targetMascotType)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.chatUnlocked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymCrushInteractionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GymCrushMessageAdapter extends TypeAdapter<GymCrushMessage> {
  @override
  final int typeId = 14;

  @override
  GymCrushMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GymCrushMessage(
      messageId: fields[0] as String,
      interactionId: fields[1] as String,
      senderId: fields[2] as String,
      receiverId: fields[3] as String,
      content: fields[4] as String,
      sentAt: fields[5] as DateTime,
      isRead: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, GymCrushMessage obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.messageId)
      ..writeByte(1)
      ..write(obj.interactionId)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.receiverId)
      ..writeByte(4)
      ..write(obj.content)
      ..writeByte(5)
      ..write(obj.sentAt)
      ..writeByte(6)
      ..write(obj.isRead);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GymCrushMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
