# 🚀 COMMANDES UTILES - MUSCLE MASTER

## 📋 Commandes Rapides

### 🌐 Accéder à l'Application Web
```bash
# URL directe (déjà démarrée)
https://5060-it46lir9innq9vkpccwle-5c13a017.sandbox.novita.ai
```

### 🔄 Redémarrer le Serveur Web (si nécessaire)
```bash
# Arrêter le serveur actuel
lsof -ti:5060 | xargs -r kill -9

# Redémarrer le serveur
cd /home/user/flutter_app
flutter build web --release
cd build/web
python3 -m http.server 5060 --bind 0.0.0.0 &
```

### 📤 Push vers GitHub

#### Option 1 : Script Automatique (Recommandé)
```bash
cd /home/user/flutter_app
./push_to_github.sh
```

#### Option 2 : Commandes Manuelles
```bash
cd /home/user/flutter_app

# Remplacer VOTRE_USERNAME par votre nom GitHub
git remote add origin https://github.com/VOTRE_USERNAME/muscle-master-app.git

# Pousser le code
git push -u origin main
```

### 📊 Vérifier l'État Git
```bash
cd /home/user/flutter_app

# Voir les commits
git log --oneline

# Voir l'état actuel
git status

# Voir les remotes configurés
git remote -v
```

### 🔍 Analyser le Code
```bash
cd /home/user/flutter_app

# Analyse complète
flutter analyze

# Formater le code
dart format .

# Vérifier les dépendances
flutter pub get
```

### 📱 Build APK Android (Pour Demain)
```bash
cd /home/user/flutter_app

# Build APK Release
flutter build apk --release

# Build APK Split par ABI (fichiers plus petits)
flutter build apk --split-per-abi --release

# Build App Bundle (pour Play Store)
flutter build appbundle --release
```

### 📚 Consulter la Documentation
```bash
cd /home/user/flutter_app

# Lire le récapitulatif d'aujourd'hui
cat COMPLETED_TODAY.md

# Lire la synthèse complète
cat docs/SYNTHESE_FINALE.md

# Lire le guide GitHub
cat docs/GITHUB_SETUP_GUIDE.md

# Lire le README principal
cat README.md
```

### 🧹 Nettoyage (si nécessaire)
```bash
cd /home/user/flutter_app

# Nettoyer les builds
flutter clean

# Réinstaller les dépendances
flutter pub get

# Rebuild complet
flutter build web --release
```

### 📊 Statistiques du Projet
```bash
cd /home/user/flutter_app

# Nombre de fichiers Dart
find lib -name "*.dart" | wc -l

# Lignes de code totales
find lib -name "*.dart" -exec wc -l {} + | tail -1

# Nombre de commits
git log --oneline | wc -l

# Taille du projet
du -sh .
```

### 🔧 Dépannage

#### Problème : Serveur Web ne répond pas
```bash
# Vérifier si le serveur tourne
curl -I http://localhost:5060

# Vérifier les processus sur le port 5060
lsof -i :5060

# Redémarrer le serveur (voir commande ci-dessus)
```

#### Problème : Erreurs de compilation
```bash
cd /home/user/flutter_app

# Nettoyer et rebuild
flutter clean
flutter pub get
flutter analyze
flutter build web --release
```

#### Problème : Push GitHub échoue
```bash
# Vérifier la configuration Git
git config --list

# Vérifier les remotes
git remote -v

# Supprimer et re-ajouter le remote
git remote remove origin
git remote add origin https://github.com/VOTRE_USERNAME/muscle-master-app.git

# Re-tenter le push
git push -u origin main
```

---

## 🎯 Commandes pour Demain

### ⚠️ AVANT TOUTE CHOSE : Mettre à jour les informations
```bash
# CONSULTEZ CE FICHIER EN PRIORITÉ :
cat /home/user/flutter_app/TODO_AVANT_PUBLICATION.md

# Informations critiques à modifier :
# - Email de contact dans README.md et ProfileScreen
# - Téléphone de contact (si souhaité)
# - AdMob IDs production (App ID + Unit IDs)
# - Firebase google-services.json production
# - Clé API Gemini production
# - In-App Purchase Product IDs
```

### Préparation Build APK
```bash
cd /home/user/flutter_app

# Vérifier la configuration Android
flutter doctor -v

# Nettoyer avant build
flutter clean
flutter pub get

# Build APK final
flutter build apk --release --split-per-abi
```

### Tests Approfondis
```bash
cd /home/user/flutter_app

# Tests unitaires
flutter test

# Tests d'intégration (si configurés)
flutter test integration_test/

# Analyse de performance
flutter analyze --watch
```

### Configuration AdMob Production
```bash
# Fichiers à modifier :
# - android/app/src/main/AndroidManifest.xml (App ID)
# - lib/services/ad_service.dart (Unit IDs)

# Après modification, rebuild
flutter build apk --release
```

---

## 📖 Documentation Disponible

| Fichier | Description |
|---------|-------------|
| `TODO_AVANT_PUBLICATION.md` | ⚠️ **CHECKLIST CRITIQUE** - Modifications obligatoires |
| `COMPLETED_TODAY.md` | Récapitulatif des 5 points complétés |
| `README.md` | Documentation complète du projet |
| `docs/SYNTHESE_FINALE.md` | Synthèse détaillée de tout |
| `docs/GITHUB_SETUP_GUIDE.md` | Guide push GitHub |
| `docs/firebase_subscription_structure.py` | Structure Firebase |
| `push_to_github.sh` | Script automatique de push |

---

## 🆘 Aide Rapide

Si vous avez besoin d'aide :

1. **Consulter les guides** : Tous les documents sont dans le projet
2. **Vérifier les logs** : `flutter analyze` pour les erreurs de code
3. **Tester localement** : L'app web est déjà accessible
4. **Git status** : `git status` pour voir l'état du repository

---

💪 **Muscle Master v1.0.0+1 - Production Ready**

*Toutes les commandes sont prêtes à être utilisées. Bonne chance !*
