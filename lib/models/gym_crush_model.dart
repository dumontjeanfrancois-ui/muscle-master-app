import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'gym_crush_model.g.dart';

/// Modèle de données pour les interactions Gym Crush
/// Stocké localement avec Hive
@HiveType(typeId: 11)
class GymCrushSettings extends HiveObject {
  /// Activation du mode Gym Crush
  @HiveField(0)
  bool isEnabled;

  /// Distance maximale de détection (en mètres)
  @HiveField(1)
  int maxDistance;

  /// Nombre maximum de gym crush actifs
  @HiveField(2)
  int maxActiveCrushes;

  GymCrushSettings({
    this.isEnabled = false, // Désactivé par défaut
    this.maxDistance = 100, // 100 mètres par défaut
    this.maxActiveCrushes = 2, // Max 2 gym crush actifs
  });

  GymCrushSettings copyWith({
    bool? isEnabled,
    int? maxDistance,
    int? maxActiveCrushes,
  }) {
    return GymCrushSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      maxDistance: maxDistance ?? this.maxDistance,
      maxActiveCrushes: maxActiveCrushes ?? this.maxActiveCrushes,
    );
  }
}

/// Statut d'une interaction Gym Crush
enum GymCrushStatus {
  @HiveField(0)
  pending, // En attente
  
  @HiveField(1)
  mutual, // Mutuel (les deux ont gym crush)
  
  @HiveField(2)
  friend, // Ami (sans gym crush)
  
  @HiveField(3)
  ignored, // Ignoré
  
  @HiveField(4)
  blocked, // Bloqué
}

/// Profil utilisateur Gym Crush (données publiques limitées)
@HiveType(typeId: 12)
class GymCrushUser {
  /// ID utilisateur (anonymisé)
  @HiveField(0)
  final String userId;

  /// Pseudo public
  @HiveField(1)
  final String pseudo;

  /// Type de mascotte (male/female)
  @HiveField(2)
  final String mascotType;

  /// Nom personnalisé de la mascotte (optionnel)
  @HiveField(3)
  final String? mascotName;

  /// Timestamp dernière activité (pour heartbeat)
  @HiveField(4)
  final DateTime lastActivity;

  /// Salle de sport (ID ou nom anonymisé)
  @HiveField(5)
  final String? gymId;

  /// Présence active (pour filtrage temps réel)
  @HiveField(6)
  final bool isActive;

  /// Date d'expiration de la présence (heartbeat)
  @HiveField(7)
  final DateTime expiresAt;

  GymCrushUser({
    required this.userId,
    required this.pseudo,
    required this.mascotType,
    this.mascotName,
    required this.lastActivity,
    this.gymId,
    this.isActive = true,
    required this.expiresAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'pseudo': pseudo,
      'mascotType': mascotType,
      'mascotName': mascotName,
      'gymId': gymId,
      'isActive': isActive,
      'lastActivity': Timestamp.fromDate(lastActivity),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }

  factory GymCrushUser.fromFirestore(Map<String, dynamic> data) {
    return GymCrushUser(
      userId: data['userId'] as String,
      pseudo: data['pseudo'] as String,
      mascotType: data['mascotType'] as String,
      mascotName: data['mascotName'] as String?,
      gymId: data['gymId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      lastActivity: (data['lastActivity'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }
}

/// Interaction Gym Crush
@HiveType(typeId: 13)
class GymCrushInteraction {
  /// ID de l'interaction
  @HiveField(0)
  final String interactionId;

  /// ID utilisateur cible
  @HiveField(1)
  final String targetUserId;

  /// Pseudo cible
  @HiveField(2)
  final String targetPseudo;

  /// Mascotte cible
  @HiveField(3)
  final String targetMascotType;

  /// Statut de l'interaction
  @HiveField(4)
  GymCrushStatus status;

  /// Date de création
  @HiveField(5)
  final DateTime createdAt;

  /// Date de dernière mise à jour
  @HiveField(6)
  DateTime updatedAt;

  /// Chat débloqué (si mutuel)
  @HiveField(7)
  bool chatUnlocked;

  GymCrushInteraction({
    required this.interactionId,
    required this.targetUserId,
    required this.targetPseudo,
    required this.targetMascotType,
    this.status = GymCrushStatus.pending,
    required this.createdAt,
    required this.updatedAt,
    this.chatUnlocked = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'interactionId': interactionId,
      'targetUserId': targetUserId,
      'targetPseudo': targetPseudo,
      'targetMascotType': targetMascotType,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'chatUnlocked': chatUnlocked,
    };
  }

  factory GymCrushInteraction.fromFirestore(Map<String, dynamic> data) {
    return GymCrushInteraction(
      interactionId: data['interactionId'] as String,
      targetUserId: data['targetUserId'] as String,
      targetPseudo: data['targetPseudo'] as String,
      targetMascotType: data['targetMascotType'] as String,
      status: GymCrushStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => GymCrushStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      chatUnlocked: data['chatUnlocked'] as bool? ?? false,
    );
  }

  GymCrushInteraction copyWith({
    GymCrushStatus? status,
    DateTime? updatedAt,
    bool? chatUnlocked,
  }) {
    return GymCrushInteraction(
      interactionId: interactionId,
      targetUserId: targetUserId,
      targetPseudo: targetPseudo,
      targetMascotType: targetMascotType,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      chatUnlocked: chatUnlocked ?? this.chatUnlocked,
    );
  }
}

/// Message Gym Crush (si chat débloqué)
@HiveType(typeId: 14)
class GymCrushMessage {
  /// ID du message
  @HiveField(0)
  final String messageId;

  /// ID de l'interaction
  @HiveField(1)
  final String interactionId;

  /// ID expéditeur
  @HiveField(2)
  final String senderId;

  /// ID destinataire
  @HiveField(3)
  final String receiverId;

  /// Contenu du message
  @HiveField(4)
  final String content;

  /// Date d'envoi
  @HiveField(5)
  final DateTime sentAt;

  /// Message lu
  @HiveField(6)
  bool isRead;

  GymCrushMessage({
    required this.messageId,
    required this.interactionId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'interactionId': interactionId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
    };
  }

  factory GymCrushMessage.fromFirestore(Map<String, dynamic> data) {
    return GymCrushMessage(
      messageId: data['messageId'] as String,
      interactionId: data['interactionId'] as String,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      content: data['content'] as String,
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
