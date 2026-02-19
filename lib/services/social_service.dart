import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/social_model.dart';

class SocialService {
  static const String _settingsBoxName = 'socialSettings';
  
  static Box<SocialSettings>? _settingsBox;
  
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Timer? _heartbeatTimer;

  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_settingsBoxName)) {
      _settingsBox = await Hive.openBox<SocialSettings>(_settingsBoxName);
    } else {
      _settingsBox = Hive.box<SocialSettings>(_settingsBoxName);
    }
  }

  static String? _getCurrentUserId() {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ Social: Aucun utilisateur Firebase connecté');
      return null;
    }
    return user.uid;
  }

  static SocialSettings getSettings() {
    if (_settingsBox == null) {
      throw Exception('SocialService not initialized');
    }

    if (_settingsBox!.isEmpty) {
      final defaultSettings = SocialSettings();
      _settingsBox!.put('current', defaultSettings);
      return defaultSettings;
    }

    return _settingsBox!.get('current', defaultValue: SocialSettings())!;
  }

  static Future<void> updateSettings(SocialSettings settings) async {
    await _settingsBox!.put('current', settings);
  }

  static Future<void> toggleSocialMode(bool enabled) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(isEnabled: enabled);
    await updateSettings(updatedSettings);

    if (!enabled) {
      await deactivatePresence();
    }
  }

  static Future<void> toggleInvisibleMode(bool invisible) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(invisibleMode: invisible);
    await updateSettings(updatedSettings);

    final userId = _getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore
          .collection('gym_crush_presence')
          .doc(userId)
          .update({'invisibleMode': invisible});
      
      debugPrint('✅ Social: Mode invisible ${invisible ? "activé" : "désactivé"}');
    } catch (e) {
      debugPrint('❌ Social: Erreur toggle invisible: $e');
    }
  }

  static bool isSocialEnabled() {
    return getSettings().isEnabled;
  }

  static bool isInvisibleMode() {
    return getSettings().invisibleMode;
  }

  static Future<void> updatePresence({
    required String pseudo,
    required String mascotType,
    String? mascotName,
    String? gymId,
  }) async {
    if (!isSocialEnabled()) return;

    final userId = _getCurrentUserId();
    if (userId == null) return;

    try {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 2));
      final invisible = isInvisibleMode();

      final activeUser = ActiveUser(
        userId: userId,
        pseudo: pseudo,
        mascotType: mascotType,
        mascotName: mascotName,
        gymId: gymId,
        isActive: true,
        lastActivity: now,
        expiresAt: expiresAt,
        invisibleMode: invisible,
      );

      await _firestore
          .collection('gym_crush_presence')
          .doc(userId)
          .set(activeUser.toFirestore(), SetOptions(merge: true));

      debugPrint('✅ Social: Présence mise à jour (invisible: $invisible)');
    } catch (e) {
      debugPrint('❌ Social: Erreur mise à jour présence: $e');
    }
  }

  static Future<void> startPresenceHeartbeat({
    required String pseudo,
    required String mascotType,
    String? mascotName,
    String? gymId,
  }) async {
    stopPresenceHeartbeat();

    await updatePresence(
      pseudo: pseudo,
      mascotType: mascotType,
      mascotName: mascotName,
      gymId: gymId,
    );

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      if (!isSocialEnabled()) {
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
        final invisible = isInvisibleMode();

        await _firestore
            .collection('gym_crush_presence')
            .doc(userId)
            .update({
          'lastActivity': Timestamp.fromDate(now),
          'expiresAt': Timestamp.fromDate(expiresAt),
          'isActive': true,
          'invisibleMode': invisible,
        });

        debugPrint('💓 Social: Heartbeat envoyé');
      } catch (e) {
        debugPrint('❌ Social: Erreur heartbeat: $e');
      }
    });

    debugPrint('✅ Social: Heartbeat démarré (30s)');
  }

  static void stopPresenceHeartbeat() {
    if (_heartbeatTimer != null) {
      _heartbeatTimer!.cancel();
      _heartbeatTimer = null;
      debugPrint('🛑 Social: Heartbeat arrêté');
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
      debugPrint('✅ Social: Présence désactivée');
    } catch (e) {
      debugPrint('❌ Social: Erreur désactivation présence: $e');
    }
  }

  static Future<List<ActiveUser>> getActiveUsers({
    required String? gymId,
  }) async {
    if (!isSocialEnabled() || gymId == null) {
      return [];
    }

    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return [];

    try {
      final now = Timestamp.now();

      final querySnapshot = await _firestore
          .collection('gym_crush_presence')
          .where('gymId', isEqualTo: gymId)
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: now)
          .where('invisibleMode', isEqualTo: false)
          .get();

      final users = querySnapshot.docs
          .map((doc) => ActiveUser.fromFirestore(doc.data()))
          .where((user) => user.userId != currentUserId)
          .toList();

      debugPrint('✅ Social: ${users.length} utilisateurs actifs détectés');
      return users;
    } catch (e) {
      debugPrint('❌ Social: Erreur détection utilisateurs: $e');
      return [];
    }
  }

  static Stream<List<ActiveUser>> listenActiveUsers({
    required String? gymId,
  }) {
    if (!isSocialEnabled() || gymId == null) {
      return Stream.value([]);
    }

    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return Stream.value([]);

    try {
      final now = Timestamp.now();

      return _firestore
          .collection('gym_crush_presence')
          .where('gymId', isEqualTo: gymId)
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: now)
          .where('invisibleMode', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => ActiveUser.fromFirestore(doc.data()))
            .where((user) => user.userId != currentUserId)
            .toList();
      });
    } catch (e) {
      debugPrint('❌ Social: Erreur stream utilisateurs: $e');
      return Stream.value([]);
    }
  }

  static Future<UserProfile> getUserProfile() async {
    final userId = _getCurrentUserId();
    if (userId == null) {
      return UserProfile(userId: '');
    }

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        final defaultProfile = UserProfile(userId: userId);
        await _firestore.collection('users').doc(userId).set(defaultProfile.toFirestore());
        return defaultProfile;
      }
      return UserProfile.fromFirestore(doc.data()!);
    } catch (e) {
      debugPrint('❌ Social: Erreur lecture profil: $e');
      return UserProfile(userId: userId);
    }
  }

  static Future<int> getConnectionsCount() async {
    final userId = _getCurrentUserId();
    if (userId == null) return 0;

    try {
      final querySnapshot = await _firestore
          .collection('connections')
          .doc(userId)
          .collection('friends')
          .where('isDeleted', isEqualTo: false)
          .where('isActive', isEqualTo: true)
          .get();
      
      return querySnapshot.docs.length;
    } catch (e) {
      debugPrint('❌ Social: Erreur count connexions: $e');
      return 0;
    }
  }

  static Future<bool> canAddConnection() async {
    final profile = await getUserProfile();
    final currentCount = await getConnectionsCount();
    
    final maxAllowed = profile.maxConnections + profile.boostCredits;
    debugPrint('📊 Social: ${currentCount}/${maxAllowed} connexions');
    
    return currentCount < maxAllowed;
  }

  static Future<bool> createConnection({
    required ActiveUser targetUser,
  }) async {
    final userId = _getCurrentUserId();
    if (userId == null) return false;

    if (!await canAddConnection()) {
      debugPrint('⚠️ Social: Limite connexions atteinte');
      return false;
    }

    try {
      final connection = Connection(
        userId: userId,
        friendId: targetUser.userId,
        pseudo: targetUser.pseudo,
        mascotType: targetUser.mascotType,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('connections')
          .doc(userId)
          .collection('friends')
          .doc(targetUser.userId)
          .set(connection.toFirestore());

      debugPrint('✅ Social: Connexion créée avec ${targetUser.pseudo}');
      return true;
    } catch (e) {
      debugPrint('❌ Social: Erreur création connexion: $e');
      return false;
    }
  }

  static Future<void> softDeleteConnection(String friendId) async {
    final userId = _getCurrentUserId();
    if (userId == null) return;

    try {
      await _firestore
          .collection('connections')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .update({
        'isDeleted': true,
        'deletedAt': Timestamp.fromDate(DateTime.now()),
      });

      debugPrint('✅ Social: Connexion soft delete');
    } catch (e) {
      debugPrint('❌ Social: Erreur soft delete: $e');
    }
  }

  static Future<List<Connection>> getActiveConnections() async {
    final userId = _getCurrentUserId();
    if (userId == null) return [];

    try {
      final querySnapshot = await _firestore
          .collection('connections')
          .doc(userId)
          .collection('friends')
          .where('isDeleted', isEqualTo: false)
          .where('isActive', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Connection.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Social: Erreur lecture connexions: $e');
      return [];
    }
  }

  static String getChatId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  static Future<bool> canChat(String friendId) async {
    final userId = _getCurrentUserId();
    if (userId == null) return false;

    try {
      final doc = await _firestore
          .collection('connections')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .get();

      if (!doc.exists) return false;

      final connection = Connection.fromFirestore(doc.data()!);
      return connection.isActive && !connection.isDeleted;
    } catch (e) {
      debugPrint('❌ Social: Erreur vérification chat: $e');
      return false;
    }
  }

  static Future<void> dispose() async {
    stopPresenceHeartbeat();
    
    if (_settingsBox != null && _settingsBox!.isOpen) {
      await _settingsBox!.close();
    }
  }
}
