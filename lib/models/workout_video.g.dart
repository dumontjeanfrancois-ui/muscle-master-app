// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_video.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutVideoAdapter extends TypeAdapter<WorkoutVideo> {
  @override
  final int typeId = 4;

  @override
  WorkoutVideo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutVideo(
      id: fields[0] as String,
      exerciseName: fields[1] as String,
      videoPath: fields[2] as String,
      recordedAt: fields[3] as DateTime,
      durationSeconds: fields[4] as int,
      keyFramePaths: (fields[5] as List).cast<String>(),
      analysis: fields[6] as WorkoutAnalysis?,
      stats: (fields[7] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutVideo obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.exerciseName)
      ..writeByte(2)
      ..write(obj.videoPath)
      ..writeByte(3)
      ..write(obj.recordedAt)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.keyFramePaths)
      ..writeByte(6)
      ..write(obj.analysis)
      ..writeByte(7)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutVideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutAnalysisAdapter extends TypeAdapter<WorkoutAnalysis> {
  @override
  final int typeId = 5;

  @override
  WorkoutAnalysis read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutAnalysis(
      overallScore: fields[0] as int,
      technicalFeedback: fields[1] as String,
      strengthPoints: (fields[2] as List).cast<String>(),
      improvementPoints: (fields[3] as List).cast<String>(),
      detailedScores: (fields[4] as Map).cast<String, int>(),
      analyzedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutAnalysis obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.overallScore)
      ..writeByte(1)
      ..write(obj.technicalFeedback)
      ..writeByte(2)
      ..write(obj.strengthPoints)
      ..writeByte(3)
      ..write(obj.improvementPoints)
      ..writeByte(4)
      ..write(obj.detailedScores)
      ..writeByte(5)
      ..write(obj.analyzedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAnalysisAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
