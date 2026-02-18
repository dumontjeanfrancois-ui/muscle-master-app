import 'package:hive/hive.dart';

part 'mascot_settings.g.dart';

/// Modèle de données pour les paramètres de la mascotte
/// Stocké localement avec Hive pour persister les préférences utilisateur
@HiveType(typeId: 10)
class MascotSettings extends HiveObject {
  /// Type de mascotte choisie par l'utilisateur
  @HiveField(0)
  String mascotType; // 'male', 'female', 'none'

  /// Visibilité de la mascotte dans l'application
  @HiveField(1)
  bool isVisible;

  /// Nom personnalisé donné à la mascotte (optionnel)
  @HiveField(2)
  String? customName;

  /// Date de dernière interaction avec la mascotte
  @HiveField(3)
  DateTime? lastInteraction;

  MascotSettings({
    this.mascotType = 'male', // Par défaut: Flexo Lion (masculin)
    this.isVisible = true, // Par défaut: visible
    this.customName,
    this.lastInteraction,
  });

  /// Obtenir le chemin de l'asset de la mascotte selon le type
  String get assetPath {
    switch (mascotType) {
      case 'male':
        return 'assets/mascots/flexo_lion_male.png';
      case 'female':
        return 'assets/mascots/flexa_lioness_female.png';
      case 'none':
      default:
        return '';
    }
  }

  /// Obtenir le nom par défaut de la mascotte
  String get defaultName {
    switch (mascotType) {
      case 'male':
        return 'Flexo Lion';
      case 'female':
        return 'Flexa Lioness';
      case 'none':
      default:
        return '';
    }
  }

  /// Obtenir le nom affiché (personnalisé ou par défaut)
  String get displayName => customName ?? defaultName;

  /// Alias pour mascotType (utilisé dans le code pour cohérence)
  String get selectedMascot => mascotType;

  /// Copier avec modifications
  MascotSettings copyWith({
    String? mascotType,
    bool? isVisible,
    String? customName,
    DateTime? lastInteraction,
  }) {
    return MascotSettings(
      mascotType: mascotType ?? this.mascotType,
      isVisible: isVisible ?? this.isVisible,
      customName: customName ?? this.customName,
      lastInteraction: lastInteraction ?? this.lastInteraction,
    );
  }

  /// Conversion en Map pour debugging
  Map<String, dynamic> toJson() {
    return {
      'mascotType': mascotType,
      'isVisible': isVisible,
      'customName': customName,
      'lastInteraction': lastInteraction?.toIso8601String(),
    };
  }

  @override
  String toString() => 'MascotSettings(${toJson()})';
}
