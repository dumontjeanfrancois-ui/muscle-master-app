import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/ai_program.dart';
import '../services/ai_program_generator.dart';
import '../utils/theme.dart';
import '../screens/workout_timer_screen.dart';
import '../screens/ai_program_detail_screen.dart';

/// Widget Programme du Jour - Affiche l'entraînement actuel de l'utilisateur
class TodayWorkoutWidget extends StatefulWidget {
  const TodayWorkoutWidget({super.key});

  @override
  State<TodayWorkoutWidget> createState() => _TodayWorkoutWidgetState();
}

class _TodayWorkoutWidgetState extends State<TodayWorkoutWidget> {
  AIProgram? _activeProgram;
  int _currentDayIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActiveProgram();
  }

  Future<void> _loadActiveProgram() async {
    try {
      developer.log('📅 Chargement du programme actif...', name: 'TodayWorkout');
      
      // Récupérer le programme actif
      final program = await AIProgramGenerator.getActiveProgram();
      
      if (program == null) {
        developer.log('📭 Aucun programme actif sélectionné', name: 'TodayWorkout');
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Calculer le jour actuel (rotation)
      final daysSinceStart = DateTime.now().difference(program.createdAt).inDays;
      final currentDay = daysSinceStart % program.workoutDays.length;
      
      developer.log('✅ Programme actif: ${program.name}', name: 'TodayWorkout');
      developer.log('📆 Jour ${currentDay + 1}/${program.workoutDays.length}', name: 'TodayWorkout');
      
      setState(() {
        _activeProgram = program;
        _currentDayIndex = currentDay;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      developer.log('❌ Erreur chargement programme: $e', name: 'TodayWorkout');
      developer.log('Stack: $stackTrace', name: 'TodayWorkout');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_activeProgram == null) {
      return _buildNoProgramCard(context);
    }

    final todayWorkout = _activeProgram!.workoutDays[_currentDayIndex];
    
    return _buildWorkoutCard(context, todayWorkout);
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.neonBlue),
      ),
    );
  }

  Widget _buildNoProgramCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonPurple.withValues(alpha: 0.2),
            AppTheme.neonBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.neonPurple, size: 28),
              const SizedBox(width: 12),
              Text(
                'Aucun programme sélectionné',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Sélectionnez un programme dans "Mes Programmes IA" pour voir votre entraînement du jour.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, AIWorkoutDay todayWorkout) {
    final exerciseCount = todayWorkout.exercises.length;
    final estimatedTime = (exerciseCount * 10).toString(); // Estimation simple

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withValues(alpha: 0.2),
            AppTheme.neonBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec nom du programme
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.neonGreen, AppTheme.neonBlue],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: AppTheme.primaryDark,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _activeProgram!.name,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Jour ${_currentDayIndex + 1}/${_activeProgram!.workoutDays.length}',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Focus du jour
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.5)),
            ),
            child: Text(
              '🎯 ${todayWorkout.focus}',
              style: TextStyle(
                color: AppTheme.neonBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Détails
          Row(
            children: [
              _buildDetail(Icons.timer_outlined, '$estimatedTime min'),
              const SizedBox(width: 16),
              _buildDetail(Icons.fitness_center, '$exerciseCount exercices'),
            ],
          ),
          const SizedBox(height: 16),

          // Liste des exercices (aperçu)
          Text(
            'Exercices :',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...todayWorkout.exercises.take(3).map((exercise) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, 
                  color: AppTheme.neonGreen, 
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${exercise.exerciseName} - ${exercise.sets}x${exercise.reps}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )),
          if (exerciseCount > 3)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+ ${exerciseCount - 3} autres exercices...',
                style: TextStyle(
                  color: AppTheme.textDisabled,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const SizedBox(height: 16),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Démarrer la séance
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkoutTimerScreen(
                          workoutName: '${_activeProgram!.name} - ${todayWorkout.dayName}',
                          exercises: todayWorkout.exercises.map((e) => {
                            'name': e.exerciseName,
                            'sets': e.sets,
                            'reps': e.reps,
                            'rest': e.restSeconds,
                          }).toList(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonGreen,
                    foregroundColor: AppTheme.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(
                    'DÉMARRER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  // Voir détails du programme
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AIProgramDetailScreen(
                        program: _activeProgram!,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cardDark,
                  foregroundColor: AppTheme.neonBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: AppTheme.neonBlue.withValues(alpha: 0.5)),
                  ),
                ),
                child: const Icon(Icons.info_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 6),
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
