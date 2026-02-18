import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service de gestion des exercices favoris
/// Utilise SharedPreferences pour la persistance
class ExerciseFavoritesService {
  static const String _favoritesKey = 'favorite_exercises';

  /// Récupérer la liste des IDs d'exercices favoris
  Future<Set<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);
      
      if (favoritesJson == null || favoritesJson.isEmpty) {
        if (kDebugMode) print('ℹ️ Aucun favori trouvé');
        return {};
      }
      
      final favoritesList = List<String>.from(json.decode(favoritesJson));
      if (kDebugMode) print('✅ ${favoritesList.length} favoris chargés');
      
      return favoritesList.toSet();
    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors du chargement des favoris: $e');
      return {};
    }
  }

  /// Ajouter un exercice aux favoris
  Future<bool> addFavorite(String exerciseId) async {
    try {
      final favorites = await getFavorites();
      favorites.add(exerciseId);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favoritesKey, json.encode(favorites.toList()));
      
      if (kDebugMode) print('⭐ Exercice $exerciseId ajouté aux favoris');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors de l\'ajout aux favoris: $e');
      return false;
    }
  }

  /// Retirer un exercice des favoris
  Future<bool> removeFavorite(String exerciseId) async {
    try {
      final favorites = await getFavorites();
      favorites.remove(exerciseId);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favoritesKey, json.encode(favorites.toList()));
      
      if (kDebugMode) print('🗑️ Exercice $exerciseId retiré des favoris');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors de la suppression des favoris: $e');
      return false;
    }
  }

  /// Vérifier si un exercice est dans les favoris
  Future<bool> isFavorite(String exerciseId) async {
    final favorites = await getFavorites();
    return favorites.contains(exerciseId);
  }

  /// Basculer le statut favori d'un exercice
  Future<bool> toggleFavorite(String exerciseId) async {
    final isFav = await isFavorite(exerciseId);
    if (isFav) {
      return await removeFavorite(exerciseId);
    } else {
      return await addFavorite(exerciseId);
    }
  }

  /// Obtenir le nombre total de favoris
  Future<int> getFavoritesCount() async {
    final favorites = await getFavorites();
    return favorites.length;
  }

  /// Effacer tous les favoris
  Future<bool> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      
      if (kDebugMode) print('🗑️ Tous les favoris ont été effacés');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors de l\'effacement des favoris: $e');
      return false;
    }
  }

  /// Exporter les favoris en JSON
  Future<String?> exportFavorites() async {
    try {
      final favorites = await getFavorites();
      if (favorites.isEmpty) {
        if (kDebugMode) print('ℹ️ Aucun favori à exporter');
        return null;
      }
      
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'favorites': favorites.toList(),
      };
      
      final jsonString = json.encode(exportData);
      if (kDebugMode) print('📤 ${favorites.length} favoris exportés');
      return jsonString;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors de l\'export des favoris: $e');
      return null;
    }
  }

  /// Importer les favoris depuis JSON
  Future<bool> importFavorites(String jsonString, {bool merge = true}) async {
    try {
      final importData = json.decode(jsonString) as Map<String, dynamic>;
      final importedFavorites = List<String>.from(importData['favorites'] ?? []);
      
      if (importedFavorites.isEmpty) {
        if (kDebugMode) print('ℹ️ Aucun favori à importer');
        return false;
      }
      
      Set<String> finalFavorites;
      if (merge) {
        // Fusion avec les favoris existants
        final existing = await getFavorites();
        finalFavorites = {...existing, ...importedFavorites};
      } else {
        // Remplacement complet
        finalFavorites = importedFavorites.toSet();
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favoritesKey, json.encode(finalFavorites.toList()));
      
      if (kDebugMode) print('📥 ${importedFavorites.length} favoris importés (total: ${finalFavorites.length})');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur lors de l\'import des favoris: $e');
      return false;
    }
  }
}
