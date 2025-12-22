import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';
import '../data/default_data.dart';

class SmartRecipesScreen extends StatefulWidget {
  const SmartRecipesScreen({super.key});

  @override
  State<SmartRecipesScreen> createState() => _SmartRecipesScreenState();
}

class _SmartRecipesScreenState extends State<SmartRecipesScreen> {
  String _userGoal = 'Prise de muscle';
  String _selectedCategory = 'Tous';
  List<Map<String, dynamic>> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadUserGoal();
  }

  Future<void> _loadUserGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userGoal = prefs.getString('goal_main') ?? 'Prise de muscle';
      _filterRecipes();
    });
  }

  void _filterRecipes() {
    var recipes = DefaultData.recipes;
    
    // Filtrer par catégorie
    if (_selectedCategory != 'Tous') {
      recipes = recipes.where((r) => r['category'] == _selectedCategory).toList();
    }
    
    // Tri selon l'objectif utilisateur
    switch (_userGoal) {
      case 'Prise de muscle':
        recipes.sort((a, b) => (b['protein'] as int).compareTo(a['protein'] as int));
        break;
      case 'Perte de poids':
        recipes.sort((a, b) => (a['calories'] as int).compareTo(b['calories'] as int));
        break;
      case 'Endurance':
        recipes.sort((a, b) => (b['carbs'] as int).compareTo(a['carbs'] as int));
        break;
      default:
        break;
    }
    
    setState(() {
      _filteredRecipes = recipes;
    });
  }

  String _getRecommendationText() {
    switch (_userGoal) {
      case 'Prise de muscle':
        return '💪 Recettes riches en protéines pour votre objectif';
      case 'Perte de poids':
        return '🔥 Recettes faibles en calories pour votre objectif';
      case 'Endurance':
        return '⚡ Recettes riches en glucides pour votre objectif';
      case 'Force maximale':
        return '💥 Recettes équilibrées pour votre objectif';
      case 'Tonification':
        return '✨ Recettes modérées pour votre objectif';
      default:
        return '🍽️ Recettes recommandées';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECETTES PERSONNALISÉES'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner objectif
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.neonOrange.withOpacity(0.2),
                      AppTheme.neonGreen.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.neonOrange.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.neonOrange, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OBJECTIF: $_userGoal',
                            style: TextStyle(
                              color: AppTheme.neonOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getRecommendationText(),
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Catégories
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['Tous', 'Petit-déjeuner', 'Déjeuner', 'Dîner', 'Snack', 'Post-workout']
                      .map((category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory = category;
                                  _filterRecipes();
                                });
                              },
                              selectedColor: AppTheme.neonOrange,
                              backgroundColor: AppTheme.cardDark,
                              labelStyle: TextStyle(
                                color: _selectedCategory == category
                                    ? AppTheme.primaryDark
                                    : AppTheme.textPrimary,
                                fontWeight: _selectedCategory == category
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 20),
              
              // Liste des recettes
              ..._filteredRecipes.map((recipe) => _buildRecipeCard(recipe)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.neonOrange.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe['name'],
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neonOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department, size: 14, color: AppTheme.neonOrange),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe['calories']} kcal',
                        style: TextStyle(
                          color: AppTheme.neonOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recipe['description'],
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMacroChip(
                  icon: Icons.fitness_center,
                  label: 'Protéines',
                  value: '${recipe['protein']}g',
                  color: AppTheme.neonGreen,
                ),
                const SizedBox(width: 8),
                _buildMacroChip(
                  icon: Icons.energy_savings_leaf,
                  label: 'Glucides',
                  value: '${recipe['carbs']}g',
                  color: AppTheme.neonBlue,
                ),
                const SizedBox(width: 8),
                _buildMacroChip(
                  icon: Icons.opacity,
                  label: 'Lipides',
                  value: '${recipe['fats']}g',
                  color: AppTheme.neonPurple,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppTheme.textDisabled),
                const SizedBox(width: 6),
                Text(
                  '${recipe['prepTime']} min',
                  style: TextStyle(
                    color: AppTheme.textDisabled,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
