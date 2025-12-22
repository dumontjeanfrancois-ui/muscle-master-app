import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_program.dart';
import 'gemini_service.dart';

class AIProgramGenerator {
  static const String _programsKey = 'ai_programs_list';
  
  /// Génère un programme personnalisé avec l'IA
  static Future<Map<String, dynamic>> generateProgram({
    String? level,
    String? goal,
    int? sessionsPerWeek,
    int? sessionDuration,
    List<String>? availableEquipment,
    String? injuries,
    String? customPrompt,
  }) async {
    // Construire le prompt en fonction du mode
    final String promptText;
    if (customPrompt != null && customPrompt.isNotEmpty) {
      promptText = '''
Crée un programme d'entraînement personnalisé selon cette demande :

**Demande utilisateur :** $customPrompt

**Format JSON STRICT :**
{
  "name": "Nom du programme",
  "description": "Description 2-3 phrases",
  "workoutDays": [
    {
      "dayName": "Jour 1",
      "focus": "Groupes musculaires",
      "exercises": [
        {
          "exerciseName": "Exercice",
          "sets": 4,
          "reps": "8-12",
          "restSeconds": 90,
          "notes": "Conseil technique"
        }
      ]
    }
  ]
}

Adapte le nombre de jours et les exercices selon la demande. Génère UNIQUEMENT le JSON, sans texte supplémentaire.
''';
    } else {
      promptText = '''
Crée un programme d'entraînement personnalisé en musculation :

**Profil :**
- Niveau : ${level ?? 'Intermédiaire'}
- Objectif : ${goal ?? 'Hypertrophie'}
- Fréquence : ${sessionsPerWeek ?? 4} séances/semaine
- Durée : ${sessionDuration ?? 60} minutes
- Équipement : ${availableEquipment?.join(', ') ?? 'Barre, Haltères'}
${injuries != null ? '- Limitations : $injuries' : ''}

**Format JSON STRICT :**
{
  "name": "Nom du programme",
  "description": "Description 2-3 phrases",
  "workoutDays": [
    {
      "dayName": "Jour 1",
      "focus": "Groupes musculaires",
      "exercises": [
        {
          "exerciseName": "Exercice",
          "sets": 4,
          "reps": "8-12",
          "restSeconds": 90,
          "notes": "Conseil technique"
        }
      ]
    }
  ]
}

Génère UNIQUEMENT le JSON, sans texte supplémentaire.
''';
    }

    final response = await GeminiService.askCoach(promptText);
    
    if (!response['success']) {
      return response;
    }
    
    try {
      String jsonText = response['answer']
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      final programData = jsonDecode(jsonText);
      
      // Créer le profil utilisateur pour l'historique (utiliser les paramètres optionnels)
      String userProfileStr;
      if (customPrompt != null && customPrompt.isNotEmpty) {
        final truncated = customPrompt.length > 50 ? customPrompt.substring(0, 50) : customPrompt;
        userProfileStr = 'Programme personnalisé: $truncated...';
      } else if (level != null && goal != null && sessionsPerWeek != null) {
        userProfileStr = 'Niveau: $level, Objectif: $goal, ${sessionsPerWeek}x/semaine';
      } else {
        userProfileStr = 'Programme personnalisé';
      }

      final program = AIProgram(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: programData['name'] as String,
        description: programData['description'] as String,
        createdAt: DateTime.now(),
        userProfile: userProfileStr,
        workoutDays: (programData['workoutDays'] as List)
            .map((day) => AIWorkoutDay(
                  dayName: day['dayName'] as String,
                  focus: day['focus'] as String,
                  exercises: (day['exercises'] as List)
                      .map((ex) => AIExerciseEntry(
                            exerciseName: ex['exerciseName'] as String,
                            sets: ex['sets'] as int,
                            reps: ex['reps'].toString(),
                            restSeconds: ex['restSeconds'] as int,
                            notes: ex['notes'] as String? ?? '',
                          ))
                      .toList(),
                ))
            .toList(),
      );
      
      await saveProgram(program);
      
      return {
        'success': true,
        'program': program,
        'quota': response['quota'],
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'parse_error',
        'message': 'Erreur génération programme. Réessayez. 🔄',
      };
    }
  }
  
  static Future<void> saveProgram(AIProgram program) async {
    final prefs = await SharedPreferences.getInstance();
    final programsList = await getPrograms();
    programsList.add(program);
    final jsonList = programsList.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_programsKey, jsonList);
  }
  
  static Future<List<AIProgram>> getPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_programsKey) ?? [];
    return jsonList
        .map((jsonStr) => AIProgram.fromJson(jsonDecode(jsonStr)))
        .toList();
  }
  
  static Future<void> deleteProgram(String programId) async {
    final prefs = await SharedPreferences.getInstance();
    final programsList = await getPrograms();
    programsList.removeWhere((p) => p.id == programId);
    final jsonList = programsList.map((p) => jsonEncode(p.toJson())).toList();
    await prefs.setStringList(_programsKey, jsonList);
  }
  
  static Future<void> updateProgram(AIProgram program) async {
    final prefs = await SharedPreferences.getInstance();
    final programsList = await getPrograms();
    final index = programsList.indexWhere((p) => p.id == program.id);
    if (index != -1) {
      programsList[index] = program;
      final jsonList = programsList.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList(_programsKey, jsonList);
    }
  }
}
