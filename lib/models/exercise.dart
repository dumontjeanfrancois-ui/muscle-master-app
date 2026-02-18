/// Modèle pour un exercice de musculation
class Exercise {
  final String id;
  final String name;
  final String description;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String equipment;
  final String difficulty; // Débutant, Intermédiaire, Avancé
  final String category; // Force, Cardio, Flexibilité, etc.
  final List<String> instructions;
  final String? videoUrl;
  final String? imageUrl;
  final List<String>? tips;
  final List<String>? commonMistakes;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.category,
    required this.instructions,
    this.videoUrl,
    this.imageUrl,
    this.tips,
    this.commonMistakes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'equipment': equipment,
      'difficulty': difficulty,
      'category': category,
      'instructions': instructions,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'tips': tips,
      'commonMistakes': commonMistakes,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      primaryMuscles: List<String>.from(json['primaryMuscles'] as List),
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] as List),
      equipment: json['equipment'] as String,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String,
      instructions: List<String>.from(json['instructions'] as List),
      videoUrl: json['videoUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      tips: json['tips'] != null ? List<String>.from(json['tips'] as List) : null,
      commonMistakes: json['commonMistakes'] != null ? List<String>.from(json['commonMistakes'] as List) : null,
    );
  }

  /// Vérifie si l'exercice correspond à une requête de recherche
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        description.toLowerCase().contains(lowerQuery) ||
        primaryMuscles.any((m) => m.toLowerCase().contains(lowerQuery)) ||
        equipment.toLowerCase().contains(lowerQuery);
  }
}
