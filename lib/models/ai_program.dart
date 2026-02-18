

/// Programme personnalisé généré par l'IA
class AIProgram {
  String id;
  String name;
  String description;
  DateTime createdAt;
  String userProfile; // Niveau, objectif, disponibilité
  List<AIWorkoutDay> workoutDays;
  
  AIProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.userProfile,
    required this.workoutDays,
  });

  factory AIProgram.fromJson(Map<String, dynamic> json) {
    return AIProgram(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name']?.toString() ?? 'Programme sans nom',
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      userProfile: json['userProfile']?.toString() ?? 'Programme importé',
      workoutDays: (json['workoutDays'] as List? ?? [])
          .map((e) => AIWorkoutDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'userProfile': userProfile,
      'workoutDays': workoutDays.map((e) => e.toJson()).toList(),
    };
  }
}

/// Jour d'entraînement dans un programme IA
class AIWorkoutDay {
  String dayName;
  String focus;
  List<AIExerciseEntry> exercises;
  
  AIWorkoutDay({
    required this.dayName,
    required this.focus,
    required this.exercises,
  });

  factory AIWorkoutDay.fromJson(Map<String, dynamic> json) {
    return AIWorkoutDay(
      dayName: json['dayName']?.toString() ?? 'Jour',
      focus: json['focus']?.toString() ?? 'Non spécifié',
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => AIExerciseEntry.fromJson(e as Map<String, dynamic>))
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

/// Exercice avec suivi et annotations
class AIExerciseEntry {
  String exerciseName;
  int sets;
  String reps;
  int restSeconds;
  String notes; // Notes du coach IA
  
  // Suivi utilisateur (éditable)
  List<SetEntry> completedSets;
  String userNotes; // Annotations personnelles
  
  AIExerciseEntry({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.notes = '',
    this.completedSets = const [],
    this.userNotes = '',
  });

  factory AIExerciseEntry.fromJson(Map<String, dynamic> json) {
    return AIExerciseEntry(
      exerciseName: json['exerciseName']?.toString() ?? 'Exercice',
      sets: json['sets'] is int ? json['sets'] as int : int.tryParse(json['sets']?.toString() ?? '3') ?? 3,
      reps: json['reps']?.toString() ?? '10',
      restSeconds: json['restSeconds'] is int ? json['restSeconds'] as int : int.tryParse(json['restSeconds']?.toString() ?? '60') ?? 60,
      notes: json['notes']?.toString() ?? '',
      completedSets: json['completedSets'] != null
          ? (json['completedSets'] as List)
              .map((e) => SetEntry.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      userNotes: json['userNotes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseName': exerciseName,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'notes': notes,
      'completedSets': completedSets.map((e) => e.toJson()).toList(),
      'userNotes': userNotes,
    };
  }
}

/// Série d'exercice complétée
class SetEntry {
  int setNumber;
  double weight; // kg
  int reps;
  bool completed;
  DateTime? timestamp;
  
  SetEntry({
    required this.setNumber,
    required this.weight,
    required this.reps,
    this.completed = false,
    this.timestamp,
  });

  factory SetEntry.fromJson(Map<String, dynamic> json) {
    return SetEntry(
      setNumber: json['setNumber'] is int ? json['setNumber'] as int : int.tryParse(json['setNumber']?.toString() ?? '1') ?? 1,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : 0.0,
      reps: json['reps'] is int ? json['reps'] as int : int.tryParse(json['reps']?.toString() ?? '0') ?? 0,
      completed: json['completed'] == true,
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'completed': completed,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}
