import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/gym_crush_model.dart';

/// Service de gestion du module social Gym Crush
/// Module activable/désactivable pour rencontres dans la salle de sport
class GymCrushService {
  static const String _settingsBoxName = 'gymCrushSettings';
  static const String _interactionsBoxName = 'gymCrushInteractions';
  
  static Box<GymCrushSettings>? _settingsBox;
  static Box<GymCrushInteraction>? _interactionsBox;
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initialiser le service Hive
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      _settingsBox = await Hive.openBox<GymCrushSettings>(_settingsBoxName);
    } else {
      _settingsBox = Hive.box<GymCrushSettings>(_settingsBoxName);
    }

    if (!Hive.isBoxOpen(_interactionsBoxName)) {
      _interactionsBox = await Hive.openBox<GymCrushInteraction>(_interactionsBoxName);
    } else {
      _interactionsBox = Hive.box<GymCrushInteraction>(_interactionsBoxName);
    }
  }

  /// Obtenir les paramètres Gym Crush
  static GymCrushSettings getSettings() {
    if (_settingsBox == null) {
      throw Exception('GymCrushService not initialized');
    }

    if (_settingsBox!.isEmpty) {
      final defaultSettings = GymCrushSettings();
      _settingsBox!.put('current', defaultSettings);
      return defaultSettings;
    }

    return _settingsBox!.get('current', defaultValue: GymCrushSettings())!;
  }

  /// Activer/Désactiver le mode Gym Crush
  static Future<void> toggleGymCrushMode(bool enabled) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(isEnabled: enabled);
    await _settingsBox!.put('current', updatedSettings);

    // Si désactivation, supprimer présence Firestore
    if (!enabled) {
      await _removeUserPresence();
    }
  }

  /// Vérifier si le mode Gym Crush est activé
  static bool isGymCrushEnabled() {
    return getSettings().isEnabled;
  }

  /// Mettre à jour la présence utilisateur dans Firestore
  /// (Appelé quand l'utilisateur est en entraînement actif)
  static Future<void> updateUserPresence({
    required String userId,
    required String pseudo,
    required String mascotType,
    String? mascotName,
    String? gymId,
  }) async {
    if (!isGymCrushEnabled()) return;

    try {
      final user = GymCrushUser(
        userId: userId,
        pseudo: pseudo,
        mascotType: mascotType,
        mascotName: mascotName,
        lastActivity: DateTime.now(),
        gymId: gymId,
      );

      await _firestore
          .collection('gym_crush_presence')
          .doc(userId)
          .set(user.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur mise à jour présence Gym Crush: $e');
      }
    }
  }

  /// Supprimer la présence utilisateur
  static Future<void> _removeUserPresence() async {
    // Implémenter selon le userId actuel
    // await _firestore.collection('gym_crush_presence').doc(userId).delete();
  }

  /// Détecter les utilisateurs proches
  /// Critères: même salle, fin d'entraînement proche (±15 min), non ignoré/bloqué
  static Future<List<GymCrushUser>> detectNearbyUsers({
    required String currentUserId,
    required String? currentGymId,
  }) async {
    if (!isGymCrushEnabled() || currentGymId == null) {
      return [];
    }

    try {
      final now = DateTime.now();
      final timeWindow = now.subtract(const Duration(minutes: 15));

      final querySnapshot = await _firestore
          .collection('gym_crush_presence')
          .where('gymId', isEqualTo: currentGymId)
          .where('lastActivity', isGreaterThan: timeWindow.toIso8601String())
          .get();

      final users = querySnapshot.docs
          .map((doc) => GymCrushUser.fromFirestore(doc.data()))
          .where((user) => user.userId != currentUserId) // Exclure soi-même
          .toList();

      // Filtrer utilisateurs déjà ignorés/bloqués
      final filteredUsers = <GymCrushUser>[];
      for (final user in users) {
        final interaction = await _getInteraction(user.userId);
        if (interaction == null ||
            (interaction.status != GymCrushStatus.ignored &&
                interaction.status != GymCrushStatus.blocked)) {
          filteredUsers.add(user);
        }
      }

      return filteredUsers;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur détection utilisateurs: $e');
      }
      return [];
    }
  }

  /// Créer une interaction Gym Crush
  static Future<GymCrushInteraction> createInteraction({
    required String currentUserId,
    required GymCrushUser targetUser,
    required GymCrushStatus status,
  }) async {
    final interactionId = '${currentUserId}_${targetUser.userId}';
    
    final interaction = GymCrushInteraction(
      interactionId: interactionId,
      targetUserId: targetUser.userId,
      targetPseudo: targetUser.pseudo,
      targetMascotType: targetUser.mascotType,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Sauvegarder localement
    await _interactionsBox!.put(interactionId, interaction);

    // Sauvegarder dans Firestore
    await _firestore
        .collection('gym_crush_interactions')
        .doc(currentUserId)
        .collection('interactions')
        .doc(targetUser.userId)
        .set(interaction.toFirestore());

    // Vérifier mutualité si gym crush
    if (status == GymCrushStatus.pending) {
      await _checkMutualCrush(currentUserId, targetUser.userId, interaction);
    }

    return interaction;
  }

  /// Vérifier si gym crush mutuel
  static Future<void> _checkMutualCrush(
    String currentUserId,
    String targetUserId,
    GymCrushInteraction currentInteraction,
  ) async {
    try {
      final targetDoc = await _firestore
          .collection('gym_crush_interactions')
          .doc(targetUserId)
          .collection('interactions')
          .doc(currentUserId)
          .get();

      if (targetDoc.exists) {
        final targetInteraction = GymCrushInteraction.fromFirestore(targetDoc.data()!);
        
        if (targetInteraction.status == GymCrushStatus.pending) {
          // Mutuel ! Débloquer le chat
          await _unlockChat(currentUserId, targetUserId);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur vérification mutualité: $e');
      }
    }
  }

  /// Débloquer le chat (gym crush mutuel)
  static Future<void> _unlockChat(String userId1, String userId2) async {
    try {
      // Mettre à jour les deux côtés
      await _firestore
          .collection('gym_crush_interactions')
          .doc(userId1)
          .collection('interactions')
          .doc(userId2)
          .update({
        'status': GymCrushStatus.mutual.toString().split('.').last,
        'chatUnlocked': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      await _firestore
          .collection('gym_crush_interactions')
          .doc(userId2)
          .collection('interactions')
          .doc(userId1)
          .update({
        'status': GymCrushStatus.mutual.toString().split('.').last,
        'chatUnlocked': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      // Mettre à jour localement
      final interactionId = '${userId1}_$userId2';
      final localInteraction = _interactionsBox!.get(interactionId);
      if (localInteraction != null) {
        final updated = localInteraction.copyWith(
          status: GymCrushStatus.mutual,
          chatUnlocked: true,
          updatedAt: DateTime.now(),
        );
        await _interactionsBox!.put(interactionId, updated);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur déblocage chat: $e');
      }
    }
  }

  /// Obtenir une interaction existante
  static Future<GymCrushInteraction?> _getInteraction(String targetUserId) async {
    final interactionId = 'currentUserId_$targetUserId'; // À remplacer par vrai userId
    return _interactionsBox!.get(interactionId);
  }

  /// Ignorer un utilisateur
  static Future<void> ignoreUser(String currentUserId, String targetUserId) async {
    final interactionId = '${currentUserId}_$targetUserId';
    final existing = _interactionsBox!.get(interactionId);
    
    if (existing != null) {
      final updated = existing.copyWith(
        status: GymCrushStatus.ignored,
        updatedAt: DateTime.now(),
      );
      await _interactionsBox!.put(interactionId, updated);
    }

    await _firestore
        .collection('gym_crush_interactions')
        .doc(currentUserId)
        .collection('interactions')
        .doc(targetUserId)
        .update({
      'status': GymCrushStatus.ignored.toString().split('.').last,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Bloquer un utilisateur
  static Future<void> blockUser(String currentUserId, String targetUserId) async {
    final interactionId = '${currentUserId}_$targetUserId';
    final existing = _interactionsBox!.get(interactionId);
    
    if (existing != null) {
      final updated = existing.copyWith(
        status: GymCrushStatus.blocked,
        updatedAt: DateTime.now(),
      );
      await _interactionsBox!.put(interactionId, updated);
    }

    await _firestore
        .collection('gym_crush_interactions')
        .doc(currentUserId)
        .collection('interactions')
        .doc(targetUserId)
        .set({
      'status': GymCrushStatus.blocked.toString().split('.').last,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));
  }

  /// Obtenir le nombre de gym crush actifs
  static Future<int> getActiveCrushesCount(String currentUserId) async {
    try {
      final querySnapshot = await _firestore
          .collection('gym_crush_interactions')
          .doc(currentUserId)
          .collection('interactions')
          .where('status', isEqualTo: GymCrushStatus.pending.toString().split('.').last)
          .get();
      
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Vérifier si la limite de gym crush est atteinte
  static Future<bool> canCreateNewCrush(String currentUserId) async {
    final settings = getSettings();
    final currentCount = await getActiveCrushesCount(currentUserId);
    return currentCount < settings.maxActiveCrushes;
  }

  /// Obtenir toutes les interactions
  static Future<List<GymCrushInteraction>> getAllInteractions() async {
    return _interactionsBox!.values.toList();
  }

  /// Fermer les boxes Hive
  static Future<void> dispose() async {
    if (_settingsBox != null && _settingsBox!.isOpen) {
      await _settingsBox!.close();
    }
    if (_interactionsBox != null && _interactionsBox!.isOpen) {
      await _interactionsBox!.close();
    }
  }
}
