import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../data/default_data.dart';
import 'ai_program_creator_screen.dart';
import 'ai_programs_list_screen.dart';
import 'custom_programs_screen.dart';
import 'predefined_program_detail_screen.dart';
import 'program_import_export_screen.dart';

class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROGRAMMES',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.neonBlue,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez le programme qui correspond à vos objectifs',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              // Bouton Générateur IA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.neonPurple.withOpacity(0.3),
                      AppTheme.neonBlue.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.neonPurple.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.auto_awesome_rounded, 
                      color: AppTheme.neonPurple, 
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'PROGRAMME PERSONNALISÉ IA',
                      style: TextStyle(
                        color: AppTheme.neonPurple,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'L\'IA crée un programme 100% adapté à toi',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AIProgramCreatorScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonPurple,
                              foregroundColor: AppTheme.primaryDark,
                            ),
                            child: Text('CRÉER'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AIProgramsListScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.neonPurple,
                              side: BorderSide(color: AppTheme.neonPurple),
                            ),
                            child: Text('MES PROGRAMMES'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Bouton Programmes Personnalisés
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.neonGreen.withOpacity(0.3),
                      AppTheme.neonBlue.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.neonGreen.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.edit_note_rounded, 
                      color: AppTheme.neonGreen, 
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'PROGRAMMES PERSONNALISÉS',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crée tes propres programmes à partir de templates',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomProgramsScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('CRÉER'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Section Programmes Pré-définis avec bouton Import/Export
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PROGRAMMES PRÉ-DÉFINIS',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProgramImportExportScreen()),
                      );
                    },
                    icon: Icon(Icons.import_export, color: AppTheme.neonBlue),
                    tooltip: 'Import/Export',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Liste des programmes
              ...DefaultData.programs.map((program) => _buildProgramCard(context, program)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, Map<String, dynamic> program) {
    Color getLevelColor(String level) {
      switch (level) {
        case 'Débutant':
          return AppTheme.neonGreen;
        case 'Intermédiaire':
          return AppTheme.neonBlue;
        case 'Avancé':
          return AppTheme.neonOrange;
        default:
          return AppTheme.neonBlue;
      }
    }
    
    final levelColor = getLevelColor(program['level']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: levelColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: levelColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  program['level'],
                  style: TextStyle(
                    color: AppTheme.primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  program['goal'],
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            program['name'],
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            program['description'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildProgramInfo(Icons.calendar_today, '${program['durationWeeks']} semaines'),
              const SizedBox(width: 16),
              _buildProgramInfo(Icons.fitness_center, '${program['sessionsPerWeek']}x/sem'),
              const SizedBox(width: 16),
              _buildProgramInfo(Icons.list, '${program['workoutDays'].length} séances'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PredefinedProgramDetailScreen(
                      programName: program['name'],
                      description: program['description'],
                      days: List<Map<String, dynamic>>.from(program['workoutDays']),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: levelColor,
                foregroundColor: AppTheme.primaryDark,
              ),
              child: Text('VOIR DÉTAILS'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
