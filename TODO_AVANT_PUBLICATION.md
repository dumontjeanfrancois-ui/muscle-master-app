# 📝 TODO AVANT PUBLICATION - MUSCLE MASTER

## ⚠️ MODIFICATIONS CRITIQUES À EFFECTUER

---

## 📞 INFORMATIONS DE CONTACT À METTRE À JOUR

### 1. README.md (Section Contact & Support)

**Fichier** : `/home/user/flutter_app/README.md`  
**Lignes** : ~344-349

**Actuel** :
```markdown
## 📞 Contact & Support

Pour toute question ou demande de collaboration :
- 📧 Email : [contact@musclemaster.app](mailto:contact@musclemaster.app)
- 🌐 Website : (à venir)
- 📱 Store : (à venir sur Google Play & App Store)
```

**À REMPLACER PAR VOS VRAIES INFORMATIONS** :
```markdown
## 📞 Contact & Support

Pour toute question ou demande de collaboration :
- 📧 Email : [VOTRE_EMAIL@domaine.com](mailto:VOTRE_EMAIL@domaine.com)
- 📱 Téléphone : +33 X XX XX XX XX (si vous voulez le publier)
- 🌐 Website : https://votre-site.com (quand disponible)
- 📱 Store : (à venir sur Google Play & App Store)
```

---

### 2. Écran Profil - Informations Contact dans l'App

**Fichier à vérifier** : `/home/user/flutter_app/lib/screens/profile_screen.dart`

Rechercher les sections contenant :
- Email de contact
- Numéro de téléphone
- Liens support

**Action requise** : Remplacer par vos vraies coordonnées

---

### 3. AndroidManifest.xml - Permissions et Contact

**Fichier** : `/home/user/flutter_app/android/app/src/main/AndroidManifest.xml`

Vérifier qu'il n'y a pas d'email ou de contact hardcodé

---

### 4. Firebase & Backend

Si vous avez configuré des emails de notification :
- Cloud Functions : Emails d'envoi
- Firebase Authentication : Email de support
- Firestore : Documents de configuration

---

## 🔑 AUTRES INFORMATIONS À PERSONNALISER

### 5. AdMob IDs (Pour Production)

**Fichier** : `/home/user/flutter_app/lib/services/ad_service.dart`

**Actuel (IDs de test)** :
```dart
static const String _bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // TEST
static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // TEST
```

**À REMPLACER par vos vrais IDs AdMob** :
```dart
static const String _bannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // PRODUCTION
static const String _interstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // PRODUCTION
```

**Comment obtenir vos IDs** :
1. Allez sur https://apps.admob.google.com/
2. Créez une application
3. Créez des blocs publicitaires (Banner + Interstitiel)
4. Copiez les IDs fournis

---

### 6. AndroidManifest.xml - AdMob App ID

**Fichier** : `/home/user/flutter_app/android/app/src/main/AndroidManifest.xml`

**Chercher cette ligne** :
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/> <!-- TEST -->
```

**Remplacer par votre vrai App ID AdMob** :
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/> <!-- PRODUCTION -->
```

---

### 7. Firebase google-services.json

**Fichier** : `/home/user/flutter_app/android/app/google-services.json`

⚠️ **IMPORTANT** : Si ce fichier contient des informations de test, remplacez-le par :
- Votre vrai fichier Firebase pour production
- Avec votre vrai nom de package Android
- Avec vos vraies clés API

**Comment l'obtenir** :
1. Firebase Console : https://console.firebase.google.com/
2. Sélectionnez votre projet
3. Project Settings → Téléchargez google-services.json
4. Remplacez le fichier existant

---

### 8. Package Name Android (Si pas déjà fait)

**Fichier** : `/home/user/flutter_app/android/app/build.gradle.kts`

**Vérifier** :
```kotlin
applicationId = "com.musclemaster.fitness" // Votre package unique
```

**Si vous voulez changer** :
- Choisir un package unique (ex: com.votrecompany.musclemaster)
- Mettre à jour dans :
  - `android/app/build.gradle.kts`
  - `android/app/src/main/AndroidManifest.xml`
  - `MainActivity.kt` (package + chemin fichier)
  - Firebase google-services.json

---

### 9. Clés API Gemini (IA)

**Fichier** : `/home/user/flutter_app/lib/services/gemini_service.dart`

**Vérifier que vous utilisez votre vraie clé API** :
```dart
static const String _apiKey = 'VOTRE_VRAIE_CLE_API_GEMINI';
```

**Comment obtenir la clé** :
1. Google AI Studio : https://makersuite.google.com/app/apikey
2. Créer une nouvelle clé API
3. Remplacer dans le code

---

### 10. In-App Purchase Product IDs

**Fichier** : `/home/user/flutter_app/lib/services/subscription_service.dart`

**Vérifier les Product IDs** :
```dart
static const String monthlySubscriptionId = 'muscle_master_monthly'; // À créer dans Play Console
static const String yearlySubscriptionId = 'muscle_master_yearly';   // À créer dans Play Console
```

**Comment les créer** :
1. Google Play Console
2. Votre app → Monétisation → Produits in-app
3. Créer des abonnements avec ces IDs exacts
4. Définir les prix : 6.99€/mois et 49.99€/an

---

## 🔐 SÉCURITÉ - INFORMATIONS À NE JAMAIS PUBLIER

Ces informations ne doivent JAMAIS être dans le code Git public :

❌ **Ne jamais commiter** :
- Clés API privées
- Tokens Firebase Admin
- Mots de passe
- Clés de signature APK
- Informations bancaires
- Données utilisateurs réelles

✅ **Utiliser à la place** :
- Variables d'environnement (fichier .env)
- Firebase Remote Config
- Secrets GitHub (si repository privé)
- Keystore sécurisé pour signature APK

---

## 📋 CHECKLIST AVANT PUBLICATION

### Configuration Application
- [ ] Email de contact mis à jour dans README.md
- [ ] Téléphone de contact ajouté (si souhaité)
- [ ] Email de contact mis à jour dans ProfileScreen
- [ ] Website URL ajoutée (quand disponible)

### Configuration AdMob
- [ ] Compte AdMob créé
- [ ] Application AdMob créée
- [ ] Banner Ad Unit ID obtenu et remplacé
- [ ] Interstitial Ad Unit ID obtenu et remplacé
- [ ] App ID AdMob remplacé dans AndroidManifest.xml

### Configuration Firebase
- [ ] Projet Firebase production créé
- [ ] google-services.json production téléchargé et remplacé
- [ ] Firestore Database créé
- [ ] Firebase Authentication configuré
- [ ] Règles de sécurité Firestore configurées

### Configuration In-App Purchase
- [ ] Compte Google Play Console créé
- [ ] Application créée sur Play Console
- [ ] Abonnement mensuel créé (6.99€)
- [ ] Abonnement annuel créé (49.99€)
- [ ] Product IDs vérifiés dans le code

### Configuration API & Clés
- [ ] Clé API Gemini production obtenue et remplacée
- [ ] Clés API Firebase vérifiées
- [ ] Toutes les clés de test remplacées par production

### Package & Signature
- [ ] Package name Android unique défini
- [ ] Keystore de signature APK créé
- [ ] key.properties configuré (ne pas commiter!)
- [ ] build.gradle configuré pour signature

### Documentation
- [ ] README.md informations de contact mises à jour
- [ ] License copyright année correcte (2025)
- [ ] Liens support et contact fonctionnels

---

## 🛠️ COMMANDES POUR EFFECTUER LES MODIFICATIONS

### 1. Mettre à jour l'email dans README.md
```bash
cd /home/user/flutter_app

# Ouvrir le fichier
nano README.md

# Chercher "contact@musclemaster.app" et remplacer
# Sauvegarder : Ctrl+O, Quitter : Ctrl+X
```

### 2. Vérifier les informations dans ProfileScreen
```bash
cd /home/user/flutter_app

# Rechercher les emails/téléphones hardcodés
grep -r "contact@" lib/screens/profile_screen.dart
grep -r "@musclemaster.app" lib/
grep -r "+33" lib/  # Si numéro de test
```

### 3. Mettre à jour AdMob IDs
```bash
cd /home/user/flutter_app

# Ouvrir le service AdMob
nano lib/services/ad_service.dart

# Remplacer les IDs de test par vos IDs production
```

### 4. Après modifications, commiter
```bash
cd /home/user/flutter_app

git add .
git commit -m "Config: Mise à jour informations de contact et IDs production

- Email de contact mis à jour
- Téléphone de contact ajouté (si applicable)
- AdMob IDs production configurés
- Firebase configuration production
- Clés API production configurées

Prêt pour build production"
```

---

## 📞 AIDE POUR OBTENIR LES INFORMATIONS

### Email Professionnel
**Options recommandées** :
- Email domaine : contact@votre-domaine.com
- Gmail pro : votre.nom@gmail.com
- Outlook : votre.nom@outlook.com

### Téléphone Support
**Options** :
- Téléphone personnel (si vous acceptez les appels users)
- Numéro professionnel dédié
- ❌ Laisser vide si vous ne voulez pas être appelé
- ✅ Email uniquement est acceptable

### Website
**Si vous n'avez pas encore de site** :
- Laisser "(à venir)" dans le README
- Créer une landing page simple plus tard
- Ou utiliser votre profil GitHub/LinkedIn

---

## ⏰ QUAND EFFECTUER CES MODIFICATIONS ?

**AVANT de :**
- ✅ Créer le build APK final
- ✅ Publier sur Google Play Store
- ✅ Rendre le repository GitHub public
- ✅ Partager l'app avec des utilisateurs réels

**ACCEPTABLE APRÈS :**
- ✅ Push initial vers GitHub privé
- ✅ Tests en développement
- ✅ Démos internes

---

## 💡 RECOMMANDATIONS

1. **Email professionnel** : Utilisez un email dédié pour l'app (ex: support@musclemaster.app)
2. **Domaine personnalisé** : Envisagez d'acheter musclemaster.app ou similar
3. **Support centralisé** : Créez une adresse email unique pour toutes les demandes
4. **Numéro pro** : Si vous publiez un numéro, utilisez un numéro professionnel dédié
5. **Privacy** : Ne publiez jamais votre numéro personnel dans une app publique

---

## 📄 FICHIERS À MODIFIER - RÉSUMÉ

| Fichier | Modification | Priorité |
|---------|--------------|----------|
| `README.md` | Email, téléphone, website | 🔴 Haute |
| `lib/screens/profile_screen.dart` | Infos contact in-app | 🔴 Haute |
| `lib/services/ad_service.dart` | AdMob IDs production | 🔴 Haute |
| `android/app/src/main/AndroidManifest.xml` | AdMob App ID | 🔴 Haute |
| `android/app/google-services.json` | Firebase production | 🔴 Haute |
| `lib/services/gemini_service.dart` | Clé API Gemini | 🔴 Haute |
| `lib/services/subscription_service.dart` | Product IDs (vérifier) | 🟡 Moyenne |
| `android/app/build.gradle.kts` | Package name (vérifier) | 🟡 Moyenne |

---

**💪 N'oubliez pas ces modifications avant la publication finale !**

*Ce document doit être consulté avant chaque build production et publication.*
