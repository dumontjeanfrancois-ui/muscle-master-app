import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../services/subscription_service.dart';
import '../widgets/premium_feature_guard.dart';
import 'paywall_screen.dart';

class AIChefScreen extends StatefulWidget {
  const AIChefScreen({super.key});

  @override
  State<AIChefScreen> createState() => _AIChefScreenState();
}

class _AIChefScreenState extends State<AIChefScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, dynamic>> _generatedRecipes = [];
  final List<Map<String, dynamic>> _savedRecipes = [];
  bool _isGenerating = false;
  String _userGoal = 'Prise de muscle';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userGoal = prefs.getString('goal_main') ?? 'Prise de muscle';
      final savedRecipesJson = prefs.getString('ai_chef_recipes');
      if (savedRecipesJson != null) {
        final List<dynamic> decoded = jsonDecode(savedRecipesJson);
        _savedRecipes.addAll(decoded.cast<Map<String, dynamic>>());
      }
    });
  }

  Future<void> _generateRecipe() async {
    if (_promptController.text.isEmpty) return;

    // Vérifier si l'utilisateur est premium
    final subscriptionService = Provider.of<SubscriptionService>(context, listen: false);
    if (!subscriptionService.isPremium) {
      // Afficher le paywall
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaywallScreen(
              feature: 'IA Chef - Génération de recettes personnalisées',
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    // Simulation génération IA (dans une vraie app, appeler API Gemini)
    await Future.delayed(const Duration(seconds: 3));

    final prompt = _promptController.text;
    final recipe = _createRecipeFromPrompt(prompt);

    setState(() {
      _generatedRecipes.insert(0, recipe);
      _isGenerating = false;
      _promptController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Recette générée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Map<String, dynamic> _createRecipeFromPrompt(String prompt) {
    // Génération intelligente basée sur le prompt et l'objectif
    final id = 'ai_rec_${DateTime.now().millisecondsSinceEpoch}';
    
    // Analyse du prompt pour adapter les macros
    int calories = 450;
    double protein = 35;
    double carbs = 45;
    double fats = 12;
    
    if (_userGoal == 'Perte de poids') {
      calories = 350;
      protein = 30;
      carbs = 30;
      fats = 10;
    } else if (_userGoal == 'Prise de muscle') {
      calories = 550;
      protein = 45;
      carbs = 55;
      fats = 15;
    } else if (_userGoal == 'Endurance') {
      calories = 500;
      protein = 25;
      carbs = 70;
      fats = 12;
    }

    return {
      'id': id,
      'name': 'Recette IA: ${prompt.substring(0, prompt.length > 30 ? 30 : prompt.length)}...',
      'description': 'Recette créée par l\'IA Chef selon votre demande: "$prompt"',
      'category': 'Personnalisé',
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'prepTime': 20,
      'ingredients': [
        '200g de protéines (poulet, poisson, ou tofu)',
        '150g de glucides complexes (riz, quinoa, patate douce)',
        'Légumes variés (brocoli, épinards, tomates)',
        'Huile d\'olive (1 cuillère à soupe)',
        'Épices et herbes au goût',
        'Sel et poivre',
      ],
      'instructions': [
        '1. PRÉPARATION DES INGRÉDIENTS',
        '   - Laver et couper tous les légumes',
        '   - Préchauffer le four à 180°C si nécessaire',
        '   - Sortir les protéines du réfrigérateur',
        '',
        '2. CUISSON DES PROTÉINES',
        '   - Assaisonner les protéines avec sel, poivre et épices',
        '   - Cuire dans une poêle ou au four pendant 15-20 minutes',
        '   - Vérifier la cuisson à cœur',
        '',
        '3. PRÉPARATION DES GLUCIDES',
        '   - Faire cuire le riz/quinoa selon les instructions',
        '   - Ou cuire les patates douces 25-30 minutes au four',
        '',
        '4. CUISSON DES LÉGUMES',
        '   - Faire revenir les légumes dans un peu d\'huile',
        '   - Assaisonner avec herbes et épices',
        '   - Cuire 5-8 minutes pour garder le croquant',
        '',
        '5. ASSEMBLAGE ET PRÉSENTATION',
        '   - Disposer harmonieusement dans l\'assiette',
        '   - Protéines + Glucides + Légumes',
        '   - Ajouter un filet d\'huile d\'olive',
        '   - Garnir avec herbes fraîches',
        '',
        '💡 CONSEIL DU CHEF:',
        '   Préparez vos ingrédients avant de commencer (mise en place).',
        '   Vous pouvez adapter les quantités selon vos besoins caloriques.',
      ],
      'tips': [
        'Adaptez les portions selon votre objectif calorique',
        'Variez les sources de protéines chaque jour',
        'Privilégiez les cuissons vapeur ou four pour limiter les graisses',
        'Préparez en batch pour la semaine',
      ],
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _saveRecipe(Map<String, dynamic> recipe) async {
    setState(() {
      _savedRecipes.insert(0, recipe);
      _generatedRecipes.remove(recipe);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_chef_recipes', jsonEncode(_savedRecipes));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Recette sauvegardée !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteRecipe(Map<String, dynamic> recipe, bool isSaved) async {
    setState(() {
      if (isSaved) {
        _savedRecipes.remove(recipe);
      } else {
        _generatedRecipes.remove(recipe);
      }
    });

    if (isSaved) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('ai_chef_recipes', jsonEncode(_savedRecipes));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Recette supprimée')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IA CHEF CUISINIER'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner IA Chef
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonOrange.withOpacity(0.2),
                    AppTheme.neonPurple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonOrange.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Icon(Icons.restaurant_menu, color: AppTheme.neonOrange, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'CHEF IA PERSONNEL',
                    style: TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Décrivez ce que vous voulez manger, le Chef IA crée la recette parfaite adaptée à votre objectif: $_userGoal',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Zone de génération
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ex: Un plat asiatique avec du poulet et des légumes\nEx: Une recette post-workout riche en protéines\nEx: Un petit-déjeuner énergétique pour ma séance',
                prefixIcon: Icon(Icons.chat_bubble, color: AppTheme.neonPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.neonOrange, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateRecipe,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isGenerating ? 'CRÉATION EN COURS...' : 'GÉNÉRER LA RECETTE',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonOrange,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            // Exemples de prompts
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildExampleChip('🍗 Poulet grillé protéiné'),
                _buildExampleChip('🥗 Salade complète équilibrée'),
                _buildExampleChip('🍝 Pâtes post-workout'),
                _buildExampleChip('🥞 Pancakes fitness'),
              ],
            ),

            if (_generatedRecipes.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'RECETTES GÉNÉRÉES',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ..._generatedRecipes.map((recipe) => _buildRecipeCard(recipe, false)),
            ],

            if (_savedRecipes.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'MES RECETTES SAUVEGARDÉES',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ..._savedRecipes.map((recipe) => _buildRecipeCard(recipe, true)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _promptController.text = text.substring(2); // Remove emoji
      },
      backgroundColor: AppTheme.cardDark,
      labelStyle: TextStyle(color: AppTheme.textPrimary, fontSize: 12),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, bool isSaved) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSaved ? AppTheme.neonGreen.withOpacity(0.3) : AppTheme.neonOrange.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showRecipeDetails(recipe),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isSaved ? Icons.bookmark : Icons.auto_awesome,
                    color: isSaved ? AppTheme.neonGreen : AppTheme.neonOrange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recipe['name'],
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!isSaved)
                    IconButton(
                      icon: Icon(Icons.bookmark_add, color: AppTheme.neonGreen),
                      onPressed: () => _saveRecipe(recipe),
                      tooltip: 'Sauvegarder',
                    ),
                  IconButton(
                    icon: Icon(Icons.delete, color: AppTheme.neonRed),
                    onPressed: () => _deleteRecipe(recipe, isSaved),
                    tooltip: 'Supprimer',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMacroTag('${recipe['calories']} kcal', AppTheme.neonOrange),
                  const SizedBox(width: 8),
                  _buildMacroTag('${recipe['protein']}g P', AppTheme.neonGreen),
                  const SizedBox(width: 8),
                  _buildMacroTag('${recipe['carbs']}g G', AppTheme.neonBlue),
                  const SizedBox(width: 8),
                  _buildMacroTag('${recipe['fats']}g L', AppTheme.neonPurple),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showRecipeDetails(Map<String, dynamic> recipe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.restaurant_menu, color: AppTheme.neonOrange, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      recipe['name'],
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                recipe['description'],
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              
              // Macros
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroDetail('${recipe['calories']}', 'kcal', AppTheme.neonOrange),
                  _buildMacroDetail('${recipe['protein']}g', 'Protéines', AppTheme.neonGreen),
                  _buildMacroDetail('${recipe['carbs']}g', 'Glucides', AppTheme.neonBlue),
                  _buildMacroDetail('${recipe['fats']}g', 'Lipides', AppTheme.neonPurple),
                ],
              ),
              const SizedBox(height: 32),
              
              // Ingrédients
              Text(
                'INGRÉDIENTS',
                style: TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ...List<String>.from(recipe['ingredients']).map((ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 16),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              
              // Instructions
              Text(
                'INSTRUCTIONS',
                style: TextStyle(
                  color: AppTheme.neonBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ...List<String>.from(recipe['instructions']).map((instruction) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      instruction,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  )),
              
              if (recipe['tips'] != null) ...[
                const SizedBox(height: 24),
                Text(
                  '💡 CONSEILS DU CHEF',
                  style: TextStyle(
                    color: AppTheme.neonPurple,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ...List<String>.from(recipe['tips']).map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb, color: AppTheme.neonPurple, size: 16),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroDetail(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
