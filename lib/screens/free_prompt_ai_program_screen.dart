import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/theme.dart';

class FreePromptAIProgramScreen extends StatefulWidget {
  const FreePromptAIProgramScreen({super.key});

  @override
  State<FreePromptAIProgramScreen> createState() => _FreePromptAIProgramScreenState();
}

class _FreePromptAIProgramScreenState extends State<FreePromptAIProgramScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedProgram;

  Future<void> _generateProgram() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    // Simulation génération IA (5 secondes)
    await Future.delayed(const Duration(seconds: 5));

    final prompt = _promptController.text;
    final program = _createProgramFromPrompt(prompt);

    setState(() {
      _generatedProgram = program;
      _isGenerating = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Programme généré avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Map<String, dynamic> _createProgramFromPrompt(String prompt) {
    // Analyse intelligente du prompt
    int daysPerWeek = 4;
    if (prompt.toLowerCase().contains('3 jours') || prompt.toLowerCase().contains('3 fois')) {
      daysPerWeek = 3;
    } else if (prompt.toLowerCase().contains('5 jours') || prompt.toLowerCase().contains('5 fois')) {
      daysPerWeek = 5;
    } else if (prompt.toLowerCase().contains('6 jours') || prompt.toLowerCase().contains('6 fois')) {
      daysPerWeek = 6;
    }

    final id = 'ai_prog_${DateTime.now().millisecondsSinceEpoch}';
    
    return {
      'id': id,
      'name': 'Programme IA: ${prompt.substring(0, prompt.length > 40 ? 40 : prompt.length)}...',
      'description': 'Programme créé par l\'IA selon votre demande: "$prompt"',
      'createdAt': DateTime.now().toIso8601String(),
      'daysPerWeek': daysPerWeek,
      'days': List.generate(daysPerWeek, (dayIndex) {
        final dayName = ['Jour 1', 'Jour 2', 'Jour 3', 'Jour 4', 'Jour 5', 'Jour 6'][dayIndex];
        return {
          'name': dayName,
          'exercises': [
            {
              'name': 'Échauffement dynamique',
              'sets': '1',
              'reps': '10 min',
              'rest': '0s',
            },
            {
              'name': 'Exercice principal 1',
              'sets': '4',
              'reps': '8-10',
              'rest': '90s',
            },
            {
              'name': 'Exercice principal 2',
              'sets': '4',
              'reps': '8-12',
              'rest': '90s',
            },
            {
              'name': 'Exercice accessoire 1',
              'sets': '3',
              'reps': '10-12',
              'rest': '60s',
            },
            {
              'name': 'Exercice accessoire 2',
              'sets': '3',
              'reps': '12-15',
              'rest': '60s',
            },
            {
              'name': 'Finisher / Cardio',
              'sets': '1',
              'reps': '10 min',
              'rest': '0s',
            },
          ],
        };
      }),
    };
  }

  Future<void> _saveProgram() async {
    if (_generatedProgram == null) return;

    final prefs = await SharedPreferences.getInstance();
    final customJson = prefs.getString('custom_programs');
    List<Map<String, dynamic>> programs = [];
    
    if (customJson != null) {
      final List<dynamic> decoded = jsonDecode(customJson);
      programs = decoded.cast<Map<String, dynamic>>();
    }

    programs.insert(0, _generatedProgram!);
    await prefs.setString('custom_programs', jsonEncode(programs));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Programme sauvegardé !'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GÉNÉRATEUR IA LIBRE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner IA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonPurple.withOpacity(0.2),
                    AppTheme.neonBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonPurple.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.neonPurple, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    'GÉNÉRATEUR IA INTELLIGENT',
                    style: TextStyle(
                      color: AppTheme.neonPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Décrivez votre programme idéal avec vos propres mots, l\'IA le crée automatiquement',
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

            // Zone de texte
            TextField(
              controller: _promptController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Exemples:\n'
                    '• Je veux un programme de 4 jours focalisé sur la force\n'
                    '• Programme pour débutant avec exercices au poids du corps\n'
                    '• Split haut/bas du corps, 5 jours par semaine\n'
                    '• Programme prise de masse avec focus pectoraux et dos',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.edit_note, color: AppTheme.neonPurple),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.neonPurple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Bouton génération
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateProgram,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isGenerating ? 'GÉNÉRATION EN COURS...' : 'GÉNÉRER LE PROGRAMME',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            if (_generatedProgram != null) ...[
              const SizedBox(height: 32),
              _buildGeneratedProgram(),
            ],

            // Exemples rapides
            const SizedBox(height: 24),
            Text(
              'EXEMPLES RAPIDES',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildExampleChip('Programme force 4 jours'),
                _buildExampleChip('Split Push/Pull/Legs'),
                _buildExampleChip('Full Body 3 fois/semaine'),
                _buildExampleChip('Programme hypertrophie'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleChip(String text) {
    return ActionChip(
      label: Text(text),
      onPressed: () {
        _promptController.text = text;
      },
      backgroundColor: AppTheme.cardDark,
      labelStyle: TextStyle(color: AppTheme.textPrimary, fontSize: 12),
    );
  }

  Widget _buildGeneratedProgram() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PROGRAMME GÉNÉRÉ',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _generatedProgram!['name'],
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _generatedProgram!['description'],
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.neonBlue, size: 20),
                const SizedBox(width: 12),
                Text(
                  '${_generatedProgram!['daysPerWeek']} jours par semaine',
                  style: TextStyle(
                    color: AppTheme.neonBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveProgram,
              icon: const Icon(Icons.save),
              label: const Text(
                'SAUVEGARDER LE PROGRAMME',
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
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
