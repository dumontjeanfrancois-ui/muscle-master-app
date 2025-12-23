# 🔐 Configuration GitHub Secrets pour APK Android

Ce document explique comment configurer les secrets GitHub pour automatiser la compilation d'APK signés via GitHub Actions.

## 📋 Secrets Required

Vous devez créer **4 secrets** dans votre repository GitHub :

### 1. `KEYSTORE_BASE64`
**Keystore encodé en Base64** pour signer l'APK Android en production.

**Valeur** : Copiez le contenu du fichier `/tmp/keystore_base64.txt`

```
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... (contenu tronqué pour la lisibilité)
```

---

### 2. `KEYSTORE_PASSWORD`
**Mot de passe du keystore** (storePassword)

**Valeur** : `MUSCLE2025master`

---

### 3. `KEY_PASSWORD`
**Mot de passe de la clé** (keyPassword)

**Valeur** : `MUSCLE2025master`

---

### 4. `KEY_ALIAS`
**Alias de la clé de signature**

**Valeur** : `muscle-master`

---

## 🛠️ Comment ajouter les secrets sur GitHub

### Étapes :

1. **Allez sur votre repository GitHub** :  
   `https://github.com/dumontjeanfrancois-ui/muscle-master-app`

2. **Cliquez sur "Settings"** (en haut à droite)

3. **Dans le menu de gauche, sélectionnez "Secrets and variables" → "Actions"**

4. **Cliquez sur "New repository secret"**

5. **Ajoutez chaque secret** :
   - **Name** : `KEYSTORE_BASE64`
   - **Value** : Copiez le contenu complet de `/tmp/keystore_base64.txt`
   - Cliquez sur **"Add secret"**

6. **Répétez l'opération pour les 3 autres secrets** :
   - `KEYSTORE_PASSWORD` → `MUSCLE2025master`
   - `KEY_PASSWORD` → `MUSCLE2025master`
   - `KEY_ALIAS` → `muscle-master`

---

## ✅ Vérification

Une fois les **4 secrets configurés**, GitHub Actions pourra automatiquement :

1. ✅ Décoder le keystore
2. ✅ Créer le fichier `key.properties`
3. ✅ Compiler et signer l'APK Android
4. ✅ Uploader les APKs en tant qu'artifacts téléchargeables

---

## 🚀 Test du Workflow

Après avoir ajouté les secrets :

1. **Faites un commit et push** :
   ```bash
   git add .
   git commit -m "Add GitHub Actions workflow for APK build"
   git push origin main
   ```

2. **Allez sur l'onglet "Actions"** de votre repository GitHub

3. **Vous verrez le workflow "Build Android APK"** se lancer automatiquement

4. **Téléchargez les APKs** depuis les artifacts une fois le build terminé

---

## 📦 Résultat Attendu

Après chaque push sur `main`, GitHub Actions générera automatiquement **3 APKs signés** :

- ✅ **Muscle-Master-arm64-v8a.apk** (23 MB) - **RECOMMANDÉ**
- ✅ **Muscle-Master-armeabi-v7a.apk** (21 MB)
- ✅ **Muscle-Master-x86_64.apk** (24 MB)

**Signature** : HomeFit Belgium (Production)  
**Package** : `com.musclemaster.fitness`  
**Version** : 1.0.0+1

---

## 🔒 Sécurité

- ⚠️ **Ne commitez JAMAIS** le keystore ou les mots de passe directement dans Git
- ✅ Utilisez **uniquement** GitHub Secrets pour stocker les informations sensibles
- ✅ Le keystore base64 ne sera **jamais visible** dans les logs GitHub Actions
- ✅ Les secrets sont **chiffrés** et accessibles uniquement pendant l'exécution du workflow

---

## 📞 Support

Si le workflow échoue :

1. Vérifiez que les **4 secrets** sont bien configurés
2. Vérifiez que la valeur de `KEYSTORE_BASE64` est **complète** (3744 caractères)
3. Consultez les logs du workflow dans l'onglet **Actions** → **Build Android APK**

---

**Document créé le** : 21 Décembre 2025  
**Keystore généré le** : 21 Décembre 2025  
**Organisation** : HomeFit Belgium  
**Alias** : `muscle-master`
