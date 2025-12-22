// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_program.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomProgramAdapter extends TypeAdapter<CustomProgram> {
  @override
  final int typeId = 5;

  @override
  CustomProgram read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomProgram(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      days: (fields[3] as List).cast<CustomWorkoutDay>(),
      createdAt: fields[4] as DateTime,
      lastModified: fields[5] as DateTime?,
      category: fields[6] as String?,
      sessionsPerWeek: fields[7] as int,
      isTemplate: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CustomProgram obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.days)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.lastModified)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.sessionsPerWeek)
      ..writeByte(8)
      ..write(obj.isTemplate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomWorkoutDayAdapter extends TypeAdapter<CustomWorkoutDay> {
  @override
  final int typeId = 6;

  @override
  CustomWorkoutDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomWorkoutDay(
      dayName: fields[0] as String,
      exercises: (fields[1] as List).cast<CustomExercise>(),
      notes: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomWorkoutDay obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.dayName)
      ..writeByte(1)
      ..write(obj.exercises)
      ..writeByte(2)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomWorkoutDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CustomExerciseAdapter extends TypeAdapter<CustomExercise> {
  @override
  final int typeId = 7;

  @override
  CustomExercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomExercise(
      name: fields[0] as String,
      sets: fields[1] as int,
      reps: fields[2] as int,
      rest: fields[3] as int,
      notes: fields[4] as String?,
      weight: fields[5] as double?,
      targetMuscle: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomExercise obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.rest)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.targetMuscle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
