#!/usr/bin/env python3
"""
Script de migration Gym Crush → Connections
Transforme les anciennes données crush en connexions amis sportifs
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime
import sys

def initialize_firebase():
    """Initialiser Firebase Admin SDK"""
    try:
        cred = credentials.Certificate('/opt/flutter/firebase-admin-sdk.json')
        firebase_admin.initialize_app(cred)
        print("✅ Firebase initialisé")
        return firestore.client()
    except Exception as e:
        print(f"❌ Erreur initialisation Firebase: {e}")
        sys.exit(1)

def migrate_gym_crush_to_connections(db):
    """Migrer les données gym_crush_interactions vers connections"""
    print("\n🔄 Migration Gym Crush → Connections...")
    
    migrated_count = 0
    error_count = 0
    
    try:
        # Lire tous les documents gym_crush_interactions
        users_ref = db.collection('gym_crush_interactions')
        users = users_ref.stream()
        
        for user_doc in users:
            user_id = user_doc.id
            print(f"\n📋 Migration user: {user_id}")
            
            # Lire les interactions de cet utilisateur
            interactions_ref = users_ref.document(user_id).collection('interactions')
            interactions = interactions_ref.stream()
            
            for interaction_doc in interactions:
                try:
                    interaction_data = interaction_doc.to_dict()
                    target_user_id = interaction_doc.id
                    
                    # Ne migrer que les status 'mutual' ou 'pending'
                    status = interaction_data.get('status', '')
                    if status not in ['mutual', 'pending']:
                        print(f"  ⏭️  Skip {target_user_id} (status: {status})")
                        continue
                    
                    # Créer connexion
                    connection_data = {
                        'userId': user_id,
                        'friendId': target_user_id,
                        'pseudo': interaction_data.get('targetPseudo', 'Unknown'),
                        'mascotType': interaction_data.get('targetMascotType', 'male'),
                        'createdAt': interaction_data.get('createdAt', firestore.SERVER_TIMESTAMP),
                        'isActive': True,
                        'isDeleted': False,
                        'deletedAt': None,
                    }
                    
                    # Écrire dans nouvelle collection
                    db.collection('connections').document(user_id).collection('friends').document(target_user_id).set(connection_data)
                    
                    print(f"  ✅ Migré: {user_id} → {target_user_id}")
                    migrated_count += 1
                    
                except Exception as e:
                    print(f"  ❌ Erreur migration interaction {target_user_id}: {e}")
                    error_count += 1
        
        print(f"\n📊 Migration terminée: {migrated_count} connexions migrées, {error_count} erreurs")
        
    except Exception as e:
        print(f"❌ Erreur migration: {e}")

def migrate_presence_add_invisible_mode(db):
    """Ajouter champ invisibleMode aux documents présence existants"""
    print("\n🔄 Ajout invisibleMode aux présences...")
    
    updated_count = 0
    
    try:
        presence_ref = db.collection('gym_crush_presence')
        docs = presence_ref.stream()
        
        for doc in docs:
            try:
                # Ajouter invisibleMode si manquant
                if 'invisibleMode' not in doc.to_dict():
                    presence_ref.document(doc.id).update({
                        'invisibleMode': False
                    })
                    updated_count += 1
                    print(f"  ✅ Updated: {doc.id}")
            except Exception as e:
                print(f"  ❌ Erreur update {doc.id}: {e}")
        
        print(f"\n📊 {updated_count} documents présence mis à jour")
        
    except Exception as e:
        print(f"❌ Erreur update présence: {e}")

def create_user_profiles(db):
    """Créer documents users pour profils premium si manquants"""
    print("\n🔄 Création profils utilisateurs...")
    
    created_count = 0
    
    try:
        # Récupérer tous les userId des connexions
        connections_ref = db.collection('connections')
        connection_docs = connections_ref.stream()
        
        user_ids = set()
        for doc in connection_docs:
            user_ids.add(doc.id)
        
        # Créer profils si manquants
        for user_id in user_ids:
            try:
                user_ref = db.collection('users').document(user_id)
                user_doc = user_ref.get()
                
                if not user_doc.exists:
                    user_ref.set({
                        'userId': user_id,
                        'isPremium': False,
                        'premiumExpiresAt': None,
                        'boostCredits': 0,
                    })
                    created_count += 1
                    print(f"  ✅ Profil créé: {user_id}")
            except Exception as e:
                print(f"  ❌ Erreur création profil {user_id}: {e}")
        
        print(f"\n📊 {created_count} profils utilisateurs créés")
        
    except Exception as e:
        print(f"❌ Erreur création profils: {e}")

def main():
    """Fonction principale de migration"""
    print("=" * 60)
    print("🔧 MIGRATION GYM CRUSH → SOCIAL CONNECTIONS")
    print("=" * 60)
    
    db = initialize_firebase()
    
    # Étape 1 : Migrer interactions → connexions
    migrate_gym_crush_to_connections(db)
    
    # Étape 2 : Ajouter invisibleMode aux présences
    migrate_presence_add_invisible_mode(db)
    
    # Étape 3 : Créer profils utilisateurs
    create_user_profiles(db)
    
    print("\n✅ MIGRATION TERMINÉE")
    print("=" * 60)

if __name__ == '__main__':
    main()
