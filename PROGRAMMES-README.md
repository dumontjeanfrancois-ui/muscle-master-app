# 📦 PROGRAMMES D'EXEMPLE MUSCLE MASTER

## 🎯 FICHIERS DISPONIBLES

### 1️⃣ **Programme-Force-Puissance.json**
- **Niveau** : Intermédiaire / Avancé
- **Durée** : 4 semaines
- **Séances** : 4 par semaine
- **Objectif** : Développer la force maximale et la puissance explosive
- **Contenu** : 
  - Séance 1 : Poussée Supérieure (Développé Couché, Dips, etc.)
  - Séance 2 : Tirage Supérieur (Tractions, Rowing, etc.)
  - Séance 3 : Jambes Force (Squat, Soulevé de Terre, etc.)
  - Séance 4 : Explosivité & Accessoires (Power Clean, Box Jump, etc.)

### 2️⃣ **Programme-Debutant-FullBody.json**
- **Niveau** : Débutant
- **Durée** : 8 semaines
- **Séances** : 3 par semaine
- **Objectif** : Apprendre les mouvements de base et construire une base solide
- **Contenu** : 
  - Full Body A : Squat, Développé Couché, Rowing, etc.
  - Full Body B : Soulevé de Terre, Développé Incliné, Tractions, etc.
  - Full Body C : Presse à Cuisses, Pompes, Tirage Horizontal, etc.

---

## 📲 COMMENT IMPORTER UN PROGRAMME DANS MUSCLE MASTER

### **MÉTHODE 1 : VIA SMARTPHONE (RECOMMANDÉ)**

#### **Étape 1 : Télécharger le fichier JSON**
1. Sur votre smartphone, ouvrez ce lien :
   ```
   https://github.com/dumontjeanfrancois-ui/muscle-master-app/tree/main
   ```
2. Cliquez sur le fichier JSON que vous voulez (ex: `Programme-Force-Puissance.json`)
3. Cliquez sur le bouton **"Raw"** (en haut à droite)
4. **Sélectionnez tout le texte** (appui long → Sélectionner tout)
5. **Copiez** le texte (Ctrl+C ou bouton Copier)

#### **Étape 2 : Importer dans l'application**
1. Ouvrez **Muscle Master** sur votre smartphone
2. Allez dans **"Programmes"** → **"Import/Export"**
3. **Collez** le JSON dans le grand champ de texte
4. Cliquez sur **"IMPORTER"**
5. ✅ **C'est fait !** Le programme apparaît dans votre liste

---

### **MÉTHODE 2 : VIA ORDINATEUR**

#### **Étape 1 : Télécharger le fichier**
1. Sur votre PC, allez sur GitHub :
   ```
   https://github.com/dumontjeanfrancois-ui/muscle-master-app/tree/main
   ```
2. Cliquez sur le fichier JSON (ex: `Programme-Debutant-FullBody.json`)
3. Cliquez sur **"Download raw file"** ou **"Raw"** puis Ctrl+S pour sauvegarder

#### **Étape 2 : Envoyer vers smartphone**
**Option A - Via Email** :
- Envoyez-vous le fichier par email
- Sur smartphone, ouvrez l'email et téléchargez la pièce jointe
- Ouvrez le fichier avec un éditeur de texte
- Copiez tout le contenu

**Option B - Via Drive** :
- Uploadez le fichier sur Google Drive
- Sur smartphone, ouvrez Drive et téléchargez le fichier
- Ouvrez avec un éditeur de texte
- Copiez tout le contenu

**Option C - Via USB** :
- Connectez smartphone à PC via USB
- Copiez le fichier JSON dans "Download" du téléphone
- Sur smartphone, ouvrez "Mes fichiers" → "Download"
- Ouvrez le fichier avec un éditeur de texte
- Copiez tout le contenu

#### **Étape 3 : Importer dans l'app**
1. Ouvrez **Muscle Master**
2. **Programmes** → **Import/Export**
3. Collez le JSON
4. Cliquez **"IMPORTER"**
5. ✅ **Terminé !**

---

## 🎓 TUTORIEL VIDÉO (À VENIR)

Nous préparons un tutoriel vidéo pour vous montrer exactement comment importer un programme. En attendant, suivez les instructions ci-dessus.

---

## ❓ QUESTIONS FRÉQUENTES

### **Q1 : Le JSON est trop long, comment faire ?**
**R :** Pas de problème ! Le champ de texte peut contenir plusieurs milliers de caractères. Assurez-vous juste de copier **TOUT** le contenu du fichier JSON, du premier `{` au dernier `}`.

### **Q2 : J'ai une erreur "Format invalide"**
**R :** Vérifiez que vous avez copié **tout** le JSON, y compris les accolades `{` et `}`. Ne modifiez pas le contenu du JSON.

### **Q3 : Puis-je modifier le programme après import ?**
**R :** Oui ! Une fois importé, le programme apparaît dans votre liste et vous pouvez le modifier comme n'importe quel programme personnalisé.

### **Q4 : Puis-je créer mes propres programmes JSON ?**
**R :** Oui ! Créez un programme dans l'app, puis exportez-le pour voir la structure JSON. Vous pouvez ensuite créer vos propres fichiers JSON en suivant le même format.

### **Q5 : Où trouver plus de programmes ?**
**R :** Consultez régulièrement notre GitHub ou rejoignez la communauté Muscle Master sur les réseaux sociaux pour découvrir de nouveaux programmes créés par la communauté !

---

## 📋 STRUCTURE D'UN PROGRAMME JSON

Voici la structure de base d'un programme JSON :

```json
{
  "name": "Nom du Programme",
  "description": "Description du programme",
  "difficulty": "Débutant / Intermédiaire / Avancé",
  "duration": "4 semaines",
  "sessionsPerWeek": 4,
  "createdBy": "Nom du créateur",
  "version": "1.0",
  "weeks": [
    {
      "weekNumber": 1,
      "focus": "Objectif de la semaine",
      "sessions": [
        {
          "day": "Lundi",
          "sessionName": "Nom de la séance",
          "duration": "60 min",
          "exercises": [
            {
              "name": "Nom de l'exercice",
              "category": "Force / Hypertrophie / Endurance",
              "muscleGroup": "Groupe musculaire",
              "sets": 4,
              "reps": "8-10",
              "rest": "2 min",
              "notes": "Notes importantes",
              "tips": "Conseils d'exécution"
            }
          ]
        }
      ]
    }
  ],
  "nutritionGuidelines": {
    "calories": "Recommandation calorique",
    "protein": "Apport protéines",
    "carbs": "Apport glucides",
    "fats": "Apport lipides"
  },
  "tips": [
    "Conseil 1",
    "Conseil 2"
  ]
}
```

---

## 🤝 PARTAGER VOS PROGRAMMES

Vous avez créé un programme génial ? Partagez-le avec la communauté !

1. Dans l'app, allez dans **Import/Export**
2. Sélectionnez votre programme
3. Cliquez sur **"COPIER JSON"** ou **"PARTAGER"**
4. Envoyez le JSON à vos amis ou postez-le sur les réseaux sociaux avec #MuscleMaster

---

## 📧 SUPPORT

Besoin d'aide ? Contactez-nous :
- **Email** : support@musclemaster.app
- **GitHub** : https://github.com/dumontjeanfrancois-ui/muscle-master-app
- **Issues** : https://github.com/dumontjeanfrancois-ui/muscle-master-app/issues

---

## 🎉 PROFITEZ DE VOS ENTRAÎNEMENTS !

Ces programmes ont été conçus par des experts en musculation pour vous aider à atteindre vos objectifs. Suivez-les consciencieusement et les résultats viendront ! 💪

**Muscle Master - Votre succès fitness commence ici !**
