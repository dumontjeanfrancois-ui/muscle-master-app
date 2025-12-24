import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'one_rm_calculator_screen.dart';

class CalculatorsScreen extends StatefulWidget {
  final int initialTab;
  
  const CalculatorsScreen({super.key, this.initialTab = 0});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Calories Calculator
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _gender = 'Homme';
  String _activityLevel = 'Modéré';
  String _goal = 'Maintien';
  double? _caloriesResult;

  // Macros Calculator
  double? _macrosCalories;
  String _macrosGoal = 'Prise de masse';
  Map<String, double>? _macrosResult;

  // 1RM Calculator
  final TextEditingController _weightLiftedController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  double? _oneRMResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.calculate_rounded, color: AppTheme.neonBlue),
            const SizedBox(width: 12),
            Text(
              'CALCULATEURS',
              style: TextStyle(
                color: AppTheme.neonBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.neonBlue,
          labelColor: AppTheme.neonBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'CALORIES'),
            Tab(text: 'MACROS'),
            Tab(text: '1RM'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCaloriesCalculator(),
          _buildMacrosCalculator(),
          _build1RMCalculator(),
        ],
      ),
    );
  }

  // CALCULATEUR DE CALORIES
  Widget _buildCaloriesCalculator() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculez vos besoins caloriques quotidiens',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildTextField(
              controller: _weightController,
              label: 'Poids (kg)',
              icon: Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _heightController,
              label: 'Taille (cm)',
              icon: Icons.height_rounded,
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _ageController,
              label: 'Âge',
              icon: Icons.cake_outlined,
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Sexe'),
            _buildGenderSelector(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Niveau d\'activité'),
            _buildActivityLevelSelector(),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Objectif'),
            _buildGoalSelector(),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _calculateCalories,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonBlue,
                  foregroundColor: AppTheme.primaryDark,
                ),
                child: const Text('CALCULER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            if (_caloriesResult != null) ...[
              const SizedBox(height: 32),
              _buildResultCard(
                title: 'Vos besoins caloriques',
                value: '${_caloriesResult!.round()} kcal/jour',
                color: AppTheme.neonBlue,
                icon: Icons.local_fire_department,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _calculateCalories() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = double.tryParse(_ageController.text);

    if (weight == null || height == null || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: AppTheme.neonOrange),
      );
      return;
    }

    // Formule Mifflin-St Jeor
    double bmr;
    if (_gender == 'Homme') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Facteur d'activité
    double activityFactor;
    switch (_activityLevel) {
      case 'Sédentaire':
        activityFactor = 1.2;
        break;
      case 'Léger':
        activityFactor = 1.375;
        break;
      case 'Modéré':
        activityFactor = 1.55;
        break;
      case 'Intense':
        activityFactor = 1.725;
        break;
      case 'Très intense':
        activityFactor = 1.9;
        break;
      default:
        activityFactor = 1.55;
    }

    double tdee = bmr * activityFactor;

    // Ajuster selon l'objectif
    switch (_goal) {
      case 'Perte de poids':
        tdee *= 0.85; // -15%
        break;
      case 'Perte de poids rapide':
        tdee *= 0.75; // -25%
        break;
      case 'Prise de masse':
        tdee *= 1.15; // +15%
        break;
      case 'Prise de masse rapide':
        tdee *= 1.25; // +25%
        break;
    }

    setState(() {
      _caloriesResult = tdee;
    });
  }

  // CALCULATEUR DE MACROS
  Widget _buildMacrosCalculator() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Calculez la répartition de vos macronutriments',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 24),
            
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories totales par jour',
                hintText: 'Ex: 2500',
                prefixIcon: Icon(Icons.local_fire_department, color: AppTheme.neonOrange),
              ),
              onChanged: (value) {
                _macrosCalories = double.tryParse(value);
              },
            ),
            const SizedBox(height: 24),
            
            _buildSectionTitle('Objectif'),
            _buildMacrosGoalSelector(),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _calculateMacros,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: AppTheme.primaryDark,
                ),
                child: const Text('CALCULER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            if (_macrosResult != null) ...[
              const SizedBox(height: 32),
              _buildMacrosResultCards(),
            ],
          ],
        ),
      ),
    );
  }

  void _calculateMacros() {
    if (_macrosCalories == null || _macrosCalories! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Entrez vos calories quotidiennes'), backgroundColor: AppTheme.neonOrange),
      );
      return;
    }

    double proteinPercent, carbsPercent, fatsPercent;

    switch (_macrosGoal) {
      case 'Prise de masse':
        proteinPercent = 0.30; // 30%
        carbsPercent = 0.50;   // 50%
        fatsPercent = 0.20;    // 20%
        break;
      case 'Sèche/Définition':
        proteinPercent = 0.40; // 40%
        carbsPercent = 0.30;   // 30%
        fatsPercent = 0.30;    // 30%
        break;
      case 'Force':
        proteinPercent = 0.35; // 35%
        carbsPercent = 0.45;   // 45%
        fatsPercent = 0.20;    // 20%
        break;
      default:
        proteinPercent = 0.30;
        carbsPercent = 0.40;
        fatsPercent = 0.30;
    }

    final proteinCalories = _macrosCalories! * proteinPercent;
    final carbsCalories = _macrosCalories! * carbsPercent;
    final fatsCalories = _macrosCalories! * fatsPercent;

    setState(() {
      _macrosResult = {
        'proteinGrams': proteinCalories / 4, // 4 kcal/g
        'carbsGrams': carbsCalories / 4,      // 4 kcal/g
        'fatsGrams': fatsCalories / 9,        // 9 kcal/g
      };
    });
  }

  Widget _buildMacrosResultCards() {
    return Column(
      children: [
        _buildMacroCard(
          'Protéines',
          '${_macrosResult!['proteinGrams']!.round()}g',
          AppTheme.neonBlue,
          Icons.egg_outlined,
        ),
        const SizedBox(height: 12),
        _buildMacroCard(
          'Glucides',
          '${_macrosResult!['carbsGrams']!.round()}g',
          AppTheme.neonGreen,
          Icons.rice_bowl_outlined,
        ),
        const SizedBox(height: 12),
        _buildMacroCard(
          'Lipides',
          '${_macrosResult!['fatsGrams']!.round()}g',
          AppTheme.neonOrange,
          Icons.water_drop_outlined,
        ),
      ],
    );
  }

  Widget _buildMacroCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryDark, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CALCULATEUR 1RM - Redirect vers version complète
  Widget _build1RMCalculator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 80,
              color: AppTheme.neonOrange,
            ),
            const SizedBox(height: 24),
            Text(
              'CALCULATEUR 1RM COMPLET',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Calculez votre 1RM pour N\'IMPORTE QUEL exercice',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '✅ Tapez n\'importe quel exercice\n✅ Historique de vos 1RM\n✅ Table d\'entraînement détaillée',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OneRMCalculatorScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('OUVRIR LE CALCULATEUR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonOrange,
                  foregroundColor: AppTheme.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction temporairement désactivée
  // ignore: unused_element
  void _calculate1RM() {
    final weight = double.tryParse(_weightLiftedController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight == null || reps == null || reps < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: AppTheme.neonOrange),
      );
      return;
    }

    // Formule Epley
    final oneRM = weight * (1 + (reps / 30));

    setState(() {
      _oneRMResult = oneRM;
    });
  }

  // Widget temporairement désactivé
  // ignore: unused_element
  Widget _build1RMPercentagesTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonOrange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TABLE DE POURCENTAGES',
            style: TextStyle(
              color: AppTheme.neonOrange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...[ [95, 2], [90, 4], [85, 6], [80, 8], [75, 10], [70, 12]].map((data) {
            final percent = data[0];
            final suggestedReps = data[1];
            final weight = (_oneRMResult! * percent / 100).round();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$percent% - $suggestedReps reps',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  Text(
                    '$weight kg',
                    style: TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // WIDGETS HELPERS
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.neonBlue),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: AppTheme.neonBlue,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: ['Homme', 'Femme'].map((gender) {
        final isSelected = _gender == gender;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(gender),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _gender = gender;
                });
              },
              selectedColor: AppTheme.neonBlue,
              backgroundColor: AppTheme.cardDark,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActivityLevelSelector() {
    final levels = ['Sédentaire', 'Léger', 'Modéré', 'Intense', 'Très intense'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: levels.map((level) {
        final isSelected = _activityLevel == level;
        return FilterChip(
          label: Text(level),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _activityLevel = level;
            });
          },
          selectedColor: AppTheme.neonGreen,
          backgroundColor: AppTheme.cardDark,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalSelector() {
    final goals = ['Perte de poids rapide', 'Perte de poids', 'Maintien', 'Prise de masse', 'Prise de masse rapide'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goals.map((goal) {
        final isSelected = _goal == goal;
        return FilterChip(
          label: Text(goal),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _goal = goal;
            });
          },
          selectedColor: AppTheme.neonOrange,
          backgroundColor: AppTheme.cardDark,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMacrosGoalSelector() {
    final goals = ['Prise de masse', 'Sèche/Définition', 'Force', 'Équilibré'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goals.map((goal) {
        final isSelected = _macrosGoal == goal;
        return FilterChip(
          label: Text(goal),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _macrosGoal = goal;
            });
          },
          selectedColor: AppTheme.neonGreen,
          backgroundColor: AppTheme.cardDark,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _weightLiftedController.dispose();
    _repsController.dispose();
    super.dispose();
  }
}
