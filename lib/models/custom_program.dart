import 'package:hive/hive.dart';

part 'custom_program.g.dart';

@HiveType(typeId: 5)
class CustomProgram extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<CustomWorkoutDay> days;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? lastModified;

  @HiveField(6)
  String? category; // Force, Hypertrophie, Endurance, etc.

  @HiveField(7)
  int sessionsPerWeek;

  @HiveField(8)
  bool isTemplate; // Si c'est un template pré-rempli

  CustomProgram({
    required this.id,
    required this.name,
    required this.description,
    required this.days,
    required this.createdAt,
    this.lastModified,
    this.category,
    required this.sessionsPerWeek,
    this.isTemplate = false,
  });

  // Créer un programme vierge
  factory CustomProgram.empty() {
    return CustomProgram(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Mon Programme',
      description: 'Programme personnalisé',
      days: [],
      createdAt: DateTime.now(),
      sessionsPerWeek: 3,
    );
  }

  // Créer un template pré-rempli
  factory CustomProgram.template(String templateName) {
    switch (templateName) {
      case 'push_pull_legs':
        return CustomProgram(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Push Pull Legs (Template)',
          description: 'Programme classique Push/Pull/Legs à personnaliser',
          days: [
            CustomWorkoutDay(
              dayName: 'Push (Poussé)',
              exercises: [
                CustomExercise(name: 'Développé couché', sets: 4, reps: 8, rest: 90),
                CustomExercise(name: 'Développé incliné haltères', sets: 3, reps: 10, rest: 75),
                CustomExercise(name: 'Écarté poulie haute', sets: 3, reps: 12, rest: 60),
                CustomExercise(name: 'Développé militaire', sets: 4, reps: 8, rest: 90),
                CustomExercise(name: 'Élévations latérales', sets: 3, reps: 12, rest: 60),
                CustomExercise(name: 'Extension triceps', sets: 3, reps: 12, rest: 60),
              ],
            ),
            CustomWorkoutDay(
              dayName: 'Pull (Tirage)',
              exercises: [
                CustomExercise(name: 'Tractions', sets: 4, reps: 8, rest: 90),
                CustomExercise(name: 'Rowing barre', sets: 4, reps: 8, rest: 90),
                CustomExercise(name: 'Tirage horizontal', sets: 3, reps: 10, rest: 75),
                CustomExercise(name: 'Pull-over', sets: 3, reps: 12, rest: 60),
                CustomExercise(name: 'Curl barre', sets: 3, reps: 10, rest: 60),
                CustomExercise(name: 'Curl marteau', sets: 3, reps: 12, rest: 60),
              ],
            ),
            CustomWorkoutDay(
              dayName: 'Legs (Jambes)',
              exercises: [
                CustomExercise(name: 'Squat', sets: 4, reps: 8, rest: 120),
                CustomExercise(name: 'Presse à cuisses', sets: 4, reps: 10, rest: 90),
                CustomExercise(name: 'Leg curl', sets: 3, reps: 12, rest: 75),
                CustomExercise(name: 'Extension quadriceps', sets: 3, reps: 12, rest: 75),
                CustomExercise(name: 'Soulevé de terre roumain', sets: 3, reps: 10, rest: 90),
                CustomExercise(name: 'Mollets debout', sets: 4, reps: 15, rest: 60),
              ],
            ),
          ],
          createdAt: DateTime.now(),
          sessionsPerWeek: 3,
          isTemplate: true,
          category: 'Hypertrophie',
        );

      case 'full_body':
        return CustomProgram(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Full Body (Template)',
          description: 'Programme corps complet 3x par semaine',
          days: [
            CustomWorkoutDay(
              dayName: 'Full Body A',
              exercises: [
                CustomExercise(name: 'Squat', sets: 4, reps: 8, rest: 120),
                CustomExercise(name: 'Développé couché', sets: 4, reps: 8, rest: 90),
                CustomExercise(name: 'Rowing barre', sets: 3, reps: 10, rest: 90),
                CustomExercise(name: 'Développé militaire', sets: 3, reps: 10, rest: 75),
                CustomExercise(name: 'Curl biceps', sets: 2, reps: 12, rest: 60),
                CustomExercise(name: 'Extension triceps', sets: 2, reps: 12, rest: 60),
              ],
            ),
            CustomWorkoutDay(
              dayName: 'Full Body B',
              exercises: [
                CustomExercise(name: 'Soulevé de terre', sets: 4, reps: 6, rest: 120),
                CustomExercise(name: 'Développé incliné', sets: 4, reps: 8, rest: 90),
                CustomExercise(name: 'Tractions', sets: 3, reps: 8, rest: 90),
                CustomExercise(name: 'Presse à cuisses', sets: 3, reps: 10, rest: 90),
                CustomExercise(name: 'Élévations latérales', sets: 3, reps: 12, rest: 60),
                CustomExercise(name: 'Abdominaux', sets: 3, reps: 15, rest: 45),
              ],
            ),
          ],
          createdAt: DateTime.now(),
          sessionsPerWeek: 3,
          isTemplate: true,
          category: 'Force',
        );

      case 'upper_lower':
        return CustomProgram(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Upper/Lower (Template)',
          description: 'Programme haut/bas du corps 4x par semaine',
          days: [
            CustomWorkoutDay(
              dayName: 'Upper A (Haut)',
              exercises: [
                CustomExercise(name: 'Développé couché', sets: 4, reps: 8, rest: 90),
                CustomExercise(name: 'Rowing barre', sets: 4, reps: 8, rest: 90),
                CustomExercise(name: 'Développé militaire', sets: 3, reps: 10, rest: 75),
                CustomExercise(name: 'Tirage vertical', sets: 3, reps: 10, rest: 75),
                CustomExercise(name: 'Curl barre', sets: 2, reps: 12, rest: 60),
                CustomExercise(name: 'Extension triceps', sets: 2, reps: 12, rest: 60),
              ],
            ),
            CustomWorkoutDay(
              dayName: 'Lower A (Bas)',
              exercises: [
                CustomExercise(name: 'Squat', sets: 4, reps: 8, rest: 120),
                CustomExercise(name: 'Leg curl', sets: 3, reps: 10, rest: 90),
                CustomExercise(name: 'Extension quadriceps', sets: 3, reps: 12, rest: 75),
                CustomExercise(name: 'Soulevé de terre roumain', sets: 3, reps: 10, rest: 90),
                CustomExercise(name: 'Mollets', sets: 4, reps: 15, rest: 60),
              ],
            ),
          ],
          createdAt: DateTime.now(),
          sessionsPerWeek: 4,
          isTemplate: true,
          category: 'Hypertrophie',
        );

      default:
        return CustomProgram.empty();
    }
  }

  // Exporter en JSON pour partage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'days': days.map((d) => d.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified?.toIso8601String(),
      'category': category,
      'sessionsPerWeek': sessionsPerWeek,
      'isTemplate': isTemplate,
    };
  }

  // Importer depuis JSON
  factory CustomProgram.fromJson(Map<String, dynamic> json) {
    return CustomProgram(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      days: (json['days'] as List).map((d) => CustomWorkoutDay.fromJson(d)).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: json['lastModified'] != null ? DateTime.parse(json['lastModified']) : null,
      category: json['category'],
      sessionsPerWeek: json['sessionsPerWeek'],
      isTemplate: json['isTemplate'] ?? false,
    );
  }
}

@HiveType(typeId: 6)
class CustomWorkoutDay {
  @HiveField(0)
  String dayName;

  @HiveField(1)
  List<CustomExercise> exercises;

  @HiveField(2)
  String? notes;

  CustomWorkoutDay({
    required this.dayName,
    required this.exercises,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayName': dayName,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'notes': notes,
    };
  }

  factory CustomWorkoutDay.fromJson(Map<String, dynamic> json) {
    return CustomWorkoutDay(
      dayName: json['dayName'],
      exercises: (json['exercises'] as List).map((e) => CustomExercise.fromJson(e)).toList(),
      notes: json['notes'],
    );
  }
}

@HiveType(typeId: 7)
class CustomExercise {
  @HiveField(0)
  String name;

  @HiveField(1)
  int sets;

  @HiveField(2)
  int reps;

  @HiveField(3)
  int rest; // Repos en secondes

  @HiveField(4)
  String? notes;

  @HiveField(5)
  double? weight; // Poids utilisé (optionnel)

  @HiveField(6)
  String? targetMuscle; // Muscle ciblé

  CustomExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    this.notes,
    this.weight,
    this.targetMuscle,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'rest': rest,
      'notes': notes,
      'weight': weight,
      'targetMuscle': targetMuscle,
    };
  }

  factory CustomExercise.fromJson(Map<String, dynamic> json) {
    return CustomExercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      rest: json['rest'],
      notes: json['notes'],
      weight: json['weight']?.toDouble(),
      targetMuscle: json['targetMuscle'],
    );
  }
}
