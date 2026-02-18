import 'package:flutter/material.dart';
import '../utils/theme.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final prepTime = recipe['prepTimeMinutes'] as int;
    final cookTime = recipe['cookTimeMinutes'] as int? ?? 0;
    final totalTime = prepTime + cookTime;
    final ingredients = recipe['ingredients'] as List<dynamic>;
    final instructions = recipe['instructions'] as List<dynamic>;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header avec nom de la recette
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                recipe['name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.neonOrange.withValues(alpha: 0.3),
                      AppTheme.neonBlue.withValues(alpha: 0.3),
                      AppTheme.primaryDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: AppTheme.neonOrange.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          
          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge catégorie + calories
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.neonOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.neonOrange),
                        ),
                        child: Text(
                          recipe['category'],
                          style: TextStyle(
                            color: AppTheme.neonOrange,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.neonOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.local_fire_department, size: 16, color: AppTheme.neonOrange),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe['calories']} kcal',
                              style: TextStyle(
                                color: AppTheme.neonOrange,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    recipe['description'],
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Informations temps
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.neonGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTimeInfo(
                          icon: Icons.kitchen,
                          label: 'Préparation',
                          time: '$prepTime min',
                          color: AppTheme.neonBlue,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.textSecondary.withValues(alpha: 0.3),
                        ),
                        if (cookTime > 0) ...[
                          _buildTimeInfo(
                            icon: Icons.whatshot,
                            label: 'Cuisson',
                            time: '$cookTime min',
                            color: AppTheme.neonOrange,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppTheme.textSecondary.withValues(alpha: 0.3),
                          ),
                        ],
                        _buildTimeInfo(
                          icon: Icons.access_time,
                          label: 'Total',
                          time: '$totalTime min',
                          color: AppTheme.neonGreen,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Macros
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.neonPurple.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VALEURS NUTRITIONNELLES',
                          style: TextStyle(
                            color: AppTheme.neonPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMacroInfo(
                              label: 'Protéines',
                              value: '${recipe['protein']}g',
                              color: AppTheme.neonBlue,
                            ),
                            _buildMacroInfo(
                              label: 'Glucides',
                              value: '${recipe['carbs']}g',
                              color: AppTheme.neonGreen,
                            ),
                            _buildMacroInfo(
                              label: 'Lipides',
                              value: '${recipe['fats']}g',
                              color: AppTheme.neonOrange,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Ingrédients
                  Text(
                    'INGRÉDIENTS',
                    style: TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.neonOrange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: ingredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: AppTheme.neonOrange,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ingredient.toString(),
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Instructions
                  Text(
                    'INSTRUCTIONS',
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...instructions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final instruction = entry.value.toString();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.neonGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.neonGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: AppTheme.primaryDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              instruction,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroInfo({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
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
}
