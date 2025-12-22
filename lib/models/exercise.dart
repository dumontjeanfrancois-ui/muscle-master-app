import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 0)
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<String> muscleGroups;

  @HiveField(4)
  String difficulty; // Débutant, Intermédiaire, Avancé

  @HiveField(5)
  String equipment; // Haltères, Barre, Poids de corps, Machine

  @HiveField(6)
  String videoUrl;

  @HiveField(7)
  String imageUrl;

  @HiveField(8)
  List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroups,
    required this.difficulty,
    required this.equipment,
    this.videoUrl = '',
    this.imageUrl = '',
    this.instructions = const [],
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      muscleGroups: List<String>.from(json['muscleGroups'] as List),
      difficulty: json['difficulty'] as String,
      equipment: json['equipment'] as String,
      videoUrl: json['videoUrl'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      instructions: json['instructions'] != null 
          ? List<String>.from(json['instructions'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroups': muscleGroups,
      'difficulty': difficulty,
      'equipment': equipment,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'instructions': instructions,
    };
  }
}
