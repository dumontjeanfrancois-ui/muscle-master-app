#!/usr/bin/env python3
"""
Guide de création de la base Firestore pour Muscle Master
"""

print("""
🔥 MUSCLE MASTER - CRÉATION BASE FIRESTORE REQUISE
============================================================

❌ ERREUR DÉTECTÉE: La base de données Firestore n'existe pas encore!

📋 ÉTAPES OBLIGATOIRES:

1️⃣  CRÉER LA BASE FIRESTORE
   
   🌐 Option A: Via Console Firebase (RAPIDE - 2 minutes)
   
   a) Ouvrir: https://console.firebase.google.com/project/muscle-master-48827
   
   b) Dans le menu latéral, cliquer sur "Firestore Database"
   
   c) Cliquer sur "Créer une base de données"
   
   d) Choisir le mode:
      - Mode Production (recommandé) : Rules strictes
      - Mode Test : Rules permissives (30 jours)
      → Choisir "Mode Production"
   
   e) Sélectionner l'emplacement:
      - europe-west1 (Belgique) - Recommandé pour Europe
      - us-central1 (Iowa) - Pour USA
      → Choisir selon votre localisation
   
   f) Cliquer "Activer"
   
   ⏳ Attendre 1-2 minutes (création de la base)
   
   ✅ Vous verrez "Cloud Firestore" avec onglets "Données", "Règles", "Index"

2️⃣  DÉPLOYER LES SECURITY RULES (APRÈS création base)
   
   a) Aller dans l'onglet "Règles"
   
   b) Remplacer le contenu par le contenu de: firestore.rules
      (voir fichier dans le projet)
   
   c) Cliquer "Publier"

3️⃣  CRÉER LES INDEX COMPOSITES
   
   a) Aller dans l'onglet "Index"
   
   b) Cliquer "Créer un index composite"
   
   c) Index 1: gym_crush_presence
      - Collection: gym_crush_presence
      - Champs: gymId (Asc), isActive (Asc), expiresAt (Asc), invisibleMode (Asc)
   
   d) Index 2: friends
      - Collection: friends
      - Champs: isDeleted (Asc), isActive (Asc)
      - Portée: Collection group

4️⃣  RELANCER CE SCRIPT
   
   Une fois la base créée (étape 1 complète):
   
   cd /home/user/flutter_app
   python3 scripts/init_firestore_collections.py

============================================================
📖 DOCUMENTATION COMPLÈTE
============================================================

Voir: FIREBASE_DEPLOYMENT_GUIDE.md
Section: "OPTION 1: Console Firebase (Web)"

============================================================
⏸️  SCRIPT EN PAUSE - ACTION REQUISE
============================================================

Veuillez créer la base Firestore via la console, puis relancer ce script.

Lien direct: https://console.firebase.google.com/project/muscle-master-48827/firestore

""")
