import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/exercise.dart';
import '../services/workout_tracking_service.dart';
import '../utils/theme.dart';

class ExerciseProgressionScreen extends StatefulWidget {
  final Exercise exercise;
  
  const ExerciseProgressionScreen({super.key, required this.exercise});

  @override
  State<ExerciseProgressionScreen> createState() => _ExerciseProgressionScreenState();
}

class _ExerciseProgressionScreenState extends State<ExerciseProgressionScreen> {
  List<Map<String, dynamic>> _progression = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgression();
  }

  Future<void> _loadProgression() async {
    setState(() => _isLoading = true);
    
    final progression = await WorkoutTrackingService.getExerciseProgression(widget.exercise.name);
    final stats = await WorkoutTrackingService.getExerciseStats(widget.exercise.name);
    
    setState(() {
      _progression = progression;
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: Text(
          'PROGRESSION',
          style: const TextStyle(
            color: AppTheme.neonGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
          : RefreshIndicator(
              onRefresh: _loadProgression,
              color: AppTheme.neonGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExerciseHeader(),
                    const SizedBox(height: 20),
                    _buildStatsCards(),
                    const SizedBox(height: 20),
                    if (_progression.isNotEmpty) ...[
                      _buildProgressionChart(),
                      const SizedBox(height: 20),
                      _buildProgressionHistory(),
                    ] else
                      _buildEmptyState(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildExerciseHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withValues(alpha: 0.1),
            AppTheme.neonBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.exercise.name.toUpperCase(),
            style: const TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag(widget.exercise.difficulty, _getDifficultyColor(widget.exercise.difficulty)),
              _buildTag(widget.exercise.equipment, AppTheme.neonPurple),
              ...widget.exercise.primaryMuscles.map((muscle) => _buildTag(muscle, AppTheme.neonBlue)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Débutant':
        return AppTheme.neonGreen;
      case 'Intermédiaire':
        return AppTheme.neonOrange;
      case 'Avancé':
        return AppTheme.neonPink;
      default:
        return AppTheme.textSecondary;
    }
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            '${_stats['timesPerformed'] ?? 0}',
            'Séances',
            AppTheme.neonGreen,
            Icons.event_available,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            '${_stats['totalSets'] ?? 0}',
            'Séries',
            AppTheme.neonBlue,
            Icons.repeat,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionChart() {
    if (_progression.length < 2) {
      return const SizedBox.shrink();
    }

    final maxWeight = (_stats['maxWeight'] ?? 0.0) as double;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonOrange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROGRESSION DES CHARGES',
                style: TextStyle(
                  color: AppTheme.neonOrange,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.neonOrange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.neonOrange.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'PR: ${maxWeight.toInt()}kg',
                  style: const TextStyle(
                    color: AppTheme.neonOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
                  horizontalInterval: maxWeight > 50 ? 20 : 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.textDisabled.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}kg',
                          style: const TextStyle(
                            color: AppTheme.textDisabled,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < _progression.length) {
                          final date = _progression[value.toInt()]['date'] as DateTime;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: const TextStyle(
                                color: AppTheme.textDisabled,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _progression.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        (entry.value['maxWeight'] as double),
                      );
                    }).toList(),
                    isCurved: true,
                    color: AppTheme.neonOrange,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.neonOrange,
                          strokeWidth: 2,
                          strokeColor: AppTheme.cardDark,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonOrange.withValues(alpha: 0.3),
                          AppTheme.neonOrange.withValues(alpha: 0.0),
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

  Widget _buildProgressionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HISTORIQUE',
          style: TextStyle(
            color: AppTheme.neonPurple,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._progression.reversed.map((session) => _buildSessionCard(session)),
      ],
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    final date = session['date'] as DateTime;
    final maxWeight = (session['maxWeight'] as double?)?.toInt() ?? 0;
    final totalReps = session['totalReps'] as int;
    final completedSets = session['completedSets'] as int;
    final dayName = _getDayName(date.weekday);
    final dateFormat = DateFormat('dd/MM/yyyy');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.neonOrange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${maxWeight}kg',
                style: const TextStyle(
                  color: AppTheme.neonOrange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$dayName ${dateFormat.format(date)}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$completedSets séries - $totalReps reps total',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            maxWeight == _stats['maxWeight']
                ? Icons.emoji_events
                : Icons.fitness_center,
            color: maxWeight == _stats['maxWeight']
                ? AppTheme.neonOrange
                : AppTheme.textDisabled,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.show_chart, size: 64, color: AppTheme.textDisabled),
          const SizedBox(height: 16),
          const Text(
            'Aucune donnée de progression',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Effectuez ${widget.exercise.name} lors d\'une séance\npour voir votre progression ici',
            style: const TextStyle(
              color: AppTheme.textDisabled,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return '';
    }
  }
}
