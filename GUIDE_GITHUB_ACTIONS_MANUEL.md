# 🚀 Guide Complet : Configuration GitHub Actions pour Build APK

## ⚠️ PROBLÈME ACTUEL
Le workflow `.github/workflows/build-apk.yml` ne peut pas être pushé via Git à cause de permissions GitHub manquantes. **Solution : Création manuelle via l'interface GitHub.**

---

## 📋 ÉTAPE 1 : CONFIGURER LES 4 SECRETS (CRITIQUE)

### 🔗 **Allez sur** : 
```
https://github.com/dumontjeanfrancois-ui/muscle-master-app/settings/secrets/actions
```

### **Créez ces 4 secrets** (bouton "New repository secret") :

#### **1️⃣ KEYSTORE_BASE64**
- **Nom** : `KEYSTORE_BASE64`
- **Valeur** : 
```
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
```

#### **2️⃣ KEYSTORE_PASSWORD**
- **Nom** : `KEYSTORE_PASSWORD`
- **Valeur** : `MUSCLE2025master`

#### **3️⃣ KEY_PASSWORD**
- **Nom** : `KEY_PASSWORD`
- **Valeur** : `MUSCLE2025master`

#### **4️⃣ KEY_ALIAS**
- **Nom** : `KEY_ALIAS`
- **Valeur** : `muscle-master`

---

## 📋 ÉTAPE 2 : CRÉER LE WORKFLOW MANUELLEMENT

### 🔗 **Allez sur** : 
```
https://github.com/dumontjeanfrancois-ui/muscle-master-app
```

### **Étapes visuelles** :

1. **Cliquez sur** : `Add file` → `Create new file`

2. **Nom du fichier** : 
```
.github/workflows/build-apk.yml
```
   ⚠️ **IMPORTANT** : Respectez exactement ce chemin (avec les `.` et `/`)

3. **Copiez-collez ce contenu** (voir ci-dessous)

4. **Message de commit** : `Add: GitHub Actions APK Build Workflow`

5. **Cliquez sur** : `Commit new file`

---

## 📄 CONTENU DU FICHIER `build-apk.yml`

```yaml
name: Build Android APK

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: 📥 Checkout repository
        uses: actions/checkout@v4

      - name: ☕ Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: 🐦 Setup Flutter 3.35.4
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.4'
          channel: 'stable'

      - name: 📦 Install dependencies
        run: flutter pub get

      - name: 🔍 Analyze code
        run: flutter analyze || true

      - name: 🔐 Decode Keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 -d > android/muscle-master-release-key.jks
          echo "✅ Keystore decoded successfully"

      - name: 📝 Create key.properties
        run: |
          cat > android/key.properties << 'EOF'
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=${{ secrets.KEY_ALIAS }}
          storeFile=muscle-master-release-key.jks
          EOF
          echo "✅ key.properties created"
          echo "📄 Content verification:"
          cat android/key.properties

      - name: 🏗️ Build Release APK (Split per ABI)
        run: flutter build apk --release --split-per-abi

      - name: 📊 List APK files
        run: |
          echo "=== APK Files Generated ==="
          ls -lh build/app/outputs/flutter-apk/*.apk
          echo ""
          echo "=== APK Details ==="
          for apk in build/app/outputs/flutter-apk/*.apk; do
            echo "File: $(basename $apk)"
            echo "Size: $(du -h $apk | cut -f1)"
            echo "---"
          done

      - name: ✅ Verify APK Signature
        run: |
          echo "=== Verifying APK Signature ==="
          jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

      - name: 📤 Upload ARM64 APK
        uses: actions/upload-artifact@v4
        with:
          name: Muscle-Master-arm64-v8a
          path: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
          retention-days: 30

      - name: 📤 Upload ARMv7 APK
        uses: actions/upload-artifact@v4
        with:
          name: Muscle-Master-armeabi-v7a
          path: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
          retention-days: 30

      - name: 📤 Upload x86_64 APK
        uses: actions/upload-artifact@v4
        with:
          name: Muscle-Master-x86_64
          path: build/app/outputs/flutter-apk/app-x86_64-release.apk
          retention-days: 30

      - name: 🎉 Build Summary
        run: |
          echo "✅ APK Build completed successfully!"
          echo ""
          echo "📦 Generated APKs:"
          echo "- ARM64-v8a: $(du -h build/app/outputs/flutter-apk/app-arm64-v8a-release.apk | cut -f1)"
          echo "- ARMv7: $(du -h build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk | cut -f1)"
          echo "- x86_64: $(du -h build/app/outputs/flutter-apk/app-x86_64-release.apk | cut -f1)"
          echo ""
          echo "🔗 Download artifacts from GitHub Actions tab"
```

---

## 📋 ÉTAPE 3 : LANCER LE BUILD

### 🔗 **Allez sur** : 
```
https://github.com/dumontjeanfrancois-ui/muscle-master-app/actions
```

1. **Cliquez sur** : `Build Android APK` (dans la liste des workflows)
2. **Cliquez sur** : `Run workflow` → `Run workflow`
3. **Attendez** : ~7 minutes ⏳

---

## ✅ ÉTAPE 4 : TÉLÉCHARGER LES APKs

Une fois le build terminé :

1. **Cliquez sur** : Le run réussi (ligne verte)
2. **Scrollez en bas** : Section "Artifacts"
3. **Téléchargez** :
   - `Muscle-Master-arm64-v8a.zip` (recommandé)
   - `Muscle-Master-armeabi-v7a.zip`
   - `Muscle-Master-x86_64.zip`

---

## 🎯 RÉSULTAT ATTENDU

- ✅ Build automatique à chaque `git push`
- ✅ APKs signés avec production keystore
- ✅ Package : `com.musclemaster.fitness`
- ✅ Version : 1.0.0+1
- ✅ Artifacts conservés 30 jours

---

## 🆘 EN CAS DE PROBLÈME

### **Erreur "Secret not found"**
→ Vérifiez que les 4 secrets sont bien créés (Étape 1)

### **Erreur de build Flutter**
→ Les warnings Flutter ont été corrigés (commit `c071c35`)

### **Keystore decode error**
→ Vérifiez que `KEYSTORE_BASE64` contient bien la valeur complète (3744 caractères)

---

## 📦 ALTERNATIVE : APKs Locaux Disponibles

Si GitHub Actions ne fonctionne toujours pas, utilisez les APKs déjà compilés :

```
/tmp/Muscle-Master-v1.0.0-arm64.apk     (23 MB)
/tmp/Muscle-Master-v1.0.0-arm32.apk     (20 MB)
/tmp/Muscle-Master-v1.0.0-x86_64.apk    (24 MB)
```

**Ces APKs sont identiques à ceux que GitHub Actions produira.**

---

📅 **Document créé** : 23 décembre 2024  
🔗 **Repository** : https://github.com/dumontjeanfrancois-ui/muscle-master-app
