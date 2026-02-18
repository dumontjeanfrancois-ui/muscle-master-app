import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/workout_session.dart';
import '../services/workout_tracking_service.dart';
import '../utils/theme.dart';

class WorkoutStatsScreen extends StatefulWidget {
  const WorkoutStatsScreen({super.key});

  @override
  State<WorkoutStatsScreen> createState() => _WorkoutStatsScreenState();
}

class _WorkoutStatsScreenState extends State<WorkoutStatsScreen> {
  List<WorkoutSession> _sessions = [];
  String? _selectedExercise;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final sessions = await WorkoutTrackingService.getAllSessions();
    
    setState(() {
      _sessions = sessions;
      _isLoading = false;
    });
  }

  // Extraire tous les exercices uniques
  List<String> get _allExercises {
    final Set<String> exercises = {};
    for (var session in _sessions) {
      for (var exercise in session.exercises) {
        exercises.add(exercise.exerciseName);
      }
    }
    return exercises.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('STATISTIQUES & PROGRESSION'),
        backgroundColor: AppTheme.cardDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📊 Statistiques générales
                      _buildGeneralStats(),
                      
                      const SizedBox(height: 24),
                      
                      // 📈 Graphique d'activité
                      _buildActivityChart(),
                      
                      const SizedBox(height: 24),
                      
                      // 🏋️ Sélecteur d'exercice
                      if (_allExercises.isNotEmpty) ...[
                        _buildExerciseSelector(),
                        const SizedBox(height: 16),
                      ],
                      
                      // 📈 Graphique de progression d'exercice
                      if (_selectedExercise != null) ...[
                        _buildExerciseProgressionChart(),
                        const SizedBox(height: 24),
                        _buildExerciseStats(),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.query_stats, size: 64, color: AppTheme.textDisabled),
          const SizedBox(height: 16),
          Text(
            'Pas encore de données',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complète des séances pour voir tes stats !',
            style: TextStyle(
              color: AppTheme.textDisabled,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralStats() {
    final totalSessions = _sessions.length;
    final totalMinutes = _sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds) ~/ 60;
    final totalSets = _sessions.fold<int>(0, (sum, s) => sum + s.totalSets);
    final avgCompletion = _sessions.isEmpty
        ? 0.0
        : _sessions.fold<double>(0, (sum, s) => sum + s.completionRate) / _sessions.length;

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
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppTheme.neonBlue, size: 24),
              const SizedBox(width: 12),
              const Text(
                'RÉSUMÉ GÉNÉRAL',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatCard('$totalSessions', 'Séances', Icons.fitness_center)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('${totalMinutes}min', 'Total', Icons.timer)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('$totalSets', 'Séries', Icons.repeat)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('${avgCompletion.toInt()}%', 'Complétion', Icons.check_circle)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.neonBlue, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
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
      ),
    );
  }

  Widget _buildActivityChart() {
    // Prendre les 7 dernières séances
    final recentSessions = _sessions.take(7).toList().reversed.toList();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.neonGreen, size: 24),
              const SizedBox(width: 12),
              const Text(
                'ACTIVITÉ RÉCENTE',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: recentSessions.isEmpty ? 100 : recentSessions.map((s) => s.durationSeconds / 60).reduce((a, b) => a > b ? a : b) * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= recentSessions.length) return const SizedBox();
                        final session = recentSessions[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${session.startTime.day}/${session.startTime.month}',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}min',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.textDisabled.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: recentSessions.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.durationSeconds / 60,
                        gradient: LinearGradient(
                          colors: [AppTheme.neonGreen, AppTheme.neonBlue],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseSelector() {
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
              Icon(Icons.sports_gymnastics, color: AppTheme.neonPurple, size: 20),
              const SizedBox(width: 8),
              const Text(
                'EXERCICE À ANALYSER',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedExercise,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.primaryDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
              ),
            ),
            dropdownColor: AppTheme.cardDark,
            style: const TextStyle(color: AppTheme.textPrimary),
            hint: Text('Sélectionner un exercice', style: TextStyle(color: AppTheme.textSecondary)),
            items: _allExercises.map((exercise) {
              return DropdownMenuItem(
                value: exercise,
                child: Text(exercise),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedExercise = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseProgressionChart() {
    // Récupérer l'historique de l'exercice
    final exerciseHistory = <Map<String, dynamic>>[];
    
    for (var session in _sessions.reversed) {
      for (var exercise in session.exercises) {
        if (exercise.exerciseName == _selectedExercise) {
          final maxWeight = exercise.sets
              .where((s) => s.completed && s.weight != null)
              .map((s) => s.weight!)
              .fold<double>(0, (max, w) => w > max ? w : max);
          
          if (maxWeight > 0) {
            exerciseHistory.add({
              'date': session.startTime,
              'weight': maxWeight,
            });
          }
        }
      }
    }

    if (exerciseHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.neonOrange.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(
            'Pas de données de poids pour cet exercice',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
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
              Icon(Icons.show_chart, color: AppTheme.neonPurple, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PROGRESSION - $_selectedExercise',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppTheme.textDisabled.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= exerciseHistory.length) return const SizedBox();
                        final date = exerciseHistory[value.toInt()]['date'] as DateTime;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}kg',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: exerciseHistory.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value['weight'] as double,
                      );
                    }).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [AppTheme.neonPurple, AppTheme.neonBlue],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.neonPurple,
                          strokeWidth: 2,
                          strokeColor: AppTheme.primaryDark,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonPurple.withValues(alpha: 0.3),
                          AppTheme.neonBlue.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStats() {
    return FutureBuilder<Map<String, dynamic>>(
      future: WorkoutTrackingService.getExerciseStats(_selectedExercise!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;
        
        return Container(
          padding: const EdgeInsets.all(20),
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
                  Icon(Icons.equalizer, color: AppTheme.neonOrange, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'STATISTIQUES DÉTAILLÉES',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStatRow('🏋️ PR (Record)', '${stats['maxWeight']} kg'),
              _buildStatRow('📊 Poids moyen', '${stats['avgWeight'].toStringAsFixed(1)} kg'),
              _buildStatRow('🔢 Séries totales', '${stats['totalSets']}'),
              _buildStatRow('💪 Reps totales', '${stats['totalReps']}'),
              _buildStatRow('🎯 Fois exécuté', '${stats['timesPerformed']}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
