/// Modèle pour une séance d'entraînement complétée
class WorkoutSession {
  final String id;
  final String programId;
  final String programName;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final List<ExerciseLog> exercises;
  final String? notes;

  WorkoutSession({
    required this.id,
    required this.programId,
    required this.programName,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.exercises,
    this.notes,
  });

  // ✨ Getters pour compatibilité avec les écrans
  String get workoutName => programName;
  
  Duration get duration => Duration(seconds: durationSeconds);
  
  int get totalSets => exercises.fold<int>(0, (sum, ex) => sum + ex.sets.length);
  
  int get completedSets => exercises.fold<int>(
    0,
    (sum, ex) => sum + ex.sets.where((set) => set.completed).length,
  );
  
  double get completionRate {
    if (totalSets == 0) return 0;
    return (completedSets / totalSets) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'programId': programId,
      'programName': programName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'durationSeconds': durationSeconds,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'] as String,
      programId: json['programId'] as String,
      programName: json['programName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      durationSeconds: json['durationSeconds'] as int,
      exercises: (json['exercises'] as List)
          .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

/// Log d'un exercice pendant une séance
class ExerciseLog {
  final String exerciseName;
  final List<SetLog> sets;
  final String? notes;

  ExerciseLog({
    required this.exerciseName,
    required this.sets,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
    };
  }

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    return ExerciseLog(
      exerciseName: json['exerciseName'] as String,
      sets: (json['sets'] as List)
          .map((s) => SetLog.fromJson(s as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

/// Log d'une série
class SetLog {
  final int setNumber;
  final bool completed;
  final double? weight; // en kg
  final int? actualReps;
  final String? targetReps;
  final int? restSeconds;
  final DateTime? completedAt;

  SetLog({
    required this.setNumber,
    required this.completed,
    this.weight,
    this.actualReps,
    this.targetReps,
    this.restSeconds,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'completed': completed,
      'weight': weight,
      'actualReps': actualReps,
      'targetReps': targetReps,
      'restSeconds': restSeconds,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      setNumber: json['setNumber'] as int,
      completed: json['completed'] as bool,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      actualReps: json['actualReps'] as int?,
      targetReps: json['targetReps'] as String?,
      restSeconds: json['restSeconds'] as int?,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String) 
          : null,
    );
  }

  SetLog copyWith({
    int? setNumber,
    bool? completed,
    double? weight,
    int? actualReps,
    String? targetReps,
    int? restSeconds,
    DateTime? completedAt,
  }) {
    return SetLog(
      setNumber: setNumber ?? this.setNumber,
      completed: completed ?? this.completed,
      weight: weight ?? this.weight,
      actualReps: actualReps ?? this.actualReps,
      targetReps: targetReps ?? this.targetReps,
      restSeconds: restSeconds ?? this.restSeconds,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
