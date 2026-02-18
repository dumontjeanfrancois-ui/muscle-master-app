import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:developer' as developer;
import '../models/workout_session.dart';

class WorkoutTrackingService {
  static const String _sessionsKey = 'workout_sessions';

  /// Sauvegarder une session complétée
  static Future<bool> saveSession(WorkoutSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey) ?? '[]';
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);

      // Ajouter la nouvelle session
      sessionsList.add(session.toJson());

      // Sauvegarder
      await prefs.setString(_sessionsKey, jsonEncode(sessionsList));

      if (kDebugMode) {
        developer.log(
          '✅ Session sauvegardée: ${session.programName}',
          name: 'WorkoutTracking',
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          '❌ Erreur saveSession: $e',
          name: 'WorkoutTracking',
          error: e,
        );
      }
      return false;
    }
  }

  /// Récupérer toutes les sessions
  static Future<List<WorkoutSession>> getAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey) ?? '[]';
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);

      final sessions = sessionsList
          .map((json) => WorkoutSession.fromJson(json as Map<String, dynamic>))
          .toList();

      // Trier par date décroissante (plus récent en premier)
      sessions.sort((a, b) => b.startTime.compareTo(a.startTime));

      if (kDebugMode) {
        developer.log(
          '📊 ${sessions.length} sessions chargées',
          name: 'WorkoutTracking',
        );
      }

      return sessions;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          '❌ Erreur getAllSessions: $e',
          name: 'WorkoutTracking',
          error: e,
        );
      }
      return [];
    }
  }

  /// Récupérer les sessions d'un programme spécifique
  static Future<List<WorkoutSession>> getSessionsByProgram(String programId) async {
    final allSessions = await getAllSessions();
    return allSessions.where((s) => s.programId == programId).toList();
  }

  /// Récupérer les sessions d'un exercice spécifique
  static Future<List<ExerciseLog>> getExerciseHistory(String exerciseName) async {
    final allSessions = await getAllSessions();
    final List<ExerciseLog> history = [];

    for (var session in allSessions) {
      for (var exercise in session.exercises) {
        if (exercise.exerciseName.toLowerCase() == exerciseName.toLowerCase()) {
          history.add(exercise);
        }
      }
    }

    return history;
  }

  /// Obtenir le meilleur poids pour un exercice
  static Future<double?> getBestWeight(String exerciseName) async {
    final history = await getExerciseHistory(exerciseName);
    double? maxWeight;

    for (var exercise in history) {
      for (var set in exercise.sets) {
        if (set.completed && set.weight != null) {
          if (maxWeight == null || set.weight! > maxWeight) {
            maxWeight = set.weight;
          }
        }
      }
    }

    return maxWeight;
  }

  /// Obtenir le nombre total de séances
  static Future<int> getTotalSessionsCount() async {
    final sessions = await getAllSessions();
    return sessions.length;
  }

  /// Obtenir le temps total d'entraînement (en minutes)
  static Future<int> getTotalWorkoutTime() async {
    final sessions = await getAllSessions();
    int totalSeconds = 0;

    for (var session in sessions) {
      totalSeconds += session.durationSeconds;
    }

    return totalSeconds ~/ 60; // Convertir en minutes
  }

  /// Supprimer une session
  static Future<bool> deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey) ?? '[]';
      final List<dynamic> sessionsList = jsonDecode(sessionsJson);

      // Retirer la session
      sessionsList.removeWhere((json) => json['id'] == sessionId);

      // Sauvegarder
      await prefs.setString(_sessionsKey, jsonEncode(sessionsList));

      if (kDebugMode) {
        developer.log(
          '🗑️ Session supprimée: $sessionId',
          name: 'WorkoutTracking',
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          '❌ Erreur deleteSession: $e',
          name: 'WorkoutTracking',
          error: e,
        );
      }
      return false;
    }
  }

  /// Récupérer les statistiques d'un exercice
  static Future<Map<String, dynamic>> getExerciseStats(String exerciseName) async {
    final history = await getExerciseHistory(exerciseName);
    
    if (history.isEmpty) {
      return {
        'totalSets': 0,
        'totalReps': 0,
        'maxWeight': 0.0,
        'avgWeight': 0.0,
        'timesPerformed': 0,
      };
    }

    int totalSets = 0;
    int totalReps = 0;
    double maxWeight = 0.0;
    double totalWeight = 0.0;
    int weightCount = 0;

    for (var exercise in history) {
      for (var set in exercise.sets) {
        if (set.completed) {
          totalSets++;
          if (set.actualReps != null) {
            totalReps += set.actualReps!;
          }
          if (set.weight != null) {
            if (set.weight! > maxWeight) {
              maxWeight = set.weight!;
            }
            totalWeight += set.weight!;
            weightCount++;
          }
        }
      }
    }

    return {
      'totalSets': totalSets,
      'totalReps': totalReps,
      'maxWeight': maxWeight,
      'avgWeight': weightCount > 0 ? totalWeight / weightCount : 0.0,
      'timesPerformed': history.length,
    };
  }

  /// Récupérer la progression d'un exercice au fil du temps
  static Future<List<Map<String, dynamic>>> getExerciseProgression(String exerciseName) async {
    final sessions = await getAllSessions();
    final progression = <Map<String, dynamic>>[];

    for (var session in sessions) {
      for (var exercise in session.exercises) {
        if (exercise.exerciseName.toLowerCase() == exerciseName.toLowerCase()) {
          // Trouver le meilleur poids pour cette session
          double? maxWeight;
          int totalReps = 0;
          int completedSets = 0;

          for (var set in exercise.sets) {
            if (set.completed) {
              completedSets++;
              if (set.weight != null && (maxWeight == null || set.weight! > maxWeight)) {
                maxWeight = set.weight;
              }
              if (set.actualReps != null) {
                totalReps += set.actualReps!;
              }
            }
          }

          if (maxWeight != null) {
            progression.add({
              'date': session.startTime,
              'maxWeight': maxWeight,
              'totalReps': totalReps,
              'completedSets': completedSets,
            });
          }
        }
      }
    }

    // Trier par date
    progression.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    if (kDebugMode) {
      developer.log(
        '📊 Progression de $exerciseName: ${progression.length} sessions',
        name: 'WorkoutTracking',
      );
    }

    return progression;
  }
}

