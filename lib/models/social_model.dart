import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'social_model.g.dart';

/// Paramètres sociaux locaux
@HiveType(typeId: 15)
class SocialSettings extends HiveObject {
  @HiveField(0)
  bool isEnabled;

  @HiveField(1)
  bool invisibleMode;

  @HiveField(2)
  int maxConnections;

  SocialSettings({
    this.isEnabled = false,
    this.invisibleMode = false,
    this.maxConnections = 3,
  });

  SocialSettings copyWith({
    bool? isEnabled,
    bool? invisibleMode,
    int? maxConnections,
  }) {
    return SocialSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      invisibleMode: invisibleMode ?? this.invisibleMode,
      maxConnections: maxConnections ?? this.maxConnections,
    );
  }
}

/// Connexion (ami sportif)
@HiveType(typeId: 16)
class Connection {
  @HiveField(0)
  final String userId;

  @HiveField(1)
  final String friendId;

  @HiveField(2)
  final String pseudo;

  @HiveField(3)
  final String mascotType;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final bool isDeleted;

  @HiveField(7)
  final DateTime? deletedAt;

  Connection({
    required this.userId,
    required this.friendId,
    required this.pseudo,
    required this.mascotType,
    required this.createdAt,
    this.isActive = true,
    this.isDeleted = false,
    this.deletedAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'friendId': friendId,
      'pseudo': pseudo,
      'mascotType': mascotType,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  factory Connection.fromFirestore(Map<String, dynamic> data) {
    return Connection(
      userId: data['userId'] as String,
      friendId: data['friendId'] as String,
      pseudo: data['pseudo'] as String,
      mascotType: data['mascotType'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
      isDeleted: data['isDeleted'] as bool? ?? false,
      deletedAt: data['deletedAt'] != null 
          ? (data['deletedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Connection copyWith({
    bool? isActive,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Connection(
      userId: userId,
      friendId: friendId,
      pseudo: pseudo,
      mascotType: mascotType,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

/// Utilisateur actif (présence temps réel)
class ActiveUser {
  final String userId;
  final String pseudo;
  final String mascotType;
  final String? mascotName;
  final String? gymId;
  final bool isActive;
  final DateTime lastActivity;
  final DateTime expiresAt;
  final bool invisibleMode;

  ActiveUser({
    required this.userId,
    required this.pseudo,
    required this.mascotType,
    this.mascotName,
    this.gymId,
    this.isActive = true,
    required this.lastActivity,
    required this.expiresAt,
    this.invisibleMode = false,
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
      'invisibleMode': invisibleMode,
    };
  }

  factory ActiveUser.fromFirestore(Map<String, dynamic> data) {
    return ActiveUser(
      userId: data['userId'] as String,
      pseudo: data['pseudo'] as String,
      mascotType: data['mascotType'] as String,
      mascotName: data['mascotName'] as String?,
      gymId: data['gymId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      lastActivity: (data['lastActivity'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      invisibleMode: data['invisibleMode'] as bool? ?? false,
    );
  }
}

/// Message chat
class ChatMessage {
  final String messageId;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  ChatMessage({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      messageId: data['messageId'] as String,
      chatId: data['chatId'] as String,
      senderId: data['senderId'] as String,
      content: data['content'] as String,
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}

/// Profil utilisateur premium
class UserProfile {
  final String userId;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final int boostCredits;

  UserProfile({
    required this.userId,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.boostCredits = 0,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt != null 
          ? Timestamp.fromDate(premiumExpiresAt!) 
          : null,
      'boostCredits': boostCredits,
    };
  }

  factory UserProfile.fromFirestore(Map<String, dynamic> data) {
    return UserProfile(
      userId: data['userId'] as String,
      isPremium: data['isPremium'] as bool? ?? false,
      premiumExpiresAt: data['premiumExpiresAt'] != null 
          ? (data['premiumExpiresAt'] as Timestamp).toDate() 
          : null,
      boostCredits: data['boostCredits'] as int? ?? 0,
    );
  }

  bool get isActivePremium {
    if (!isPremium) return false;
    if (premiumExpiresAt == null) return false;
    return premiumExpiresAt!.isAfter(DateTime.now());
  }

  int get maxConnections {
    return isActivePremium ? 999999 : 3;
  }
}
