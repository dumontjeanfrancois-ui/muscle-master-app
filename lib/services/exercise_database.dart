import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import 'comprehensive_exercise_database.dart';

class ExerciseDatabase {
  static const String _exercisesKey = 'exercises_database';
  static const String _favoritesKey = 'favorite_exercises';

  /// Récupérer tous les exercices
  static Future<List<Exercise>> getAllExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = prefs.getString(_exercisesKey);
    
    if (exercisesJson == null) {
      // Première utilisation - charger les exercices par défaut (120+ exercices)
      final defaultExercises = ComprehensiveExerciseDatabase.getAllExercises();
      await _saveExercises(defaultExercises);
      return defaultExercises;
    }
    
    final List<dynamic> exercisesList = jsonDecode(exercisesJson);
    return exercisesList
        .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Sauvegarder les exercices
  static Future<void> _saveExercises(List<Exercise> exercises) async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = jsonEncode(exercises.map((e) => e.toJson()).toList());
    await prefs.setString(_exercisesKey, exercisesJson);
  }

  /// Rechercher des exercices
  static Future<List<Exercise>> searchExercises(String query) async {
    final allExercises = await getAllExercises();
    if (query.isEmpty) return allExercises;
    
    return allExercises.where((ex) => ex.matchesQuery(query)).toList();
  }

  /// Filtrer par muscle
  static Future<List<Exercise>> filterByMuscle(String muscle) async {
    final allExercises = await getAllExercises();
    return allExercises.where((ex) => 
      ex.primaryMuscles.contains(muscle) || 
      ex.secondaryMuscles.contains(muscle)
    ).toList();
  }

  /// Filtrer par équipement
  static Future<List<Exercise>> filterByEquipment(String equipment) async {
    final allExercises = await getAllExercises();
    return allExercises.where((ex) => ex.equipment == equipment).toList();
  }

  /// Filtrer par difficulté
  static Future<List<Exercise>> filterByDifficulty(String difficulty) async {
    final allExercises = await getAllExercises();
    return allExercises.where((ex) => ex.difficulty == difficulty).toList();
  }

  /// Récupérer les favoris
  static Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  /// Ajouter aux favoris
  static Future<void> addToFavorites(String exerciseId) async {
    final favorites = await getFavorites();
    if (!favorites.contains(exerciseId)) {
      favorites.add(exerciseId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  /// Retirer des favoris
  static Future<void> removeFromFavorites(String exerciseId) async {
    final favorites = await getFavorites();
    favorites.remove(exerciseId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favorites);
  }

  /// Vérifier si un exercice est favori
  static Future<bool> isFavorite(String exerciseId) async {
    final favorites = await getFavorites();
    return favorites.contains(exerciseId);
  }

  /// Obtenir les exercices favoris
  static Future<List<Exercise>> getFavoriteExercises() async {
    final allExercises = await getAllExercises();
    final favorites = await getFavorites();
    return allExercises.where((ex) => favorites.contains(ex.id)).toList();
  }

  /// Base de données d'exercices par défaut - Utilise maintenant ComprehensiveExerciseDatabase
  static List<Exercise> _getDefaultExercises() {
    return ComprehensiveExerciseDatabase.getAllExercises();
  }
}
