import 'package:flutter/material.dart';
import 'dart:convert';
import '../utils/theme.dart';
import '../models/ai_program.dart';
import '../services/ai_program_generator.dart';
import 'workout_timer_screen.dart';

class PredefinedProgramDetailScreen extends StatelessWidget {
  final String programName;
  final String description;
  final List<Map<String, dynamic>> days;

  const PredefinedProgramDetailScreen({
    super.key,
    required this.programName,
    required this.description,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(programName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Description
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neonBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      color: AppTheme.neonBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Jours d'entraînement
            Text(
              'PROGRAMME DÉTAILLÉ',
              style: TextStyle(
                color: AppTheme.neonPurple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            ...days.asMap().entries.map((entry) {
              final dayIndex = entry.key;
              final day = entry.value;
              return _buildDayCard(context, dayIndex, day);
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSelectProgramButton(context),
    );
  }

  /// Bouton pour sélectionner ce programme comme actif
  Widget _buildSelectProgramButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        border: Border(
          top: BorderSide(color: AppTheme.neonPurple.withOpacity(0.3)),
        ),
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () => _selectProgramAsActive(context),
          icon: const Icon(Icons.check_circle, size: 24),
          label: const Text(
            'SÉLECTIONNER CE PROGRAMME',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.neonGreen,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            shadowColor: AppTheme.neonGreen.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  /// Convertir et sélectionner ce programme comme actif
  Future<void> _selectProgramAsActive(BuildContext context) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Convertir le programme prédéfini en format JSON compatible avec AIProgram
      final programJson = {
        'name': programName,
        'description': description,
        'userProfile': 'Programme Prédéfini',
        'workoutDays': days.map((day) {
          return {
            'dayName': day['name'],
            'focus': day['focus'] ?? 'Entraînement',
            'exercises': (day['exercises'] as List).map((ex) {
              return {
                'exerciseName': ex['exerciseName'] ?? ex['name'] ?? 'Exercice',
                'sets': ex['sets'] ?? 3,
                'reps': ex['reps']?.toString() ?? '10',
                'restSeconds': ex['restSeconds'] ?? ex['rest'] ?? 60,
                'notes': ex['notes'] ?? '',
              };
            }).toList(),
          };
        }).toList(),
      };

      // Importer le programme converti
      final result = await AIProgramGenerator.importProgramFromJson(
        jsonEncode(programJson),
      );

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Fermer le dialog de chargement

      if (result['success'] == true) {
        // Le programme est sauvegardé, maintenant le définir comme actif
        final program = result['program'] as AIProgram;
        final programId = program.id;

        final success = await AIProgramGenerator.setActiveProgram(programId);

        if (!context.mounted) return;

        if (success) {
          // Afficher une confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.black),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✅ "$programName" est maintenant votre programme actif !',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.neonGreen,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Retourner à l'écran précédent
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('❌ Erreur lors de la sélection du programme.'),
              backgroundColor: AppTheme.neonOrange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message'] ?? 'Erreur lors de l\'import du programme.'}'),
            backgroundColor: AppTheme.neonOrange,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Fermer le dialog de chargement
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur : $e'),
          backgroundColor: AppTheme.neonOrange,
        ),
      );
    }
  }

  Widget _buildDayCard(BuildContext context, int dayIndex, Map<String, dynamic> day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: dayIndex == 0,
        title: Text(
          day['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text('${day['exercises'].length} exercices'),
        leading: CircleAvatar(
          backgroundColor: AppTheme.neonBlue.withOpacity(0.2),
          child: Text(
            '${dayIndex + 1}',
            style: TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Liste des exercices
                ...day['exercises'].map<Widget>((exercise) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.neonBlue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise['exerciseName'] ?? exercise['name'] ?? 'Exercice',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${exercise['sets']} séries × ${exercise['reps']} reps',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${exercise['restSeconds'] ?? exercise['rest'] ?? 60}s',
                          style: TextStyle(
                            color: AppTheme.neonGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),

                // Bouton DÉMARRER
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutTimerScreen(
                          workoutName: '$programName - ${day['name']}',
                          exercises: List<Map<String, dynamic>>.from(day['exercises']),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('DÉMARRER LA SÉANCE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    foregroundColor: AppTheme.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
