import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/ai_program_generator.dart';
import 'ai_program_detail_screen.dart';

class AIProgramGeneratorScreen extends StatefulWidget {
  const AIProgramGeneratorScreen({super.key});

  @override
  State<AIProgramGeneratorScreen> createState() => _AIProgramGeneratorScreenState();
}

class _AIProgramGeneratorScreenState extends State<AIProgramGeneratorScreen> {
  String _level = 'Intermédiaire';
  String _goal = 'Hypertrophie';
  int _sessionsPerWeek = 4;
  int _sessionDuration = 60;
  final Set<String> _equipment = {'Barre', 'Haltères', 'Machine'};
  final TextEditingController _injuriesController = TextEditingController();
  final TextEditingController _customPromptController = TextEditingController();
  
  bool _isGenerating = false;
  bool _useCustomPrompt = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppTheme.neonPurple),
            const SizedBox(width: 12),
            Text(
              'GÉNÉRATEUR IA',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.neonPurple,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neonPurple.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.neonPurple.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.neonPurple, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'L\'IA va créer un programme 100% personnalisé selon votre profil',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Toggle Mode
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.neonBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mode prompt libre',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: _useCustomPrompt,
                    onChanged: (value) {
                      setState(() {
                        _useCustomPrompt = value;
                      });
                    },
                    activeColor: AppTheme.neonBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Custom Prompt Field (si activé)
            if (_useCustomPrompt) ...[
              _buildSection('Décrivez votre programme', [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.neonGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: AppTheme.neonGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'EXEMPLES DE PROMPTS',
                            style: TextStyle(
                              color: AppTheme.neonGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '• "Programme Hyrox 4x semaine"\n'
                        '• "Hybride padel + musculation 3x semaine"\n'
                        '• "Préparation marathon avec renforcement"\n'
                        '• "CrossFit débutant sans équipement"',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _customPromptController,
                  maxLines: 5,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Ex: Programme hybride padel + musculation 3x semaine, focus endurance et explosivité...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.neonBlue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.neonBlue,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 32),
            ],

            // Formulaire détaillé (si mode standard)
            if (!_useCustomPrompt) ...[
              // Niveau
              _buildSection('Votre Niveau', [
                _buildLevelSelector(),
              ]),
              const SizedBox(height: 24),
            ],
            
            // Objectif
            _buildSection('Votre Objectif', [
              _buildGoalSelector(),
            ]),
            const SizedBox(height: 24),
            
            // Fréquence
            _buildSection('Fréquence d\'entraînement', [
              _buildFrequencySlider(),
            ]),
            const SizedBox(height: 24),
            
            // Durée
            _buildSection('Durée des séances', [
              _buildDurationSlider(),
            ]),
            const SizedBox(height: 24),
            
            // Équipement
            _buildSection('Équipement disponible', [
              _buildEquipmentSelector(),
            ]),
            const SizedBox(height: 24),
            
            // Blessures/Limitations
            _buildSection('Blessures ou limitations (optionnel)', [
              TextField(
                controller: _injuriesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ex: Douleur au genou droit, éviter overhead press...',
                  filled: true,
                  fillColor: AppTheme.cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 32),
            
            // Bouton Générer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateProgram,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPurple,
                  foregroundColor: AppTheme.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                          Text('GÉNÉRATION EN COURS...'),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded),
                          const SizedBox(width: 8),
                          Text('GÉNÉRER MON PROGRAMME'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: AppTheme.neonPurple,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildLevelSelector() {
    final levels = ['Débutant', 'Intermédiaire', 'Avancé'];
    
    return Row(
      children: levels.map((level) {
        final isSelected = _level == level;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => setState(() => _level = level),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.neonPurple : AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.neonPurple 
                        : AppTheme.textDisabled.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  level,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGoalSelector() {
    final goals = ['Force', 'Hypertrophie', 'Endurance', 'Perte de poids'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goals.map((goal) {
        final isSelected = _goal == goal;
        return InkWell(
          onTap: () => setState(() => _goal = goal),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.neonPurple : AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.neonPurple 
                    : AppTheme.textDisabled.withOpacity(0.3),
              ),
            ),
            child: Text(
              goal,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
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
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neonPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_sessionsPerWeek×',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 18,
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
          activeColor: AppTheme.neonPurple,
          inactiveColor: AppTheme.textDisabled,
          onChanged: (value) => setState(() => _sessionsPerWeek = value.toInt()),
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
              'Durée de chaque séance',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.neonPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_sessionDuration min',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 18,
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
          activeColor: AppTheme.neonPurple,
          inactiveColor: AppTheme.textDisabled,
          onChanged: (value) => setState(() => _sessionDuration = value.toInt()),
        ),
      ],
    );
  }

  Widget _buildEquipmentSelector() {
    final allEquipment = ['Barre', 'Haltères', 'Machine', 'Poids de corps', 'Kettlebell', 'Élastiques'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allEquipment.map((equipment) {
        final isSelected = _equipment.contains(equipment);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _equipment.remove(equipment);
              } else {
                _equipment.add(equipment);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.neonPurple : AppTheme.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected 
                    ? AppTheme.neonPurple 
                    : AppTheme.textDisabled.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.primaryDark,
                  ),
                if (isSelected) const SizedBox(width: 4),
                Text(
                  equipment,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _generateProgram() async {
    // Validation pour mode prompt libre
    if (_useCustomPrompt && _customPromptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez décrire le programme que vous souhaitez'),
          backgroundColor: AppTheme.neonOrange,
        ),
      );
      return;
    }

    // Validation pour mode formulaire
    if (!_useCustomPrompt && _equipment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sélectionnez au moins un équipement'),
          backgroundColor: AppTheme.neonOrange,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final result = await AIProgramGenerator.generateProgram(
      level: _useCustomPrompt ? null : _level,
      goal: _useCustomPrompt ? null : _goal,
      sessionsPerWeek: _useCustomPrompt ? null : _sessionsPerWeek,
      sessionDuration: _useCustomPrompt ? null : _sessionDuration,
      availableEquipment: _useCustomPrompt ? null : _equipment.toList(),
      injuries: _useCustomPrompt 
          ? null 
          : (_injuriesController.text.trim().isEmpty 
              ? null 
              : _injuriesController.text.trim()),
      customPrompt: _useCustomPrompt ? _customPromptController.text.trim() : null,
    );

    setState(() => _isGenerating = false);

    if (!mounted) return;

    if (result['success']) {
      // Succès ! Naviguer vers le programme
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AIProgramDetailScreen(
            program: result['program'],
          ),
        ),
      );
    } else {
      // Afficher l'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Erreur lors de la génération'),
          backgroundColor: AppTheme.neonOrange,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  void dispose() {
    _injuriesController.dispose();
    _customPromptController.dispose();
    super.dispose();
  }
}
