import 'package:hive/hive.dart';

part 'workout_program.g.dart';

@HiveType(typeId: 1)
class WorkoutProgram extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String level; // Débutant, Intermédiaire, Avancé

  @HiveField(4)
  String goal; // Force, Hypertrophie, Endurance, Perte de poids

  @HiveField(5)
  int durationWeeks;

  @HiveField(6)
  int sessionsPerWeek;

  @HiveField(7)
  List<WorkoutDay> workoutDays;

  WorkoutProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.goal,
    required this.durationWeeks,
    required this.sessionsPerWeek,
    required this.workoutDays,
  });

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    return WorkoutProgram(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      level: json['level'] as String,
      goal: json['goal'] as String,
      durationWeeks: json['durationWeeks'] as int,
      sessionsPerWeek: json['sessionsPerWeek'] as int,
      workoutDays: (json['workoutDays'] as List)
          .map((e) => WorkoutDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level': level,
      'goal': goal,
      'durationWeeks': durationWeeks,
      'sessionsPerWeek': sessionsPerWeek,
      'workoutDays': workoutDays.map((e) => e.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 2)
class WorkoutDay extends HiveObject {
  @HiveField(0)
  String dayName;

  @HiveField(1)
  String focus; // Push, Pull, Legs, Full Body, etc.

  @HiveField(2)
  List<WorkoutExercise> exercises;

  WorkoutDay({
    required this.dayName,
    required this.focus,
    required this.exercises,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      dayName: json['dayName'] as String,
      focus: json['focus'] as String,
      exercises: (json['exercises'] as List)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayName': dayName,
      'focus': focus,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 3)
class WorkoutExercise extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  String exerciseName;

  @HiveField(2)
  int sets;

  @HiveField(3)
  String reps; // "8-12", "15-20", "Max", etc.

  @HiveField(4)
  int restSeconds;

  @HiveField(5)
  String notes;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes = '',
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as String,
      restSeconds: json['restSeconds'] as int,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'notes': notes,
    };
  }
}
