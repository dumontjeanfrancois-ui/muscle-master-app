import 'package:flutter/material.dart';
import '../models/workout_session.dart';
import '../services/workout_tracking_service.dart';
import '../utils/theme.dart';

class WorkoutSummaryScreen extends StatelessWidget {
  final WorkoutSession session;
  final String programId;

  const WorkoutSummaryScreen({
    super.key,
    required this.session,
    required this.programId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: FutureBuilder<WorkoutSession?>(
          future: _getPreviousSession(),
          builder: (context, snapshot) {
            final previousSession = snapshot.data;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🎉 Célébration
                  _buildCelebrationHeader(),
                  
                  const SizedBox(height: 32),
                  
                  // 📊 Résumé de la séance
                  _buildSessionSummary(),
                  
                  const SizedBox(height: 24),
                  
                  // 📈 Comparaison avec la séance précédente
                  if (previousSession != null) ...[
                    _buildComparison(previousSession),
                    const SizedBox(height: 24),
                  ],
                  
                  // 🎯 Records personnels
                  _buildPersonalRecords(),
                  
                  const SizedBox(height: 32),
                  
                  // 🎮 Boutons d'action
                  _buildActionButtons(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<WorkoutSession?> _getPreviousSession() async {
    try {
      final sessions = await WorkoutTrackingService.getSessionsByProgram(programId);
      // Retirer la session actuelle et prendre la précédente
      sessions.removeWhere((s) => s.id == session.id);
      return sessions.isEmpty ? null : sessions.first;
    } catch (e) {
      return null;
    }
  }

  Widget _buildCelebrationHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withValues(alpha: 0.3),
            AppTheme.neonBlue.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            color: AppTheme.neonGreen,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'SÉANCE TERMINÉE !',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Bravo ! Tu viens de compléter une super séance 💪',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSummary() {
    final duration = session.duration;
    final completionRate = session.completionRate;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: AppTheme.neonBlue, size: 24),
              const SizedBox(width: 12),
              const Text(
                'RÉSUMÉ',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Nom du programme
          _buildSummaryRow(Icons.fitness_center, 'Programme', session.programName),
          const SizedBox(height: 12),
          
          // Durée
          _buildSummaryRow(Icons.timer, 'Durée', '${duration.inMinutes}min ${duration.inSeconds % 60}s'),
          const SizedBox(height: 12),
          
          // Exercices
          _buildSummaryRow(Icons.sports_gymnastics, 'Exercices', '${session.exercises.length}'),
          const SizedBox(height: 12),
          
          // Séries
          _buildSummaryRow(Icons.repeat, 'Séries', '${session.completedSets}/${session.totalSets}'),
          const SizedBox(height: 12),
          
          // Taux de complétion
          Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 20),
              const SizedBox(width: 12),
              Text(
                'Complétion',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: completionRate == 100
                      ? AppTheme.neonGreen.withValues(alpha: 0.2)
                      : AppTheme.neonOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: completionRate == 100
                        ? AppTheme.neonGreen.withValues(alpha: 0.5)
                        : AppTheme.neonOrange.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '${completionRate.toInt()}%',
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

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.neonBlue, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildComparison(WorkoutSession previousSession) {
    final durationDiff = session.durationSeconds - previousSession.durationSeconds;
    final completionDiff = session.completionRate - previousSession.completionRate;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: AppTheme.neonPurple, size: 24),
              const SizedBox(width: 12),
              const Text(
                'VS DERNIÈRE SÉANCE',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Durée
          _buildComparisonRow(
            'Durée',
            durationDiff,
            durationDiff == 0 ? '=' : '${durationDiff.abs()}s',
            suffix: durationDiff < 0 ? 'plus rapide' : 'plus long',
          ),
          const SizedBox(height: 12),
          
          // Complétion
          _buildComparisonRow(
            'Complétion',
            completionDiff,
            '${completionDiff.abs().toStringAsFixed(1)}%',
            suffix: completionDiff > 0 ? 'de mieux' : 'de moins',
          ),
          const SizedBox(height: 12),
          
          // Séries complétées
          _buildComparisonRow(
            'Séries',
            session.completedSets - previousSession.completedSets,
            '${(session.completedSets - previousSession.completedSets).abs()}',
            suffix: session.completedSets > previousSession.completedSets ? 'de plus' : 'de moins',
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, num difference, String value, {String? suffix}) {
    final isPositive = difference > 0;
    final isNeutral = difference == 0;
    
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Icon(
          isNeutral
              ? Icons.horizontal_rule
              : isPositive
                  ? Icons.trending_up
                  : Icons.trending_down,
          color: isNeutral
              ? AppTheme.textDisabled
              : isPositive
                  ? AppTheme.neonGreen
                  : AppTheme.neonRed,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          isNeutral ? 'Identique' : '$value ${suffix ?? ''}',
          style: TextStyle(
            color: isNeutral
                ? AppTheme.textDisabled
                : isPositive
                    ? AppTheme.neonGreen
                    : AppTheme.neonRed,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalRecords() {
    // Récupérer les exercices avec les meilleurs poids
    final bestExercises = <Map<String, dynamic>>[];
    
    for (var exercise in session.exercises) {
      final maxWeight = exercise.sets
          .where((s) => s.completed && s.weight != null)
          .map((s) => s.weight!)
          .fold<double>(0, (max, w) => w > max ? w : max);
      
      if (maxWeight > 0) {
        bestExercises.add({
          'name': exercise.exerciseName,
          'weight': maxWeight,
        });
      }
    }

    if (bestExercises.isEmpty) {
      return const SizedBox.shrink();
    }

    // Trier par poids décroissant et prendre les 3 meilleurs
    bestExercises.sort((a, b) => (b['weight'] as double).compareTo(a['weight'] as double));
    final topExercises = bestExercises.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonOrange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium, color: AppTheme.neonOrange, size: 24),
              const SizedBox(width: 12),
              const Text(
                'TOP CHARGES',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...topExercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            final medals = ['🥇', '🥈', '🥉'];
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text(
                    medals[index],
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      exercise['name'] as String,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${exercise['weight']} kg',
                    style: TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton principal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('RETOUR À L\'ACCUEIL'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Boutons secondaires
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implémenter le partage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonction de partage à venir !'),
                    ),
                  );
                },
                icon: Icon(Icons.share, color: AppTheme.neonGreen),
                label: Text('Partager', style: TextStyle(color: AppTheme.neonGreen)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.neonGreen.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // TODO: Naviguer vers l'historique
                },
                icon: Icon(Icons.history, color: AppTheme.neonPurple),
                label: Text('Historique', style: TextStyle(color: AppTheme.neonPurple)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.neonPurple.withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
