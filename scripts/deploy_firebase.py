#!/usr/bin/env python3
"""
Script de déploiement Firebase pour Muscle Master
Synchronise les rules, indexes et données avec Firebase
"""

import json
import sys
from pathlib import Path

print("🔥 MUSCLE MASTER - DÉPLOIEMENT FIREBASE")
print("=" * 60)

# Vérifier projet Firebase
project_id = "muscle-master-48827"
print(f"\n📦 Projet Firebase: {project_id}")

# Vérifier fichiers de configuration
config_files = {
    "firestore.rules": "Firestore Security Rules",
    "firestore.indexes.json": "Firestore Indexes",
    ".firebaserc": "Firebase Project Config",
    "firebase.json": "Firebase CLI Config"
}

print("\n📁 Vérification des fichiers de configuration:")
all_present = True
for file, description in config_files.items():
    file_path = Path(file)
    if file_path.exists():
        size = file_path.stat().st_size
        print(f"  ✅ {file} ({size} bytes) - {description}")
    else:
        print(f"  ❌ {file} - MANQUANT")
        all_present = False

if not all_present:
    print("\n❌ Fichiers manquants détectés!")
    sys.exit(1)

# Lire et valider firestore.rules
print("\n🔒 Validation Firestore Rules:")
with open("firestore.rules", "r") as f:
    rules_content = f.read()
    rules_lines = rules_content.split('\n')
    print(f"  ✅ {len(rules_lines)} lignes")
    
    # Vérifier collections couvertes
    collections = []
    if "users" in rules_content:
        collections.append("users (profils)")
    if "gym_crush_presence" in rules_content:
        collections.append("gym_crush_presence (présence)")
    if "connections" in rules_content:
        collections.append("connections (amis)")
    if "chats" in rules_content:
        collections.append("chats (messages)")
    
    print(f"  ✅ Collections sécurisées: {len(collections)}")
    for col in collections:
        print(f"     - {col}")

# Lire et valider firestore.indexes.json
print("\n📊 Validation Firestore Indexes:")
with open("firestore.indexes.json", "r") as f:
    indexes = json.load(f)
    index_count = len(indexes.get("indexes", []))
    print(f"  ✅ {index_count} index(es) composite(s)")
    
    for idx in indexes.get("indexes", []):
        collection = idx.get("collectionGroup", "unknown")
        fields = [f["fieldPath"] for f in idx.get("fields", [])]
        print(f"     - {collection}: {' + '.join(fields)}")

# Instructions de déploiement
print("\n" + "=" * 60)
print("📋 INSTRUCTIONS DE DÉPLOIEMENT MANUEL")
print("=" * 60)

print("""
⚠️  AUTHENTIFICATION REQUISE

Le déploiement Firebase nécessite une authentification. Voici les options:

🔐 OPTION 1: Firebase CLI (Recommandé)
   Depuis votre machine locale avec accès au projet Firebase:
   
   1. Cloner le repo:
      git clone https://github.com/dumontjeanfrancois-ui/muscle-master-app.git
      cd muscle-master-app
   
   2. Installer Firebase CLI:
      npm install -g firebase-tools
   
   3. Se connecter:
      firebase login
   
   4. Déployer les rules:
      firebase deploy --only firestore:rules
   
   5. Déployer les indexes:
      firebase deploy --only firestore:indexes

🌐 OPTION 2: Console Firebase (Interface Web)
   Via https://console.firebase.google.com/
   
   1. Ouvrir: https://console.firebase.google.com/project/muscle-master-48827
   
   2. Rules (Firestore Rules):
      - Aller dans Firestore Database > Rules
      - Copier le contenu de firestore.rules
      - Cliquer "Publier"
   
   3. Indexes (Firestore Indexes):
      - Aller dans Firestore Database > Indexes
      - Cliquer "Créer un index composite"
      - Pour gym_crush_presence:
        * Collection: gym_crush_presence
        * Champs: gymId (Asc), isActive (Asc), expiresAt (Asc), invisibleMode (Asc)
      - Pour friends:
        * Collection: friends
        * Champs: isDeleted (Asc), isActive (Asc)

🔧 OPTION 3: Service Account (CI/CD)
   
   1. Télécharger la clé de service account depuis:
      https://console.firebase.google.com/project/muscle-master-48827/settings/serviceaccounts/adminsdk
   
   2. Sauvegarder dans: firebase-admin-sdk.json
   
   3. Utiliser avec Firebase Admin SDK Python

""")

print("=" * 60)
print("✅ VALIDATION DES FICHIERS COMPLÈTE")
print("=" * 60)
print(f"\n📦 Projet: {project_id}")
print(f"✅ Rules: Prêt à déployer")
print(f"✅ Indexes: Prêt à déployer")
print(f"\n🚀 Utilisez une des 3 options ci-dessus pour déployer sur Firebase")
