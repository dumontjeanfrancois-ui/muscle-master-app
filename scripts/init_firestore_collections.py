#!/usr/bin/env python3
"""
Script d'initialisation des collections Firestore pour Muscle Master
Crée les collections avec des données de test
"""

print("""
🔥 MUSCLE MASTER - INITIALISATION FIRESTORE
============================================================

⚠️  PRÉREQUIS:
   Ce script nécessite Firebase Admin SDK avec authentification.
   
   Télécharger la clé depuis:
   https://console.firebase.google.com/project/muscle-master-48827/settings/serviceaccounts/adminsdk
   
   Sauvegarder dans: /opt/flutter/firebase-admin-sdk.json

============================================================
""")

import sys
from pathlib import Path

# Vérifier si firebase-admin-sdk.json existe
sdk_paths = [
    Path("/opt/flutter/firebase-admin-sdk.json"),
    Path("firebase-admin-sdk.json"),
    Path("../firebase-admin-sdk.json")
]

sdk_path = None
for path in sdk_paths:
    if path.exists():
        sdk_path = path
        break

if not sdk_path:
    print("❌ Fichier firebase-admin-sdk.json non trouvé!")
    print("\n📥 Pour obtenir ce fichier:")
    print("1. Aller sur: https://console.firebase.google.com/project/muscle-master-48827")
    print("2. Paramètres du projet > Comptes de service")
    print("3. Cliquer 'Générer une nouvelle clé privée'")
    print("4. Sauvegarder dans: /opt/flutter/firebase-admin-sdk.json")
    print("\n💡 Alternative: Créer les collections manuellement via Console Firebase")
    sys.exit(1)

# Importer Firebase Admin
try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("❌ firebase-admin non installé!")
    print("\n📦 Installation:")
    print("   pip install firebase-admin==7.1.0")
    sys.exit(1)

print(f"✅ Firebase Admin SDK trouvé: {sdk_path}")

# Initialiser Firebase
try:
    cred = credentials.Certificate(str(sdk_path))
    firebase_admin.initialize_app(cred)
    db = firestore.client()
    print("✅ Connexion Firebase établie")
except Exception as e:
    print(f"❌ Erreur d'initialisation: {e}")
    sys.exit(1)

# Créer collections de test
print("\n📊 Création des collections de test...")

# 1. Collection users (profils)
print("\n1️⃣  Collection: users")
test_users = [
    {
        "userId": "test_user_001",
        "pseudo": "Flexo Lion",
        "mascotType": "lion_male",
        "isPremium": True,
        "premiumExpiresAt": firestore.SERVER_TIMESTAMP,
        "boostCredits": 2,
        "createdAt": firestore.SERVER_TIMESTAMP
    },
    {
        "userId": "test_user_002",
        "pseudo": "Flexa Lioness",
        "mascotType": "lion_female",
        "isPremium": False,
        "premiumExpiresAt": None,
        "boostCredits": 0,
        "createdAt": firestore.SERVER_TIMESTAMP
    }
]

for user in test_users:
    user_id = user["userId"]
    db.collection("users").document(user_id).set(user)
    print(f"   ✅ Créé: {user['pseudo']} ({user_id})")

# 2. Collection gym_crush_presence (présence temps réel)
print("\n2️⃣  Collection: gym_crush_presence")
from datetime import datetime, timedelta

test_presence = [
    {
        "userId": "test_user_001",
        "pseudo": "Flexo Lion",
        "mascotType": "lion_male",
        "gymId": "gym_001",
        "isActive": True,
        "lastActivity": firestore.SERVER_TIMESTAMP,
        "expiresAt": firestore.SERVER_TIMESTAMP,
        "invisibleMode": False
    }
]

for presence in test_presence:
    user_id = presence["userId"]
    db.collection("gym_crush_presence").document(user_id).set(presence)
    print(f"   ✅ Créé: {presence['pseudo']} @ {presence['gymId']}")

# 3. Collection connections (amis)
print("\n3️⃣  Collection: connections/{userId}/friends/{friendId}")

# Connection test_user_001 -> test_user_002
connection_data = {
    "userId": "test_user_001",
    "friendId": "test_user_002",
    "pseudo": "Flexa Lioness",
    "mascotType": "lion_female",
    "createdAt": firestore.SERVER_TIMESTAMP,
    "isActive": True,
    "isDeleted": False,
    "deletedAt": None
}

db.collection("connections").document("test_user_001")\
  .collection("friends").document("test_user_002").set(connection_data)
print(f"   ✅ Connection créée: test_user_001 -> test_user_002")

# Connection réciproque test_user_002 -> test_user_001
connection_data_reverse = {
    "userId": "test_user_002",
    "friendId": "test_user_001",
    "pseudo": "Flexo Lion",
    "mascotType": "lion_male",
    "createdAt": firestore.SERVER_TIMESTAMP,
    "isActive": True,
    "isDeleted": False,
    "deletedAt": None
}

db.collection("connections").document("test_user_002")\
  .collection("friends").document("test_user_001").set(connection_data_reverse)
print(f"   ✅ Connection créée: test_user_002 -> test_user_001")

# 4. Collection chats (messages)
print("\n4️⃣  Collection: chats/{chatId}/messages/{messageId}")

# ChatId = sorted userIds
chat_id = "test_user_001_test_user_002"

test_messages = [
    {
        "senderId": "test_user_001",
        "receiverId": "test_user_002",
        "content": "Salut ! Bon entraînement aujourd'hui 💪",
        "sentAt": firestore.SERVER_TIMESTAMP,
        "isRead": False
    },
    {
        "senderId": "test_user_002",
        "receiverId": "test_user_001",
        "content": "Merci ! Toi aussi, super séance de squat 🦁",
        "sentAt": firestore.SERVER_TIMESTAMP,
        "isRead": True
    }
]

for i, message in enumerate(test_messages, 1):
    message_id = f"msg_{i:03d}"
    db.collection("chats").document(chat_id)\
      .collection("messages").document(message_id).set(message)
    print(f"   ✅ Message créé: {message_id} de {message['senderId']}")

# Vérifications finales
print("\n" + "=" * 60)
print("✅ INITIALISATION COMPLÈTE")
print("=" * 60)

print("\n📊 Collections créées:")
print("   ✅ users: 2 profils de test")
print("   ✅ gym_crush_presence: 1 utilisateur actif")
print("   ✅ connections: 2 relations bidirectionnelles")
print("   ✅ chats: 2 messages de test")

print("\n🔍 Vérification dans Firebase Console:")
print(f"   https://console.firebase.google.com/project/muscle-master-48827/firestore")

print("\n✅ Données de test prêtes pour l'application!")
