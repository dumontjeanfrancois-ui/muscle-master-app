# 📊 DATA SAFETY DECLARATION - GOOGLE PLAY CONSOLE

## 🎯 MUSCLE MASTER - Déclaration de Sécurité des Données

Document à remplir dans **Google Play Console** → **App content** → **Data safety**

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

---

## 3. SÉCURITÉ DES DONNÉES

### Question: "Is all of the user data collected by your app encrypted in transit?"
**Réponse: OUI** ✅
- TLS/HTTPS pour toutes les communications
- Firebase utilise SSL/TLS

### Question: "Do you provide a way for users to request that their data is deleted?"
**Réponse: OUI** ✅
- In-app: Profil → Paramètres → Supprimer mon compte
- URL publique: https://musclemaster.app/delete-account

---

## 4. PARTAGE DES DONNÉES

### Question: "Does your app share any of the required user data types with third parties?"
**Réponse: NON** ❌
- Muscle Master ne partage PAS de données avec des tiers
- Firebase (Google) est utilisé uniquement pour l'hébergement backend
- Aucun partenaire publicitaire ne reçoit de données personnelles

---

## 5. DATA SAFETY SUMMARY

### Données Collectées:
| Type | Collecté | Partagé | Optionnel | But Principal |
|------|----------|---------|-----------|---------------|
| Email | ✅ | ❌ | ❌ | Authentification |
| User ID | ✅ | ❌ | ❌ | Gestion compte |
| Fitness Data | ✅ | ❌ | ✅ | Suivi entraînement |
| Nutrition Data | ✅ | ❌ | ✅ | Suivi nutritionnel |
| App Interactions | ✅ | ❌ | ❌ | Analytics |
| Crash Logs | ✅ | ❌ | ❌ | Correction bugs |
| Device IDs | ✅ | ❌ | ❌ | Analytics |

### Sécurité:
- ✅ Chiffrement en transit (TLS/HTTPS)
- ✅ Suppression de compte disponible
- ✅ Politique de confidentialité publiée
- ✅ Données stockées sur Firebase (certifié ISO 27001)

### Conformité:
- ✅ RGPD compliant
- ✅ Aucune vente de données
- ✅ Aucun tracking publicitaire
- ✅ Transparence totale

---

## 6. DÉCLARATION TEXTUELLE (RÉSUMÉ COURT)

**Pour la section "Privacy policy"** :

```
Muscle Master collecte des données pour permettre le fonctionnement de l'application:

DONNÉES COLLECTÉES:
• Email et ID utilisateur (authentification)
• Données d'entraînement (séances, charges, progression)
• Données nutritionnelles (journal alimentaire, macros)
• Analytics (utilisation de l'app, via Firebase)
• Diagnostics (crash reports, performances)

UTILISATION:
• Sauvegarder vos programmes et progrès
• Personnaliser votre expérience
• Améliorer l'application

SÉCURITÉ:
• Chiffrement HTTPS/TLS
• Données stockées sur Firebase (Google Cloud)
• Suppression de compte disponible in-app
• Aucune vente ou partage avec des tiers

SUPPRESSION:
Profil → Paramètres → Supprimer mon compte
ou https://musclemaster.app/delete-account

Politique complète: https://musclemaster.app/privacy
```

---

## 7. CHECKLIST GOOGLE PLAY CONSOLE

### Avant de soumettre l'app:
- [ ] Data Safety form rempli complètement
- [ ] Privacy Policy URL ajoutée
- [ ] Delete Account URL ajoutée
- [ ] Toutes les permissions justifiées
- [ ] Screenshots mis à jour
- [ ] Description de l'app ajustée (pas de claims santé exagérés)
- [ ] Catégorie: Health & Fitness
- [ ] Target audience: Adultes 18+

---

## 8. URLS À FOURNIR

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

## 9. QUESTIONS FRÉQUENTES

### "Dois-je déclarer Firebase Analytics?"
**OUI** - Firebase Analytics collecte automatiquement des données, même si vous ne l'utilisez pas explicitement.

### "Dois-je cocher 'Shared with third parties'?"
**NON** - Firebase est votre backend, pas un tiers. Les données ne sont pas vendues ou partagées commercialement.

### "Que signifie 'Ephemeral'?"
Données temporaires supprimées automatiquement après un délai (ex: analytics 14 mois, crashlytics 90 jours).

### "Dois-je déclarer AdMob?"
**OUI si utilisé** - Si vous affichez des pub AdMob, cochez "Advertising or marketing" dans les purposes.

---

## 10. WORDING IMPORTANT

### ❌ NE PAS UTILISER:
- "Résultats garantis"
- "Scientifiquement prouvé"
- "Perte de poids assurée"
- "Sans risque médical"
- Claims santé non vérifiés

### ✅ À UTILISER:
- "Aide à structurer votre entraînement"
- "Suivi personnalisé de votre progression"
- "Outil de planification fitness"
- "Consultez un professionnel de santé avant tout programme"

---

**✅ COMPLETION STATUS**: Document de déclaration complet, prêt pour Google Play Console
**⏱️ TEMPS ESTIMÉ**: 15-20 minutes pour remplir le formulaire Data Safety
**🔗 LIENS REQUIS**: Assurez-vous que privacy.html et delete-account.html sont accessibles en production
