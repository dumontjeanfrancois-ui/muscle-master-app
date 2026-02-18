import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  // ⚠️ IMPORTANT : Clé API Gemini configurée pour Muscle Master
  // Obtenez-la gratuitement sur : https://makersuite.google.com/app/apikey
  static const String _apiKey = 'AIzaSyD19ooMMrcDFMMSLai2MVSwX3taTc8GguI';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent';
  
  // Limites gratuites
  static const int FREE_QUESTIONS_PER_MONTH = 10;
  static const String _questionCountKey = 'gemini_question_count';
  static const String _lastResetKey = 'gemini_last_reset';
  
  // Prompt système pour le coach
  static const String _systemPrompt = '''
Tu es un coach professionnel en musculation et nutrition sportive avec 15 ans d'expérience.

**Ton expertise :**
- Programmes de musculation (force, hypertrophie, endurance)
- Nutrition sportive et calcul de macronutriments
- Supplémentation (créatine, whey, BCAA, etc.)
- Technique d'exécution des exercices
- Prévention des blessures
- Motivation et mental

**Ton style de communication :**
- Direct et motivant (style underground/hardcore)
- Utilise des émojis 💪🔥⚡ pour l'énergie
- Réponses concises mais complètes (150-300 mots max)
- Toujours basé sur la science et l'expérience
- Encourage et motive l'utilisateur

**Important :**
- Adapte tes conseils au niveau de l'utilisateur
- Demande des précisions si nécessaire (poids, taille, objectif)
- Ne donne JAMAIS de conseils médicaux (renvoie vers un médecin)
- Réponds en français

Sois le meilleur coach qu'ils aient jamais eu ! 💪
''';

  /// Vérifie si l'utilisateur a encore des questions gratuites disponibles
  static Future<Map<String, dynamic>> checkQuota() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Vérifier si on doit reset le compteur (nouveau mois)
    final lastReset = prefs.getString(_lastResetKey);
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month}';
    
    if (lastReset != currentMonth) {
      // Nouveau mois, reset le compteur
      await prefs.setInt(_questionCountKey, 0);
      await prefs.setString(_lastResetKey, currentMonth);
    }
    
    final count = prefs.getInt(_questionCountKey) ?? 0;
    final remaining = FREE_QUESTIONS_PER_MONTH - count;
    
    return {
      'used': count,
      'remaining': remaining > 0 ? remaining : 0,
      'hasQuota': remaining > 0,
      'total': FREE_QUESTIONS_PER_MONTH,
    };
  }
  
  /// Incrémente le compteur de questions
  static Future<void> _incrementQuestionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_questionCountKey) ?? 0;
    await prefs.setInt(_questionCountKey, count + 1);
  }
  
  /// Envoie une question au coach IA Gemini
  static Future<Map<String, dynamic>> askCoach(String question) async {
    // Vérifier le quota
    final quota = await checkQuota();
    if (!quota['hasQuota']) {
      return {
        'success': false,
        'error': 'quota_exceeded',
        'message': 'Vous avez atteint la limite de ${FREE_QUESTIONS_PER_MONTH} questions gratuites ce mois-ci. '
                   'Passez à Muscle Master Premium pour des questions illimitées ! 💎',
      };
    }
    
    // Vérifier la clé API
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return {
        'success': false,
        'error': 'no_api_key',
        'message': '⚠️ Clé API Gemini manquante. '
                   'Le développeur doit configurer la clé API dans gemini_service.dart',
      };
    }
    
    try {
      // Construire la requête avec le prompt système
      final fullPrompt = '$_systemPrompt\n\nQuestion de l\'utilisateur : $question';
      
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': fullPrompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extraire la réponse
        final answer = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? 
                      'Désolé, je n\'ai pas pu générer une réponse.';
        
        // Incrémenter le compteur
        await _incrementQuestionCount();
        
        // Récupérer le nouveau quota
        final newQuota = await checkQuota();
        
        return {
          'success': true,
          'answer': answer,
          'quota': newQuota,
        };
      } else {
        // Gérer les erreurs API
        final errorData = jsonDecode(response.body);
        String errorMessage = 'Erreur API (${response.statusCode})';
        
        if (errorData['error']?['message'] != null) {
          errorMessage = errorData['error']['message'];
        }
        
        return {
          'success': false,
          'error': 'api_error',
          'message': 'Erreur Gemini : $errorMessage',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'network_error',
        'message': 'Erreur de connexion. Vérifiez votre connexion Internet. 📡',
      };
    }
  }
  
  /// Reset le compteur de questions (pour debug uniquement)
  static Future<void> resetQuota() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_questionCountKey, 0);
  }
}
