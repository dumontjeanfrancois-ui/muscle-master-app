import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../utils/theme.dart';

class WorkoutSessionDetailScreen extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSessionDetailScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('DÉTAILS DE LA SÉANCE'),
        backgroundColor: AppTheme.cardDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏋️ En-tête de la séance
            _buildSessionHeader(),
            
            const SizedBox(height: 24),
            
            // 📊 Statistiques
            _buildStatsSection(),
            
            const SizedBox(height: 24),
            
            // 💪 Exercices détaillés
            _buildExercisesSection(),
            
            // 📝 Notes (si présentes)
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildNotesSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHeader() {
    final duration = session.duration;
    final completionRate = session.completionRate;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonBlue.withValues(alpha: 0.2),
            AppTheme.neonPurple.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              Icon(
                completionRate == 100 ? Icons.celebration : Icons.fitness_center,
                color: completionRate == 100 ? AppTheme.neonGreen : AppTheme.neonBlue,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  session.workoutName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Date et heure
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppTheme.neonBlue),
              const SizedBox(width: 8),
              Text(
                _formatDate(session.startTime),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 24),
              Icon(Icons.schedule, size: 16, color: AppTheme.neonBlue),
              const SizedBox(width: 8),
              Text(
                '${_formatTime(session.startTime)} - ${session.endTime != null ? _formatTime(session.endTime!) : "..."}',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Durée et complétion
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, size: 18, color: AppTheme.neonBlue),
                    const SizedBox(width: 6),
                    Text(
                      '${duration.inMinutes}min ${duration.inSeconds % 60}s',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: completionRate == 100
                      ? AppTheme.neonGreen.withValues(alpha: 0.2)
                      : AppTheme.neonOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${completionRate.toInt()}% complété',
                  style: TextStyle(
                    color: completionRate == 100 ? AppTheme.neonGreen : AppTheme.neonOrange,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'STATISTIQUES',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.fitness_center, '${session.exercises.length}', 'Exercices')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.repeat, '${session.totalSets}', 'Séries totales')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.check_circle, '${session.completedSets}', 'Séries faites')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.close, '${session.totalSets - session.completedSets}', 'Séries sautées')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.neonBlue, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'EXERCICES',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...session.exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return _buildExerciseCard(exercise, index + 1);
        }),
      ],
    );
  }

  Widget _buildExerciseCard(ExerciseLog exercise, int number) {
    final completedSets = exercise.sets.where((set) => set.completed).length;
    final totalSets = exercise.sets.length;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: AppTheme.neonBlue.withValues(alpha: 0.1),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.5)),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: AppTheme.neonBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            exercise.exerciseName,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '$completedSets/$totalSets séries complétées',
              style: TextStyle(
                color: completedSets == totalSets ? AppTheme.neonGreen : AppTheme.neonOrange,
                fontSize: 13,
              ),
            ),
          ),
          children: [
            ...exercise.sets.asMap().entries.map((entry) {
              final setIndex = entry.key;
              final set = entry.value;
              return _buildSetRow(set, setIndex + 1);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(SetLog set, int setNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: set.completed
            ? AppTheme.neonGreen.withValues(alpha: 0.1)
            : AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: set.completed
              ? AppTheme.neonGreen.withValues(alpha: 0.3)
              : AppTheme.textDisabled.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Numéro de série
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: set.completed
                  ? AppTheme.neonGreen.withValues(alpha: 0.2)
                  : AppTheme.textDisabled.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$setNumber',
                style: TextStyle(
                  color: set.completed ? AppTheme.neonGreen : AppTheme.textDisabled,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Poids
          if (set.weight != null) ...[
            Icon(Icons.fitness_center, size: 16, color: AppTheme.neonBlue),
            const SizedBox(width: 4),
            Text(
              '${set.weight} kg',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
          ],
          
          // Reps
          if (set.actualReps != null) ...[
            Icon(Icons.repeat, size: 16, color: AppTheme.neonPurple),
            const SizedBox(width: 4),
            Text(
              '${set.actualReps} reps',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          
          const Spacer(),
          
          // Statut
          Icon(
            set.completed ? Icons.check_circle : Icons.cancel,
            color: set.completed ? AppTheme.neonGreen : AppTheme.textDisabled,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notes, color: AppTheme.neonPurple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'NOTES',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.notes ?? '',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
