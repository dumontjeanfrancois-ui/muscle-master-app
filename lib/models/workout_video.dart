import 'package:hive/hive.dart';

part 'workout_video.g.dart';

@HiveType(typeId: 4)
class WorkoutVideo extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String exerciseName;

  @HiveField(2)
  String videoPath;

  @HiveField(3)
  DateTime recordedAt;

  @HiveField(4)
  int durationSeconds;

  @HiveField(5)
  List<String> keyFramePaths;

  @HiveField(6)
  WorkoutAnalysis? analysis;

  @HiveField(7)
  Map<String, dynamic> stats;

  WorkoutVideo({
    required this.id,
    required this.exerciseName,
    required this.videoPath,
    required this.recordedAt,
    required this.durationSeconds,
    required this.keyFramePaths,
    this.analysis,
    required this.stats,
  });
}

@HiveType(typeId: 5)
class WorkoutAnalysis extends HiveObject {
  @HiveField(0)
  int overallScore; // Score sur 100

  @HiveField(1)
  String technicalFeedback;

  @HiveField(2)
  List<String> strengthPoints;

  @HiveField(3)
  List<String> improvementPoints;

  @HiveField(4)
  Map<String, int> detailedScores; // posture, alignement, profondeur, symétrie

  @HiveField(5)
  DateTime analyzedAt;

  WorkoutAnalysis({
    required this.overallScore,
    required this.technicalFeedback,
    required this.strengthPoints,
    required this.improvementPoints,
    required this.detailedScores,
    required this.analyzedAt,
  });
}
