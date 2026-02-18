import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint, kIsWeb;
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
        name: programData['name']?.toString() ?? 'Programme IA',
        description: programData['description']?.toString() ?? '',
        createdAt: DateTime.now(),
        userProfile: userProfileStr,
        workoutDays: (programData['workoutDays'] as List? ?? [])
            .map((day) => AIWorkoutDay(
                  dayName: day['dayName']?.toString() ?? 'Jour',
                  focus: day['focus']?.toString() ?? 'Entraînement',
                  exercises: (day['exercises'] as List? ?? [])
                      .map((ex) => AIExerciseEntry(
                            exerciseName: ex['exerciseName']?.toString() ?? 'Exercice',
                            sets: ex['sets'] is int ? ex['sets'] as int : int.tryParse(ex['sets']?.toString() ?? '3') ?? 3,
                            reps: ex['reps']?.toString() ?? '10',
                            restSeconds: ex['restSeconds'] is int ? ex['restSeconds'] as int : int.tryParse(ex['restSeconds']?.toString() ?? '60') ?? 60,
                            notes: ex['notes']?.toString() ?? '',
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
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 🔍 DEBUG: Afficher TOUTES les clés disponibles
      if (kIsWeb) {
        final allKeys = prefs.getKeys();
        developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'Storage');
        developer.log('📋 TOUTES LES CLÉS: ${allKeys.toList()}', name: 'Storage');
        developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'Storage');
      }
      
      final jsonList = prefs.getStringList(_programsKey) ?? [];
      
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'getPrograms');
      developer.log('📋 getPrograms() APPELÉ', name: 'getPrograms');
      developer.log('   Clé: $_programsKey', name: 'getPrograms');
      developer.log('   Éléments: ${jsonList.length}', name: 'getPrograms');
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'getPrograms');
      
      final programs = <AIProgram>[];
      for (var i = 0; i < jsonList.length; i++) {
        try {
          developer.log('🔄 Parsing $i...', name: 'getPrograms');
          developer.log('   JSON: ${jsonList[i].substring(0, jsonList[i].length > 100 ? 100 : jsonList[i].length)}', name: 'getPrograms');
          
          final jsonStr = jsonList[i];
          final program = AIProgram.fromJson(jsonDecode(jsonStr));
          programs.add(program);
          
          developer.log('   ✅ Parsé: ${program.name}', name: 'getPrograms');
        } catch (e, stackTrace) {
          developer.log('   ❌ ERREUR $i: $e', name: 'getPrograms');
          print('   Stack: ${stackTrace.toString().split('\n').take(3).join('\n')}');
          // Continuer avec les autres programmes
        }
      }
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      developer.log('✅ RÉSULTAT: ${programs.length} programmes', name: 'getPrograms');
      for (var i = 0; i < programs.length; i++) {
        developer.log('   ${i + 1}. ${programs[i].name} (${programs[i].id})', name: 'getPrograms');
      }
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'getPrograms');
      
      return programs;
    } catch (e, stackTrace) {
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'getPrograms');
      developer.log('❌ ERREUR: $e', name: 'getPrograms');
      developer.log('Stack: $stackTrace', name: 'getPrograms');
      developer.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━', name: 'getPrograms');
      return [];
    }
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
  
  /// Exporte un programme au format JSON
  static Future<String> exportProgramAsJson(AIProgram program) async {
    final jsonMap = program.toJson();
    return const JsonEncoder.withIndent('  ').convert(jsonMap);
  }
  
  /// Partage un programme (JSON ou texte)
  static Future<void> shareProgram(AIProgram program, {bool asJson = true}) async {
    if (asJson) {
      final jsonString = await exportProgramAsJson(program);
      await Share.share(
        jsonString,
        subject: 'Programme ${program.name} - Muscle Master',
      );
    } else {
      final textString = _programToReadableText(program);
      await Share.share(
        textString,
        subject: 'Programme ${program.name} - Muscle Master',
      );
    }
  }
  
  /// Convertit un programme en texte lisible (Markdown)
  static String _programToReadableText(AIProgram program) {
    final buffer = StringBuffer();
    buffer.writeln('# ${program.name}');
    buffer.writeln();
    buffer.writeln('## Description');
    buffer.writeln(program.description);
    buffer.writeln();
    buffer.writeln('## Programme');
    buffer.writeln();
    
    for (var day in program.workoutDays) {
      buffer.writeln('### ${day.dayName} - ${day.focus}');
      buffer.writeln();
      for (var exercise in day.exercises) {
        buffer.writeln('**${exercise.exerciseName}**');
        buffer.writeln('- ${exercise.sets} séries x ${exercise.reps} reps');
        buffer.writeln('- Repos: ${exercise.restSeconds}s');
        if (exercise.notes.isNotEmpty) {
          buffer.writeln('- Notes: ${exercise.notes}');
        }
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }
  
  /// Importe un programme depuis du JSON
  static Future<Map<String, dynamic>> importProgramFromJson(String jsonString) async {
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Créer le programme depuis le JSON
      final program = AIProgram(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: jsonMap['name']?.toString() ?? 'Programme importé',
        description: jsonMap['description']?.toString() ?? '',
        createdAt: DateTime.now(),
        userProfile: jsonMap['userProfile']?.toString() ?? 'Programme importé',
        workoutDays: (jsonMap['workoutDays'] as List? ?? [])
            .map((day) => AIWorkoutDay(
                  dayName: day['dayName']?.toString() ?? 'Jour',
                  focus: day['focus']?.toString() ?? 'Entraînement',
                  exercises: (day['exercises'] as List? ?? [])
                      .map((ex) => AIExerciseEntry(
                            exerciseName: ex['exerciseName']?.toString() ?? 'Exercice',
                            sets: ex['sets'] is int ? ex['sets'] as int : int.tryParse(ex['sets']?.toString() ?? '3') ?? 3,
                            reps: ex['reps']?.toString() ?? '10',
                            restSeconds: ex['restSeconds'] is int ? ex['restSeconds'] as int : int.tryParse(ex['restSeconds']?.toString() ?? '60') ?? 60,
                            notes: ex['notes']?.toString() ?? '',
                          ))
                      .toList(),
                ))
            .toList(),
      );
      
      await saveProgram(program);
      
      return {
        'success': true,
        'program': program,
        'message': '✅ Programme importé avec succès !',
      };
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Erreur import JSON: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return {
        'success': false,
        'error': 'json_parse_error',
        'message': '❌ Erreur: ${e.toString()}',
        'details': stackTrace.toString(),
      };
    }
  }
  
  /// Importe un programme depuis du texte/Markdown
  /// Utilise l'IA pour interpréter le texte et créer le JSON
  static Future<Map<String, dynamic>> importProgramFromText(String textContent) async {
    try {
      final prompt = '''
Analyse ce programme d'entraînement et convertis-le en JSON STRICT :

**Contenu du programme :**
$textContent

**Format JSON STRICT à générer :**
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

Instructions:
- Extrais tous les exercices et leurs détails
- Si une info manque (sets, reps, repos), utilise des valeurs par défaut raisonnables
- Organise les exercices par jours si mentionnés
- Génère UNIQUEMENT le JSON, sans texte supplémentaire
''';

      final response = await GeminiService.askCoach(prompt);
      
      if (!response['success']) {
        return {
          'success': false,
          'error': 'ai_error',
          'message': '❌ Erreur IA lors de l\'analyse. Réessayez.',
        };
      }
      
      String jsonText = response['answer']
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      
      // Maintenant on utilise importProgramFromJson
      return await importProgramFromJson(jsonText);
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('❌ Erreur import texte: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return {
        'success': false,
        'error': 'text_parse_error',
        'message': '❌ Erreur: ${e.toString()}',
        'details': stackTrace.toString(),
      };
    }
  }
  
  /// Détecte automatiquement le type de contenu (JSON ou texte) et importe
  static Future<Map<String, dynamic>> importProgramAuto(String content) async {
    final trimmed = content.trim();
    
    // Vérifier que le contenu n'est pas vide
    if (trimmed.isEmpty) {
      return {
        'success': false,
        'error': 'empty_content',
        'message': '❌ Le contenu est vide. Collez votre programme.',
      };
    }
    
    // Essayer d'abord de parser comme JSON
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        // Tenter de valider le JSON
        final jsonTest = jsonDecode(trimmed);
        
        // Si c'est un objet JSON, tenter l'import
        if (jsonTest is Map) {
          return await importProgramFromJson(trimmed);
        }
      } catch (e) {
        // JSON invalide, proposer de corriger
        return {
          'success': false,
          'error': 'invalid_json',
          'message': '❌ JSON invalide. Vérifiez le format.\n\n'
              '💡 Astuce : Utilisez un validateur JSON en ligne ou copiez l\'exemple fourni.',
        };
      }
    }
    
    // Si ce n'est pas du JSON, expliquer clairement
    return {
      'success': false,
      'error': 'text_format_detected',
      'message': '📝 Texte libre détecté.\n\n'
          '⚠️ La conversion automatique nécessite l\'IA Gemini.\n'
          'Quota temporairement dépassé.\n\n'
          '💡 Solutions :\n'
          '1. Formatez votre programme en JSON (voir exemple ci-dessous)\n'
          '2. Réessayez dans quelques minutes\n\n'
          '📋 Exemple de format JSON :\n'
          '{\n'
          '  "name": "Mon Programme",\n'
          '  "description": "Description du programme",\n'
          '  "userProfile": "Niveau, Objectif",\n'
          '  "workoutDays": [\n'
          '    {\n'
          '      "dayName": "Jour 1",\n'
          '      "focus": "Groupes musculaires",\n'
          '      "exercises": [\n'
          '        {\n'
          '          "exerciseName": "Squat",\n'
          '          "sets": 4,\n'
          '          "reps": "10",\n'
          '          "restSeconds": 90,\n'
          '          "notes": "Conseil technique"\n'
          '        }\n'
          '      ]\n'
          '    }\n'
          '  ]\n'
          '}',
    };
  }
  
  /// Importe un programme depuis un fichier (TXT, JSON, PDF, etc.)
  static Future<Map<String, dynamic>> importProgramFromFile() async {
    try {
      // Ouvrir le sélecteur de fichiers - ACCEPTE TOUS LES FICHIERS
      // Sur mobile (iOS/Android), cela permet de sélectionner depuis n'importe quelle app
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,  // ✅ Accepte TOUS les types de fichiers
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return {
          'success': false,
          'error': 'cancelled',
          'message': '⚠️ Aucun fichier sélectionné.',
        };
      }

      final file = result.files.first;
      String content;

      if (kIsWeb) {
        // Sur Web, utiliser les bytes
        if (file.bytes == null) {
          return {
            'success': false,
            'error': 'no_content',
            'message': '❌ Impossible de lire le fichier.',
          };
        }
        content = String.fromCharCodes(file.bytes!);
      } else {
        // Sur mobile, lire depuis le path
        if (file.path == null) {
          return {
            'success': false,
            'error': 'no_path',
            'message': '❌ Chemin du fichier introuvable.',
          };
        }
        final fileObj = File(file.path!);
        content = await fileObj.readAsString();
      }

      // Vérifier si le contenu est valide (pas vide)
      if (content.trim().isEmpty) {
        return {
          'success': false,
          'error': 'empty_file',
          'message': '❌ Le fichier est vide.\n\n'
              '💡 Astuce : Copiez le contenu et collez-le dans le champ texte.',
        };
      }
      
      // Si c'est un fichier binaire ou non-texte, proposer copier-coller
      if (content.contains(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'))) {
        return {
          'success': false,
          'error': 'binary_file',
          'message': '❌ Ce fichier n\'est pas un fichier texte.\n\n'
              '💡 Astuce : Si c\'est un PDF ou Word, copiez le contenu et collez-le dans le champ texte.',
        };
      }

      // Maintenant on traite le contenu
      return await importProgramAuto(content);

    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur import fichier: $e');
      }
      return {
        'success': false,
        'error': 'file_read_error',
        'message': '❌ Erreur lors de la lecture du fichier.',
      };
    }
  }

  /// ============================================================
  /// SYSTÈME DE PROGRAMME ACTIF / SÉLECTIONNÉ
  /// ============================================================

  static const String _activeProgramKey = 'active_program_id';

  /// Définir un programme comme actif
  static Future<bool> setActiveProgram(String programId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeProgramKey, programId);
      
      if (kDebugMode) {
        developer.log(
          '✅ Programme actif défini: $programId',
          name: 'ActiveProgram',
        );
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          '❌ Erreur setActiveProgram: $e',
          name: 'ActiveProgram',
          error: e,
        );
      }
      return false;
    }
  }

  /// Obtenir l'ID du programme actif
  static Future<String?> getActiveProgramId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeProgramId = prefs.getString(_activeProgramKey);
      
      if (kDebugMode) {
        developer.log(
          'Programme actif: ${activeProgramId ?? "Aucun"}',
          name: 'ActiveProgram',
        );
      }
      
      return activeProgramId;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          '❌ Erreur getActiveProgramId: $e',
          name: 'ActiveProgram',
          error: e,
        );
      }
      return null;
    }
  }

  /// Obtenir le programme actif complet
  static Future<AIProgram?> getActiveProgram() async {
    try {
      final activeProgramId = await getActiveProgramId();
      if (activeProgramId == null) return null;

      final programs = await getPrograms();
      
      for (var program in programs) {
        if (program.id == activeProgramId) {
          if (kDebugMode) {
            developer.log(
              '✅ Programme actif trouvé: ${program.name}',
              name: 'ActiveProgram',
            );
          }
          return program;
        }
      }
      
      if (kDebugMode) {
        developer.log(
          '⚠️ Programme actif introuvable (ID: $activeProgramId)',
          name: 'ActiveProgram',
        );
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          '❌ Erreur getActiveProgram: $e',
          name: 'ActiveProgram',
          error: e,
        );
      }
      return null;
    }
  }

  /// Désactiver le programme actif
  static Future<bool> clearActiveProgram() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeProgramKey);
      
      if (kDebugMode) {
        developer.log(
          '🔄 Programme actif désactivé',
          name: 'ActiveProgram',
        );
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        developer.log(
          '❌ Erreur clearActiveProgram: $e',
          name: 'ActiveProgram',
          error: e,
        );
      }
      return false;
    }
  }
}
