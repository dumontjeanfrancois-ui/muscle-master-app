import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 4)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category; // Petit-déjeuner, Déjeuner, Dîner, Snack, Post-workout

  @HiveField(4)
  int calories;

  @HiveField(5)
  double protein; // en grammes

  @HiveField(6)
  double carbs; // en grammes

  @HiveField(7)
  double fats; // en grammes

  @HiveField(8)
  int prepTimeMinutes;

  @HiveField(9)
  List<String> ingredients;

  @HiveField(10)
  List<String> instructions;

  @HiveField(11)
  String imageUrl;

  @HiveField(12)
  List<String> tags; // Riche en protéines, Végétarien, Sans lactose, etc.

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.prepTimeMinutes,
    required this.ingredients,
    required this.instructions,
    this.imageUrl = '',
    this.tags = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      prepTimeMinutes: json['prepTimeMinutes'] as int,
      ingredients: List<String>.from(json['ingredients'] as List),
      instructions: List<String>.from(json['instructions'] as List),
      imageUrl: json['imageUrl'] as String? ?? '',
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'prepTimeMinutes': prepTimeMinutes,
      'ingredients': ingredients,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'tags': tags,
    };
  }
}
