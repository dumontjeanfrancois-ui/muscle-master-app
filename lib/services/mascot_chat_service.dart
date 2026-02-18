import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

/// Service de chat avec la mascotte (IA locale)
/// Utilise une base de connaissances pré-programmée pour répondre aux questions
class MascotChatService {
  static const String _chatHistoryKey = 'mascot_chat_history';
  static const int _maxHistoryLength = 100;

  /// Obtenir l'historique des messages
  static Future<List<ChatMessage>> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_chatHistoryKey);
    
    if (historyJson == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((json) => ChatMessage.fromJson(json)).toList();
  }

  /// Sauvegarder l'historique des messages
  static Future<void> _saveChatHistory(List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Limiter la taille de l'historique
    final limitedMessages = messages.length > _maxHistoryLength
        ? messages.sublist(messages.length - _maxHistoryLength)
        : messages;
    
    final encoded = jsonEncode(limitedMessages.map((m) => m.toJson()).toList());
    await prefs.setString(_chatHistoryKey, encoded);
  }

  /// Ajouter un message utilisateur et obtenir une réponse
  static Future<ChatMessage> sendMessage(String userMessage) async {
    // Ajouter le message utilisateur à l'historique
    final history = await getChatHistory();
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );
    history.add(userMsg);

    // Générer une réponse basée sur la base de connaissances
    final response = _generateResponse(userMessage.toLowerCase());
    final mascotMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_bot',
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
    history.add(mascotMsg);

    // Sauvegarder l'historique
    await _saveChatHistory(history);

    return mascotMsg;
  }

  /// Effacer l'historique des messages
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
  }

  /// Générer une réponse basée sur les mots-clés
  static String _generateResponse(String message) {
    // Base de connaissances fitness/nutrition
    
    // Questions sur la musculation
    if (message.contains('muscle') || message.contains('musculation')) {
      return "💪 La musculation est essentielle pour développer ta force et ta masse musculaire ! "
          "Je te recommande de suivre un programme progressif avec des exercices de base comme le squat, "
          "le développé couché et le soulevé de terre.";
    }
    
    if (message.contains('exercice') || message.contains('mouvement')) {
      return "🏋️ Les meilleurs exercices dépendent de tes objectifs ! "
          "Pour la masse : squat, développé couché, soulevé de terre, rowing. "
          "Pour la définition : ajoute des exercices d'isolation et du cardio modéré.";
    }

    if (message.contains('squat')) {
      return "🦵 Le squat est le roi des exercices ! Voici mes conseils :\n"
          "• Garde le dos droit\n"
          "• Descends jusqu'à ce que tes cuisses soient parallèles au sol\n"
          "• Pousse sur tes talons pour remonter\n"
          "• Engage tes abdos pendant tout le mouvement";
    }

    if (message.contains('développé') || message.contains('bench')) {
      return "💪 Le développé couché est excellent pour les pectoraux ! Conseils :\n"
          "• Garde les omoplates serrées\n"
          "• Descends la barre jusqu'à ta poitrine\n"
          "• Pousse de manière explosive vers le haut\n"
          "• Ne verrouille pas complètement les coudes en haut";
    }

    // Questions sur la nutrition
    if (message.contains('protéine') || message.contains('proteine')) {
      return "🥩 Les protéines sont essentielles pour la construction musculaire ! "
          "Vise 1,6 à 2,2g par kg de poids corporel. Sources : poulet, poisson, œufs, "
          "légumineuses, produits laitiers.";
    }

    if (message.contains('macro') || message.contains('calorie')) {
      return "📊 Tes macros dépendent de ton objectif :\n"
          "• Prise de masse : surplus de 300-500 cal, 40% glucides, 30% protéines, 30% lipides\n"
          "• Sèche : déficit de 300-500 cal, 30% glucides, 40% protéines, 30% lipides\n"
          "Utilise le calculateur de l'app pour personnaliser !";
    }

    if (message.contains('manger') || message.contains('alimentation')) {
      return "🍽️ Une alimentation équilibrée est la clé ! Privilégie :\n"
          "• Protéines maigres (poulet, poisson, œufs)\n"
          "• Glucides complexes (riz, patates douces, avoine)\n"
          "• Bonnes graisses (avocat, noix, huile d'olive)\n"
          "• Légumes à chaque repas";
    }

    // Questions sur la récupération
    if (message.contains('repos') || message.contains('récupération') || message.contains('recuperation')) {
      return "😴 La récupération est aussi importante que l'entraînement !\n"
          "• Dors 7-9h par nuit\n"
          "• Laisse 48h de repos entre deux séances du même groupe musculaire\n"
          "• Hydrate-toi bien (2-3L d'eau/jour)\n"
          "• Mange suffisamment de protéines";
    }

    if (message.contains('sommeil') || message.contains('dormir')) {
      return "😴 Le sommeil est crucial pour la croissance musculaire ! "
          "Pendant le sommeil, ton corps libère de l'hormone de croissance et répare tes muscles. "
          "Vise 7-9h de sommeil de qualité chaque nuit.";
    }

    // Questions sur les programmes
    if (message.contains('programme') || message.contains('plan')) {
      return "📋 Choisis un programme adapté à ton niveau :\n"
          "• Débutant : full body 3x/semaine\n"
          "• Intermédiaire : upper/lower split 4x/semaine\n"
          "• Avancé : push/pull/legs 6x/semaine\n"
          "Consulte la section Programmes de l'app !";
    }

    // Questions sur la motivation
    if (message.contains('motiv') || message.contains('courage')) {
      return "🔥 Tu as ça en toi ! La régularité bat l'intensité. "
          "Chaque séance te rapproche de ton objectif. Ne compare pas ton chapitre 1 "
          "au chapitre 20 de quelqu'un d'autre. Continue, tu vas y arriver ! 💪";
    }

    if (message.contains('commencer') || message.contains('débuter') || message.contains('debuter')) {
      return "🚀 Félicitations pour ta décision ! Voici par où commencer :\n"
          "1. Fixe des objectifs réalistes\n"
          "2. Commence par 3 séances/semaine\n"
          "3. Apprends la technique avant de charger lourd\n"
          "4. Sois patient et régulier\n"
          "Tu as tout ce qu'il faut dans cette app !";
    }

    // Questions sur les objectifs
    if (message.contains('prise de masse') || message.contains('prendre du muscle')) {
      return "💪 Pour la prise de masse :\n"
          "• Surplus calorique de 300-500 cal/jour\n"
          "• Entraînement avec charges lourdes (6-12 reps)\n"
          "• 1,6-2,2g protéines/kg de poids\n"
          "• Sommeil de qualité 7-9h\n"
          "• Patience : vise 0,5-1kg de muscle/mois";
    }

    if (message.contains('sèche') || message.contains('seche') || message.contains('perdre') || message.contains('maigrir')) {
      return "🔥 Pour la sèche/perte de gras :\n"
          "• Déficit calorique de 300-500 cal/jour\n"
          "• Garde ton apport en protéines élevé (2g/kg)\n"
          "• Continue la muscu pour préserver le muscle\n"
          "• Ajoute du cardio modéré 2-3x/semaine\n"
          "• Vise 0,5-1kg/semaine max";
    }

    // Salutations
    if (message.contains('bonjour') || message.contains('salut') || message.contains('hello') || message.contains('hey')) {
      return "🦁 Salut champion ! Je suis là pour répondre à tes questions sur la musculation, "
          "la nutrition et t'aider à atteindre tes objectifs. Que veux-tu savoir ?";
    }

    if (message.contains('merci') || message.contains('thanks')) {
      return "😊 De rien ! C'est un plaisir de t'aider. N'hésite pas si tu as d'autres questions. "
          "Continue comme ça, tu es sur la bonne voie ! 💪";
    }

    // Réponse par défaut
    return "🤔 Je n'ai pas bien compris ta question. Voici ce sur quoi je peux t'aider :\n\n"
        "💪 Musculation : exercices, techniques, programmes\n"
        "🍽️ Nutrition : macros, calories, alimentation\n"
        "😴 Récupération : sommeil, repos\n"
        "🎯 Objectifs : prise de masse, sèche, force\n\n"
        "Reformule ta question et je ferai de mon mieux pour t'aider !";
  }
}
