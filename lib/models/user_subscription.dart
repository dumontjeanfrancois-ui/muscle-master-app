import 'package:cloud_firestore/cloud_firestore.dart';

class UserSubscription {
  final String userId;
  final String status; // 'free', 'premium', 'trial'
  final DateTime? expiryDate;
  final String? platform; // 'android', 'ios', 'stripe', 'web'
  final String? subscriptionId;
  final String? productId;
  final DateTime? startDate;

  UserSubscription({
    required this.userId,
    required this.status,
    this.expiryDate,
    this.platform,
    this.subscriptionId,
    this.productId,
    this.startDate,
  });

  /// Vérifie si l'utilisateur a un abonnement premium actif
  bool get isPremium {
    if (status != 'premium' && status != 'trial') return false;
    if (expiryDate == null) return true; // Lifetime premium
    return expiryDate!.isAfter(DateTime.now());
  }

  /// Vérifie si l'utilisateur est en période d'essai
  bool get isTrial => status == 'trial' && isPremium;

  /// Jours restants avant expiration
  int get daysRemaining {
    if (expiryDate == null) return 999999; // Illimité
    final remaining = expiryDate!.difference(DateTime.now()).inDays;
    return remaining > 0 ? remaining : 0;
  }

  /// Conversion vers Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'status': status,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'platform': platform,
      'subscriptionId': subscriptionId,
      'productId': productId,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Création depuis Map Firestore
  factory UserSubscription.fromMap(Map<String, dynamic> map, String userId) {
    return UserSubscription(
      userId: userId,
      status: map['status'] ?? 'free',
      expiryDate: map['expiryDate'] != null 
          ? (map['expiryDate'] as Timestamp).toDate() 
          : null,
      platform: map['platform'],
      subscriptionId: map['subscriptionId'],
      productId: map['productId'],
      startDate: map['startDate'] != null 
          ? (map['startDate'] as Timestamp).toDate() 
          : null,
    );
  }

  /// État par défaut (gratuit)
  factory UserSubscription.free(String userId) {
    return UserSubscription(
      userId: userId,
      status: 'free',
    );
  }

  /// Copie avec modifications
  UserSubscription copyWith({
    String? status,
    DateTime? expiryDate,
    String? platform,
    String? subscriptionId,
    String? productId,
    DateTime? startDate,
  }) {
    return UserSubscription(
      userId: userId,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      platform: platform ?? this.platform,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      productId: productId ?? this.productId,
      startDate: startDate ?? this.startDate,
    );
  }
}
