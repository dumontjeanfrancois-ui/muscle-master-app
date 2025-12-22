import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../data/default_data.dart';
import 'calculators_screen.dart';
import 'advanced_macro_calculator_screen.dart';
import 'smart_recipes_screen.dart';
import 'ai_chef_screen.dart';
import 'ai_photo_analysis_screen.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NUTRITION',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.neonOrange,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alimentez vos muscles correctement',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    indicatorColor: AppTheme.neonOrange,
                    labelColor: AppTheme.neonOrange,
                    unselectedLabelColor: AppTheme.textSecondary,
                    tabs: const [
                      Tab(text: 'RECETTES'),
                      Tab(text: 'CALCULATEURS'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildRecipesTab(context),
                  _buildCalculatorsTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipesTab(BuildContext context) {
    final categories = ['Tous', 'Petit-déjeuner', 'Déjeuner', 'Dîner', 'Snack', 'Post-workout'];
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Boutons IA Chef, Recettes Personnalisées et Photo Calories
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AIChefScreen()),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('IA CHEF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonOrange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SmartRecipesScreen()),
                      );
                    },
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('PERSONNALISÉES'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.neonGreen,
                      side: BorderSide(color: AppTheme.neonGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bouton Photo Calories IA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AIPhotoAnalysisScreen()),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('📸 PHOTO CALORIES IA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(categories[index]),
                      selected: index == 0,
                      onSelected: (selected) {},
                      selectedColor: AppTheme.neonOrange,
                      backgroundColor: AppTheme.cardDark,
                      labelStyle: TextStyle(
                        color: index == 0 ? AppTheme.primaryDark : AppTheme.textPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ...DefaultData.recipes.take(10).map((recipe) => _buildRecipeCard(recipe)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonOrange.withOpacity(0.3),
          width: 1,
        ),
      ),
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
          const SizedBox(height: 8),
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
              _buildMacroChip('P: ${recipe['protein']}g', AppTheme.neonBlue),
              const SizedBox(width: 8),
              _buildMacroChip('G: ${recipe['carbs']}g', AppTheme.neonGreen),
              const SizedBox(width: 8),
              _buildMacroChip('L: ${recipe['fats']}g', AppTheme.neonOrange),
              const Spacer(),
              Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${recipe['prepTimeMinutes']} min',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
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

  Widget _buildCalculatorsTab(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Calculateur Macros AVANCÉ (en premier - recommandé)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonPurple.withOpacity(0.3),
                    AppTheme.neonBlue.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonPurple, width: 2),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvancedMacroCalculatorScreen(),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.science, color: AppTheme.neonPurple, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MACROS ULTRA-PRÉCIS',
                                style: TextStyle(
                                  color: AppTheme.neonPurple,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Formules Mifflin-St Jeor + Katch-McArdle',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'RECOMMANDÉ',
                            style: TextStyle(
                              color: AppTheme.primaryDark,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '✓ Calcul BMR & TDEE scientifique\n'
                      '✓ Option masse grasse (±5% précision)\n'
                      '✓ Répartition optimale par objectif\n'
                      '✓ Détails par repas (5 repas/jour)',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Calculateurs simples
            _buildCalculatorCard(
              context,
              'Calculateur de Calories',
              'Calculez votre besoin calorique quotidien',
              Icons.calculate_rounded,
              AppTheme.neonBlue,
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              'Calculateur de Macros',
              'Répartition protéines, glucides, lipides',
              Icons.pie_chart_rounded,
              AppTheme.neonGreen,
            ),
            const SizedBox(height: 16),
            _buildCalculatorCard(
              context,
              'Calculateur 1RM',
              'Calculez votre force maximale',
              Icons.fitness_center_rounded,
              AppTheme.neonOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    int tabIndex = 0;
    if (title.contains('Macros')) tabIndex = 1;
    if (title.contains('1RM')) tabIndex = 2;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalculatorsScreen(initialTab: tabIndex),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }
}
