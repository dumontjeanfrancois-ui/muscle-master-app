import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/ai_program_generator.dart';
import 'ai_program_detail_screen.dart';
import 'free_prompt_ai_program_screen.dart';

class AIProgramCreatorScreen extends StatefulWidget {
  const AIProgramCreatorScreen({super.key});

  @override
  State<AIProgramCreatorScreen> createState() => _AIProgramCreatorScreenState();
}

class _AIProgramCreatorScreenState extends State<AIProgramCreatorScreen> {
  String _selectedLevel = 'Intermédiaire';
  String _selectedGoal = 'Hypertrophie';
  int _sessionsPerWeek = 4;
  int _sessionDuration = 60;
  final Set<String> _selectedEquipment = {'Haltères', 'Barre', 'Poids de corps'};
  final TextEditingController _injuriesController = TextEditingController();
  bool _isGenerating = false;

  final List<String> _levels = ['Débutant', 'Intermédiaire', 'Avancé'];
  final List<String> _goals = ['Force', 'Hypertrophie', 'Endurance', 'Perte de poids'];
  final List<String> _equipment = [
    'Haltères',
    'Barre',
    'Poids de corps',
    'Machine',
    'Élastiques',
    'Kettlebell',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppTheme.neonPurple),
            const SizedBox(width: 12),
            Text(
              'CRÉER PROGRAMME IA',
              style: TextStyle(
                color: AppTheme.neonPurple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FreePromptAIProgramScreen()),
              );
            },
            icon: Icon(Icons.chat_bubble_outline, color: AppTheme.neonGreen),
            tooltip: 'Mode Prompt Libre',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Votre niveau'),
              _buildLevelSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Votre objectif'),
              _buildGoalSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Fréquence d\'entraînement'),
              _buildFrequencySlider(),
              const SizedBox(height: 24),
              _buildSectionTitle('Durée des séances'),
              _buildDurationSlider(),
              const SizedBox(height: 24),
              _buildSectionTitle('Équipement disponible'),
              _buildEquipmentSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Limitations (optionnel)'),
              _buildInjuriesField(),
              const SizedBox(height: 32),
              _buildGenerateButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.neonPurple.withOpacity(0.2),
                AppTheme.neonBlue.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.neonPurple.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.neonPurple, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'L\'IA va créer un programme 100% personnalisé selon vos critères 💪',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: AppTheme.neonPurple.withOpacity(0.3)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: AppTheme.neonGreen, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Préférez décrire en langage naturel ? Utilisez le mode Prompt Libre (icône en haut à droite)',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: AppTheme.neonPurple,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildLevelSelector() {
    return Wrap(
      spacing: 12,
      children: _levels.map((level) {
        final isSelected = _selectedLevel == level;
        return FilterChip(
          label: Text(level),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedLevel = level;
            });
          },
          selectedColor: AppTheme.neonPurple,
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
    return Wrap(
      spacing: 12,
      children: _goals.map((goal) {
        final isSelected = _selectedGoal == goal;
        return FilterChip(
          label: Text(goal),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedGoal = goal;
            });
          },
          selectedColor: AppTheme.neonBlue,
          backgroundColor: AppTheme.cardDark,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencySlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_sessionsPerWeek séances par semaine',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_sessionsPerWeek',
                style: TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: _sessionsPerWeek.toDouble(),
          min: 2,
          max: 6,
          divisions: 4,
          activeColor: AppTheme.neonGreen,
          inactiveColor: AppTheme.cardDark,
          onChanged: (value) {
            setState(() {
              _sessionsPerWeek = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDurationSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_sessionDuration minutes par séance',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neonOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_sessionDuration}min',
                style: TextStyle(
                  color: AppTheme.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: _sessionDuration.toDouble(),
          min: 30,
          max: 120,
          divisions: 9,
          activeColor: AppTheme.neonOrange,
          inactiveColor: AppTheme.cardDark,
          onChanged: (value) {
            setState(() {
              _sessionDuration = value.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildEquipmentSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _equipment.map((equip) {
        final isSelected = _selectedEquipment.contains(equip);
        return FilterChip(
          label: Text(equip),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedEquipment.add(equip);
              } else {
                _selectedEquipment.remove(equip);
              }
            });
          },
          selectedColor: AppTheme.neonBlue,
          backgroundColor: AppTheme.cardDark,
          checkmarkColor: AppTheme.primaryDark,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInjuriesField() {
    return TextField(
      controller: _injuriesController,
      decoration: InputDecoration(
        hintText: 'Ex: Douleur au genou gauche, éviter squat lourd',
        filled: true,
        fillColor: AppTheme.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.textDisabled),
        ),
      ),
      maxLines: 2,
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateProgram,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.neonPurple,
          foregroundColor: AppTheme.primaryDark,
          disabledBackgroundColor: AppTheme.textDisabled,
        ),
        child: _isGenerating
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('IA EN TRAIN DE CRÉER...'),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome_rounded, size: 24),
                  SizedBox(width: 12),
                  Text('GÉNÉRER MON PROGRAMME'),
                ],
              ),
      ),
    );
  }

  Future<void> _generateProgram() async {
    if (_selectedEquipment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sélectionnez au moins un équipement'),
          backgroundColor: AppTheme.neonOrange,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    final result = await AIProgramGenerator.generateProgram(
      level: _selectedLevel,
      goal: _selectedGoal,
      sessionsPerWeek: _sessionsPerWeek,
      sessionDuration: _sessionDuration,
      availableEquipment: _selectedEquipment.toList(),
      injuries: _injuriesController.text.trim().isEmpty ? null : _injuriesController.text.trim(),
    );

    setState(() {
      _isGenerating = false;
    });

    if (result['success']) {
      // Naviguer vers la page de détail du programme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AIProgramDetailScreen(program: result['program']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur génération'),
          backgroundColor: AppTheme.neonOrange,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _injuriesController.dispose();
    super.dispose();
  }
}
