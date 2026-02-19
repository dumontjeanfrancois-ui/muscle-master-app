# 🔥 SYNCHRONISATION FIREBASE RÉELLE - GUIDE COMPLET

**Projet Firebase**: `muscle-master-48827`  
**Date**: 19 février 2026  
**Statut**: ✅ Fichiers Prêts | ⏳ Déploiement en Attente d'Authentification

---

## 📋 ÉTAT ACTUEL

### ✅ Fichiers de Configuration Créés

| Fichier | Taille | Status | Description |
|---------|--------|--------|-------------|
| `.firebaserc` | 61 bytes | ✅ Prêt | Configuration projet Firebase |
| `firebase.json` | 97 bytes | ✅ Prêt | Configuration Firebase CLI |
| `firestore.rules` | 1.5 KB | ✅ Prêt | Security Rules (4 collections) |
| `firestore.indexes.json` | 607 bytes | ✅ Prêt | 2 index composites |

### 📊 Collections Couvertes par les Rules

1. **users** - Profils utilisateurs + Premium
2. **gym_crush_presence** - Présence temps réel en salle
3. **connections/{userId}/friends/{friendId}** - Relations sociales
4. **chats/{chatId}/messages/{messageId}** - Messages entre amis

### 🔍 Index Composites Définis

1. **gym_crush_presence**
   - Champs: `gymId` + `isActive` + `expiresAt` + `invisibleMode`
   - Objectif: Optimiser détection utilisateurs proches actifs

2. **friends** (sous-collection de connections)
   - Champs: `isDeleted` + `isActive`
   - Objectif: Filtrer connections actives vs supprimées

---

## 🚀 OPTIONS DE DÉPLOIEMENT

### OPTION 1: Console Firebase (Web) - **RECOMMANDÉ POUR VOUS**

**Accès Direct**: https://console.firebase.google.com/project/muscle-master-48827

#### Étape 1: Déployer Firestore Rules

1. Aller dans **Firestore Database** > **Règles** (Rules)
2. **Copier le contenu** ci-dessous et le coller dans l'éditeur
3. Cliquer **Publier** (Publish)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection (profils premium)
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    // Gym presence (temps réel)
    match /gym_crush_presence/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    // Connections (amis sportifs)
    match /connections/{userId}/friends/{friendId} {
      allow read: if isOwner(userId);
      allow write: if isOwner(userId);
    }
    
    // Chats
    match /chats/{chatId}/messages/{messageId} {
      // Autoriser lecture si l'utilisateur fait partie du chat
      allow read: if isAuthenticated() && 
        (chatId.split('_')[0] == request.auth.uid || 
         chatId.split('_')[1] == request.auth.uid);
      
      // Autoriser écriture uniquement si expéditeur authentifié
      allow create: if isAuthenticated() && 
        request.resource.data.senderId == request.auth.uid;
      
      allow update: if isAuthenticated() && 
        (resource.data.senderId == request.auth.uid ||
         chatId.split('_')[0] == request.auth.uid ||
         chatId.split('_')[1] == request.auth.uid);
    }
  }
}
```

#### Étape 2: Créer les Index Composites

1. Aller dans **Firestore Database** > **Index** (Indexes)
2. Cliquer **Créer un index composite** (Create composite index)

**Index 1: gym_crush_presence**
- **Collection ID**: `gym_crush_presence`
- **Champ 1**: `gymId` | Ordre: **Croissant** (Ascending)
- **Champ 2**: `isActive` | Ordre: **Croissant** (Ascending)
- **Champ 3**: `expiresAt` | Ordre: **Croissant** (Ascending)
- **Champ 4**: `invisibleMode` | Ordre: **Croissant** (Ascending)
- **Portée de requête**: Collection
- Cliquer **Créer**

**Index 2: friends** (sous-collection)
- **Collection ID**: `friends`
- **Champ 1**: `isDeleted` | Ordre: **Croissant** (Ascending)
- **Champ 2**: `isActive` | Ordre: **Croissant** (Ascending)
- **Portée de requête**: Collection group
- Cliquer **Créer**

⏳ **Note**: La création des index peut prendre quelques minutes.

#### Étape 3: Créer les Collections de Test

1. Aller dans **Firestore Database** > **Données** (Data)
2. Cliquer **Démarrer la collection** (Start collection)

**Collection 1: users**
- **ID de document**: `test_user_001`
- **Champs**:
  ```
  userId: "test_user_001" (string)
  pseudo: "Flexo Lion" (string)
  mascotType: "lion_male" (string)
  isPremium: true (boolean)
  boostCredits: 2 (number)
  createdAt: [Timestamp maintenant]
  premiumExpiresAt: [Timestamp +1 an]
  ```

**Collection 2: gym_crush_presence**
- **ID de document**: `test_user_001`
- **Champs**:
  ```
  userId: "test_user_001" (string)
  pseudo: "Flexo Lion" (string)
  mascotType: "lion_male" (string)
  gymId: "gym_001" (string)
  isActive: true (boolean)
  invisibleMode: false (boolean)
  lastActivity: [Timestamp maintenant]
  expiresAt: [Timestamp +2 minutes]
  ```

**Collection 3: connections**
- **ID de document**: `test_user_001`
- **Sous-collection**: `friends`
- **ID de document sous-collection**: `test_user_002`
- **Champs**:
  ```
  userId: "test_user_001" (string)
  friendId: "test_user_002" (string)
  pseudo: "Flexa Lioness" (string)
  mascotType: "lion_female" (string)
  isActive: true (boolean)
  isDeleted: false (boolean)
  createdAt: [Timestamp maintenant]
  deletedAt: null
  ```

**Collection 4: chats**
- **ID de document**: `test_user_001_test_user_002`
- **Sous-collection**: `messages`
- **ID de document sous-collection**: `msg_001`
- **Champs**:
  ```
  senderId: "test_user_001" (string)
  receiverId: "test_user_002" (string)
  content: "Salut ! Bon entraînement 💪" (string)
  isRead: false (boolean)
  sentAt: [Timestamp maintenant]
  ```

---

### OPTION 2: Firebase CLI (Terminal)

**Prérequis**: Accès à une machine avec `firebase-tools` installé

```bash
# 1. Cloner le repo
git clone https://github.com/dumontjeanfrancois-ui/muscle-master-app.git
cd muscle-master-app

# 2. Installer Firebase CLI (si pas déjà installé)
npm install -g firebase-tools

# 3. Se connecter
firebase login

# 4. Vérifier projet
firebase projects:list
firebase use muscle-master-48827

# 5. Déployer Rules
firebase deploy --only firestore:rules

# 6. Déployer Indexes
firebase deploy --only firestore:indexes
```

---

### OPTION 3: Script Python (Automatisé)

**Prérequis**: Service Account Firebase Admin SDK

```bash
# 1. Télécharger Service Account Key
# Aller sur: https://console.firebase.google.com/project/muscle-master-48827/settings/serviceaccounts/adminsdk
# Cliquer: "Générer une nouvelle clé privée"
# Sauvegarder dans: /opt/flutter/firebase-admin-sdk.json

# 2. Installer dépendances
pip install firebase-admin==7.1.0

# 3. Exécuter script d'initialisation
cd /home/user/flutter_app
python3 scripts/init_firestore_collections.py
```

---

## ✅ CHECKLIST DE VALIDATION

Une fois le déploiement effectué (via une des 3 options), vérifiez:

### Dans Firebase Console

**Firestore Rules** (https://console.firebase.google.com/project/muscle-master-48827/firestore/rules)
- [ ] Rules contiennent 4 collections (users, gym_crush_presence, connections, chats)
- [ ] Rules utilisent `isAuthenticated()` et `isOwner()`
- [ ] Date de dernière publication visible

**Firestore Indexes** (https://console.firebase.google.com/project/muscle-master-48827/firestore/indexes)
- [ ] Index `gym_crush_presence` existe (4 champs)
- [ ] Index `friends` existe (2 champs)
- [ ] Statut: **Activé** (vert) pour les deux

**Firestore Data** (https://console.firebase.google.com/project/muscle-master-48827/firestore/data)
- [ ] Collection `users` existe avec au moins 1 document
- [ ] Collection `gym_crush_presence` existe
- [ ] Collection `connections` existe avec sous-collection `friends`
- [ ] Collection `chats` existe avec sous-collection `messages`
- [ ] Tous les Timestamps sont de type `timestamp` (pas `string`)

### Dans l'Application Flutter

**Test de Présence**
- [ ] Démarrer un entraînement dans `WorkoutTimerScreen`
- [ ] Vérifier dans Firestore: document `gym_crush_presence/{userId}` créé
- [ ] Observer heartbeat: `lastActivity` et `expiresAt` mis à jour toutes les 30s
- [ ] Quitter l'entraînement: `isActive` passe à `false`

**Test de Connections**
- [ ] Tester création connection (via UI quand Phase 2 complète)
- [ ] Vérifier dans Firestore: document `connections/{userId}/friends/{friendId}` créé
- [ ] Vérifier champs: `isActive=true`, `isDeleted=false`, `createdAt` Timestamp

**Test de Chat**
- [ ] Envoyer message entre 2 utilisateurs amis
- [ ] Vérifier dans Firestore: document `chats/{chatId}/messages/{messageId}` créé
- [ ] Vérifier `sentAt` est un Timestamp Firestore

---

## 📊 SCRIPTS CRÉÉS

| Script | Chemin | Fonction |
|--------|--------|----------|
| **Déploiement Firebase** | `scripts/deploy_firebase.py` | Valide config + instructions |
| **Initialisation Collections** | `scripts/init_firestore_collections.py` | Crée données de test |
| **Migration Crush→Social** | `scripts/migrate_crush_to_social.py` | Migre anciennes données |

---

## 🔐 SÉCURITÉ

### Règles Appliquées

1. **Authentification Obligatoire**: Toutes les opérations nécessitent `request.auth != null`
2. **Écriture Limitée**: Utilisateurs ne peuvent écrire que leurs propres documents
3. **Lecture Contrôlée**: 
   - `users`: Lecture publique (authentifiés)
   - `gym_crush_presence`: Lecture publique (pour détection)
   - `connections`: Lecture limitée au propriétaire
   - `chats`: Lecture limitée aux participants du chat

### Protection des Données

- ✅ Pas d'écriture cross-user
- ✅ Chat accessible uniquement aux participants
- ✅ Présence modifiable uniquement par l'utilisateur
- ✅ Connections gérées par le propriétaire

---

## 📝 PROCHAINES ÉTAPES

### Après Déploiement Firebase

1. **Phase UI Mascotte** (Phase 2)
   - Créer `lib/widgets/flexo_mascot_widget.dart`
   - Intégrer grid mascottes actives
   - Implémenter toggle mode invisible
   - Ajouter compteur connections + badge Premium

2. **Tests Utilisateur** (Phase 3)
   - Tester heartbeat sur appareil réel
   - Valider expiration 2 minutes
   - Vérifier lifecycle pause/resume
   - Tester limites connections (3 gratuit, illimité Premium)

3. **Migration Données** (Phase 4)
   - Exécuter `migrate_crush_to_social.py`
   - Vérifier conversion Crush → Connections
   - Valider conservation des chats existants

---

## 🆘 SUPPORT

### En Cas de Problème

**Erreur: Permission Denied**
- Vérifier que les Rules sont bien déployées
- Vérifier que l'utilisateur est authentifié (`FirebaseAuth.instance.currentUser != null`)

**Erreur: Index Required**
- Vérifier que les index composites sont créés et **Activés** (vert)
- Attendre quelques minutes après création (indexation peut prendre du temps)

**Timestamps en String au lieu de Timestamp**
- Utiliser `Timestamp.fromDate(DateTime.now())` en Dart
- Utiliser `firestore.SERVER_TIMESTAMP` en Python
- Ne JAMAIS utiliser `.toIso8601String()`

### Ressources

- **Console Firebase**: https://console.firebase.google.com/project/muscle-master-48827
- **Documentation Firestore Rules**: https://firebase.google.com/docs/firestore/security/get-started
- **Documentation Indexes**: https://firebase.google.com/docs/firestore/query-data/indexing
- **Repository GitHub**: https://github.com/dumontjeanfrancois-ui/muscle-master-app

---

## ✅ RÉSUMÉ

**Projet Firebase**: `muscle-master-48827`  
**Fichiers Créés**: ✅ `.firebaserc`, `firebase.json`, `firestore.rules`, `firestore.indexes.json`  
**Collections Définies**: ✅ `users`, `gym_crush_presence`, `connections`, `chats`  
**Index Composites**: ✅ 2 index (gym_crush_presence + friends)  
**Scripts Python**: ✅ 3 scripts (deploy, init, migrate)  

**🚀 Prêt à Déployer**: Utilisez **OPTION 1 (Console Web)** pour un déploiement rapide sans CLI

---

**Dernière mise à jour**: 19 février 2026, 02:30 UTC  
**Auteur**: Claude AI Developer  
**Statut**: ✅ Prêt pour Déploiement Manuel
