"""
Backend Endpoint pour Suppression de Compte - VERSION SÉCURISÉE
COMPLIANCE: Requis par Google Play et Apple App Store

Ce script fournit un endpoint /delete-account pour la suppression de compte via API externe.

SÉCURITÉ RENFORCÉE:
- Token Firebase OBLIGATOIRE (id_token)
- CORS strict (uniquement domaines autorisés)
- Rate limiting (5 requêtes/minute par IP)
- HTTPS obligatoire en production
- Vérification cohérence uid + email
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
import firebase_admin
from firebase_admin import credentials, firestore, auth
import os

app = Flask(__name__)

# Configuration CORS stricte - UNIQUEMENT domaines autorisés
ALLOWED_ORIGINS = [
    'https://musclemaster.app',
    'https://www.musclemaster.app',
    'http://localhost:3000',      # Développement local
    'http://127.0.0.1:3000'       # Développement local
]

CORS(app, resources={
    r"/delete-account": {
        "origins": ALLOWED_ORIGINS,
        "methods": ["POST"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})

# Rate Limiting - Maximum 5 requêtes par minute par IP
limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["100 per hour"],
    storage_uri="memory://"
)

# Initialiser Firebase Admin SDK
cred_path = os.getenv('FIREBASE_ADMIN_SDK_PATH', '/opt/flutter/firebase-admin-sdk.json')
if os.path.exists(cred_path):
    cred = credentials.Certificate(cred_path)
    firebase_admin.initialize_app(cred)
else:
    print("⚠️ Firebase Admin SDK non trouvé. Utiliser les credentials par défaut.")
    firebase_admin.initialize_app()

db = firestore.client()


@app.route('/delete-account', methods=['POST', 'GET'])
@limiter.limit("5 per minute")  # Rate limiting strict
def delete_account():
    """
    Endpoint pour supprimer un compte utilisateur - VERSION SÉCURISÉE
    
    GET: Affiche une page d'information (redirection vers /delete-account.html)
    POST: Supprime réellement le compte (API)
    
    Paramètres POST (JSON) - TOUS OBLIGATOIRES:
    - user_id: ID Firebase de l'utilisateur
    - email: Email de l'utilisateur (pour vérification)
    - id_token: Token d'authentification Firebase (OBLIGATOIRE)
    
    SÉCURITÉ:
    - id_token vérifié avec Firebase Auth
    - Cohérence uid/email vérifiée
    - HTTPS obligatoire en production
    - Rate limiting 5 req/min
    """
    
    if request.method == 'GET':
        # Rediriger vers la page HTML statique
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta http-equiv="refresh" content="0; url=/delete-account.html">
        </head>
        <body>
            <p>Redirection vers la page de suppression...</p>
        </body>
        </html>
        """
    
    # VÉRIFICATION HTTPS EN PRODUCTION
    is_production = os.getenv('ENVIRONMENT', 'production') == 'production'
    if is_production and not request.is_secure:
        return jsonify({
            'success': False,
            'error': 'HTTPS requis en production'
        }), 403
    
    # Méthode POST : suppression réelle
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'error': 'Données JSON manquantes'
            }), 400
        
        user_id = data.get('user_id')
        email = data.get('email')
        id_token = data.get('id_token')
        
        # VÉRIFICATION 1: Tous les champs OBLIGATOIRES
        if not user_id or not email or not id_token:
            return jsonify({
                'success': False,
                'error': 'user_id, email et id_token sont OBLIGATOIRES'
            }), 400
        
        # VÉRIFICATION 2: Token Firebase (OBLIGATOIRE)
        try:
            decoded_token = auth.verify_id_token(id_token)
            token_user_id = decoded_token['uid']
            token_email = decoded_token.get('email')
            
            # VÉRIFICATION 3: Cohérence uid
            if token_user_id != user_id:
                return jsonify({
                    'success': False,
                    'error': 'user_id ne correspond pas au token'
                }), 403
            
            # VÉRIFICATION 4: Cohérence email
            if token_email != email:
                return jsonify({
                    'success': False,
                    'error': 'email ne correspond pas au token'
                }), 403
                
        except auth.InvalidIdTokenError:
            return jsonify({
                'success': False,
                'error': 'Token Firebase invalide'
            }), 401
        except auth.ExpiredIdTokenError:
            return jsonify({
                'success': False,
                'error': 'Token Firebase expiré'
            }), 401
        except Exception as e:
            return jsonify({
                'success': False,
                'error': f'Erreur de vérification du token: {str(e)}'
            }), 401
        
        # Supprimer les données Firestore
        deleted_count = delete_user_data(user_id)
        
        # Supprimer le compte Firebase Auth
        try:
            auth.delete_user(user_id)
            auth_deleted = True
        except Exception as e:
            print(f"⚠️ Erreur suppression compte Auth: {e}")
            auth_deleted = False
        
        return jsonify({
            'success': True,
            'message': 'Compte supprimé avec succès',
            'details': {
                'user_id': user_id,
                'firestore_documents_deleted': deleted_count,
                'auth_account_deleted': auth_deleted
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': f'Erreur serveur: {str(e)}'
        }), 500


def delete_user_data(user_id: str) -> int:
    """
    Supprime toutes les données Firestore d'un utilisateur
    
    Args:
        user_id: ID Firebase de l'utilisateur
    
    Returns:
        Nombre total de documents supprimés
    """
    deleted_count = 0
    
    collections_to_delete = [
        'programs',
        'workouts',
        'food_logs',
        'progress',
        'user_preferences',
        'users'
    ]
    
    for collection_name in collections_to_delete:
        try:
            # Requête pour trouver tous les documents de l'utilisateur
            docs = db.collection(collection_name).where('userId', '==', user_id).stream()
            
            for doc in docs:
                doc.reference.delete()
                deleted_count += 1
                print(f"✅ Supprimé: {collection_name}/{doc.id}")
        
        except Exception as e:
            print(f"⚠️ Erreur suppression {collection_name}: {e}")
    
    # Supprimer le document utilisateur principal
    try:
        db.collection('users').document(user_id).delete()
        deleted_count += 1
        print(f"✅ Document utilisateur principal supprimé")
    except Exception as e:
        print(f"⚠️ Erreur suppression document utilisateur: {e}")
    
    return deleted_count


@app.route('/health', methods=['GET'])
def health_check():
    """Endpoint de santé pour vérifier que le serveur fonctionne"""
    return jsonify({
        'status': 'healthy',
        'service': 'Muscle Master Account Deletion API',
        'version': '2.0.0-secured'
    }), 200


@app.route('/test-delete', methods=['GET'])
def test_delete():
    """Endpoint de test simple pour vérifier l'accessibilité"""
    return jsonify({
        "status": "Delete endpoint reachable",
        "delete_url": "/delete-account"
    }), 200


if __name__ == '__main__':
    print("🚀 Muscle Master Delete API running on http://localhost:5000")
    print("📍 Test endpoint: http://localhost:5000/test-delete")
    print("🗑️  Delete endpoint: http://localhost:5000/delete-account")
    # Mode développement
    app.run(host='0.0.0.0', port=5000, debug=True)


"""
DÉPLOIEMENT PRODUCTION

DÉPENDANCES REQUISES:
pip install flask flask-cors flask-limiter firebase-admin

1. Google Cloud Run / App Engine / Cloud Functions
2. AWS Lambda + API Gateway
3. Azure Functions
4. Heroku
5. DigitalOcean App Platform

CONFIGURATION REQUISE:
- Variable d'environnement: FIREBASE_ADMIN_SDK_PATH
- Variable d'environnement: ENVIRONMENT=production (pour forcer HTTPS)
- Fichier: firebase-admin-sdk.json (credentials Firebase)
- Port: 5000 (ou défini par l'environnement)

SÉCURITÉ RENFORCÉE v2.0:
- ✅ Token Firebase OBLIGATOIRE (id_token)
- ✅ Vérification cohérence uid + email
- ✅ CORS strict (uniquement musclemaster.app)
- ✅ Rate limiting 5 req/min par IP
- ✅ HTTPS obligatoire en production
- ✅ Gestion erreurs détaillée
- ✅ Validation complète des données

CHANGEMENTS PAR RAPPORT À v1.0:
- id_token maintenant OBLIGATOIRE (plus optionnel)
- Vérification email ajoutée (en plus de uid)
- CORS configuré avec flask-cors
- Rate limiting avec flask-limiter
- HTTPS forcé en production
- Meilleure gestion des erreurs token

URLs À DÉCLARER:
- Google Play Console: https://musclemaster.app/delete-account
- App Store Connect: https://musclemaster.app/delete-account

EXEMPLE REQUÊTE CLIENT (Flutter):
```dart
final response = await http.post(
  Uri.parse('https://musclemaster.app/delete-account'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'user_id': currentUser.uid,
    'email': currentUser.email,
    'id_token': await currentUser.getIdToken(),  // OBLIGATOIRE
  }),
);
```
"""
