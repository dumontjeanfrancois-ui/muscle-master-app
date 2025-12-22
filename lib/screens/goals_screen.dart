import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  String _mainGoal = 'Prise de muscle';
  String _experienceLevel = 'Intermédiaire';
  int _weeklyWorkouts = 4;
  String _targetArea = 'Corps complet';
  bool _hasInjury = false;
  final TextEditingController _injuryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mainGoal = prefs.getString('goal_main') ?? 'Prise de muscle';
      _experienceLevel = prefs.getString('goal_experience') ?? 'Intermédiaire';
      _weeklyWorkouts = prefs.getInt('goal_weekly_workouts') ?? 4;
      _targetArea = prefs.getString('goal_target_area') ?? 'Corps complet';
      _hasInjury = prefs.getBool('goal_has_injury') ?? false;
      _injuryController.text = prefs.getString('goal_injury_description') ?? '';
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('goal_main', _mainGoal);
    await prefs.setString('goal_experience', _experienceLevel);
    await prefs.setInt('goal_weekly_workouts', _weeklyWorkouts);
    await prefs.setString('goal_target_area', _targetArea);
    await prefs.setBool('goal_has_injury', _hasInjury);
    await prefs.setString('goal_injury_description', _injuryController.text);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Objectifs sauvegardés'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MES OBJECTIFS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection(
              title: 'OBJECTIF PRINCIPAL',
              icon: Icons.flag,
              color: AppTheme.neonGreen,
              child: _buildGoalSelector(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'NIVEAU D\'EXPÉRIENCE',
              icon: Icons.trending_up,
              color: AppTheme.neonBlue,
              child: _buildExperienceSelector(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'FRÉQUENCE D\'ENTRAÎNEMENT',
              icon: Icons.calendar_today,
              color: AppTheme.neonOrange,
              child: _buildFrequencySelector(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'ZONE CIBLÉE',
              icon: Icons.fitness_center,
              color: AppTheme.neonPurple,
              child: _buildTargetAreaSelector(),
            ),
            const SizedBox(height: 24),
            _buildInjurySection(),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveGoals,
                icon: const Icon(Icons.save),
                label: const Text(
                  'SAUVEGARDER',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildGoalSelector() {
    final goals = [
      'Prise de muscle',
      'Perte de poids',
      'Force maximale',
      'Endurance',
      'Tonification',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goals.map((goal) {
        final isSelected = _mainGoal == goal;
        return ChoiceChip(
          label: Text(goal),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _mainGoal = goal;
            });
          },
          selectedColor: AppTheme.neonGreen.withOpacity(0.3),
          backgroundColor: AppTheme.cardDark,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.neonGreen : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExperienceSelector() {
    final levels = ['Débutant', 'Intermédiaire', 'Avancé', 'Expert'];

    return Column(
      children: levels.map((level) {
        final isSelected = _experienceLevel == level;
        return RadioListTile<String>(
          value: level,
          groupValue: _experienceLevel,
          onChanged: (value) {
            setState(() {
              _experienceLevel = value!;
            });
          },
          title: Text(
            level,
            style: TextStyle(
              color: isSelected ? AppTheme.neonBlue : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          activeColor: AppTheme.neonBlue,
          tileColor: AppTheme.cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonOrange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$_weeklyWorkouts séances par semaine',
            style: TextStyle(
              color: AppTheme.neonOrange,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: _weeklyWorkouts.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: '$_weeklyWorkouts',
            activeColor: AppTheme.neonOrange,
            onChanged: (value) {
              setState(() {
                _weeklyWorkouts = value.round();
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: TextStyle(color: AppTheme.textSecondary)),
              Text('7', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAreaSelector() {
    final areas = [
      'Corps complet',
      'Haut du corps',
      'Bas du corps',
      'Bras',
      'Jambes',
      'Dos',
      'Pectoraux',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: areas.map((area) {
        final isSelected = _targetArea == area;
        return ChoiceChip(
          label: Text(area),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _targetArea = area;
            });
          },
          selectedColor: AppTheme.neonPurple.withOpacity(0.3),
          backgroundColor: AppTheme.cardDark,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.neonPurple : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInjurySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasInjury 
              ? AppTheme.neonRed.withOpacity(0.3)
              : AppTheme.textDisabled.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            value: _hasInjury,
            onChanged: (value) {
              setState(() {
                _hasInjury = value;
              });
            },
            title: Text(
              'Blessure ou limitation physique',
              style: TextStyle(
                color: _hasInjury ? AppTheme.neonRed : AppTheme.textPrimary,
                fontWeight: _hasInjury ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            activeColor: AppTheme.neonRed,
            contentPadding: EdgeInsets.zero,
          ),
          if (_hasInjury) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _injuryController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Décrivez votre blessure ou limitation...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.textDisabled),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.textDisabled.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.neonRed, width: 2),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _injuryController.dispose();
    super.dispose();
  }
}
