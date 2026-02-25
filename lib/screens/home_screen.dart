import 'package:flutter/material.dart';
import 'workout_history_screen.dart';
import 'exercise_library_screen.dart';
import 'calculators_screen.dart';
import 'real_video_analysis_screen.dart';
import 'food_journal_screen.dart';
import 'combined_progress_screen.dart';
import 'ai_coach_screen.dart';
import '../widgets/today_workout_widget.dart';
import '../widgets/mascot_floating_button.dart';

import '../utils/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          'MUSCLE MASTER',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        actions: [
          // 📊 Bouton Historique
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutHistoryScreen(),
                ),
              );
            },
            tooltip: 'Historique des séances',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.purple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Column(
                children: [
                  const Icon(Icons.fitness_center, size: 64, color: Colors.blue),
                  const SizedBox(height: 16),
                  Text(
                    'BON ${_getTimeOfDay()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateTime.now().toString().split(' ')[0],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quote motivante
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F3A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.withOpacity(0.3)),
              ),
              child: const Text(
                '"La force ne vient pas de la capacité physique. Elle vient d\'une volonté indomptable."',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),

            // Statistiques
            const Text(
              'STATISTIQUES RAPIDES',
              style: TextStyle(
                color: Colors.purple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('450', 'kcal', Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('3', 'séances', Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('7', 'jours', Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('+5kg', 'progrès', Colors.purple)),
              ],
            ),
            const SizedBox(height: 24),

            // Bouton Vue d'ensemble
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CombinedProgressScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.neonPurple.withValues(alpha: 0.2),
                      AppTheme.neonBlue.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.5), width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.neonPurple.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.insights,
                        color: AppTheme.neonPurple,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VUE D\'ENSEMBLE',
                            style: TextStyle(
                              color: AppTheme.neonPurple,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Entraînement + Nutrition = Résultats',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.neonPurple,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Programme du jour
            const Text(
              'PROGRAMME DU JOUR',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            TodayWorkoutWidget(key: UniqueKey()),
            const SizedBox(height: 24),

            // Actions rapides
            const Text(
              'ACTIONS RAPIDES',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Calculateur',
                    Icons.calculate,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Journal Alimentaire',
                    Icons.restaurant_menu,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Analyse Vidéo',
                    Icons.videocam,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Coach IA',
                    Icons.smart_toy,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    'Exercices',
                    Icons.library_books,
                    const Color(0xFF4A90E2), // Bleu néon
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ExerciseLibraryScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Container()), // Espace vide
              ],
            ),
          ],
        ),
      ),
      // 🦁 Bouton Mascotte Flottant
      Positioned(
        right: 12,
        bottom: 12 + kBottomNavigationBarHeight,
        child: const MascotFloatingButton(),
      ),
    ],
  ),
);
}

String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'MATIN';
    if (hour < 18) return 'APRÈS-MIDI';
    return 'SOIR';
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
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
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    [VoidCallback? customOnTap]
  ) {
    return InkWell(
      onTap: customOnTap ?? () {
        // Navigation vers les écrans correspondants
        if (label == 'Calculateur') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalculatorsScreen()),
          );
        } else if (label == 'Journal Alimentaire') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FoodJournalScreen()),
          );
        } else if (label == 'Analyse Vidéo') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RealVideoAnalysisScreen()),
          );
        } else if (label == 'Coach IA') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AICoachScreen()),
          );
        } else if (label == 'Exercices') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExerciseLibraryScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$label - En développement')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

