import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/workout_video.dart';

class GeminiVisionService {
  static const String _apiKey = 'AIzaSyD19ooMMrcDFMMSLai2MVSwX3taTc8GguI'; // Clé API Muscle Master
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  /// Analyse technique d'un exercice vidéo à partir de frames
  static Future<WorkoutAnalysis> analyzeWorkoutVideo({
    required String exerciseName,
    required List<String> framesPaths,
  }) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception('⚠️ Clé API Gemini manquante. Configurez votre clé dans gemini_vision_service.dart');
    }

    try {
      // Lire et encoder les images en base64
      final List<String> base64Images = [];
      for (final framePath in framesPaths) {
        final file = File(framePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          base64Images.add(base64Encode(bytes));
        }
      }

      if (base64Images.isEmpty) {
        throw Exception('Aucune image à analyser');
      }

      // Construire le prompt expert
      final prompt = _buildAnalysisPrompt(exerciseName, base64Images.length);

      // Construire la requête
      final parts = <Map<String, dynamic>>[];
      parts.add({'text': prompt});
      
      for (final base64Image in base64Images) {
        parts.add({
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Image,
          }
        });
      }

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {'parts': parts}
          ],
          'generationConfig': {
            'temperature': 0.4,
            'topK': 32,
            'topP': 1,
            'maxOutputTokens': 2048,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final answer = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 
                      'Impossible de générer une analyse.';

        // Parser la réponse pour extraire les données structurées
        return _parseAnalysisResponse(answer);
      } else {
        throw Exception('Erreur API Gemini (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  static String _buildAnalysisPrompt(String exerciseName, int frameCount) {
    return '''
Tu es un coach expert en musculation avec 20 ans d'expérience. 
Analyse la technique d'exécution de cet exercice : **$exerciseName**

J'ai $frameCount images montrant la séquence complète du mouvement :
- Image 1 : Position de départ
- Image 2 : Phase descendante / concentrique
- Image 3 : Position basse / point critique
- Image 4 : Phase montante / excentrique

**Instructions d'analyse :**

1. **Score technique** : Donne un score global /10
2. **Points forts** : Liste 2-3 aspects bien exécutés
3. **Points à améliorer** : Liste 2-3 erreurs ou risques détectés
4. **Conseils pratiques** : 3 tips concrets pour progresser

**Critères d'évaluation pour $exerciseName :**
- Alignement du dos et de la colonne
- Position et trajectoire des articulations
- Amplitude du mouvement (ROM)
- Symétrie gauche/droite
- Stabilité et équilibre
- Risques de blessure

**Format de réponse STRICT (JSON) :**
{
  "overallScore": 75,
  "technicalFeedback": "Technique correcte avec quelques ajustements nécessaires. Le mouvement est bien contrôlé mais nécessite des améliorations au niveau de la posture.",
  "strengthPoints": [
    "Dos bien droit durant tout le mouvement",
    "Profondeur excellente",
    "Bon contrôle de la descente"
  ],
  "improvementPoints": [
    "Genoux légèrement en avant des orteils",
    "Talons qui décollent en position basse",
    "Remontée un peu trop rapide"
  ],
  "detailedScores": {
    "posture": 80,
    "alignement": 70,
    "profondeur": 85,
    "symétrie": 75
  }
}

Génère UNIQUEMENT le JSON, sans texte avant ou après.
Sois direct, motivant et professionnel. Utilise un ton encourageant mais honnête.
''';
  }

  static WorkoutAnalysis _parseAnalysisResponse(String response) {
    try {
      // Nettoyer la réponse
      String jsonText = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = jsonDecode(jsonText);

      return WorkoutAnalysis(
        overallScore: data['overallScore'] as int? ?? 50,
        technicalFeedback: data['technicalFeedback'] as String? ?? 'Analyse terminée.',
        strengthPoints: data['strengthPoints'] != null
            ? List<String>.from(data['strengthPoints'] as List)
            : ['Technique correcte'],
        improvementPoints: data['improvementPoints'] != null
            ? List<String>.from(data['improvementPoints'] as List)
            : ['Continue de t\'entraîner'],
        detailedScores: data['detailedScores'] != null
            ? Map<String, int>.from(data['detailedScores'])
            : {
                'posture': 50,
                'alignement': 50,
                'profondeur': 50,
                'symétrie': 50,
              },
        analyzedAt: DateTime.now(),
      );
    } catch (e) {
      // Fallback si le parsing échoue
      return WorkoutAnalysis(
        overallScore: 50,
        technicalFeedback: response.length > 500 ? response.substring(0, 500) : response,
        strengthPoints: ['Technique analysée'],
        improvementPoints: ['Voir feedback détaillé ci-dessus'],
        detailedScores: {
          'posture': 50,
          'alignement': 50,
          'profondeur': 50,
          'symétrie': 50,
        },
        analyzedAt: DateTime.now(),
      );
    }
  }
}
