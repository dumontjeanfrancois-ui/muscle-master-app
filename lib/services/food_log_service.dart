import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/food_log.dart';

/// Service de gestion du journal alimentaire
class FoodLogService {
  static const String _logsKey = 'daily_food_logs';
  static const String _foodDatabaseKey = 'food_database';

  /// Sauvegarder un journal quotidien
  Future<bool> saveDailyLog(DailyFoodLog log) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_logsKey);
      
      Map<String, dynamic> logs = {};
      if (logsJson != null && logsJson.isNotEmpty) {
        logs = Map<String, dynamic>.from(json.decode(logsJson));
      }
      
      logs[log.dateKey] = log.toJson();
      await prefs.setString(_logsKey, json.encode(logs));
      
      if (kDebugMode) print('✅ Journal du ${log.dateKey} sauvegardé');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur sauvegarde journal: $e');
      return false;
    }
  }

  /// Récupérer le journal d'une date spécifique
  Future<DailyFoodLog?> getDailyLog(DateTime date) async {
    try {
      final dateKey = _getDateKey(date);
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_logsKey);
      
      if (logsJson == null || logsJson.isEmpty) {
        if (kDebugMode) print('ℹ️ Aucun journal trouvé pour $dateKey');
        return null;
      }
      
      final logs = Map<String, dynamic>.from(json.decode(logsJson));
      if (!logs.containsKey(dateKey)) {
        if (kDebugMode) print('ℹ️ Aucun journal pour $dateKey');
        return null;
      }
      
      return DailyFoodLog.fromJson(logs[dateKey]);
    } catch (e) {
      if (kDebugMode) print('❌ Erreur chargement journal: $e');
      return null;
    }
  }

  /// Récupérer tous les journaux
  Future<List<DailyFoodLog>> getAllLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_logsKey);
      
      if (logsJson == null || logsJson.isEmpty) {
        if (kDebugMode) print('ℹ️ Aucun journal trouvé');
        return [];
      }
      
      final logs = Map<String, dynamic>.from(json.decode(logsJson));
      final logsList = logs.values
          .map((l) => DailyFoodLog.fromJson(l as Map<String, dynamic>))
          .toList();
      
      logsList.sort((a, b) => b.date.compareTo(a.date));
      
      if (kDebugMode) print('✅ ${logsList.length} journaux chargés');
      return logsList;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur chargement journaux: $e');
      return [];
    }
  }

  /// Récupérer les journaux d'une période
  Future<List<DailyFoodLog>> getLogsBetween(DateTime start, DateTime end) async {
    final allLogs = await getAllLogs();
    return allLogs.where((log) {
      return log.date.isAfter(start.subtract(const Duration(days: 1))) &&
             log.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Ajouter un repas au journal du jour
  Future<bool> addMealToToday(Meal meal) async {
    final today = DateTime.now();
    var log = await getDailyLog(today);
    
    if (log == null) {
      log = DailyFoodLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: today,
        meals: [meal],
      );
    } else {
      log = log.copyWith(meals: [...log.meals, meal]);
    }
    
    return await saveDailyLog(log);
  }

  /// Supprimer un repas
  Future<bool> deleteMeal(DateTime date, String mealId) async {
    final log = await getDailyLog(date);
    if (log == null) return false;
    
    final updatedMeals = log.meals.where((m) => m.id != mealId).toList();
    final updatedLog = log.copyWith(meals: updatedMeals);
    
    return await saveDailyLog(updatedLog);
  }

  /// Mettre à jour la consommation d'eau
  Future<bool> updateWaterIntake(DateTime date, double liters) async {
    var log = await getDailyLog(date);
    
    if (log == null) {
      log = DailyFoodLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: date,
        meals: [],
        waterIntake: liters,
      );
    } else {
      log = log.copyWith(waterIntake: liters);
    }
    
    return await saveDailyLog(log);
  }

  /// Calculer les moyennes sur une période
  Future<Map<String, double>> getAverages(DateTime start, DateTime end) async {
    final logs = await getLogsBetween(start, end);
    
    if (logs.isEmpty) {
      return {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
        'fiber': 0,
        'water': 0,
      };
    }
    
    final totalCalories = logs.fold(0.0, (sum, log) => sum + log.totalCalories);
    final totalProtein = logs.fold(0.0, (sum, log) => sum + log.totalProtein);
    final totalCarbs = logs.fold(0.0, (sum, log) => sum + log.totalCarbs);
    final totalFat = logs.fold(0.0, (sum, log) => sum + log.totalFat);
    final totalFiber = logs.fold(0.0, (sum, log) => sum + log.totalFiber);
    final totalWater = logs.fold(0.0, (sum, log) => sum + (log.waterIntake ?? 0));
    
    final days = logs.length;
    
    return {
      'calories': totalCalories / days,
      'protein': totalProtein / days,
      'carbs': totalCarbs / days,
      'fat': totalFat / days,
      'fiber': totalFiber / days,
      'water': totalWater / days,
    };
  }

  /// Supprimer un journal
  Future<bool> deleteLog(DateTime date) async {
    try {
      final dateKey = _getDateKey(date);
      final prefs = await SharedPreferences.getInstance();
      final logsJson = prefs.getString(_logsKey);
      
      if (logsJson == null || logsJson.isEmpty) return false;
      
      final logs = Map<String, dynamic>.from(json.decode(logsJson));
      logs.remove(dateKey);
      
      await prefs.setString(_logsKey, json.encode(logs));
      if (kDebugMode) print('🗑️ Journal du $dateKey supprimé');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur suppression journal: $e');
      return false;
    }
  }

  /// Obtenir la clé de date au format "yyyy-MM-dd"
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Base de données d'aliments communs (100+ aliments)
  static List<FoodItem> getCommonFoods() {
    return [
      // ========== PROTÉINES ANIMALES ==========
      
      // Viandes blanches
      FoodItem(id: 'chicken_breast', name: 'Blanc de poulet', quantity: 100, unit: 'g', calories: 165, protein: 31, carbs: 0, fat: 3.6),
      FoodItem(id: 'turkey_breast', name: 'Blanc de dinde', quantity: 100, unit: 'g', calories: 135, protein: 30, carbs: 0, fat: 1),
      FoodItem(id: 'chicken_thigh', name: 'Cuisse de poulet', quantity: 100, unit: 'g', calories: 209, protein: 26, carbs: 0, fat: 11),
      
      // Viandes rouges
      FoodItem(id: 'beef_steak', name: 'Steak de bœuf', quantity: 100, unit: 'g', calories: 250, protein: 26, carbs: 0, fat: 15),
      FoodItem(id: 'ground_beef', name: 'Bœuf haché (5%)', quantity: 100, unit: 'g', calories: 215, protein: 26, carbs: 0, fat: 12),
      FoodItem(id: 'lamb', name: 'Agneau', quantity: 100, unit: 'g', calories: 294, protein: 25, carbs: 0, fat: 21),
      
      // Poissons
      FoodItem(id: 'salmon', name: 'Saumon', quantity: 100, unit: 'g', calories: 208, protein: 20, carbs: 0, fat: 13),
      FoodItem(id: 'tuna', name: 'Thon', quantity: 100, unit: 'g', calories: 132, protein: 28, carbs: 0, fat: 1.3),
      FoodItem(id: 'cod', name: 'Cabillaud', quantity: 100, unit: 'g', calories: 82, protein: 18, carbs: 0, fat: 0.7),
      FoodItem(id: 'tilapia', name: 'Tilapia', quantity: 100, unit: 'g', calories: 96, protein: 20, carbs: 0, fat: 1.7),
      FoodItem(id: 'sardines', name: 'Sardines', quantity: 100, unit: 'g', calories: 208, protein: 25, carbs: 0, fat: 11),
      FoodItem(id: 'mackerel', name: 'Maquereau', quantity: 100, unit: 'g', calories: 205, protein: 19, carbs: 0, fat: 14),
      
      // Œufs et produits laitiers
      FoodItem(id: 'eggs', name: 'Œufs entiers', quantity: 100, unit: 'g', calories: 155, protein: 13, carbs: 1.1, fat: 11),
      FoodItem(id: 'egg_whites', name: 'Blancs d\'œufs', quantity: 100, unit: 'g', calories: 52, protein: 11, carbs: 0.7, fat: 0.2),
      FoodItem(id: 'greek_yogurt', name: 'Yaourt grec 0%', quantity: 100, unit: 'g', calories: 59, protein: 10, carbs: 3.6, fat: 0.4),
      FoodItem(id: 'cottage_cheese', name: 'Fromage blanc 0%', quantity: 100, unit: 'g', calories: 72, protein: 12, carbs: 3.4, fat: 0.3),
      FoodItem(id: 'cheddar', name: 'Cheddar', quantity: 100, unit: 'g', calories: 403, protein: 25, carbs: 1.3, fat: 33),
      FoodItem(id: 'mozzarella', name: 'Mozzarella', quantity: 100, unit: 'g', calories: 280, protein: 28, carbs: 2.2, fat: 17),
      FoodItem(id: 'milk', name: 'Lait écrémé', quantity: 100, unit: 'ml', calories: 34, protein: 3.4, carbs: 5, fat: 0.1),
      
      // ========== PROTÉINES VÉGÉTALES ==========
      FoodItem(id: 'tofu', name: 'Tofu', quantity: 100, unit: 'g', calories: 76, protein: 8, carbs: 1.9, fat: 4.8),
      FoodItem(id: 'tempeh', name: 'Tempeh', quantity: 100, unit: 'g', calories: 193, protein: 19, carbs: 9, fat: 11),
      FoodItem(id: 'seitan', name: 'Seitan', quantity: 100, unit: 'g', calories: 370, protein: 75, carbs: 14, fat: 2),
      FoodItem(id: 'lentils', name: 'Lentilles cuites', quantity: 100, unit: 'g', calories: 116, protein: 9, carbs: 20, fat: 0.4, fiber: 8),
      FoodItem(id: 'chickpeas', name: 'Pois chiches cuits', quantity: 100, unit: 'g', calories: 164, protein: 9, carbs: 27, fat: 2.6, fiber: 8),
      FoodItem(id: 'black_beans', name: 'Haricots noirs cuits', quantity: 100, unit: 'g', calories: 132, protein: 9, carbs: 24, fat: 0.5, fiber: 9),
      FoodItem(id: 'kidney_beans', name: 'Haricots rouges cuits', quantity: 100, unit: 'g', calories: 127, protein: 8.7, carbs: 23, fat: 0.5, fiber: 7.4),
      FoodItem(id: 'edamame', name: 'Edamame', quantity: 100, unit: 'g', calories: 122, protein: 11, carbs: 10, fat: 5, fiber: 5),
      
      // ========== GLUCIDES - RIZ ==========
      FoodItem(id: 'rice_white', name: 'Riz blanc cuit', quantity: 100, unit: 'g', calories: 130, protein: 2.7, carbs: 28, fat: 0.3),
      FoodItem(id: 'rice_basmati', name: 'Riz basmati cuit', quantity: 100, unit: 'g', calories: 121, protein: 3, carbs: 25, fat: 0.4),
      FoodItem(id: 'rice_brown', name: 'Riz complet cuit', quantity: 100, unit: 'g', calories: 111, protein: 2.6, carbs: 23, fat: 0.9, fiber: 1.8),
      FoodItem(id: 'rice_black', name: 'Riz noir cuit', quantity: 100, unit: 'g', calories: 120, protein: 3, carbs: 25, fat: 1, fiber: 2),
      FoodItem(id: 'rice_wild', name: 'Riz sauvage cuit', quantity: 100, unit: 'g', calories: 101, protein: 4, carbs: 21, fat: 0.3, fiber: 1.8),
      FoodItem(id: 'rice_jasmine', name: 'Riz jasmin cuit', quantity: 100, unit: 'g', calories: 129, protein: 2.7, carbs: 28, fat: 0.2),
      
      // Pâtes et céréales
      FoodItem(id: 'pasta', name: 'Pâtes blanches cuites', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'pasta_whole', name: 'Pâtes complètes cuites', quantity: 100, unit: 'g', calories: 124, protein: 5, carbs: 26, fat: 0.5, fiber: 3.5),
      FoodItem(id: 'quinoa', name: 'Quinoa cuit', quantity: 100, unit: 'g', calories: 120, protein: 4.4, carbs: 21, fat: 1.9, fiber: 2.8),
      FoodItem(id: 'couscous', name: 'Couscous cuit', quantity: 100, unit: 'g', calories: 112, protein: 3.8, carbs: 23, fat: 0.2),
      FoodItem(id: 'bulgur', name: 'Boulgour cuit', quantity: 100, unit: 'g', calories: 83, protein: 3, carbs: 19, fat: 0.2, fiber: 4.5),
      FoodItem(id: 'oatmeal', name: 'Flocons d\'avoine', quantity: 100, unit: 'g', calories: 389, protein: 17, carbs: 66, fat: 7, fiber: 10),
      FoodItem(id: 'bread_white', name: 'Pain blanc', quantity: 100, unit: 'g', calories: 265, protein: 9, carbs: 49, fat: 3.2),
      FoodItem(id: 'bread_whole', name: 'Pain complet', quantity: 100, unit: 'g', calories: 247, protein: 13, carbs: 41, fat: 3.4, fiber: 7),
      
      // Tubercules
      FoodItem(id: 'potato', name: 'Pomme de terre cuite', quantity: 100, unit: 'g', calories: 87, protein: 2, carbs: 20, fat: 0.1, fiber: 1.8),
      FoodItem(id: 'sweet_potato', name: 'Patate douce cuite', quantity: 100, unit: 'g', calories: 86, protein: 1.6, carbs: 20, fat: 0.1, fiber: 3),
      
      // ========== FRUITS ==========
      FoodItem(id: 'banana', name: 'Banane', quantity: 100, unit: 'g', calories: 89, protein: 1.1, carbs: 23, fat: 0.3, fiber: 2.6),
      FoodItem(id: 'apple', name: 'Pomme', quantity: 100, unit: 'g', calories: 52, protein: 0.3, carbs: 14, fat: 0.2, fiber: 2.4),
      FoodItem(id: 'orange', name: 'Orange', quantity: 100, unit: 'g', calories: 47, protein: 0.9, carbs: 12, fat: 0.1, fiber: 2.4),
      FoodItem(id: 'strawberry', name: 'Fraises', quantity: 100, unit: 'g', calories: 32, protein: 0.7, carbs: 8, fat: 0.3, fiber: 2),
      FoodItem(id: 'blueberry', name: 'Myrtilles', quantity: 100, unit: 'g', calories: 57, protein: 0.7, carbs: 14, fat: 0.3, fiber: 2.4),
      FoodItem(id: 'mango', name: 'Mangue', quantity: 100, unit: 'g', calories: 60, protein: 0.8, carbs: 15, fat: 0.4, fiber: 1.6),
      FoodItem(id: 'pineapple', name: 'Ananas', quantity: 100, unit: 'g', calories: 50, protein: 0.5, carbs: 13, fat: 0.1, fiber: 1.4),
      FoodItem(id: 'kiwi', name: 'Kiwi', quantity: 100, unit: 'g', calories: 61, protein: 1.1, carbs: 15, fat: 0.5, fiber: 3),
      FoodItem(id: 'grapes', name: 'Raisins', quantity: 100, unit: 'g', calories: 69, protein: 0.7, carbs: 18, fat: 0.2, fiber: 0.9),
      FoodItem(id: 'watermelon', name: 'Pastèque', quantity: 100, unit: 'g', calories: 30, protein: 0.6, carbs: 8, fat: 0.2, fiber: 0.4),
      
      // ========== LÉGUMES ==========
      FoodItem(id: 'broccoli', name: 'Brocoli', quantity: 100, unit: 'g', calories: 34, protein: 2.8, carbs: 7, fat: 0.4, fiber: 2.6),
      FoodItem(id: 'spinach', name: 'Épinards', quantity: 100, unit: 'g', calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2),
      FoodItem(id: 'carrots', name: 'Carottes', quantity: 100, unit: 'g', calories: 41, protein: 0.9, carbs: 10, fat: 0.2, fiber: 2.8),
      FoodItem(id: 'tomato', name: 'Tomate', quantity: 100, unit: 'g', calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2),
      FoodItem(id: 'cucumber', name: 'Concombre', quantity: 100, unit: 'g', calories: 15, protein: 0.7, carbs: 3.6, fat: 0.1, fiber: 0.5),
      FoodItem(id: 'bell_pepper', name: 'Poivron', quantity: 100, unit: 'g', calories: 31, protein: 1, carbs: 6, fat: 0.3, fiber: 2.1),
      FoodItem(id: 'zucchini', name: 'Courgette', quantity: 100, unit: 'g', calories: 17, protein: 1.2, carbs: 3.1, fat: 0.3, fiber: 1),
      FoodItem(id: 'eggplant', name: 'Aubergine', quantity: 100, unit: 'g', calories: 25, protein: 1, carbs: 6, fat: 0.2, fiber: 3),
      FoodItem(id: 'asparagus', name: 'Asperges', quantity: 100, unit: 'g', calories: 20, protein: 2.2, carbs: 3.9, fat: 0.1, fiber: 2.1),
      FoodItem(id: 'green_beans', name: 'Haricots verts', quantity: 100, unit: 'g', calories: 31, protein: 1.8, carbs: 7, fat: 0.2, fiber: 2.7),
      FoodItem(id: 'cauliflower', name: 'Chou-fleur', quantity: 100, unit: 'g', calories: 25, protein: 1.9, carbs: 5, fat: 0.3, fiber: 2),
      FoodItem(id: 'lettuce', name: 'Laitue', quantity: 100, unit: 'g', calories: 15, protein: 1.4, carbs: 2.9, fat: 0.2, fiber: 1.3),
      FoodItem(id: 'mushrooms', name: 'Champignons', quantity: 100, unit: 'g', calories: 22, protein: 3.1, carbs: 3.3, fat: 0.3, fiber: 1),
      
      // ========== LIPIDES SAINS ==========
      FoodItem(id: 'almonds', name: 'Amandes', quantity: 100, unit: 'g', calories: 579, protein: 21, carbs: 22, fat: 50, fiber: 12),
      FoodItem(id: 'walnuts', name: 'Noix', quantity: 100, unit: 'g', calories: 654, protein: 15, carbs: 14, fat: 65, fiber: 7),
      FoodItem(id: 'cashews', name: 'Noix de cajou', quantity: 100, unit: 'g', calories: 553, protein: 18, carbs: 30, fat: 44, fiber: 3.3),
      FoodItem(id: 'peanuts', name: 'Cacahuètes', quantity: 100, unit: 'g', calories: 567, protein: 26, carbs: 16, fat: 49, fiber: 8.5),
      FoodItem(id: 'peanut_butter', name: 'Beurre de cacahuète', quantity: 100, unit: 'g', calories: 588, protein: 25, carbs: 20, fat: 50, fiber: 6),
      FoodItem(id: 'almond_butter', name: 'Beurre d\'amande', quantity: 100, unit: 'g', calories: 614, protein: 21, carbs: 19, fat: 56, fiber: 10),
      FoodItem(id: 'avocado', name: 'Avocat', quantity: 100, unit: 'g', calories: 160, protein: 2, carbs: 9, fat: 15, fiber: 7),
      FoodItem(id: 'olive_oil', name: 'Huile d\'olive', quantity: 100, unit: 'ml', calories: 884, protein: 0, carbs: 0, fat: 100),
      FoodItem(id: 'coconut_oil', name: 'Huile de coco', quantity: 100, unit: 'ml', calories: 862, protein: 0, carbs: 0, fat: 100),
      FoodItem(id: 'chia_seeds', name: 'Graines de chia', quantity: 100, unit: 'g', calories: 486, protein: 17, carbs: 42, fat: 31, fiber: 34),
      FoodItem(id: 'flax_seeds', name: 'Graines de lin', quantity: 100, unit: 'g', calories: 534, protein: 18, carbs: 29, fat: 42, fiber: 27),
      FoodItem(id: 'pumpkin_seeds', name: 'Graines de courge', quantity: 100, unit: 'g', calories: 559, protein: 30, carbs: 11, fat: 49, fiber: 6),
      
      // ========== SNACKS ET SUPPLÉMENTS ==========
      FoodItem(id: 'protein_powder', name: 'Whey protéine', quantity: 100, unit: 'g', calories: 400, protein: 80, carbs: 6, fat: 5),
      FoodItem(id: 'protein_bar', name: 'Barre protéinée', quantity: 100, unit: 'g', calories: 350, protein: 30, carbs: 35, fat: 10),
      FoodItem(id: 'dark_chocolate', name: 'Chocolat noir 70%', quantity: 100, unit: 'g', calories: 598, protein: 8, carbs: 46, fat: 43, fiber: 11),
      FoodItem(id: 'honey', name: 'Miel', quantity: 100, unit: 'g', calories: 304, protein: 0.3, carbs: 82, fat: 0),
      
      // ========== AJOUTS SUPPLÉMENTAIRES (50+ nouveaux aliments) ==========
      
      // Poissons et Fruits de mer supplémentaires
      FoodItem(id: 'sea_bass', name: 'Bar', quantity: 100, unit: 'g', calories: 97, protein: 18, carbs: 0, fat: 2.5),
      FoodItem(id: 'trout', name: 'Truite', quantity: 100, unit: 'g', calories: 119, protein: 20, carbs: 0, fat: 3.5),
      FoodItem(id: 'shrimp', name: 'Crevettes', quantity: 100, unit: 'g', calories: 99, protein: 24, carbs: 0.2, fat: 0.3),
      FoodItem(id: 'crab', name: 'Crabe', quantity: 100, unit: 'g', calories: 87, protein: 18, carbs: 0, fat: 1.1),
      FoodItem(id: 'lobster', name: 'Homard', quantity: 100, unit: 'g', calories: 89, protein: 19, carbs: 0, fat: 1),
      FoodItem(id: 'mussels', name: 'Moules', quantity: 100, unit: 'g', calories: 86, protein: 12, carbs: 3.7, fat: 2.2),
      FoodItem(id: 'squid', name: 'Calamar', quantity: 100, unit: 'g', calories: 92, protein: 16, carbs: 3, fat: 1.4),
      FoodItem(id: 'octopus', name: 'Poulpe', quantity: 100, unit: 'g', calories: 82, protein: 15, carbs: 2.2, fat: 1),
      
      // Viandes supplémentaires
      FoodItem(id: 'pork_loin', name: 'Filet de porc', quantity: 100, unit: 'g', calories: 143, protein: 26, carbs: 0, fat: 3.5),
      FoodItem(id: 'pork_chop', name: 'Côtelette de porc', quantity: 100, unit: 'g', calories: 231, protein: 25, carbs: 0, fat: 14),
      FoodItem(id: 'duck', name: 'Canard', quantity: 100, unit: 'g', calories: 337, protein: 19, carbs: 0, fat: 28),
      FoodItem(id: 'rabbit', name: 'Lapin', quantity: 100, unit: 'g', calories: 173, protein: 33, carbs: 0, fat: 3.5),
      FoodItem(id: 'veal', name: 'Veau', quantity: 100, unit: 'g', calories: 172, protein: 31, carbs: 0, fat: 4.5),
      FoodItem(id: 'bacon', name: 'Bacon', quantity: 100, unit: 'g', calories: 541, protein: 37, carbs: 1.4, fat: 42),
      FoodItem(id: 'ham', name: 'Jambon blanc', quantity: 100, unit: 'g', calories: 145, protein: 21, carbs: 1.5, fat: 5.5),
      FoodItem(id: 'salami', name: 'Salami', quantity: 100, unit: 'g', calories: 407, protein: 23, carbs: 1, fat: 34),
      
      // Produits laitiers supplémentaires
      FoodItem(id: 'whole_milk', name: 'Lait entier', quantity: 100, unit: 'ml', calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3),
      FoodItem(id: 'semi_milk', name: 'Lait demi-écrémé', quantity: 100, unit: 'ml', calories: 46, protein: 3.3, carbs: 4.8, fat: 1.5),
      FoodItem(id: 'butter', name: 'Beurre', quantity: 100, unit: 'g', calories: 717, protein: 0.9, carbs: 0.1, fat: 81),
      FoodItem(id: 'cream', name: 'Crème fraîche', quantity: 100, unit: 'g', calories: 292, protein: 2.2, carbs: 3.4, fat: 30),
      FoodItem(id: 'parmesan', name: 'Parmesan', quantity: 100, unit: 'g', calories: 392, protein: 36, carbs: 3.2, fat: 26),
      FoodItem(id: 'feta', name: 'Feta', quantity: 100, unit: 'g', calories: 264, protein: 14, carbs: 4.1, fat: 21),
      FoodItem(id: 'goat_cheese', name: 'Fromage de chèvre', quantity: 100, unit: 'g', calories: 364, protein: 22, carbs: 2.5, fat: 30),
      FoodItem(id: 'ricotta', name: 'Ricotta', quantity: 100, unit: 'g', calories: 174, protein: 11, carbs: 3, fat: 13),
      
      // Céréales et pains supplémentaires
      FoodItem(id: 'white_bread', name: 'Pain blanc', quantity: 100, unit: 'g', calories: 265, protein: 9, carbs: 49, fat: 3.2),
      FoodItem(id: 'whole_bread', name: 'Pain complet', quantity: 100, unit: 'g', calories: 247, protein: 13, carbs: 41, fat: 3.4, fiber: 7),
      FoodItem(id: 'baguette', name: 'Baguette', quantity: 100, unit: 'g', calories: 280, protein: 9, carbs: 55, fat: 2.5),
      FoodItem(id: 'rye_bread', name: 'Pain de seigle', quantity: 100, unit: 'g', calories: 259, protein: 9, carbs: 48, fat: 3.3, fiber: 6),
      FoodItem(id: 'bagel', name: 'Bagel', quantity: 100, unit: 'g', calories: 257, protein: 10, carbs: 50, fat: 1.5),
      FoodItem(id: 'tortilla', name: 'Tortilla', quantity: 100, unit: 'g', calories: 312, protein: 8, carbs: 50, fat: 8),
      FoodItem(id: 'cornflakes', name: 'Corn Flakes', quantity: 100, unit: 'g', calories: 357, protein: 7, carbs: 84, fat: 0.9),
      FoodItem(id: 'granola', name: 'Granola', quantity: 100, unit: 'g', calories: 471, protein: 13, carbs: 64, fat: 17, fiber: 8),
      FoodItem(id: 'muesli', name: 'Muesli', quantity: 100, unit: 'g', calories: 368, protein: 11, carbs: 66, fat: 5.9, fiber: 8),
      
      // Légumes supplémentaires
      FoodItem(id: 'kale', name: 'Chou kale', quantity: 100, unit: 'g', calories: 49, protein: 4.3, carbs: 9, fat: 0.9, fiber: 2),
      FoodItem(id: 'brussels_sprouts', name: 'Choux de Bruxelles', quantity: 100, unit: 'g', calories: 43, protein: 3.4, carbs: 9, fat: 0.3, fiber: 3.8),
      FoodItem(id: 'artichoke', name: 'Artichaut', quantity: 100, unit: 'g', calories: 47, protein: 3.3, carbs: 11, fat: 0.2, fiber: 5),
      FoodItem(id: 'celery', name: 'Céleri', quantity: 100, unit: 'g', calories: 16, protein: 0.7, carbs: 3, fat: 0.2, fiber: 1.6),
      FoodItem(id: 'radish', name: 'Radis', quantity: 100, unit: 'g', calories: 16, protein: 0.7, carbs: 3.4, fat: 0.1, fiber: 1.6),
      FoodItem(id: 'leek', name: 'Poireau', quantity: 100, unit: 'g', calories: 61, protein: 1.5, carbs: 14, fat: 0.3, fiber: 1.8),
      FoodItem(id: 'fennel', name: 'Fenouil', quantity: 100, unit: 'g', calories: 31, protein: 1.2, carbs: 7, fat: 0.2, fiber: 3.1),
      FoodItem(id: 'turnip', name: 'Navet', quantity: 100, unit: 'g', calories: 28, protein: 0.9, carbs: 6, fat: 0.1, fiber: 1.8),
      FoodItem(id: 'beetroot', name: 'Betterave', quantity: 100, unit: 'g', calories: 43, protein: 1.6, carbs: 10, fat: 0.2, fiber: 2.8),
      FoodItem(id: 'corn', name: 'Maïs', quantity: 100, unit: 'g', calories: 86, protein: 3.3, carbs: 19, fat: 1.4, fiber: 2.4),
      FoodItem(id: 'peas', name: 'Petits pois', quantity: 100, unit: 'g', calories: 81, protein: 5, carbs: 14, fat: 0.4, fiber: 5),
      
      // Fruits supplémentaires
      FoodItem(id: 'pear', name: 'Poire', quantity: 100, unit: 'g', calories: 57, protein: 0.4, carbs: 15, fat: 0.1, fiber: 3.1),
      FoodItem(id: 'peach', name: 'Pêche', quantity: 100, unit: 'g', calories: 39, protein: 0.9, carbs: 10, fat: 0.3, fiber: 1.5),
      FoodItem(id: 'apricot', name: 'Abricot', quantity: 100, unit: 'g', calories: 48, protein: 1.4, carbs: 11, fat: 0.4, fiber: 2),
      FoodItem(id: 'plum', name: 'Prune', quantity: 100, unit: 'g', calories: 46, protein: 0.7, carbs: 11, fat: 0.3, fiber: 1.4),
      FoodItem(id: 'cherry', name: 'Cerise', quantity: 100, unit: 'g', calories: 50, protein: 1, carbs: 12, fat: 0.3, fiber: 1.6),
      FoodItem(id: 'melon', name: 'Melon', quantity: 100, unit: 'g', calories: 34, protein: 0.8, carbs: 8, fat: 0.2, fiber: 0.9),
      FoodItem(id: 'papaya', name: 'Papaye', quantity: 100, unit: 'g', calories: 43, protein: 0.5, carbs: 11, fat: 0.3, fiber: 1.7),
      FoodItem(id: 'grapefruit', name: 'Pamplemousse', quantity: 100, unit: 'g', calories: 42, protein: 0.8, carbs: 11, fat: 0.1, fiber: 1.6),
      FoodItem(id: 'lemon', name: 'Citron', quantity: 100, unit: 'g', calories: 29, protein: 1.1, carbs: 9, fat: 0.3, fiber: 2.8),
      FoodItem(id: 'lime', name: 'Citron vert', quantity: 100, unit: 'g', calories: 30, protein: 0.7, carbs: 11, fat: 0.2, fiber: 2.8),
      FoodItem(id: 'coconut', name: 'Noix de coco', quantity: 100, unit: 'g', calories: 354, protein: 3.3, carbs: 15, fat: 33, fiber: 9),
      FoodItem(id: 'dates', name: 'Dattes', quantity: 100, unit: 'g', calories: 282, protein: 2.5, carbs: 75, fat: 0.4, fiber: 8),
      FoodItem(id: 'figs', name: 'Figues', quantity: 100, unit: 'g', calories: 74, protein: 0.8, carbs: 19, fat: 0.3, fiber: 2.9),
      
      // Condiments et assaisonnements
      FoodItem(id: 'ketchup', name: 'Ketchup', quantity: 100, unit: 'g', calories: 112, protein: 1.2, carbs: 27, fat: 0.1),
      FoodItem(id: 'mustard', name: 'Moutarde', quantity: 100, unit: 'g', calories: 66, protein: 4, carbs: 6, fat: 3.3),
      FoodItem(id: 'mayo', name: 'Mayonnaise', quantity: 100, unit: 'g', calories: 680, protein: 1, carbs: 0.6, fat: 75),
      FoodItem(id: 'soy_sauce', name: 'Sauce soja', quantity: 100, unit: 'ml', calories: 53, protein: 8, carbs: 5, fat: 0.1),
      FoodItem(id: 'hot_sauce', name: 'Sauce piquante', quantity: 100, unit: 'ml', calories: 12, protein: 0.7, carbs: 2.5, fat: 0.1),
      FoodItem(id: 'vinegar', name: 'Vinaigre', quantity: 100, unit: 'ml', calories: 18, protein: 0, carbs: 0.04, fat: 0),
      FoodItem(id: 'maple_syrup', name: 'Sirop d\'érable', quantity: 100, unit: 'g', calories: 260, protein: 0, carbs: 67, fat: 0.2),
      
      // ========== PÂTES & NOUILLES (15 items) ==========
      FoodItem(id: 'pasta_white_cooked', name: 'Pâtes blanches cuites', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1, fiber: 1.8),
      FoodItem(id: 'pasta_whole_wheat', name: 'Pâtes complètes cuites', quantity: 100, unit: 'g', calories: 124, protein: 5.3, carbs: 23, fat: 1.4, fiber: 3.9),
      FoodItem(id: 'pasta_penne', name: 'Penne cuites', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'pasta_spaghetti', name: 'Spaghetti cuits', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'pasta_fusilli', name: 'Fusilli cuits', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'pasta_farfalle', name: 'Farfalle (papillon) cuites', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'pasta_tagliatelle', name: 'Tagliatelle cuites', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'pasta_lasagna', name: 'Lasagnes cuites', quantity: 100, unit: 'g', calories: 135, protein: 5.5, carbs: 26, fat: 1.2),
      FoodItem(id: 'pasta_ravioli', name: 'Raviolis (viande)', quantity: 100, unit: 'g', calories: 180, protein: 8, carbs: 23, fat: 6),
      FoodItem(id: 'pasta_tortellini', name: 'Tortellinis (fromage)', quantity: 100, unit: 'g', calories: 190, protein: 9, carbs: 24, fat: 6.5),
      FoodItem(id: 'noodles_egg', name: 'Nouilles aux œufs cuites', quantity: 100, unit: 'g', calories: 138, protein: 4.5, carbs: 25, fat: 2.1),
      FoodItem(id: 'noodles_instant', name: 'Nouilles instantanées', quantity: 100, unit: 'g', calories: 436, protein: 8.9, carbs: 61, fat: 17),
      FoodItem(id: 'mac_cheese', name: 'Macaronis au fromage', quantity: 100, unit: 'g', calories: 164, protein: 6.4, carbs: 17, fat: 7.4),
      FoodItem(id: 'pasta_carbonara', name: 'Pâtes carbonara', quantity: 100, unit: 'g', calories: 195, protein: 8, carbs: 20, fat: 9),
      FoodItem(id: 'pasta_bolognese', name: 'Pâtes bolognaise', quantity: 100, unit: 'g', calories: 120, protein: 7, carbs: 15, fat: 3.5),
      
      // ========== SOUPES & BOUILLONS (25 items) ==========
      FoodItem(id: 'veg_broth', name: 'Bouillon de légumes', quantity: 100, unit: 'ml', calories: 12, protein: 0.4, carbs: 2.3, fat: 0.2),
      FoodItem(id: 'chicken_broth', name: 'Bouillon de poulet', quantity: 100, unit: 'ml', calories: 15, protein: 1.6, carbs: 1.1, fat: 0.5),
      FoodItem(id: 'beef_broth', name: 'Bouillon de bœuf', quantity: 100, unit: 'ml', calories: 17, protein: 2.7, carbs: 0.5, fat: 0.5),
      FoodItem(id: 'fish_broth', name: 'Bouillon de poisson', quantity: 100, unit: 'ml', calories: 16, protein: 2.1, carbs: 0.9, fat: 0.4),
      FoodItem(id: 'miso_soup', name: 'Soupe miso', quantity: 100, unit: 'ml', calories: 40, protein: 2.2, carbs: 5.4, fat: 1.2),
      FoodItem(id: 'tomato_soup', name: 'Soupe de tomates', quantity: 100, unit: 'ml', calories: 74, protein: 1.9, carbs: 15, fat: 1.3),
      FoodItem(id: 'pumpkin_soup', name: 'Soupe de potiron', quantity: 100, unit: 'ml', calories: 56, protein: 1.5, carbs: 11, fat: 0.9),
      FoodItem(id: 'mushroom_soup', name: 'Soupe de champignons', quantity: 100, unit: 'ml', calories: 85, protein: 1.7, carbs: 9.2, fat: 4.7),
      FoodItem(id: 'onion_soup', name: 'Soupe à l\'oignon', quantity: 100, unit: 'ml', calories: 52, protein: 3.8, carbs: 7.2, fat: 0.8),
      FoodItem(id: 'carrot_soup', name: 'Soupe de carottes', quantity: 100, unit: 'ml', calories: 55, protein: 0.9, carbs: 11, fat: 0.8),
      FoodItem(id: 'leek_soup', name: 'Soupe de poireaux', quantity: 100, unit: 'ml', calories: 45, protein: 1.2, carbs: 8.5, fat: 0.7),
      FoodItem(id: 'minestrone', name: 'Minestrone', quantity: 100, unit: 'ml', calories: 71, protein: 3, carbs: 12, fat: 1.2),
      FoodItem(id: 'lentil_soup', name: 'Soupe de lentilles', quantity: 100, unit: 'ml', calories: 91, protein: 5.6, carbs: 14, fat: 1.4),
      FoodItem(id: 'chicken_noodle_soup', name: 'Soupe poulet nouilles', quantity: 100, unit: 'ml', calories: 34, protein: 2.5, carbs: 4.3, fat: 0.9),
      FoodItem(id: 'veg_soup', name: 'Soupe de légumes', quantity: 100, unit: 'ml', calories: 48, protein: 1.8, carbs: 9.7, fat: 0.5),
      FoodItem(id: 'pea_soup', name: 'Soupe de pois', quantity: 100, unit: 'ml', calories: 118, protein: 6.5, carbs: 18, fat: 2),
      FoodItem(id: 'butternut_soup', name: 'Soupe butternut', quantity: 100, unit: 'ml', calories: 48, protein: 1, carbs: 10, fat: 0.6),
      FoodItem(id: 'corn_soup', name: 'Soupe de maïs', quantity: 100, unit: 'ml', calories: 75, protein: 2, carbs: 14, fat: 1.5),
      FoodItem(id: 'gazpacho', name: 'Gazpacho', quantity: 100, unit: 'ml', calories: 46, protein: 1.1, carbs: 8.5, fat: 1.2),
      FoodItem(id: 'pho', name: 'Soupe Pho vietnamienne', quantity: 100, unit: 'ml', calories: 85, protein: 5.4, carbs: 12, fat: 1.5),
      FoodItem(id: 'ramen_soup', name: 'Soupe ramen', quantity: 100, unit: 'ml', calories: 95, protein: 4.2, carbs: 14, fat: 2.5),
      FoodItem(id: 'borscht', name: 'Bortsch (soupe betterave)', quantity: 100, unit: 'ml', calories: 49, protein: 1.6, carbs: 9.5, fat: 0.9),
      FoodItem(id: 'clam_chowder', name: 'Soupe de palourdes', quantity: 100, unit: 'ml', calories: 98, protein: 4.8, carbs: 10, fat: 4),
      FoodItem(id: 'french_onion', name: 'Soupe à l\'oignon gratinée', quantity: 100, unit: 'ml', calories: 125, protein: 6, carbs: 12, fat: 5.5),
      FoodItem(id: 'wonton_soup', name: 'Soupe wonton', quantity: 100, unit: 'ml', calories: 70, protein: 3.5, carbs: 9, fat: 2),
      
      // ========== PRODUITS BOULANGERIE (30 items) ==========
      FoodItem(id: 'baguette', name: 'Baguette', quantity: 100, unit: 'g', calories: 274, protein: 9, carbs: 56, fat: 1.2),
      FoodItem(id: 'croissant', name: 'Croissant', quantity: 100, unit: 'g', calories: 406, protein: 8.2, carbs: 46, fat: 21),
      FoodItem(id: 'pain_choc', name: 'Pain au chocolat', quantity: 100, unit: 'g', calories: 414, protein: 7.5, carbs: 47, fat: 22),
      FoodItem(id: 'brioche', name: 'Brioche', quantity: 100, unit: 'g', calories: 370, protein: 8.8, carbs: 50, fat: 15),
      FoodItem(id: 'muffin_blueberry', name: 'Muffin myrtilles', quantity: 100, unit: 'g', calories: 347, protein: 5.3, carbs: 52, fat: 13),
      FoodItem(id: 'donut', name: 'Donut', quantity: 100, unit: 'g', calories: 452, protein: 4.9, carbs: 51, fat: 25),
      FoodItem(id: 'bagel', name: 'Bagel', quantity: 100, unit: 'g', calories: 257, protein: 10, carbs: 50, fat: 1.4),
      FoodItem(id: 'english_muffin', name: 'Muffin anglais', quantity: 100, unit: 'g', calories: 235, protein: 7.6, carbs: 46, fat: 2.2),
      FoodItem(id: 'pita', name: 'Pain pita', quantity: 100, unit: 'g', calories: 275, protein: 9.1, carbs: 55, fat: 1.2),
      FoodItem(id: 'naan', name: 'Pain naan', quantity: 100, unit: 'g', calories: 262, protein: 8.7, carbs: 45, fat: 5.1),
      FoodItem(id: 'tortilla_wheat', name: 'Tortilla blé', quantity: 100, unit: 'g', calories: 304, protein: 8.4, carbs: 51, fat: 7.3),
      FoodItem(id: 'tortilla_corn', name: 'Tortilla maïs', quantity: 100, unit: 'g', calories: 218, protein: 5.7, carbs: 44, fat: 2.8),
      FoodItem(id: 'waffle', name: 'Gaufre', quantity: 100, unit: 'g', calories: 291, protein: 7.3, carbs: 38, fat: 12),
      FoodItem(id: 'pancake', name: 'Pancake', quantity: 100, unit: 'g', calories: 227, protein: 6.4, carbs: 28, fat: 9.7),
      FoodItem(id: 'crepe', name: 'Crêpe', quantity: 100, unit: 'g', calories: 192, protein: 6, carbs: 25, fat: 7.1),
      FoodItem(id: 'brownie', name: 'Brownie', quantity: 100, unit: 'g', calories: 466, protein: 5.3, carbs: 63, fat: 22),
      FoodItem(id: 'cookie_choc', name: 'Cookie chocolat', quantity: 100, unit: 'g', calories: 488, protein: 5.9, carbs: 64, fat: 23),
      FoodItem(id: 'madeleine', name: 'Madeleine', quantity: 100, unit: 'g', calories: 443, protein: 5.9, carbs: 52, fat: 23),
      FoodItem(id: 'pain_raisin', name: 'Pain aux raisins', quantity: 100, unit: 'g', calories: 333, protein: 6.9, carbs: 51, fat: 11),
      FoodItem(id: 'chausson_pomme', name: 'Chausson aux pommes', quantity: 100, unit: 'g', calories: 280, protein: 3.5, carbs: 40, fat: 12),
      FoodItem(id: 'eclair', name: 'Éclair', quantity: 100, unit: 'g', calories: 262, protein: 5.6, carbs: 32, fat: 12),
      FoodItem(id: 'tarte_citron', name: 'Tarte au citron', quantity: 100, unit: 'g', calories: 311, protein: 5, carbs: 41, fat: 14),
      FoodItem(id: 'tarte_pomme', name: 'Tarte aux pommes', quantity: 100, unit: 'g', calories: 237, protein: 2.2, carbs: 34, fat: 11),
      FoodItem(id: 'cheesecake', name: 'Cheesecake', quantity: 100, unit: 'g', calories: 321, protein: 5.5, carbs: 25, fat: 23),
      FoodItem(id: 'tiramisu', name: 'Tiramisu', quantity: 100, unit: 'g', calories: 241, protein: 5.6, carbs: 28, fat: 11),
      FoodItem(id: 'mousse_choc', name: 'Mousse au chocolat', quantity: 100, unit: 'g', calories: 189, protein: 4.4, carbs: 16, fat: 12),
      FoodItem(id: 'profiterole', name: 'Profiterole', quantity: 100, unit: 'g', calories: 298, protein: 5.7, carbs: 29, fat: 17),
      FoodItem(id: 'macaron', name: 'Macaron', quantity: 100, unit: 'g', calories: 394, protein: 6.2, carbs: 51, fat: 18),
      FoodItem(id: 'financier', name: 'Financier', quantity: 100, unit: 'g', calories: 458, protein: 8.5, carbs: 46, fat: 27),
      FoodItem(id: 'pain_epice', name: 'Pain d\'épices', quantity: 100, unit: 'g', calories: 355, protein: 4.5, carbs: 76, fat: 3.8),
      
      // ========== FAST-FOOD & PLATS PRÉPARÉS (40 items) ==========
      FoodItem(id: 'burger', name: 'Burger classique', quantity: 100, unit: 'g', calories: 254, protein: 13, carbs: 21, fat: 12),
      FoodItem(id: 'cheeseburger', name: 'Cheeseburger', quantity: 100, unit: 'g', calories: 287, protein: 15, carbs: 22, fat: 15),
      FoodItem(id: 'bigmac', name: 'Big Mac', quantity: 100, unit: 'g', calories: 257, protein: 12, carbs: 21, fat: 13),
      FoodItem(id: 'whopper', name: 'Whopper', quantity: 100, unit: 'g', calories: 254, protein: 13, carbs: 23, fat: 12),
      FoodItem(id: 'mcnuggets', name: 'Nuggets poulet', quantity: 100, unit: 'g', calories: 296, protein: 15, carbs: 16, fat: 18),
      FoodItem(id: 'fries', name: 'Frites', quantity: 100, unit: 'g', calories: 312, protein: 3.4, carbs: 41, fat: 15),
      FoodItem(id: 'onion_rings', name: 'Rondelles d\'oignon', quantity: 100, unit: 'g', calories: 407, protein: 5.3, carbs: 38, fat: 26),
      FoodItem(id: 'hot_dog', name: 'Hot-dog', quantity: 100, unit: 'g', calories: 290, protein: 10, carbs: 23, fat: 17),
      FoodItem(id: 'kebab', name: 'Kebab', quantity: 100, unit: 'g', calories: 230, protein: 12, carbs: 19, fat: 12),
      FoodItem(id: 'tacos', name: 'Tacos', quantity: 100, unit: 'g', calories: 217, protein: 9.1, carbs: 20, fat: 11),
      FoodItem(id: 'burrito', name: 'Burrito', quantity: 100, unit: 'g', calories: 206, protein: 9.4, carbs: 26, fat: 7.2),
      FoodItem(id: 'quesadilla', name: 'Quesadilla', quantity: 100, unit: 'g', calories: 234, protein: 10, carbs: 22, fat: 11),
      FoodItem(id: 'nachos', name: 'Nachos fromage', quantity: 100, unit: 'g', calories: 341, protein: 9.7, carbs: 35, fat: 18),
      FoodItem(id: 'pizza_marg', name: 'Pizza margherita', quantity: 100, unit: 'g', calories: 266, protein: 11, carbs: 33, fat: 10),
      FoodItem(id: 'pizza_pepp', name: 'Pizza pepperoni', quantity: 100, unit: 'g', calories: 298, protein: 12, carbs: 34, fat: 13),
      FoodItem(id: 'pizza_4from', name: 'Pizza 4 fromages', quantity: 100, unit: 'g', calories: 281, protein: 12, carbs: 30, fat: 12),
      FoodItem(id: 'lasagna_meat', name: 'Lasagnes viande', quantity: 100, unit: 'g', calories: 135, protein: 7.3, carbs: 12, fat: 6.3),
      FoodItem(id: 'quiche_lorr', name: 'Quiche lorraine', quantity: 100, unit: 'g', calories: 253, protein: 9.4, carbs: 17, fat: 16),
      FoodItem(id: 'croque_monsieur', name: 'Croque-monsieur', quantity: 100, unit: 'g', calories: 228, protein: 11, carbs: 18, fat: 12),
      FoodItem(id: 'sandwich_jambon', name: 'Sandwich jambon-beurre', quantity: 100, unit: 'g', calories: 265, protein: 12, carbs: 27, fat: 11),
      FoodItem(id: 'sandwich_poulet', name: 'Sandwich poulet', quantity: 100, unit: 'g', calories: 230, protein: 14, carbs: 25, fat: 8),
      FoodItem(id: 'panini', name: 'Panini', quantity: 100, unit: 'g', calories: 254, protein: 11, carbs: 28, fat: 10),
      FoodItem(id: 'wrap_poulet', name: 'Wrap poulet', quantity: 100, unit: 'g', calories: 189, protein: 11, carbs: 21, fat: 6.8),
      FoodItem(id: 'sushi_roll', name: 'Sushi roll', quantity: 100, unit: 'g', calories: 143, protein: 5.8, carbs: 24, fat: 2.5),
      FoodItem(id: 'sashimi', name: 'Sashimi', quantity: 100, unit: 'g', calories: 127, protein: 20, carbs: 0, fat: 4.4),
      FoodItem(id: 'pad_thai', name: 'Pad thaï', quantity: 100, unit: 'g', calories: 154, protein: 4.8, carbs: 22, fat: 5.3),
      FoodItem(id: 'spring_roll', name: 'Rouleau de printemps', quantity: 100, unit: 'g', calories: 175, protein: 3.6, carbs: 25, fat: 6.7),
      FoodItem(id: 'samosa', name: 'Samosa', quantity: 100, unit: 'g', calories: 252, protein: 4.8, carbs: 31, fat: 12),
      FoodItem(id: 'falafel', name: 'Falafel', quantity: 100, unit: 'g', calories: 333, protein: 13, carbs: 32, fat: 18),
      FoodItem(id: 'couscous', name: 'Couscous royal', quantity: 100, unit: 'g', calories: 112, protein: 6.5, carbs: 15, fat: 3.1),
      FoodItem(id: 'paella', name: 'Paëlla', quantity: 100, unit: 'g', calories: 139, protein: 7.2, carbs: 18, fat: 4),
      FoodItem(id: 'risotto', name: 'Risotto', quantity: 100, unit: 'g', calories: 143, protein: 3.5, carbs: 22, fat: 4.5),
      FoodItem(id: 'gratin_dauphinois', name: 'Gratin dauphinois', quantity: 100, unit: 'g', calories: 151, protein: 3.8, carbs: 12, fat: 10),
      FoodItem(id: 'pot_au_feu', name: 'Pot-au-feu', quantity: 100, unit: 'g', calories: 82, protein: 9.5, carbs: 4.6, fat: 2.9),
      FoodItem(id: 'blanquette', name: 'Blanquette de veau', quantity: 100, unit: 'g', calories: 138, protein: 10, carbs: 5.3, fat: 8.6),
      FoodItem(id: 'cassoulet', name: 'Cassoulet', quantity: 100, unit: 'g', calories: 155, protein: 9.7, carbs: 14, fat: 7.1),
      FoodItem(id: 'choucroute', name: 'Choucroute garnie', quantity: 100, unit: 'g', calories: 110, protein: 6.8, carbs: 6.2, fat: 6.5),
      FoodItem(id: 'boeuf_bourg', name: 'Bœuf bourguignon', quantity: 100, unit: 'g', calories: 142, protein: 11, carbs: 5.2, fat: 8.5),
      FoodItem(id: 'tajine', name: 'Tajine poulet', quantity: 100, unit: 'g', calories: 120, protein: 10, carbs: 9, fat: 5),
      FoodItem(id: 'curry_chicken', name: 'Curry de poulet', quantity: 100, unit: 'g', calories: 119, protein: 9.3, carbs: 7.8, fat: 6.2),
      
      // ========== PÂTES COMPLÈTES (30 variétés) ==========
      FoodItem(id: 'spaghetti', name: 'Spaghetti cuits', quantity: 100, unit: 'g', calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9),
      FoodItem(id: 'spaghetti_complet', name: 'Spaghetti complets cuits', quantity: 100, unit: 'g', calories: 124, protein: 5, carbs: 26, fat: 0.5, fiber: 3.5),
      FoodItem(id: 'penne', name: 'Penne cuites', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'penne_complet', name: 'Penne complètes cuites', quantity: 100, unit: 'g', calories: 124, protein: 5, carbs: 26, fat: 0.5, fiber: 3.5),
      FoodItem(id: 'fusilli', name: 'Fusilli cuites', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'fusilli_complet', name: 'Fusilli complètes cuites', quantity: 100, unit: 'g', calories: 124, protein: 5, carbs: 26, fat: 0.5, fiber: 3.5),
      FoodItem(id: 'farfalle', name: 'Farfalle cuites', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'rigatoni', name: 'Rigatoni cuits', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'linguine', name: 'Linguine cuites', quantity: 100, unit: 'g', calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9),
      FoodItem(id: 'tagliatelle', name: 'Tagliatelle cuites', quantity: 100, unit: 'g', calories: 158, protein: 5.8, carbs: 30.9, fat: 0.9),
      FoodItem(id: 'lasagne', name: 'Lasagne cuites', quantity: 100, unit: 'g', calories: 135, protein: 5.3, carbs: 26, fat: 1.2),
      FoodItem(id: 'cannelloni', name: 'Cannelloni cuits', quantity: 100, unit: 'g', calories: 135, protein: 5.3, carbs: 26, fat: 1.2),
      FoodItem(id: 'macaroni', name: 'Macaroni cuits', quantity: 100, unit: 'g', calories: 131, protein: 5, carbs: 25, fat: 1.1),
      FoodItem(id: 'pates_riz', name: 'Pâtes de riz cuites', quantity: 100, unit: 'g', calories: 109, protein: 0.9, carbs: 24, fat: 0.1),
      FoodItem(id: 'pates_quinoa', name: 'Pâtes de quinoa cuites', quantity: 100, unit: 'g', calories: 112, protein: 4.5, carbs: 21, fat: 1.8),
      FoodItem(id: 'pates_lentilles', name: 'Pâtes de lentilles cuites', quantity: 100, unit: 'g', calories: 116, protein: 11.6, carbs: 17.5, fat: 0.7, fiber: 4),
      FoodItem(id: 'pates_oeufs', name: 'Pâtes aux œufs cuites', quantity: 100, unit: 'g', calories: 138, protein: 5.3, carbs: 25, fat: 2.1),
      FoodItem(id: 'nouilles_chinoises', name: 'Nouilles chinoises cuites', quantity: 100, unit: 'g', calories: 138, protein: 4.5, carbs: 28, fat: 0.5),
      FoodItem(id: 'nouilles_soba', name: 'Nouilles soba cuites', quantity: 100, unit: 'g', calories: 99, protein: 5.1, carbs: 21, fat: 0.1, fiber: 1.5),
      FoodItem(id: 'vermicelles_riz', name: 'Vermicelles de riz cuits', quantity: 100, unit: 'g', calories: 109, protein: 0.9, carbs: 24, fat: 0.1),
      FoodItem(id: 'ramen', name: 'Ramen cuits', quantity: 100, unit: 'g', calories: 436, protein: 10, carbs: 64, fat: 14),
      
      // ========== SOUPES & BOUILLONS (40 variétés) ==========
      FoodItem(id: 'bouillon_legumes', name: 'Bouillon de légumes', quantity: 100, unit: 'ml', calories: 12, protein: 0.4, carbs: 2.3, fat: 0.2),
      FoodItem(id: 'bouillon_poulet', name: 'Bouillon de poulet', quantity: 100, unit: 'ml', calories: 15, protein: 1.6, carbs: 0.9, fat: 0.5),
      FoodItem(id: 'bouillon_boeuf', name: 'Bouillon de bœuf', quantity: 100, unit: 'ml', calories: 17, protein: 2.1, carbs: 0.7, fat: 0.6),
      FoodItem(id: 'bouillon_poisson', name: 'Bouillon de poisson', quantity: 100, unit: 'ml', calories: 14, protein: 1.9, carbs: 0.5, fat: 0.4),
      FoodItem(id: 'bouillon_miso', name: 'Bouillon miso', quantity: 100, unit: 'ml', calories: 36, protein: 2.5, carbs: 4.9, fat: 1.2),
      FoodItem(id: 'bouillon_pho', name: 'Bouillon pho', quantity: 100, unit: 'ml', calories: 19, protein: 1.3, carbs: 2.1, fat: 0.7),
      FoodItem(id: 'soupe_legumes', name: 'Soupe de légumes', quantity: 100, unit: 'ml', calories: 38, protein: 1.4, carbs: 7.2, fat: 0.6, fiber: 1.5),
      FoodItem(id: 'soupe_tomates', name: 'Soupe de tomates', quantity: 100, unit: 'ml', calories: 35, protein: 1.1, carbs: 7.3, fat: 0.2, fiber: 0.7),
      FoodItem(id: 'soupe_champignons', name: 'Soupe de champignons', quantity: 100, unit: 'ml', calories: 46, protein: 1.9, carbs: 6.8, fat: 1.5),
      FoodItem(id: 'soupe_minestrone', name: 'Soupe minestrone', quantity: 100, unit: 'ml', calories: 44, protein: 2.1, carbs: 7.9, fat: 0.8, fiber: 1.2),
      FoodItem(id: 'soupe_carottes', name: 'Soupe de carottes', quantity: 100, unit: 'ml', calories: 40, protein: 0.8, carbs: 8.5, fat: 0.5, fiber: 1.1),
      FoodItem(id: 'gaspacho', name: 'Gaspacho', quantity: 100, unit: 'ml', calories: 27, protein: 0.8, carbs: 5.4, fat: 0.3, fiber: 1),
      FoodItem(id: 'creme_potiron', name: 'Crème de potiron', quantity: 100, unit: 'ml', calories: 52, protein: 1.3, carbs: 9.2, fat: 1.5, fiber: 1.3),
      FoodItem(id: 'creme_champignons', name: 'Crème de champignons', quantity: 100, unit: 'ml', calories: 64, protein: 1.8, carbs: 7.5, fat: 3.2),
      FoodItem(id: 'veloute_poireaux', name: 'Velouté de poireaux', quantity: 100, unit: 'ml', calories: 58, protein: 1.5, carbs: 8.3, fat: 2.1, fiber: 1.2),
      FoodItem(id: 'creme_asperges', name: 'Crème d\'asperges', quantity: 100, unit: 'ml', calories: 55, protein: 2.3, carbs: 6.9, fat: 2.5, fiber: 1.4),
      FoodItem(id: 'soupe_miso', name: 'Soupe miso', quantity: 100, unit: 'ml', calories: 36, protein: 2.5, carbs: 4.9, fat: 1.2),
      FoodItem(id: 'soupe_wonton', name: 'Soupe wonton', quantity: 100, unit: 'ml', calories: 58, protein: 3.2, carbs: 8.1, fat: 1.8),
      FoodItem(id: 'tom_yum', name: 'Tom yum', quantity: 100, unit: 'ml', calories: 31, protein: 2.1, carbs: 4.3, fat: 0.9),
      FoodItem(id: 'pho_bo', name: 'Pho bo', quantity: 100, unit: 'ml', calories: 45, protein: 3.8, carbs: 6.2, fat: 1.1),
      FoodItem(id: 'laksa', name: 'Laksa', quantity: 100, unit: 'ml', calories: 89, protein: 4.3, carbs: 9.7, fat: 4.2),
      FoodItem(id: 'ramen_bouillon', name: 'Ramen bouillon', quantity: 100, unit: 'ml', calories: 52, protein: 2.9, carbs: 5.8, fat: 2.1),
      FoodItem(id: 'soupe_lentilles', name: 'Soupe de lentilles', quantity: 100, unit: 'ml', calories: 63, protein: 4.7, carbs: 11.2, fat: 0.3, fiber: 2.8),
      FoodItem(id: 'soupe_pois_casses', name: 'Soupe aux pois cassés', quantity: 100, unit: 'ml', calories: 71, protein: 5.1, carbs: 12.8, fat: 0.4, fiber: 3.2),
      FoodItem(id: 'soupe_haricots_noirs', name: 'Soupe de haricots noirs', quantity: 100, unit: 'ml', calories: 68, protein: 4.9, carbs: 12.1, fat: 0.3, fiber: 3.5),
      FoodItem(id: 'minestrone_legumineuses', name: 'Minestrone aux légumineuses', quantity: 100, unit: 'ml', calories: 72, protein: 5.3, carbs: 13.4, fat: 0.5, fiber: 3.1),
      FoodItem(id: 'soupe_oignon', name: 'Soupe à l\'oignon', quantity: 100, unit: 'ml', calories: 45, protein: 1.7, carbs: 6.8, fat: 1.5),
      FoodItem(id: 'veloute_chou_fleur', name: 'Velouté de chou-fleur', quantity: 100, unit: 'ml', calories: 53, protein: 2.1, carbs: 7.4, fat: 1.9, fiber: 1.5),
      FoodItem(id: 'soupe_brocoli', name: 'Soupe de brocoli', quantity: 100, unit: 'ml', calories: 48, protein: 2.8, carbs: 6.7, fat: 1.3, fiber: 1.8),
      FoodItem(id: 'bisque_homard', name: 'Bisque de homard', quantity: 100, unit: 'ml', calories: 89, protein: 3.7, carbs: 7.2, fat: 5.1),
      FoodItem(id: 'chaudrée', name: 'Chaudrée de fruits de mer', quantity: 100, unit: 'ml', calories: 76, protein: 4.9, carbs: 8.3, fat: 2.8),
      
      // ========== BOULANGERIE & VIENNOISERIES (50 items) ==========
      FoodItem(id: 'pain_blanc', name: 'Pain blanc', quantity: 100, unit: 'g', calories: 265, protein: 9, carbs: 49, fat: 3.2),
      FoodItem(id: 'pain_complet', name: 'Pain complet', quantity: 100, unit: 'g', calories: 247, protein: 13, carbs: 41, fat: 3.4, fiber: 7),
      FoodItem(id: 'pain_seigle', name: 'Pain de seigle', quantity: 100, unit: 'g', calories: 259, protein: 8.5, carbs: 48, fat: 3.3, fiber: 5.8),
      FoodItem(id: 'pain_cereales', name: 'Pain aux céréales', quantity: 100, unit: 'g', calories: 252, protein: 10, carbs: 43, fat: 4.2, fiber: 6.5),
      FoodItem(id: 'pain_mie', name: 'Pain de mie', quantity: 100, unit: 'g', calories: 266, protein: 8.4, carbs: 49, fat: 3.5),
      FoodItem(id: 'baguette', name: 'Baguette', quantity: 100, unit: 'g', calories: 274, protein: 9.2, carbs: 55, fat: 0.8),
      FoodItem(id: 'ciabatta', name: 'Ciabatta', quantity: 100, unit: 'g', calories: 271, protein: 9.1, carbs: 50, fat: 3.5),
      FoodItem(id: 'pain_pita', name: 'Pain pita', quantity: 100, unit: 'g', calories: 275, protein: 9.1, carbs: 55, fat: 1.2),
      FoodItem(id: 'tortillas', name: 'Tortillas', quantity: 100, unit: 'g', calories: 312, protein: 8.2, carbs: 51, fat: 7.5),
      FoodItem(id: 'pain_burger', name: 'Pain burger', quantity: 100, unit: 'g', calories: 270, protein: 8.8, carbs: 48, fat: 4.2),
      FoodItem(id: 'pain_hotdog', name: 'Pain hot-dog', quantity: 100, unit: 'g', calories: 268, protein: 8.5, carbs: 49, fat: 3.9),
      FoodItem(id: 'pain_sans_gluten', name: 'Pain sans gluten', quantity: 100, unit: 'g', calories: 251, protein: 4.2, carbs: 46, fat: 5.1),
      FoodItem(id: 'pain_epeautre', name: 'Pain d\'épeautre', quantity: 100, unit: 'g', calories: 246, protein: 10.7, carbs: 43, fat: 2.7, fiber: 6.2),
      FoodItem(id: 'pain_levain', name: 'Pain au levain', quantity: 100, unit: 'g', calories: 239, protein: 9.4, carbs: 45, fat: 1.1, fiber: 2.7),
      FoodItem(id: 'croissant', name: 'Croissant', quantity: 100, unit: 'g', calories: 406, protein: 8.2, carbs: 45, fat: 21),
      FoodItem(id: 'pain_chocolat', name: 'Pain au chocolat', quantity: 100, unit: 'g', calories: 414, protein: 7.9, carbs: 48, fat: 21),
      FoodItem(id: 'pain_raisins', name: 'Pain aux raisins', quantity: 100, unit: 'g', calories: 352, protein: 6.9, carbs: 52, fat: 13),
      FoodItem(id: 'brioche', name: 'Brioche', quantity: 100, unit: 'g', calories: 375, protein: 8.3, carbs: 50, fat: 16),
      FoodItem(id: 'chausson_pommes', name: 'Chausson aux pommes', quantity: 100, unit: 'g', calories: 327, protein: 4.7, carbs: 45, fat: 14),
      FoodItem(id: 'eclair', name: 'Éclair', quantity: 100, unit: 'g', calories: 302, protein: 6.3, carbs: 32, fat: 17),
      FoodItem(id: 'chouquette', name: 'Chouquette', quantity: 100, unit: 'g', calories: 387, protein: 8.5, carbs: 39, fat: 22),
      FoodItem(id: 'macaron', name: 'Macaron', quantity: 100, unit: 'g', calories: 407, protein: 6.2, carbs: 51, fat: 20),
      FoodItem(id: 'tarte_pommes', name: 'Tarte aux pommes', quantity: 100, unit: 'g', calories: 237, protein: 2.4, carbs: 34, fat: 10),
      FoodItem(id: 'tarte_citron', name: 'Tarte au citron', quantity: 100, unit: 'g', calories: 298, protein: 4.8, carbs: 43, fat: 12),
      FoodItem(id: 'gateau_chocolat', name: 'Gâteau au chocolat', quantity: 100, unit: 'g', calories: 389, protein: 4.9, carbs: 49, fat: 20),
      FoodItem(id: 'brownie', name: 'Brownie', quantity: 100, unit: 'g', calories: 466, protein: 6.3, carbs: 63, fat: 23),
      FoodItem(id: 'muffin_nature', name: 'Muffin nature', quantity: 100, unit: 'g', calories: 377, protein: 6.3, carbs: 51, fat: 17),
      FoodItem(id: 'muffin_chocolat', name: 'Muffin chocolat', quantity: 100, unit: 'g', calories: 425, protein: 6.8, carbs: 54, fat: 21),
      FoodItem(id: 'muffin_myrtilles', name: 'Muffin myrtilles', quantity: 100, unit: 'g', calories: 363, protein: 5.7, carbs: 52, fat: 15),
      FoodItem(id: 'cookies', name: 'Cookies', quantity: 100, unit: 'g', calories: 488, protein: 5.3, carbs: 68, fat: 21),
      FoodItem(id: 'donuts', name: 'Donuts', quantity: 100, unit: 'g', calories: 452, protein: 5.1, carbs: 51, fat: 25),
      FoodItem(id: 'pancakes', name: 'Pancakes', quantity: 100, unit: 'g', calories: 227, protein: 6.4, carbs: 28, fat: 10),
      FoodItem(id: 'gaufres', name: 'Gaufres', quantity: 100, unit: 'g', calories: 291, protein: 7, carbs: 38, fat: 13),
      FoodItem(id: 'crepes', name: 'Crêpes', quantity: 100, unit: 'g', calories: 227, protein: 6.4, carbs: 28, fat: 10),
      
      // ========== FAST-FOOD & PLATS PRÉPARÉS (60+ items) ==========
      FoodItem(id: 'big_mac', name: 'Big Mac', quantity: 100, unit: 'g', calories: 257, protein: 12.5, carbs: 19.8, fat: 13.9),
      FoodItem(id: 'whopper', name: 'Whopper', quantity: 100, unit: 'g', calories: 254, protein: 11.9, carbs: 19.1, fat: 14.2),
      FoodItem(id: 'cheeseburger', name: 'Cheeseburger', quantity: 100, unit: 'g', calories: 303, protein: 15.4, carbs: 24.3, fat: 15.4),
      FoodItem(id: 'burger_vegetarien', name: 'Burger végétarien', quantity: 100, unit: 'g', calories: 217, protein: 8.7, carbs: 23.4, fat: 9.8),
      FoodItem(id: 'burger_poulet', name: 'Burger poulet', quantity: 100, unit: 'g', calories: 264, protein: 13.2, carbs: 22.1, fat: 12.8),
      FoodItem(id: 'pizza_margherita', name: 'Pizza margherita', quantity: 100, unit: 'g', calories: 266, protein: 11, carbs: 33, fat: 10),
      FoodItem(id: 'pizza_4_fromages', name: 'Pizza 4 fromages', quantity: 100, unit: 'g', calories: 298, protein: 13.2, carbs: 30, fat: 13.5),
      FoodItem(id: 'pizza_pepperoni', name: 'Pizza pepperoni', quantity: 100, unit: 'g', calories: 298, protein: 12.1, carbs: 32, fat: 13.2),
      FoodItem(id: 'pizza_vegetarienne', name: 'Pizza végétarienne', quantity: 100, unit: 'g', calories: 238, protein: 9.5, carbs: 33, fat: 7.8),
      FoodItem(id: 'pizza_calzone', name: 'Pizza calzone', quantity: 100, unit: 'g', calories: 274, protein: 11.8, carbs: 31, fat: 11.2),
      FoodItem(id: 'pizza_hawaienne', name: 'Pizza hawaïenne', quantity: 100, unit: 'g', calories: 247, protein: 10.3, carbs: 32, fat: 8.9),
      FoodItem(id: 'sandwich_jambon_beurre', name: 'Sandwich jambon-beurre', quantity: 100, unit: 'g', calories: 272, protein: 11.5, carbs: 28, fat: 12),
      FoodItem(id: 'sandwich_poulet', name: 'Sandwich poulet', quantity: 100, unit: 'g', calories: 245, protein: 13.2, carbs: 26, fat: 9.8),
      FoodItem(id: 'croque_monsieur', name: 'Croque-monsieur', quantity: 100, unit: 'g', calories: 279, protein: 13.1, carbs: 19, fat: 16),
      FoodItem(id: 'panini', name: 'Panini', quantity: 100, unit: 'g', calories: 268, protein: 11.7, carbs: 27, fat: 12.3),
      FoodItem(id: 'sub_sandwich', name: 'Sub sandwich', quantity: 100, unit: 'g', calories: 234, protein: 10.9, carbs: 29, fat: 8.1),
      FoodItem(id: 'kebab', name: 'Kebab', quantity: 100, unit: 'g', calories: 215, protein: 9.8, carbs: 20, fat: 10.5),
      FoodItem(id: 'wrap_poulet', name: 'Wrap poulet', quantity: 100, unit: 'g', calories: 189, protein: 11, carbs: 21, fat: 6.8),
      FoodItem(id: 'wrap_vegetarien', name: 'Wrap végétarien', quantity: 100, unit: 'g', calories: 164, protein: 5.7, carbs: 24, fat: 4.9),
      FoodItem(id: 'frites', name: 'Frites', quantity: 100, unit: 'g', calories: 312, protein: 3.4, carbs: 41, fat: 15),
      FoodItem(id: 'nuggets_poulet', name: 'Nuggets de poulet', quantity: 100, unit: 'g', calories: 296, protein: 15.3, carbs: 17.8, fat: 18.1),
      FoodItem(id: 'onion_rings', name: 'Onion rings', quantity: 100, unit: 'g', calories: 407, protein: 5.3, carbs: 38, fat: 26),
      FoodItem(id: 'tenders', name: 'Tenders', quantity: 100, unit: 'g', calories: 264, protein: 16.8, carbs: 14.5, fat: 15.7),
      FoodItem(id: 'fish_chips', name: 'Fish & chips', quantity: 100, unit: 'g', calories: 232, protein: 9.8, carbs: 18, fat: 13.5),
      FoodItem(id: 'tacos', name: 'Tacos', quantity: 100, unit: 'g', calories: 226, protein: 9.4, carbs: 21, fat: 11.7),
      FoodItem(id: 'nachos', name: 'Nachos', quantity: 100, unit: 'g', calories: 498, protein: 7.1, carbs: 61, fat: 25),
      FoodItem(id: 'quesadillas', name: 'Quesadillas', quantity: 100, unit: 'g', calories: 234, protein: 9.7, carbs: 22, fat: 11.9),
      FoodItem(id: 'california_roll', name: 'California roll', quantity: 100, unit: 'g', calories: 176, protein: 3.8, carbs: 28, fat: 5.3),
      FoodItem(id: 'lasagnes', name: 'Lasagnes', quantity: 100, unit: 'g', calories: 135, protein: 6.9, carbs: 14, fat: 5.4),
      FoodItem(id: 'cannelloni', name: 'Cannelloni', quantity: 100, unit: 'g', calories: 140, protein: 7.3, carbs: 15, fat: 5.8),
      FoodItem(id: 'carbonara', name: 'Pâtes carbonara', quantity: 100, unit: 'g', calories: 166, protein: 6.7, carbs: 20, fat: 6.5),
      FoodItem(id: 'bolognaise', name: 'Pâtes bolognaise', quantity: 100, unit: 'g', calories: 134, protein: 6.2, carbs: 17, fat: 4.8),
      FoodItem(id: 'pizza_maison', name: 'Pizza maison', quantity: 100, unit: 'g', calories: 266, protein: 11, carbs: 33, fat: 10),
      
      // ========== CONDIMENTS & SAUCES (50+ items) ==========
      FoodItem(id: 'ketchup', name: 'Ketchup', quantity: 100, unit: 'g', calories: 112, protein: 1.2, carbs: 27, fat: 0.1),
      FoodItem(id: 'mayonnaise', name: 'Mayonnaise', quantity: 100, unit: 'g', calories: 680, protein: 1, carbs: 0.6, fat: 75),
      FoodItem(id: 'moutarde', name: 'Moutarde', quantity: 100, unit: 'g', calories: 66, protein: 4.4, carbs: 5.3, fat: 3.3),
      FoodItem(id: 'sauce_barbecue', name: 'Sauce barbecue', quantity: 100, unit: 'g', calories: 172, protein: 1, carbs: 41, fat: 0.4),
      FoodItem(id: 'sauce_burger', name: 'Sauce burger', quantity: 100, unit: 'g', calories: 312, protein: 0.7, carbs: 18, fat: 26),
      FoodItem(id: 'sauce_algerienne', name: 'Sauce algérienne', quantity: 100, unit: 'g', calories: 198, protein: 1.2, carbs: 12, fat: 16),
      FoodItem(id: 'harissa', name: 'Harissa', quantity: 100, unit: 'g', calories: 72, protein: 2.1, carbs: 9.5, fat: 3.2),
      FoodItem(id: 'tabasco', name: 'Tabasco', quantity: 100, unit: 'ml', calories: 12, protein: 0.7, carbs: 2.5, fat: 0.1),
      FoodItem(id: 'sauce_soja', name: 'Sauce soja', quantity: 100, unit: 'ml', calories: 53, protein: 8, carbs: 5, fat: 0.1),
      FoodItem(id: 'sauce_teriyaki', name: 'Sauce teriyaki', quantity: 100, unit: 'ml', calories: 89, protein: 5.9, carbs: 15.6, fat: 0.1),
      FoodItem(id: 'sauce_hoisin', name: 'Sauce hoisin', quantity: 100, unit: 'ml', calories: 220, protein: 2, carbs: 51, fat: 2),
      FoodItem(id: 'sauce_huitres', name: 'Sauce aux huîtres', quantity: 100, unit: 'ml', calories: 51, protein: 1.4, carbs: 11, fat: 0.2),
      FoodItem(id: 'sauce_fish', name: 'Sauce fish', quantity: 100, unit: 'ml', calories: 35, protein: 5.5, carbs: 3.6, fat: 0),
      FoodItem(id: 'sauce_satay', name: 'Sauce satay', quantity: 100, unit: 'ml', calories: 447, protein: 13, carbs: 23, fat: 35),
      FoodItem(id: 'sriracha', name: 'Sriracha', quantity: 100, unit: 'ml', calories: 93, protein: 1.5, carbs: 20, fat: 0.9),
      FoodItem(id: 'vinaigrette_balsamique', name: 'Vinaigrette balsamique', quantity: 100, unit: 'ml', calories: 241, protein: 0.5, carbs: 17, fat: 19),
      FoodItem(id: 'vinaigrette_cesar', name: 'Vinaigrette césar', quantity: 100, unit: 'ml', calories: 458, protein: 2.3, carbs: 7.2, fat: 46),
      FoodItem(id: 'vinaigrette_miel_moutarde', name: 'Vinaigrette miel-moutarde', quantity: 100, unit: 'ml', calories: 267, protein: 1.1, carbs: 24, fat: 18),
      FoodItem(id: 'vinaigrette_ranch', name: 'Vinaigrette ranch', quantity: 100, unit: 'ml', calories: 479, protein: 1.4, carbs: 5.6, fat: 50),
      FoodItem(id: 'pesto', name: 'Pesto', quantity: 100, unit: 'g', calories: 418, protein: 5.5, carbs: 5.1, fat: 42),
      FoodItem(id: 'tapenade', name: 'Tapenade', quantity: 100, unit: 'g', calories: 264, protein: 2.5, carbs: 7.8, fat: 25),
      FoodItem(id: 'houmous', name: 'Houmous', quantity: 100, unit: 'g', calories: 166, protein: 8, carbs: 14, fat: 10, fiber: 6),
      FoodItem(id: 'guacamole', name: 'Guacamole', quantity: 100, unit: 'g', calories: 160, protein: 2, carbs: 9, fat: 15, fiber: 7),
      FoodItem(id: 'salsa', name: 'Salsa', quantity: 100, unit: 'g', calories: 36, protein: 1.5, carbs: 7.9, fat: 0.2),
      FoodItem(id: 'aioli', name: 'Aïoli', quantity: 100, unit: 'g', calories: 769, protein: 1, carbs: 0.9, fat: 85),
      FoodItem(id: 'sauce_tartare', name: 'Sauce tartare', quantity: 100, unit: 'g', calories: 512, protein: 1.3, carbs: 6.7, fat: 53),
      FoodItem(id: 'confiture', name: 'Confiture', quantity: 100, unit: 'g', calories: 278, protein: 0.4, carbs: 69, fat: 0.1),
      FoodItem(id: 'nutella', name: 'Nutella', quantity: 100, unit: 'g', calories: 539, protein: 6.3, carbs: 57, fat: 31),
      FoodItem(id: 'miel', name: 'Miel', quantity: 100, unit: 'g', calories: 304, protein: 0.3, carbs: 82, fat: 0),
      
      // ========== BOISSONS (40+ items) ==========
      FoodItem(id: 'jus_orange', name: 'Jus d\'orange', quantity: 100, unit: 'ml', calories: 45, protein: 0.7, carbs: 10, fat: 0.2),
      FoodItem(id: 'jus_pomme', name: 'Jus de pomme', quantity: 100, unit: 'ml', calories: 46, protein: 0.1, carbs: 11, fat: 0.1),
      FoodItem(id: 'jus_raisin', name: 'Jus de raisin', quantity: 100, unit: 'ml', calories: 60, protein: 0.4, carbs: 15, fat: 0.1),
      FoodItem(id: 'jus_ananas', name: 'Jus d\'ananas', quantity: 100, unit: 'ml', calories: 53, protein: 0.4, carbs: 13, fat: 0.1),
      FoodItem(id: 'jus_pamplemousse', name: 'Jus de pamplemousse', quantity: 100, unit: 'ml', calories: 39, protein: 0.5, carbs: 9, fat: 0.1),
      FoodItem(id: 'jus_cranberry', name: 'Jus de cranberry', quantity: 100, unit: 'ml', calories: 46, protein: 0.4, carbs: 12, fat: 0.1),
      FoodItem(id: 'jus_tomate', name: 'Jus de tomate', quantity: 100, unit: 'ml', calories: 17, protein: 0.8, carbs: 3.9, fat: 0.1),
      FoodItem(id: 'coca_cola', name: 'Coca-Cola', quantity: 100, unit: 'ml', calories: 42, protein: 0, carbs: 10.6, fat: 0),
      FoodItem(id: 'pepsi', name: 'Pepsi', quantity: 100, unit: 'ml', calories: 41, protein: 0, carbs: 11, fat: 0),
      FoodItem(id: 'sprite', name: 'Sprite', quantity: 100, unit: 'ml', calories: 37, protein: 0, carbs: 9, fat: 0),
      FoodItem(id: 'fanta', name: 'Fanta', quantity: 100, unit: 'ml', calories: 42, protein: 0, carbs: 11, fat: 0),
      FoodItem(id: 'dr_pepper', name: 'Dr Pepper', quantity: 100, unit: 'ml', calories: 40, protein: 0, carbs: 10, fat: 0),
      FoodItem(id: 'ice_tea', name: 'Ice Tea', quantity: 100, unit: 'ml', calories: 28, protein: 0, carbs: 7, fat: 0),
      FoodItem(id: 'limonade', name: 'Limonade', quantity: 100, unit: 'ml', calories: 43, protein: 0, carbs: 11, fat: 0),
      FoodItem(id: 'lait_entier', name: 'Lait entier', quantity: 100, unit: 'ml', calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3),
      FoodItem(id: 'lait_demi_ecreme', name: 'Lait demi-écrémé', quantity: 100, unit: 'ml', calories: 46, protein: 3.3, carbs: 4.8, fat: 1.5),
      FoodItem(id: 'lait_amande', name: 'Lait d\'amande', quantity: 100, unit: 'ml', calories: 24, protein: 0.6, carbs: 0.8, fat: 2.3),
      FoodItem(id: 'lait_soja', name: 'Lait de soja', quantity: 100, unit: 'ml', calories: 54, protein: 3.3, carbs: 6, fat: 1.8),
      FoodItem(id: 'lait_avoine', name: 'Lait d\'avoine', quantity: 100, unit: 'ml', calories: 47, protein: 1, carbs: 8, fat: 1.5),
      FoodItem(id: 'lait_coco', name: 'Lait de coco', quantity: 100, unit: 'ml', calories: 230, protein: 2.3, carbs: 6, fat: 24),
      FoodItem(id: 'smoothie_proteine', name: 'Smoothie protéiné', quantity: 100, unit: 'ml', calories: 72, protein: 6, carbs: 9, fat: 1.2),
      FoodItem(id: 'cafe_noir', name: 'Café noir', quantity: 100, unit: 'ml', calories: 2, protein: 0.3, carbs: 0, fat: 0),
      FoodItem(id: 'cafe_lait', name: 'Café au lait', quantity: 100, unit: 'ml', calories: 30, protein: 1.6, carbs: 2.4, fat: 1.7),
      FoodItem(id: 'cappuccino', name: 'Cappuccino', quantity: 100, unit: 'ml', calories: 38, protein: 2.1, carbs: 3.2, fat: 2.2),
      FoodItem(id: 'latte', name: 'Latte', quantity: 100, unit: 'ml', calories: 54, protein: 3, carbs: 4.3, fat: 2.9),
      FoodItem(id: 'the_vert', name: 'Thé vert', quantity: 100, unit: 'ml', calories: 1, protein: 0, carbs: 0, fat: 0),
      FoodItem(id: 'the_noir', name: 'Thé noir', quantity: 100, unit: 'ml', calories: 1, protein: 0, carbs: 0.3, fat: 0),
      FoodItem(id: 'chocolat_chaud', name: 'Chocolat chaud', quantity: 100, unit: 'ml', calories: 77, protein: 3.5, carbs: 10.7, fat: 2.3),
      FoodItem(id: 'red_bull', name: 'Red Bull', quantity: 100, unit: 'ml', calories: 45, protein: 0, carbs: 11, fat: 0),
      FoodItem(id: 'monster', name: 'Monster', quantity: 100, unit: 'ml', calories: 50, protein: 0, carbs: 13, fat: 0),
      FoodItem(id: 'gatorade', name: 'Gatorade', quantity: 100, unit: 'ml', calories: 25, protein: 0, carbs: 6, fat: 0),
      FoodItem(id: 'powerade', name: 'Powerade', quantity: 100, unit: 'ml', calories: 27, protein: 0, carbs: 6.7, fat: 0),
      FoodItem(id: 'isotonique', name: 'Boisson isotonique', quantity: 100, unit: 'ml', calories: 28, protein: 0, carbs: 7, fat: 0),
      
      // ========== SNACKS & ENCAS (50+ items) ==========
      FoodItem(id: 'chips_nature', name: 'Chips nature', quantity: 100, unit: 'g', calories: 536, protein: 6.6, carbs: 53, fat: 34),
      FoodItem(id: 'chips_barbecue', name: 'Chips barbecue', quantity: 100, unit: 'g', calories: 516, protein: 7, carbs: 51, fat: 32),
      FoodItem(id: 'chips_paprika', name: 'Chips paprika', quantity: 100, unit: 'g', calories: 538, protein: 6.5, carbs: 53, fat: 34),
      FoodItem(id: 'tortilla_chips', name: 'Tortilla chips', quantity: 100, unit: 'g', calories: 498, protein: 7.1, carbs: 61, fat: 25),
      FoodItem(id: 'pringles', name: 'Pringles', quantity: 100, unit: 'g', calories: 536, protein: 4, carbs: 53, fat: 35),
      FoodItem(id: 'popcorn_nature', name: 'Pop-corn nature', quantity: 100, unit: 'g', calories: 375, protein: 12, carbs: 74, fat: 4.5, fiber: 15),
      FoodItem(id: 'popcorn_caramel', name: 'Pop-corn caramel', quantity: 100, unit: 'g', calories: 381, protein: 3.6, carbs: 76, fat: 9),
      FoodItem(id: 'barre_cereales', name: 'Barre céréales', quantity: 100, unit: 'g', calories: 392, protein: 6.8, carbs: 69, fat: 10, fiber: 5.2),
      FoodItem(id: 'barre_chocolat', name: 'Barre chocolat', quantity: 100, unit: 'g', calories: 480, protein: 5.4, carbs: 64, fat: 23),
      FoodItem(id: 'snickers', name: 'Snickers', quantity: 100, unit: 'g', calories: 488, protein: 8.7, carbs: 60, fat: 24),
      FoodItem(id: 'mars', name: 'Mars', quantity: 100, unit: 'g', calories: 449, protein: 4.3, carbs: 68, fat: 17),
      FoodItem(id: 'twix', name: 'Twix', quantity: 100, unit: 'g', calories: 502, protein: 5, carbs: 63, fat: 25),
      FoodItem(id: 'kit_kat', name: 'Kit Kat', quantity: 100, unit: 'g', calories: 518, protein: 6.9, carbs: 61, fat: 27),
      FoodItem(id: 'bounty', name: 'Bounty', quantity: 100, unit: 'g', calories: 471, protein: 4.3, carbs: 59, fat: 25),
      FoodItem(id: 'raisins_secs', name: 'Raisins secs', quantity: 100, unit: 'g', calories: 299, protein: 3.1, carbs: 79, fat: 0.5, fiber: 3.7),
      FoodItem(id: 'dattes', name: 'Dattes', quantity: 100, unit: 'g', calories: 282, protein: 2.5, carbs: 75, fat: 0.4, fiber: 8),
      FoodItem(id: 'figues_seches', name: 'Figues sèches', quantity: 100, unit: 'g', calories: 249, protein: 3.3, carbs: 64, fat: 0.9, fiber: 10),
      FoodItem(id: 'abricots_secs', name: 'Abricots secs', quantity: 100, unit: 'g', calories: 241, protein: 3.4, carbs: 63, fat: 0.5, fiber: 7.3),
      FoodItem(id: 'pruneaux', name: 'Pruneaux', quantity: 100, unit: 'g', calories: 240, protein: 2.2, carbs: 64, fat: 0.4, fiber: 7.1),
      FoodItem(id: 'cranberries_sechees', name: 'Cranberries séchées', quantity: 100, unit: 'g', calories: 308, protein: 0.2, carbs: 82, fat: 1.4, fiber: 5.3),
      FoodItem(id: 'noisettes', name: 'Noisettes', quantity: 100, unit: 'g', calories: 628, protein: 15, carbs: 17, fat: 61, fiber: 9.7),
      FoodItem(id: 'pistaches', name: 'Pistaches', quantity: 100, unit: 'g', calories: 560, protein: 20, carbs: 28, fat: 45, fiber: 10),
      FoodItem(id: 'noix_pecan', name: 'Noix de pécan', quantity: 100, unit: 'g', calories: 691, protein: 9.2, carbs: 14, fat: 72, fiber: 9.6),
      FoodItem(id: 'graines_tournesol', name: 'Graines de tournesol', quantity: 100, unit: 'g', calories: 584, protein: 21, carbs: 20, fat: 51, fiber: 8.6),
      FoodItem(id: 'mix_noix', name: 'Mix de noix', quantity: 100, unit: 'g', calories: 607, protein: 17, carbs: 20, fat: 54, fiber: 8),
      
      // ========== LÉGUMES SUPPLÉMENTAIRES (30 items) ==========
      FoodItem(id: 'chou', name: 'Chou', quantity: 100, unit: 'g', calories: 25, protein: 1.3, carbs: 5.8, fat: 0.1, fiber: 2.5),
      FoodItem(id: 'chou_bruxelles', name: 'Chou de Bruxelles', quantity: 100, unit: 'g', calories: 43, protein: 3.4, carbs: 9, fat: 0.3, fiber: 3.8),
      FoodItem(id: 'artichaut', name: 'Artichaut', quantity: 100, unit: 'g', calories: 47, protein: 3.3, carbs: 11, fat: 0.2, fiber: 5.4),
      FoodItem(id: 'poivron_rouge', name: 'Poivron rouge', quantity: 100, unit: 'g', calories: 31, protein: 1, carbs: 6, fat: 0.3, fiber: 2.1),
      FoodItem(id: 'poivron_vert', name: 'Poivron vert', quantity: 100, unit: 'g', calories: 20, protein: 0.9, carbs: 4.6, fat: 0.2, fiber: 1.7),
      FoodItem(id: 'celeri', name: 'Céleri', quantity: 100, unit: 'g', calories: 14, protein: 0.7, carbs: 3, fat: 0.2, fiber: 1.6),
      FoodItem(id: 'radis', name: 'Radis', quantity: 100, unit: 'g', calories: 16, protein: 0.7, carbs: 3.4, fat: 0.1, fiber: 1.6),
      FoodItem(id: 'navet', name: 'Navet', quantity: 100, unit: 'g', calories: 28, protein: 0.9, carbs: 6.4, fat: 0.1, fiber: 1.8),
      FoodItem(id: 'betterave', name: 'Betterave', quantity: 100, unit: 'g', calories: 43, protein: 1.6, carbs: 9.6, fat: 0.2, fiber: 2.8),
      FoodItem(id: 'potiron', name: 'Potiron', quantity: 100, unit: 'g', calories: 26, protein: 1, carbs: 6.5, fat: 0.1, fiber: 0.5),
      FoodItem(id: 'courge_butternut', name: 'Courge butternut', quantity: 100, unit: 'g', calories: 45, protein: 1, carbs: 12, fat: 0.1, fiber: 2),
      FoodItem(id: 'champignons_paris', name: 'Champignons de Paris', quantity: 100, unit: 'g', calories: 22, protein: 3.1, carbs: 3.3, fat: 0.3, fiber: 1),
      FoodItem(id: 'shiitake', name: 'Shiitake', quantity: 100, unit: 'g', calories: 34, protein: 2.2, carbs: 6.8, fat: 0.5, fiber: 2.5),
      FoodItem(id: 'pleurotes', name: 'Pleurotes', quantity: 100, unit: 'g', calories: 33, protein: 3.3, carbs: 6.1, fat: 0.4, fiber: 2.3),
      FoodItem(id: 'kale', name: 'Kale', quantity: 100, unit: 'g', calories: 49, protein: 4.3, carbs: 9, fat: 0.9, fiber: 2),
      FoodItem(id: 'roquette', name: 'Roquette', quantity: 100, unit: 'g', calories: 25, protein: 2.6, carbs: 3.7, fat: 0.7, fiber: 1.6),
      FoodItem(id: 'laitue_iceberg', name: 'Laitue iceberg', quantity: 100, unit: 'g', calories: 14, protein: 0.9, carbs: 3, fat: 0.1, fiber: 1.2),
      FoodItem(id: 'laitue_romaine', name: 'Laitue romaine', quantity: 100, unit: 'g', calories: 17, protein: 1.2, carbs: 3.3, fat: 0.3, fiber: 2.1),
      FoodItem(id: 'mache', name: 'Mâche', quantity: 100, unit: 'g', calories: 21, protein: 2, carbs: 3.6, fat: 0.4, fiber: 1.5),
      FoodItem(id: 'endives', name: 'Endives', quantity: 100, unit: 'g', calories: 17, protein: 0.9, carbs: 4, fat: 0.1, fiber: 3.1),
      
      // ========== FRUITS SUPPLÉMENTAIRES (20 items) ==========
      FoodItem(id: 'fraises', name: 'Fraises', quantity: 100, unit: 'g', calories: 32, protein: 0.7, carbs: 8, fat: 0.3, fiber: 2),
      FoodItem(id: 'framboises', name: 'Framboises', quantity: 100, unit: 'g', calories: 52, protein: 1.2, carbs: 12, fat: 0.7, fiber: 6.5),
      FoodItem(id: 'mures', name: 'Mûres', quantity: 100, unit: 'g', calories: 43, protein: 1.4, carbs: 10, fat: 0.5, fiber: 5.3),
      FoodItem(id: 'cerises', name: 'Cerises', quantity: 100, unit: 'g', calories: 63, protein: 1.1, carbs: 16, fat: 0.2, fiber: 2.1),
      FoodItem(id: 'melon', name: 'Melon', quantity: 100, unit: 'g', calories: 34, protein: 0.8, carbs: 8, fat: 0.2, fiber: 0.9),
      FoodItem(id: 'peche', name: 'Pêche', quantity: 100, unit: 'g', calories: 39, protein: 0.9, carbs: 10, fat: 0.3, fiber: 1.5),
      FoodItem(id: 'nectarine', name: 'Nectarine', quantity: 100, unit: 'g', calories: 44, protein: 1.1, carbs: 11, fat: 0.3, fiber: 1.7),
      FoodItem(id: 'abricot', name: 'Abricot', quantity: 100, unit: 'g', calories: 48, protein: 1.4, carbs: 11, fat: 0.4, fiber: 2),
      FoodItem(id: 'prune', name: 'Prune', quantity: 100, unit: 'g', calories: 46, protein: 0.7, carbs: 11, fat: 0.3, fiber: 1.4),
      FoodItem(id: 'grenade', name: 'Grenade', quantity: 100, unit: 'g', calories: 83, protein: 1.7, carbs: 19, fat: 1.2, fiber: 4),
      FoodItem(id: 'figue', name: 'Figue', quantity: 100, unit: 'g', calories: 74, protein: 0.8, carbs: 19, fat: 0.3, fiber: 2.9),
      FoodItem(id: 'litchi', name: 'Litchi', quantity: 100, unit: 'g', calories: 66, protein: 0.8, carbs: 17, fat: 0.4, fiber: 1.3),
      FoodItem(id: 'fruit_passion', name: 'Fruit de la passion', quantity: 100, unit: 'g', calories: 97, protein: 2.2, carbs: 23, fat: 0.7, fiber: 10),
      
      // ========== FROMAGES (20 items) ==========
      FoodItem(id: 'brie', name: 'Brie', quantity: 100, unit: 'g', calories: 334, protein: 21, carbs: 0.5, fat: 28),
      FoodItem(id: 'camembert', name: 'Camembert', quantity: 100, unit: 'g', calories: 299, protein: 20, carbs: 0.5, fat: 24),
      FoodItem(id: 'roquefort', name: 'Roquefort', quantity: 100, unit: 'g', calories: 369, protein: 22, carbs: 2, fat: 31),
      FoodItem(id: 'comte', name: 'Comté', quantity: 100, unit: 'g', calories: 409, protein: 28, carbs: 0.5, fat: 33),
      FoodItem(id: 'gruyere', name: 'Gruyère', quantity: 100, unit: 'g', calories: 413, protein: 29, carbs: 0.4, fat: 32),
      FoodItem(id: 'emmental', name: 'Emmental', quantity: 100, unit: 'g', calories: 382, protein: 28, carbs: 3.6, fat: 28),
      FoodItem(id: 'parmesan', name: 'Parmesan', quantity: 100, unit: 'g', calories: 431, protein: 38, carbs: 4.1, fat: 29),
      FoodItem(id: 'feta', name: 'Feta', quantity: 100, unit: 'g', calories: 264, protein: 14, carbs: 4.1, fat: 21),
      FoodItem(id: 'chevre', name: 'Chèvre', quantity: 100, unit: 'g', calories: 364, protein: 21, carbs: 2.5, fat: 30),
      FoodItem(id: 'ricotta', name: 'Ricotta', quantity: 100, unit: 'g', calories: 174, protein: 11, carbs: 3, fat: 13),
      FoodItem(id: 'gorgonzola', name: 'Gorgonzola', quantity: 100, unit: 'g', calories: 353, protein: 21, carbs: 2.3, fat: 29),
      FoodItem(id: 'mascarpone', name: 'Mascarpone', quantity: 100, unit: 'g', calories: 429, protein: 4.8, carbs: 4.8, fat: 44),
      FoodItem(id: 'cream_cheese', name: 'Cream cheese', quantity: 100, unit: 'g', calories: 342, protein: 5.9, carbs: 4.1, fat: 34),
      FoodItem(id: 'boursin', name: 'Boursin', quantity: 100, unit: 'g', calories: 357, protein: 10, carbs: 4, fat: 34),
    ];
  }
}
