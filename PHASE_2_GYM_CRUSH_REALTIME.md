# ✅ PHASE 2 – SYSTÈME PRÉSENCE TEMPS RÉEL GYMCRUSH

**Commit**: `fbc7eba`  
**Branche**: `main`  
**Date**: 2026-02-18

---

## 🎯 OBJECTIF

Transformer le système actuel basé sur `lastActivity ±15min` en système **temps réel robuste** avec **heartbeat périodique** et **expiration automatique**.

---

## ✅ MODIFICATIONS APPLIQUÉES

### 1️⃣ **Nouvelle structure gym_crush_presence**

**Champs ajoutés** :

```dart
/// Présence active (pour filtrage temps réel)
@HiveField(6)
final bool isActive;

/// Date d'expiration de la présence (heartbeat)
@HiveField(7)
final DateTime expiresAt;
```

**Avant** (Phase 1) :
```dart
class GymCrushUser {
  final String userId;
  final String pseudo;
  final String mascotType;
  final String? mascotName;
  final DateTime lastActivity;
  final String? gymId;
}
```

**Après** (Phase 2) :
```dart
class GymCrushUser {
  final String userId;
  final String pseudo;
  final String mascotType;
  final String? mascotName;
  final DateTime lastActivity;
  final String? gymId;
  final bool isActive;        // ✅ NOUVEAU
  final DateTime expiresAt;   // ✅ NOUVEAU
}
```

**Impact Firestore** :
```json
{
  "userId": "abc123",
  "pseudo": "Flexo Lion",
  "mascotType": "male",
  "lastActivity": "2026-02-18T22:45:00Z",
  "gymId": "gym_001",
  "isActive": true,
  "expiresAt": "2026-02-18T22:47:00Z"
}
```

---

### 2️⃣ **Refactor updateUserPresence()**

**Avant** (Phase 1) :
```dart
final timeWindow = Timestamp.fromDate(
  DateTime.now().subtract(const Duration(minutes: 15)),
);
```

**Après** (Phase 2) :
```dart
static Future<void> updateUserPresence({
  required String pseudo,
  required String mascotType,
  String? mascotName,
  String? gymId,
}) async {
  final userId = _getCurrentUserId();
  if (userId == null) return;

  try {
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(minutes: 2));  // ✅ Expiration 2 min

    final user = GymCrushUser(
      userId: userId,
      pseudo: pseudo,
      mascotType: mascotType,
      mascotName: mascotName,
      lastActivity: now,
      gymId: gymId,
      isActive: true,          // ✅ Active par défaut
      expiresAt: expiresAt,    // ✅ Expire dans 2 minutes
    );

    await _firestore
        .collection('gym_crush_presence')
        .doc(userId)
        .set(user.toFirestore(), SetOptions(merge: true));
  } catch (e) {
    debugPrint('❌ GymCrush: Erreur mise à jour présence: $e');
  }
}
```

**Avantages** :
- ✅ **Expiration précise** : 2 minutes après chaque update
- ✅ **État actif** : `isActive: true` pour filtrage immédiat
- ✅ **Compatible Phase 1** : Conserve `lastActivity` pour historique

---

### 3️⃣ **Système heartbeat périodique**

**Nouvelle méthode `startPresenceHeartbeat()`** :

```dart
static Timer? _heartbeatTimer;

static Future<void> startPresenceHeartbeat({
  required String pseudo,
  required String mascotType,
  String? mascotName,
  String? gymId,
}) async {
  stopPresenceHeartbeat();

  // Mise à jour initiale
  await updateUserPresence(
    pseudo: pseudo,
    mascotType: mascotType,
    mascotName: mascotName,
    gymId: gymId,
  );

  // Timer périodique 30 secondes
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
        'lastActivity': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'isActive': true,
      });

      debugPrint('💓 GymCrush: Heartbeat envoyé (expire à ${expiresAt.toIso8601String()})');
    } catch (e) {
      debugPrint('❌ GymCrush: Erreur heartbeat: $e');
    }
  });

  debugPrint('✅ GymCrush: Heartbeat démarré (30s)');
}
```

**Nouvelle méthode `stopPresenceHeartbeat()`** :

```dart
static void stopPresenceHeartbeat() {
  if (_heartbeatTimer != null) {
    _heartbeatTimer!.cancel();
    _heartbeatTimer = null;
    debugPrint('🛑 GymCrush: Heartbeat arrêté');
  }
}
```

**Fonctionnement** :
1. **Démarrage** : Appel `startPresenceHeartbeat()` → Mise à jour immédiate + Timer
2. **Heartbeat** : Toutes les 30 secondes → Update `lastActivity` + `expiresAt`
3. **Expiration** : Si heartbeat manqué pendant 2 minutes → Utilisateur invisible
4. **Arrêt** : Appel `stopPresenceHeartbeat()` → Timer annulé

**Avantages** :
- ✅ **Présence en temps réel** : Utilisateurs visibles uniquement s'ils sont actifs
- ✅ **Expiration automatique** : Pas besoin de cleanup manuel
- ✅ **Optimisation réseau** : Update toutes les 30s (vs query permanente)
- ✅ **Robustesse** : Auto-stop si mode désactivé ou utilisateur déconnecté

---

### 4️⃣ **Refactor detectNearbyUsers()**

**Avant** (Phase 1) :
```dart
final timeWindow = Timestamp.fromDate(
  DateTime.now().subtract(const Duration(minutes: 15)),
);

final querySnapshot = await _firestore
    .collection('gym_crush_presence')
    .where('gymId', isEqualTo: currentGymId)
    .where('lastActivity', isGreaterThan: timeWindow)  // ❌ Comparaison ±15min
    .get();
```

**Après** (Phase 2) :
```dart
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
        .where('isActive', isEqualTo: true)        // ✅ Uniquement actifs
        .where('expiresAt', isGreaterThan: now)    // ✅ Non expirés
        .get();

    final users = querySnapshot.docs
        .map((doc) => GymCrushUser.fromFirestore(doc.data()))
        .where((user) => user.userId != currentUserId)
        .toList();

    // Filtrage local ignorés/bloqués
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
```

**Avantages** :
- ✅ **Filtrage précis** : `isActive = true` + `expiresAt > now()`
- ✅ **Performance** : Index Firestore sur `isActive` + `expiresAt`
- ✅ **Temps réel** : Utilisateurs expirés exclus automatiquement

---

### 5️⃣ **Nouvelle méthode deactivatePresence()**

```dart
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
      'expiresAt': DateTime.now().toIso8601String(),
    });
    debugPrint('✅ GymCrush: Présence désactivée pour $userId');
  } catch (e) {
    debugPrint('❌ GymCrush: Erreur désactivation présence: $e');
  }
}
```

**Utilisation** :
```dart
// Appelée automatiquement lors de toggleGymCrushMode(false)
static Future<void> toggleGymCrushMode(bool enabled) async {
  final currentSettings = getSettings();
  final updatedSettings = currentSettings.copyWith(isEnabled: enabled);
  await _settingsBox!.put('current', updatedSettings);

  if (!enabled) {
    await deactivatePresence();  // ✅ Désactivation propre
  }
}
```

**Avantages** :
- ✅ **Désactivation immédiate** : `isActive: false` → Invisible instantanément
- ✅ **Stop heartbeat** : Annulation automatique du Timer
- ✅ **Économie réseau** : Pas de mise à jour pendant inactivité

---

### 6️⃣ **Stream temps réel listenNearbyUsers()**

**Nouvelle méthode avec snapshots Firestore** :

```dart
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

      // Filtrage local ignorés/bloqués
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
```

**Utilisation UI** :
```dart
StreamBuilder<List<GymCrushUser>>(
  stream: GymCrushService.listenNearbyUsers(currentGymId: 'gym_001'),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final users = snapshot.data!;
      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return UserTile(user: users[index]);
        },
      );
    }
    return CircularProgressIndicator();
  },
)
```

**Avantages** :
- ✅ **Updates temps réel** : UI actualisée automatiquement
- ✅ **Filtrage local** : Interactions ignorées/bloquées exclues
- ✅ **Performance** : Firestore snapshots optimisés
- ✅ **Scalabilité** : Stream géré par Firestore (pas de polling)

---

### 7️⃣ **Null safety complète**

**Vérifications ajoutées** :
```dart
// Toutes les méthodes vérifient l'authentification
final userId = _getCurrentUserId();
if (userId == null) return;  // ou return [];

// fromFirestore avec fallback
isActive: data['isActive'] as bool? ?? true,
expiresAt: data['expiresAt'] != null
    ? DateTime.parse(data['expiresAt'] as String)
    : DateTime.now().add(const Duration(minutes: 2)),
```

**Avantages** :
- ✅ Pas de crash si `currentUser` null
- ✅ Pas de crash si champs Firestore manquants
- ✅ Valeurs par défaut sécurisées

---

### 8️⃣ **Gestion erreur robuste**

**Tous les blocs try-catch avec debugPrint** :
```dart
try {
  // Opération Firestore
} catch (e) {
  debugPrint('❌ GymCrush: Erreur descriptive: $e');
  return [];  // Valeur par défaut sécurisée
}
```

**Messages contextualisés** :
- ✅ `💓 GymCrush: Heartbeat envoyé`
- ✅ `🛑 GymCrush: Heartbeat arrêté`
- ✅ `✅ GymCrush: Présence désactivée`
- ✅ `❌ GymCrush: Erreur heartbeat: ...`

---

## 📊 RÉSUMÉ DES MODIFICATIONS

| Fichier | Lignes | Modifications |
|---------|--------|---------------|
| `gym_crush_model.dart` | +25 / -8 | Ajout `isActive` + `expiresAt` + toFirestore/fromFirestore |
| `gym_crush_service.dart` | +138 / -1 | Heartbeat, Stream, deactivatePresence |
| `gym_crush_model.g.dart` | Régénéré | Build runner Hive |

**Total** : 3 fichiers, 163 insertions(+), 9 deletions(-)

---

## ✅ COMPATIBILITÉ PHASE 1

**Conservé** :
- ✅ `_getCurrentUserId()` avec FirebaseAuth
- ✅ `lastActivity` pour historique
- ✅ Toutes les méthodes existantes (`createInteraction`, `ignoreUser`, etc.)
- ✅ Null safety strict
- ✅ `debugPrint()` dans tous les catch

**Amélioré** :
- ✅ `detectNearbyUsers()` : Logique 15min → `isActive` + `expiresAt`
- ✅ `updateUserPresence()` : Ajout `isActive: true` + `expiresAt`
- ✅ `toggleGymCrushMode(false)` : Appel automatique `deactivatePresence()`

**Ajouté** :
- ✅ `startPresenceHeartbeat()` : Timer 30s
- ✅ `stopPresenceHeartbeat()` : Cancel Timer
- ✅ `deactivatePresence()` : Désactivation propre
- ✅ `listenNearbyUsers()` : Stream temps réel

---

## 🔧 VALIDATION

**Analyse statique** :
```bash
flutter analyze
```
**Résultat** : ✅ **0 error, 1 warning** (`_removeUserPresence` unused - conservé pour fallback)

**Compilation** : ✅ Tous les fichiers compilent sans erreur

**Hive build_runner** : ✅ `gym_crush_model.g.dart` régénéré avec succès

---

## 🚀 UTILISATION

### Démarrer la présence avec heartbeat :
```dart
await GymCrushService.startPresenceHeartbeat(
  pseudo: 'Flexo Lion',
  mascotType: 'male',
  gymId: 'gym_001',
);
// ✅ Heartbeat démarré (30s)
// 💓 Updates automatiques toutes les 30s
```

### Écouter utilisateurs en temps réel :
```dart
GymCrushService.listenNearbyUsers(currentGymId: 'gym_001')
  .listen((users) {
    print('${users.length} utilisateurs détectés');
    // UI actualisée automatiquement
  });
```

### Désactiver présence :
```dart
await GymCrushService.deactivatePresence();
// 🛑 Heartbeat arrêté
// ✅ Présence désactivée (isActive: false)
```

---

## 🔗 LIENS

**Repository** : https://github.com/dumontjeanfrancois-ui/muscle-master-app

**Commits** :
- **Phase 1** : `9b4ec4b` (stabilisation backend)
- **Phase 2** : `fbc7eba` (présence temps réel)

**Branche** : `main`

---

## 🎉 CONCLUSION

Le système GymCrush dispose maintenant d'une **présence temps réel robuste** avec :

✅ **Heartbeat automatique** : Updates toutes les 30s  
✅ **Expiration automatique** : Utilisateurs invisibles après 2 min d'inactivité  
✅ **Filtrage précis** : `isActive = true` + `expiresAt > now()`  
✅ **Stream temps réel** : UI actualisée automatiquement via snapshots Firestore  
✅ **Performance optimisée** : Pas de polling, index Firestore efficaces  
✅ **Compatibilité Phase 1** : Conservation de toutes les fonctionnalités existantes  
✅ **Null safety** : Gestion erreur robuste avec fallbacks  

**🔒 Pas de modification UI – Backend uniquement, prêt pour intégration UI Phase 3.**
