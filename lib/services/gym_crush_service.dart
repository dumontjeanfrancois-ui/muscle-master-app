import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/gym_crush_model.dart';

class GymCrushService {
  static const String _settingsBoxName = 'gymCrushSettings';
  static const String _interactionsBoxName = 'gymCrushInteractions';
  
  static Box<GymCrushSettings>? _settingsBox;
  static Box<GymCrushInteraction>? _interactionsBox;
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Timer? _heartbeatTimer;

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

  static String? _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ GymCrush: Aucun utilisateur Firebase connecté');
      return null;
    }
    return user.uid;
  }

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

  static Future<void> toggleGymCrushMode(bool enabled) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(isEnabled: enabled);
    await _settingsBox!.put('current', updatedSettings);

    if (!enabled) {
      await deactivatePresence();
    }
  }

  static bool isGymCrushEnabled() {
    return getSettings().isEnabled;
  }

  static Future<void> updateUserPresence({
    required String pseudo,
    required String mascotType,
    String? mascotName,
    String? gymId,
  }) async {
    if (!isGymCrushEnabled()) return;

    final userId = _getCurrentUserId();
    if (userId == null) return;

    try {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 2));

      final user = GymCrushUser(
        userId: userId,
        pseudo: pseudo,
        mascotType: mascotType,
        mascotName: mascotName,
        lastActivity: now,
        gymId: gymId,
        isActive: true,
        expiresAt: expiresAt,
      );

      await _firestore
          .collection('gym_crush_presence')
          .doc(userId)
          .set(user.toFirestore(), SetOptions(merge: true));

      debugPrint('✅ GymCrush: Présence mise à jour (expire à ${expiresAt.toIso8601String()})');
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur mise à jour présence: $e');
    }
  }

  static Future<void> startPresenceHeartbeat({
    required String pseudo,
    required String mascotType,
    String? mascotName,
    String? gymId,
  }) async {
    stopPresenceHeartbeat();

    await updateUserPresence(
      pseudo: pseudo,
      mascotType: mascotType,
      mascotName: mascotName,
      gymId: gymId,
    );

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!isGymCrushEnabled()) {
        stopPresenceHeartbeat();
        return;
      }

      final userId = _getCurrentUserId();
      if (userId == null) {
        stopPresenceHeartbeat();
        return;
      }

      try {
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(minutes: 2));

        await _firestore
            .collection('gym_crush_presence')
            .doc(userId)
            .update({
          'lastActivity': Timestamp.fromDate(now),
          'expiresAt': Timestamp.fromDate(expiresAt),
          'isActive': true,
        });

        debugPrint('💓 GymCrush: Heartbeat envoyé (expire à ${expiresAt.toIso8601String()})');
      } catch (e) {
        debugPrint('❌ GymCrush: Erreur heartbeat: $e');
      }
    });

    debugPrint('✅ GymCrush: Heartbeat démarré (30s)');
  }

  static void stopPresenceHeartbeat() {
    if (_heartbeatTimer != null) {
      _heartbeatTimer!.cancel();
      _heartbeatTimer = null;
      debugPrint('🛑 GymCrush: Heartbeat arrêté');
    }
  }

  static Future<void> deactivatePresence() async {
    stopPresenceHeartbeat();

    final userId = _getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore
          .collection('gym_crush_presence')
          .doc(userId)
          .update({
        'isActive': false,
        'expiresAt': Timestamp.fromDate(DateTime.now()),
      });
      debugPrint('✅ GymCrush: Présence désactivée pour $userId');
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur désactivation présence: $e');
    }
  }

  static Future<void> _removeUserPresence() async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore.collection('gym_crush_presence').doc(userId).delete();
      debugPrint('✅ GymCrush: Présence supprimée pour $userId');
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur suppression présence: $e');
    }
  }

  static Future<List<GymCrushUser>> detectNearbyUsers({
    required String? currentGymId,
  }) async {
    if (!isGymCrushEnabled() || currentGymId == null) {
      return [];
    }

    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return [];

    try {
      final now = Timestamp.now();

      final querySnapshot = await _firestore
          .collection('gym_crush_presence')
          .where('gymId', isEqualTo: currentGymId)
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: now)
          .get();

      final users = querySnapshot.docs
          .map((doc) => GymCrushUser.fromFirestore(doc.data()))
          .where((user) => user.userId != currentUserId)
          .toList();

      final filteredUsers = <GymCrushUser>[];
      for (final user in users) {
        final interaction = await _getInteraction(user.userId);
        if (interaction == null ||
            (interaction.status != GymCrushStatus.ignored &&
                interaction.status != GymCrushStatus.blocked)) {
          filteredUsers.add(user);
        }
      }

      debugPrint('✅ GymCrush: ${filteredUsers.length} utilisateurs détectés');
      return filteredUsers;
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur détection utilisateurs: $e');
      return [];
    }
  }

  static Stream<List<GymCrushUser>> listenNearbyUsers({
    required String? currentGymId,
  }) {
    if (!isGymCrushEnabled() || currentGymId == null) {
      return Stream.value([]);
    }

    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return Stream.value([]);

    try {
      final now = Timestamp.now();

      return _firestore
          .collection('gym_crush_presence')
          .where('gymId', isEqualTo: currentGymId)
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: now)
          .snapshots()
          .asyncMap((snapshot) async {
        final users = snapshot.docs
            .map((doc) => GymCrushUser.fromFirestore(doc.data()))
            .where((user) => user.userId != currentUserId)
            .toList();

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
      });
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur stream utilisateurs: $e');
      return Stream.value([]);
    }
  }

  static Future<GymCrushInteraction?> createInteraction({
    required GymCrushUser targetUser,
    required GymCrushStatus status,
  }) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return null;

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

    try {
      await _interactionsBox!.put(interactionId, interaction);

      await _firestore
          .collection('gym_crush_interactions')
          .doc(currentUserId)
          .collection('interactions')
          .doc(targetUser.userId)
          .set(interaction.toFirestore());

      if (status == GymCrushStatus.pending) {
        await _checkMutualCrush(currentUserId, targetUser.userId, interaction);
      }

      return interaction;
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur création interaction: $e');
      return null;
    }
  }

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
          await _unlockChat(currentUserId, targetUserId);
          debugPrint('✅ GymCrush: Match mutuel détecté!');
        }
      }
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur vérification mutualité: $e');
    }
  }

  static Future<void> _unlockChat(String userId1, String userId2) async {
    try {
      final now = Timestamp.now();

      await _firestore
          .collection('gym_crush_interactions')
          .doc(userId1)
          .collection('interactions')
          .doc(userId2)
          .update({
        'status': GymCrushStatus.mutual.toString().split('.').last,
        'chatUnlocked': true,
        'updatedAt': now,
      });

      await _firestore
          .collection('gym_crush_interactions')
          .doc(userId2)
          .collection('interactions')
          .doc(userId1)
          .update({
        'status': GymCrushStatus.mutual.toString().split('.').last,
        'chatUnlocked': true,
        'updatedAt': now,
      });

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
      debugPrint('❌ GymCrush: Erreur déblocage chat: $e');
    }
  }

  static Future<GymCrushInteraction?> _getInteraction(String targetUserId) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return null;

    final interactionId = '${currentUserId}_$targetUserId';
    return _interactionsBox!.get(interactionId);
  }

  static Future<void> ignoreUser(String targetUserId) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return;

    final interactionId = '${currentUserId}_$targetUserId';
    final existing = _interactionsBox!.get(interactionId);
    
    try {
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
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur ignore user: $e');
    }
  }

  static Future<void> blockUser(String targetUserId) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return;

    final interactionId = '${currentUserId}_$targetUserId';
    final existing = _interactionsBox!.get(interactionId);
    
    try {
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
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur block user: $e');
    }
  }

  static Future<int> getActiveCrushesCount() async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return 0;

    try {
      final querySnapshot = await _firestore
          .collection('gym_crush_interactions')
          .doc(currentUserId)
          .collection('interactions')
          .where('status', isEqualTo: GymCrushStatus.pending.toString().split('.').last)
          .get();
      
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur count crushes: $e');
      return 0;
    }
  }

  static Future<bool> canCreateNewCrush() async {
    final settings = getSettings();
    final currentCount = await getActiveCrushesCount();
    return currentCount < settings.maxActiveCrushes;
  }

  static Future<List<GymCrushInteraction>> getAllInteractions() async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return [];

    try {
      return _interactionsBox!.values.toList();
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur get interactions: $e');
      return [];
    }
  }

  static Future<void> dispose() async {
    stopPresenceHeartbeat();
    
    if (_settingsBox != null && _settingsBox!.isOpen) {
      await _settingsBox!.close();
    }
    if (_interactionsBox != null && _interactionsBox!.isOpen) {
      await _interactionsBox!.close();
    }
  }
}
