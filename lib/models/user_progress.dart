import 'package:hive/hive.dart';

part 'user_progress.g.dart';

@HiveType(typeId: 5)
class UserProgress extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double weight; // en kg

  @HiveField(2)
  Map<String, double> measurements; // neck, chest, waist, hips, biceps, thighs, etc.

  @HiveField(3)
  String notes;

  @HiveField(4)
  String photoUrl;

  UserProgress({
    required this.date,
    required this.weight,
    this.measurements = const {},
    this.notes = '',
    this.photoUrl = '',
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      date: DateTime.parse(json['date'] as String),
      weight: (json['weight'] as num).toDouble(),
      measurements: Map<String, double>.from(json['measurements'] as Map? ?? {}),
      notes: json['notes'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'measurements': measurements,
      'notes': notes,
      'photoUrl': photoUrl,
    };
  }
}

@HiveType(typeId: 6)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String programId;

  @HiveField(3)
  String programName;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  List<ExerciseLog> exercises;

  @HiveField(6)
  String notes;

  WorkoutSession({
    required this.id,
    required this.date,
    required this.programId,
    required this.programName,
    required this.durationMinutes,
    required this.exercises,
    this.notes = '',
  });

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      programId: json['programId'] as String,
      programName: json['programName'] as String,
      durationMinutes: json['durationMinutes'] as int,
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'programId': programId,
      'programName': programName,
      'durationMinutes': durationMinutes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }
}

@HiveType(typeId: 7)
class ExerciseLog extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  String exerciseName;

  @HiveField(2)
  List<SetLog> sets;

  ExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as List)
          .map((e) => SetLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets.map((e) => e.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 8)
class SetLog extends HiveObject {
  @HiveField(0)
  int setNumber;

  @HiveField(1)
  double weight; // en kg

  @HiveField(2)
  int reps;

  @HiveField(3)
  bool completed;

  SetLog({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.completed = true,
  });

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      setNumber: json['setNumber'] as int,
      weight: (json['weight'] as num).toDouble(),
      reps: json['reps'] as int,
      completed: json['completed'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'completed': completed,
    };
  }
}
