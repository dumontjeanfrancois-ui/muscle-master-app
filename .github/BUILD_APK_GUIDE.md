# 🚀 GitHub Actions - Build APK Automatique

Ce repository est configuré avec **GitHub Actions** pour builder automatiquement les APK Android.

---

## 📦 Comment Récupérer les APKs

### **Méthode 1: Télécharger depuis GitHub Actions**

1. Allez sur l'onglet **"Actions"** du repository
   - URL: https://github.com/dumontjeanfrancois-ui/muscle-master-app/actions

2. Cliquez sur le dernier workflow **"Build Android APK"** (avec ✅ check vert)

3. Scrollez vers le bas jusqu'à la section **"Artifacts"**

4. Téléchargez **"release-apks"** (fichier ZIP contenant les 3 APKs)

5. Extrayez le ZIP pour obtenir:
   - `app-armeabi-v7a-release.apk` (32-bit ARM)
   - `app-arm64-v8a-release.apk` (64-bit ARM) ⭐ **Recommandé**
   - `app-x86_64-release.apk` (64-bit x86)

---

## ⚙️ Comment Déclencher un Build

### **Build Automatique**
Le build se lance automatiquement quand vous:
- Poussez du code sur la branche `main`
- Créez une Pull Request vers `main`

### **Build Manuel**
1. Allez sur l'onglet **"Actions"**
2. Sélectionnez **"Build Android APK"** dans la liste à gauche
3. Cliquez sur **"Run workflow"** (bouton en haut à droite)
4. Sélectionnez la branche `main`
5. Cliquez sur **"Run workflow"** vert
6. Attendez 5-8 minutes (le build est en cours)
7. Téléchargez les APKs dans la section Artifacts

---

## 📊 Statut du Build

[![Build Android APK](https://github.com/dumontjeanfrancois-ui/muscle-master-app/actions/workflows/build-apk.yml/badge.svg)](https://github.com/dumontjeanfrancois-ui/muscle-master-app/actions/workflows/build-apk.yml)

Cliquez sur le badge ci-dessus pour voir l'état actuel du build.

---

## 🎯 Configuration du Workflow

Le workflow GitHub Actions:
- ✅ Utilise **Flutter 3.35.4** (stable)
- ✅ Compile avec **Java 17**
- ✅ Build en mode **release**
- ✅ Crée 3 APKs séparés (split-per-abi)
- ✅ Artifacts conservés pendant **30 jours**
- ✅ Build automatique sur chaque push

---

## 📱 Installation sur Android

### **Recommandation:**
Utilisez `app-arm64-v8a-release.apk` pour la plupart des smartphones modernes (2017+).

### **Étapes d'installation:**
1. Téléchargez l'APK recommandé
2. Transférez-le sur votre smartphone Android
3. Ouvrez le fichier APK
4. Autorisez "Sources inconnues" si demandé
5. Installez l'application
6. Lancez **Muscle Master** !

---

## 🔒 Sécurité

**Note:** Les APKs générés par GitHub Actions sont signés avec une clé de debug. Pour la production (Google Play Store), vous devrez:
- Générer une clé de signature release
- Configurer les secrets GitHub pour la signature automatique
- Ou builder localement avec votre clé de production

---

## ⏱️ Temps de Build

- **Temps moyen:** 5-8 minutes
- **Runner:** ubuntu-latest (GitHub hosted)
- **Parallélisation:** 3 APKs en une seule exécution

---

## 📚 Documentation Complète

Pour plus d'informations:
- **README principal:** [README.md](README.md)
- **Checklist publication:** [TODO_AVANT_PUBLICATION.md](TODO_AVANT_PUBLICATION.md)
- **Commandes utiles:** [COMMANDES_UTILES.md](COMMANDES_UTILES.md)

---

## 🎊 Build Local Alternative

Si vous préférez builder localement:
```bash
git clone https://github.com/dumontjeanfrancois-ui/muscle-master-app.git
cd muscle-master-app
flutter pub get
flutter build apk --release --split-per-abi
```

Les APKs seront dans: `build/app/outputs/flutter-apk/`

---

**Version:** 1.0.0+1  
**Status:** Production Ready 🚀  
**Last Updated:** 2025-12-23
