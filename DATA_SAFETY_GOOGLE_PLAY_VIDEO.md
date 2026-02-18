# 📊 DATA SAFETY DECLARATION - GOOGLE PLAY CONSOLE (MISE À JOUR VIDÉO)

## 🎯 MUSCLE MASTER - Déclaration de Sécurité des Données (Version 3.1 - Enregistrement Vidéo)

**⚠️ MISE À JOUR MAJEURE** : Ajout de l'enregistrement vidéo pendant les séances

Document à remplir dans **Google Play Console** → **App content** → **Data safety**

---

## ⚠️ NOUVEAUTÉS VERSION 3.1

### 🎥 Enregistrement Vidéo des Exercices
- **Fonctionnalité** : Bouton REC pendant les séances
- **But** : Enregistrer les exercices pour analyser la technique
- **Stockage** : Local sur l'appareil (pas d'upload automatique)
- **Permissions** : CAMERA, RECORD_AUDIO, STORAGE

---

## 1. COLLECTE DE DONNÉES

### Question: "Does your app collect or share any of the required user data types?"
**Réponse: OUI** ✅

---

## 2. TYPES DE DONNÉES COLLECTÉES

### 📧 **Personal Information**
- ✅ **Email address**
  - **Collected**: Yes
  - **Shared**: No
  - **Ephemeral**: No
  - **Required**: Yes (pour créer un compte)
  - **Purpose**: 
    - App functionality (authentification)
    - Account management

- ✅ **User IDs**
  - **Collected**: Yes (Firebase UID)
  - **Shared**: No
  - **Ephemeral**: No
  - **Required**: Yes
  - **Purpose**:
    - App functionality
    - Account management

### 💪 **Health and Fitness**
- ✅ **Fitness info**
  - **Collected**: Yes (séances, charges, RM, progression)
  - **Shared**: No
  - **Ephemeral**: No
  - **Required**: Optional (l'utilisateur choisit de logger)
  - **Purpose**:
    - App functionality (suivi d'entraînement)
    - Personalization

- ✅ **Health info**
  - **Collected**: Yes (données nutritionnelles: macros, calories)
  - **Shared**: No
  - **Ephemeral**: No
  - **Required**: Optional
  - **Purpose**:
    - App functionality (suivi nutritionnel)
    - Personalization

### 🎥 **Photos and Videos** ⭐ CORRECTION IMPORTANTE
- ❌ **Photos**
  - **Collected**: **NO** (pas collectées par nos serveurs)
  - **Shared**: No
  - **Ephemeral**: N/A
  - **Required**: N/A
  - **Purpose**: N/A

- ❌ **Videos**
  - **Collected**: **NO** (stockage LOCAL uniquement sur l'appareil)
  - **Shared**: No (jamais transmises à nos serveurs)
  - **Ephemeral**: N/A (stockage local, pas de collecte serveur)
  - **Required**: Optional (fonctionnalité optionnelle)
  - **Purpose**: N/A (pas de collecte serveur)

**⚠️ CLARIFICATION IMPORTANTE:**
Les vidéos enregistrées pendant les séances d'entraînement sont stockées **UNIQUEMENT** sur l'appareil de l'utilisateur. Elles ne sont **JAMAIS** uploadées vers nos serveurs Firebase ou tout autre service cloud. L'application accède à la caméra et au stockage local, mais aucune vidéo n'est transmise en dehors de l'appareil sauf si l'utilisateur choisit explicitement de partager via les réseaux sociaux (partage géré par Android, pas par notre app).

**Pourquoi déclarer "NO" :**
- Google Play exige de déclarer "Collected: Yes" uniquement si les données sont **transmises hors de l'appareil**
- Nos vidéos restent 100% locales
- L'utilisateur a le contrôle total (supprimer, partager manuellement)
- Pas de collecte, stockage ou traitement côté serveur

### 🎤 **Audio** ⭐ CORRECTION IMPORTANTE
- ❌ **Audio or sound recordings**
  - **Collected**: **NO** (stockage LOCAL uniquement)
  - **Shared**: No (jamais transmis à nos serveurs)
  - **Ephemeral**: N/A (stockage local)
  - **Required**: Optional
  - **Purpose**: N/A (pas de collecte serveur)

**⚠️ CLARIFICATION:**
L'audio est enregistré localement avec les vidéos mais **jamais transmis** à nos serveurs. Stockage 100% local sur l'appareil.

### 📱 **App Activity**
- ✅ **App interactions**
  - **Collected**: Yes (via Firebase Analytics)
  - **Shared**: No
  - **Ephemeral**: Yes (14 mois max)
  - **Required**: No (collecté automatiquement)
  - **Purpose**:
    - Analytics
    - Personalization
    - App functionality improvement

### 🐛 **App Info and Performance**
- ✅ **Crash logs**
  - **Collected**: Yes (via Firebase Crashlytics)
  - **Shared**: No
  - **Ephemeral**: Yes (90 jours)
  - **Required**: No (collecté automatiquement)
  - **Purpose**:
    - App functionality (correction des bugs)

- ✅ **Diagnostics**
  - **Collected**: Yes (via Firebase Performance)
  - **Shared**: No
  - **Ephemeral**: Yes
  - **Required**: No
  - **Purpose**:
    - App functionality (optimisation performances)

### 📲 **Device or Other IDs**
- ✅ **Device or other IDs**
  - **Collected**: Yes (Firebase Installation ID)
  - **Shared**: No
  - **Ephemeral**: Yes
  - **Required**: No (généré automatiquement)
  - **Purpose**:
    - Analytics
    - App functionality

### 📂 **Files and Docs** ⭐ NOUVEAU
- ✅ **Files and docs**
  - **Collected**: Yes (vidéos d'entraînement stockées localement)
  - **Shared**: No (sauf partage manuel utilisateur)
  - **Ephemeral**: No
  - **Required**: Optional
  - **Purpose**:
    - App functionality (stockage vidéos)

---

## 3. SÉCURITÉ DES DONNÉES

### Question: "Is all of the user data collected by your app encrypted in transit?"
**Réponse: OUI** ✅
- TLS/HTTPS pour toutes les communications réseau
- Firebase utilise SSL/TLS
- **Vidéos stockées localement** : Pas de transmission réseau automatique

### Question: "Do you provide a way for users to request that their data is deleted?"
**Réponse: OUI** ✅
- In-app: Profil → Paramètres → Supprimer mon compte
- URL publique: https://musclemaster.app/delete-account
- **Vidéos** : Supprimables individuellement dans l'écran "Mes Vidéos"

---

## 4. PARTAGE DES DONNÉES

### Question: "Does your app share any of the required user data types with third parties?"
**Réponse: NON** ❌

**⚠️ IMPORTANT** :
- Muscle Master ne partage PAS automatiquement les vidéos
- L'utilisateur peut **manuellement** partager via Share Plus (réseaux sociaux)
- Cela ne compte PAS comme "partage avec des tiers" selon Google
- Firebase (Google) est utilisé uniquement pour l'hébergement backend
- **Les vidéos ne sont PAS uploadées sur Firebase** - stockage local uniquement

---

## 5. JUSTIFICATION DES PERMISSIONS

### CAMERA
- **Pourquoi** : Enregistrer les exercices pendant les séances
- **Optionnel** : Oui, l'utilisateur peut refuser
- **Alternative** : App fonctionne sans enregistrement vidéo

### RECORD_AUDIO
- **Pourquoi** : Audio synchronisé avec vidéo pour analyse respiration
- **Optionnel** : Oui, refusable
- **Alternative** : Vidéo sans son possible

### WRITE_EXTERNAL_STORAGE
- **Pourquoi** : Sauvegarder vidéos localement
- **Optionnel** : Oui, refusable
- **Alternative** : Pas de sauvegarde vidéo

### READ_EXTERNAL_STORAGE
- **Pourquoi** : Accéder aux vidéos sauvegardées
- **Optionnel** : Oui
- **Alternative** : Pas d'accès aux vidéos

---

## 6. DATA SAFETY SUMMARY (MISE À JOUR)

### Données Collectées:
| Type | Collecté | Partagé | Optionnel | But Principal |
|------|----------|---------|-----------|---------------|
| Email | ✅ | ❌ | ❌ | Authentification |
| User ID | ✅ | ❌ | ❌ | Gestion compte |
| Fitness Data | ✅ | ❌ | ✅ | Suivi entraînement |
| Nutrition Data | ✅ | ❌ | ✅ | Suivi nutritionnel |
| **Vidéos** ⭐ | **✅** | **❌** | **✅** | **Analyse technique** |
| **Audio** ⭐ | **✅** | **❌** | **✅** | **Analyse respiration** |
| App Interactions | ✅ | ❌ | ❌ | Analytics |
| Crash Logs | ✅ | ❌ | ❌ | Correction bugs |
| Device IDs | ✅ | ❌ | ❌ | Analytics |

### Sécurité:
- ✅ Chiffrement en transit (TLS/HTTPS)
- ✅ Vidéos stockées localement (pas d'upload automatique)
- ✅ Suppression de compte disponible
- ✅ Suppression individuelle des vidéos
- ✅ Politique de confidentialité publiée
- ✅ Données stockées sur Firebase (certifié ISO 27001)

### Conformité:
- ✅ RGPD compliant
- ✅ Aucune vente de données
- ✅ Aucun tracking publicitaire
- ✅ Transparence totale
- ✅ Permissions optionnelles

---

## 7. DÉCLARATION TEXTUELLE (RÉSUMÉ COURT) - MISE À JOUR

**Pour la section "Privacy policy"** :

```
Muscle Master collecte des données pour permettre le fonctionnement de l'application:

DONNÉES COLLECTÉES:
• Email et ID utilisateur (authentification)
• Données d'entraînement (séances, charges, progression)
• Données nutritionnelles (journal alimentaire, macros)
• Vidéos d'exercices (enregistrement optionnel pendant séances) ⭐ NOUVEAU
• Audio (synchronisé avec vidéos d'exercices) ⭐ NOUVEAU
• Analytics (utilisation de l'app, via Firebase)
• Diagnostics (crash reports, performances)

UTILISATION:
• Sauvegarder vos programmes et progrès
• Enregistrer vos exercices pour analyser votre technique ⭐
• Personnaliser votre expérience
• Améliorer l'application

STOCKAGE VIDÉOS:
• Vidéos stockées LOCALEMENT sur votre appareil ⭐
• Aucun upload automatique vers nos serveurs
• Vous contrôlez le partage de vos vidéos

SÉCURITÉ:
• Chiffrement HTTPS/TLS
• Données stockées sur Firebase (Google Cloud)
• Vidéos uniquement locales (pas de cloud)
• Suppression de compte disponible in-app
• Suppression individuelle des vidéos possible
• Aucune vente ou partage avec des tiers

PERMISSIONS:
• Caméra: Enregistrer vos exercices (OPTIONNEL)
• Microphone: Audio des vidéos (OPTIONNEL)
• Stockage: Sauvegarder vidéos localement (OPTIONNEL)
• L'app fonctionne sans ces permissions

SUPPRESSION:
Profil → Paramètres → Supprimer mon compte
ou https://musclemaster.app/delete-account

Politique complète: https://musclemaster.app/privacy
```

---

## 8. CHECKLIST GOOGLE PLAY CONSOLE (MISE À JOUR)

### Avant de soumettre l'app:
- [ ] Data Safety form rempli complètement
- [ ] **NOUVEAU**: Photos/Videos déclaré ✅
- [ ] **NOUVEAU**: Audio déclaré ✅
- [ ] Privacy Policy URL ajoutée
- [ ] Delete Account URL ajoutée
- [ ] **Toutes les permissions justifiées** (CAMERA, MICROPHONE, STORAGE)
- [ ] Screenshots mis à jour (montrer fonction REC)
- [ ] Description de l'app ajustée (mentionner enregistrement vidéo)
- [ ] Catégorie: Health & Fitness
- [ ] Target audience: Adultes 18+

---

## 9. URLS À FOURNIR

### Privacy Policy:
```
https://musclemaster.app/privacy
```

### Delete Account:
```
https://musclemaster.app/delete-account
```

### Support:
```
support@musclemaster.app
```

---

## 10. QUESTIONS FRÉQUENTES (MISE À JOUR)

### "Dois-je déclarer l'enregistrement vidéo?"
**OUI** - Même si les vidéos sont stockées localement, vous devez déclarer la collecte de vidéos/audio.

### "Les vidéos sont partagées avec des tiers?"
**NON** - Les vidéos restent locales. Si l'utilisateur partage manuellement (via Share Plus), ce n'est PAS considéré comme un partage automatique avec des tiers.

### "Dois-je cocher 'Optional'?"
**OUI** - Les permissions CAMERA/MICROPHONE sont optionnelles. L'app fonctionne sans.

### "Que dire sur les permissions CAMERA/MICROPHONE?"
Justifier clairement :
- **CAMERA** : "Enregistrer les exercices pour analyse technique"
- **MICROPHONE** : "Audio synchronisé pour analyse respiration"
- **STORAGE** : "Sauvegarder les vidéos d'entraînement localement"

---

## 11. WORDING IMPORTANT (MISE À JOUR)

### ❌ NE PAS UTILISER:
- "Nous analysons vos vidéos automatiquement" (si non implémenté)
- "Vos vidéos sont sauvegardées dans le cloud"
- "Partage automatique avec coach"

### ✅ À UTILISER:
- "Enregistrez vos exercices pour améliorer votre technique"
- "Vidéos stockées localement sur votre appareil"
- "Vous contrôlez le partage de vos vidéos"
- "Permissions optionnelles - l'app fonctionne sans"
- "Analysez votre forme et progression visuellement"

---

**✅ COMPLETION STATUS**: Document de déclaration complet avec enregistrement vidéo
**⏱️ TEMPS ESTIMÉ**: 20-25 minutes pour remplir le formulaire Data Safety mis à jour
**🔗 LIENS REQUIS**: privacy.html et delete-account.html (déjà créés)
**📹 NOUVEAUTÉ**: Déclaration vidéo/audio complète et conforme

---

## 12. CHANGEMENTS PAR RAPPORT À LA VERSION PRÉCÉDENTE

### Ajouts:
- ✅ Photos/Videos data type
- ✅ Audio data type
- ✅ Files and docs data type
- ✅ Justification permissions CAMERA/MICROPHONE/STORAGE
- ✅ Précisions sur le stockage local
- ✅ Clarifications sur le partage manuel vs automatique

### Reste inchangé:
- Email, User ID
- Health & Fitness data
- Analytics, Crash logs
- Sécurité TLS/HTTPS
- Suppression de compte

---

**Date de mise à jour** : 20 Janvier 2026
**Version** : 3.1 (Enregistrement Vidéo)
**Compatibilité** : Google Play Store Data Safety 2024
