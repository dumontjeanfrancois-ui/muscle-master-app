import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/theme.dart';

class AdvancedMacroCalculatorScreen extends StatefulWidget {
  const AdvancedMacroCalculatorScreen({super.key});

  @override
  State<AdvancedMacroCalculatorScreen> createState() => _AdvancedMacroCalculatorScreenState();
}

class _AdvancedMacroCalculatorScreenState extends State<AdvancedMacroCalculatorScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _bodyFatController = TextEditingController();
  
  String _gender = 'Homme';
  String _activityLevel = 'Modéré';
  String _goal = 'Maintien';
  bool _useBodyFat = false;
  
  Map<String, dynamic>? _results;

  // Formule Mifflin-St Jeor (la plus précise)
  double _calculateBMR(double weight, double height, int age, String gender) {
    if (gender == 'Homme') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Formule Katch-McArdle (avec pourcentage de masse grasse)
  double _calculateBMRWithBodyFat(double weight, double bodyFatPercent) {
    double leanMass = weight * (1 - bodyFatPercent / 100);
    return 370 + (21.6 * leanMass);
  }

  // Facteurs d'activité précis
  double _getActivityFactor(String level) {
    switch (level) {
      case 'Sédentaire': return 1.2;
      case 'Léger': return 1.375;
      case 'Modéré': return 1.55;
      case 'Actif': return 1.725;
      case 'Très actif': return 1.9;
      default: return 1.55;
    }
  }

  void _calculate() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);
    final bodyFat = double.tryParse(_bodyFatController.text);

    if (weight == null || height == null || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    if (_useBodyFat && bodyFat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre pourcentage de masse grasse')),
      );
      return;
    }

    // Calcul du BMR
    double bmr;
    if (_useBodyFat && bodyFat != null) {
      bmr = _calculateBMRWithBodyFat(weight, bodyFat);
    } else {
      bmr = _calculateBMR(weight, height, age, _gender);
    }

    // TDEE (Total Daily Energy Expenditure)
    double tdee = bmr * _getActivityFactor(_activityLevel);

    // Ajustement selon l'objectif
    double targetCalories;
    double proteinRatio, carbsRatio, fatsRatio;

    switch (_goal) {
      case 'Perte de poids':
        targetCalories = tdee * 0.80; // -20%
        proteinRatio = 0.35; // 35% protéines (préserver muscle)
        carbsRatio = 0.35;   // 35% glucides
        fatsRatio = 0.30;    // 30% lipides
        break;
      case 'Perte de poids rapide':
        targetCalories = tdee * 0.70; // -30%
        proteinRatio = 0.40; // 40% protéines (préserver muscle)
        carbsRatio = 0.30;   // 30% glucides
        fatsRatio = 0.30;    // 30% lipides
        break;
      case 'Prise de masse':
        targetCalories = tdee * 1.15; // +15%
        proteinRatio = 0.30; // 30% protéines
        carbsRatio = 0.45;   // 45% glucides (énergie)
        fatsRatio = 0.25;    // 25% lipides
        break;
      case 'Prise de masse rapide':
        targetCalories = tdee * 1.25; // +25%
        proteinRatio = 0.25; // 25% protéines
        carbsRatio = 0.50;   // 50% glucides (énergie)
        fatsRatio = 0.25;    // 25% lipides
        break;
      case 'Sèche/Définition':
        targetCalories = tdee * 0.85; // -15%
        proteinRatio = 0.40; // 40% protéines (préserver muscle max)
        carbsRatio = 0.30;   // 30% glucides (bas)
        fatsRatio = 0.30;    // 30% lipides
        break;
      default: // Maintien
        targetCalories = tdee;
        proteinRatio = 0.30;
        carbsRatio = 0.40;
        fatsRatio = 0.30;
    }

    // Calcul des macros en grammes
    double proteinGrams = (targetCalories * proteinRatio) / 4; // 4 cal/g
    double carbsGrams = (targetCalories * carbsRatio) / 4;     // 4 cal/g
    double fatsGrams = (targetCalories * fatsRatio) / 9;       // 9 cal/g

    // Recommandations par repas (5 repas par jour)
    int mealsPerDay = 5;
    double caloriesPerMeal = targetCalories / mealsPerDay;
    double proteinPerMeal = proteinGrams / mealsPerDay;
    double carbsPerMeal = carbsGrams / mealsPerDay;
    double fatsPerMeal = fatsGrams / mealsPerDay;

    setState(() {
      _results = {
        'bmr': bmr,
        'tdee': tdee,
        'targetCalories': targetCalories,
        'proteinGrams': proteinGrams,
        'carbsGrams': carbsGrams,
        'fatsGrams': fatsGrams,
        'proteinPercent': proteinRatio * 100,
        'carbsPercent': carbsRatio * 100,
        'fatsPercent': fatsRatio * 100,
        'caloriesPerMeal': caloriesPerMeal,
        'proteinPerMeal': proteinPerMeal,
        'carbsPerMeal': carbsPerMeal,
        'fatsPerMeal': fatsPerMeal,
        'mealsPerDay': mealsPerDay,
      };
    });

    _saveResults();
  }

  Future<void> _saveResults() async {
    if (_results != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('macro_results', jsonEncode(_results));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CALCUL MACROS PRÉCIS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info méthode
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonBlue.withOpacity(0.2),
                    AppTheme.neonPurple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonBlue.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, color: AppTheme.neonBlue),
                      const SizedBox(width: 8),
                      Text(
                        'MÉTHODE ULTRA-PRÉCISE',
                        style: TextStyle(
                          color: AppTheme.neonBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '✓ Formule Mifflin-St Jeor (la plus précise)\n'
                    '✓ Formule Katch-McArdle (avec % masse grasse)\n'
                    '✓ Ajustement selon composition corporelle\n'
                    '✓ Répartition optimale des macros par objectif',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Informations de base
            Text(
              'INFORMATIONS DE BASE',
              style: TextStyle(
                color: AppTheme.neonPurple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            // Sexe
            _buildSectionLabel('Sexe'),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Homme'),
                    value: 'Homme',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Femme'),
                    value: 'Femme',
                    groupValue: _gender,
                    onChanged: (value) => setState(() => _gender = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Poids
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'POIDS (kg)',
                hintText: 'Ex: 75',
                prefixIcon: Icon(Icons.monitor_weight, color: AppTheme.neonGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Taille
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'TAILLE (cm)',
                hintText: 'Ex: 175',
                prefixIcon: Icon(Icons.height, color: AppTheme.neonGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Âge
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'ÂGE',
                hintText: 'Ex: 25',
                prefixIcon: Icon(Icons.cake, color: AppTheme.neonGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Option masse grasse
            SwitchListTile(
              title: Text(
                'Utiliser le % de masse grasse (plus précis)',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              subtitle: Text(
                'Active la formule Katch-McArdle',
                style: TextStyle(color: AppTheme.textDisabled, fontSize: 12),
              ),
              value: _useBodyFat,
              onChanged: (value) => setState(() => _useBodyFat = value),
            ),

            if (_useBodyFat) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _bodyFatController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '% MASSE GRASSE',
                  hintText: 'Ex: 15',
                  prefixIcon: Icon(Icons.percent, color: AppTheme.neonOrange),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  helperText: 'Homme: 10-20% athlétique | Femme: 18-28%',
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Niveau d'activité
            _buildSectionLabel('Niveau d\'activité'),
            _buildDropdown(
              value: _activityLevel,
              items: ['Sédentaire', 'Léger', 'Modéré', 'Actif', 'Très actif'],
              onChanged: (value) => setState(() => _activityLevel = value!),
            ),
            const SizedBox(height: 8),
            _buildActivityInfo(),
            const SizedBox(height: 24),

            // Objectif
            _buildSectionLabel('Objectif'),
            _buildDropdown(
              value: _goal,
              items: [
                'Perte de poids rapide',
                'Perte de poids',
                'Maintien',
                'Prise de masse',
                'Prise de masse rapide',
                'Sèche/Définition',
              ],
              onChanged: (value) => setState(() => _goal = value!),
            ),
            const SizedBox(height: 32),

            // Bouton calcul
            ElevatedButton(
              onPressed: _calculate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'CALCULER MES MACROS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Résultats
            if (_results != null) ...[
              const SizedBox(height: 32),
              _buildResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.textDisabled),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildActivityInfo() {
    Map<String, String> info = {
      'Sédentaire': 'Travail de bureau, peu d\'exercice',
      'Léger': '1-3 séances/semaine',
      'Modéré': '3-5 séances/semaine',
      'Actif': '6-7 séances/semaine',
      'Très actif': 'Athlète professionnel, 2 séances/jour',
    };
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        info[_activityLevel] ?? '',
        style: TextStyle(color: AppTheme.textDisabled, fontSize: 12),
      ),
    );
  }

  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'VOS RÉSULTATS',
          style: TextStyle(
            color: AppTheme.neonGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Calories cibles
        _buildResultCard(
          title: 'CALORIES QUOTIDIENNES',
          value: '${_results!['targetCalories'].round()} kcal',
          subtitle: 'BMR: ${_results!['bmr'].round()} | TDEE: ${_results!['tdee'].round()}',
          color: AppTheme.neonGreen,
        ),
        const SizedBox(height: 16),

        // Macros
        Row(
          children: [
            Expanded(child: _buildMacroCard('PROTÉINES', _results!['proteinGrams'], _results!['proteinPercent'], AppTheme.neonBlue)),
            const SizedBox(width: 12),
            Expanded(child: _buildMacroCard('GLUCIDES', _results!['carbsGrams'], _results!['carbsPercent'], AppTheme.neonOrange)),
            const SizedBox(width: 12),
            Expanded(child: _buildMacroCard('LIPIDES', _results!['fatsGrams'], _results!['fatsPercent'], AppTheme.neonPurple)),
          ],
        ),
        const SizedBox(height: 24),

        // Par repas
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PAR REPAS (${_results!['mealsPerDay']} repas/jour)',
                style: TextStyle(
                  color: AppTheme.neonBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildMealMacro('Calories', _results!['caloriesPerMeal'], 'kcal'),
              _buildMealMacro('Protéines', _results!['proteinPerMeal'], 'g'),
              _buildMealMacro('Glucides', _results!['carbsPerMeal'], 'g'),
              _buildMealMacro('Lipides', _results!['fatsPerMeal'], 'g'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: AppTheme.textPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMacroCard(String label, double grams, double percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${grams.round()}g', style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${percent.round()}%', style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMealMacro(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text('${value.round()} $unit', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
