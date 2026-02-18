import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;
import '../models/workout_session.dart';
import '../services/workout_tracking_service.dart';
import '../utils/theme.dart';
import 'workout_session_detail_screen.dart';
import 'workout_stats_screen.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  List<WorkoutSession> _sessions = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      setState(() => _isLoading = true);
      
      final sessions = await WorkoutTrackingService.getAllSessions();
      
      if (kDebugMode) {
        developer.log('✅ ${sessions.length} sessions chargées', name: 'WorkoutHistory');
      }
      
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        developer.log('❌ Erreur chargement sessions: $e', name: 'WorkoutHistory');
      }
      setState(() => _isLoading = false);
    }
  }

  List<WorkoutSession> get _filteredSessions {
    if (_searchQuery.isEmpty) return _sessions;
    
    return _sessions.where((session) {
      return session.workoutName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('HISTORIQUE DES SÉANCES'),
        backgroundColor: AppTheme.cardDark,
        actions: [
          // 📊 Bouton Statistiques
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WorkoutStatsScreen(),
                ),
              );
            },
            tooltip: 'Statistiques & Graphiques',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Barre de recherche
          _buildSearchBar(),
          
          // 📊 Statistiques rapides
          _buildQuickStats(),
          
          // 📝 Liste des séances
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSessions.isEmpty
                    ? _buildEmptyState()
                    : _buildSessionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Rechercher une séance...',
          hintStyle: TextStyle(color: AppTheme.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppTheme.neonBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final totalSessions = _sessions.length;
    final totalDuration = _sessions.fold<int>(
      0,
      (sum, session) => sum + session.duration.inMinutes,
    );
    final totalExercises = _sessions.fold<int>(
      0,
      (sum, session) => sum + session.exercises.length,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonBlue.withValues(alpha: 0.1),
            AppTheme.neonPurple.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.fitness_center, '$totalSessions', 'Séances'),
          _buildStatItem(Icons.timer, '$totalDuration min', 'Total'),
          _buildStatItem(Icons.sports_gymnastics, '$totalExercises', 'Exercices'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.neonBlue, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppTheme.textDisabled),
          const SizedBox(height: 16),
          Text(
            'Aucune séance enregistrée',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complète une séance pour voir ton historique !',
            style: TextStyle(
              color: AppTheme.textDisabled,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredSessions.length,
      itemBuilder: (context, index) {
        final session = _filteredSessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(WorkoutSession session) {
    final duration = session.duration;
    final completionRate = session.completionRate;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: completionRate == 100
              ? AppTheme.neonGreen.withValues(alpha: 0.3)
              : AppTheme.neonBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutSessionDetailScreen(session: session),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                Row(
                  children: [
                    Icon(
                      completionRate == 100 ? Icons.check_circle : Icons.play_circle,
                      color: completionRate == 100 ? AppTheme.neonGreen : AppTheme.neonBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        session.workoutName,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${duration.inMinutes}min',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Date
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppTheme.textDisabled),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(session.startTime),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, size: 14, color: AppTheme.textDisabled),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(session.startTime),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Stats
                Row(
                  children: [
                    _buildSmallStat(Icons.fitness_center, '${session.exercises.length} ex'),
                    const SizedBox(width: 16),
                    _buildSmallStat(Icons.repeat, '${session.totalSets} séries'),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: completionRate == 100
                            ? AppTheme.neonGreen.withValues(alpha: 0.2)
                            : AppTheme.neonOrange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${completionRate.toInt()}%',
                        style: TextStyle(
                          color: completionRate == 100 ? AppTheme.neonGreen : AppTheme.neonOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.neonBlue),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDate = DateTime(date.year, date.month, date.day);
    
    if (sessionDate == today) {
      return "Aujourd'hui";
    } else if (sessionDate == yesterday) {
      return 'Hier';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
