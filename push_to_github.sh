#!/bin/bash
# 🚀 Script de Push GitHub - Muscle Master
# Exécuter après avoir autorisé GitHub dans le sandbox

echo "🚀 MUSCLE MASTER - Push vers GitHub"
echo "===================================="
echo ""

# Vérifier si on est dans le bon dossier
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis /home/user/flutter_app"
    exit 1
fi

# Afficher l'état Git actuel
echo "📊 État Git actuel:"
git status --short
echo ""

# Demander le nom d'utilisateur GitHub
read -p "📝 Entrez votre nom d'utilisateur GitHub: " github_username

if [ -z "$github_username" ]; then
    echo "❌ Nom d'utilisateur requis"
    exit 1
fi

# Construire l'URL du repository
REPO_URL="https://github.com/$github_username/muscle-master-app.git"

echo ""
echo "🔗 URL du repository: $REPO_URL"
echo ""

# Vérifier si le remote existe déjà
if git remote | grep -q "origin"; then
    echo "⚠️  Remote 'origin' existe déjà"
    read -p "Voulez-vous le remplacer? (y/N): " replace_remote
    if [ "$replace_remote" = "y" ] || [ "$replace_remote" = "Y" ]; then
        echo "🔄 Suppression de l'ancien remote..."
        git remote remove origin
        echo "➕ Ajout du nouveau remote..."
        git remote add origin "$REPO_URL"
    else
        echo "✅ Conservation du remote existant"
    fi
else
    echo "➕ Ajout du remote origin..."
    git remote add origin "$REPO_URL"
fi

echo ""
echo "📤 Affichage des commits à pousser:"
git log --oneline -5
echo ""

# Demander confirmation
read -p "🚀 Pousser le code vers GitHub? (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "❌ Push annulé"
    exit 0
fi

echo ""
echo "🚀 Push en cours..."
echo ""

# Pousser le code
if git push -u origin main; then
    echo ""
    echo "✅ ============================================"
    echo "✅ PUSH RÉUSSI !"
    echo "✅ ============================================"
    echo ""
    echo "🔗 Visitez votre repository:"
    echo "   https://github.com/$github_username/muscle-master-app"
    echo ""
    echo "📊 Commits poussés:"
    echo "   - Monétisation complète (Freemium + In-App + AdMob)"
    echo "   - Corrections erreurs compilation"
    echo "   - Guide GitHub complet"
    echo "   - README.md professionnel"
    echo "   - Synthèse finale du projet"
    echo ""
    echo "🎯 Prochaines étapes:"
    echo "   1. Vérifier les fichiers sur GitHub"
    echo "   2. Configurer GitHub Actions (optionnel)"
    echo "   3. Préparer le build APK"
    echo ""
else
    echo ""
    echo "❌ ============================================"
    echo "❌ ERREUR LORS DU PUSH"
    echo "❌ ============================================"
    echo ""
    echo "🔍 Vérifications à faire:"
    echo "   1. GitHub est-il autorisé dans le sandbox?"
    echo "   2. Le repository existe-t-il sur GitHub?"
    echo "   3. Avez-vous les droits d'accès?"
    echo ""
    echo "📖 Consultez le guide détaillé:"
    echo "   cat docs/GITHUB_SETUP_GUIDE.md"
    echo ""
    exit 1
fi
