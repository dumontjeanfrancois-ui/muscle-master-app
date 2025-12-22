/// Configuration des limitations Freemium
class FreemiumConfig {
  // Fonctionnalités complètement bloquées en version gratuite
  static const premiumOnlyFeatures = [
    'IA Chef - Génération de recettes',
    'IA Programme Avancé',
    'Analyse Vidéo IA (TEMPO/POSTURE/CHARGE)',
    'Photo Calories IA',
    'Import/Export JSON',
    'Notifications Personnalisées Avancées',
  ];

  // Limitations version gratuite
  static const int maxSaved1RMExercises = 3;
  static const int maxRecordsExercises = 5;
  static const int maxSavedPrograms = 2;
  static const int maxRecipesView = 10;
  static const int maxVideoAnalyses = 0; // Bloqué
  static const int maxPhotoAnalyses = 0; // Bloqué
  
  // Publicités
  static const bool showAdsInFreeVersion = true;
  static const int interstitialAdFrequency = 3; // Toutes les 3 actions
  
  // Accès fonctionnalités
  static bool canAccessAIChef(bool isPremium) => isPremium;
  static bool canAccessAIProgram(bool isPremium) => isPremium;
  static bool canAccessVideoAnalysis(bool isPremium) => isPremium;
  static bool canAccessPhotoAnalysis(bool isPremium) => isPremium;
  static bool canAccessImportExport(bool isPremium) => isPremium;
  static bool canAccessAdvancedNotifications(bool isPremium) => isPremium;
  
  // Messages de limitation
  static String getLimitMessage(String feature) {
    return '🔒 $feature est une fonctionnalité PREMIUM\n\n'
           'Débloquez toutes les fonctionnalités avec Premium à partir de 6,99€/mois';
  }
  
  // Programmes prédéfinis accessibles en gratuit (3 sur 5)
  static const freePrograms = [
    'prog_001', // Débutant - Full Body
    'prog_002', // Push Pull Legs  
    'prog_003', // Force - 5x5
  ];
  
  static bool canAccessProgram(String programId, bool isPremium) {
    if (isPremium) return true;
    return freePrograms.contains(programId);
  }
}
