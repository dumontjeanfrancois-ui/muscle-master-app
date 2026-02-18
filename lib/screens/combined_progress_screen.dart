import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/workout_tracking_service.dart';
import '../services/food_log_service.dart';
import '../utils/theme.dart';
import 'workout_stats_screen.dart';
import 'food_history_screen.dart';

class CombinedProgressScreen extends StatefulWidget {
  const CombinedProgressScreen({super.key});

  @override
  State<CombinedProgressScreen> createState() => _CombinedProgressScreenState();
}

class _CombinedProgressScreenState extends State<CombinedProgressScreen> {
  final WorkoutTrackingService _workoutService = WorkoutTrackingService();
  final FoodLogService _foodService = FoodLogService();
  
  bool _isLoading = true;
  String _selectedPeriod = '7';
  
  // Données d'entraînement
  int _totalSessions = 0;
  int _totalWorkoutTime = 0;
  
  // Données nutrition
  Map<String, double> _nutritionAverages = {};
  List<Map<String, dynamic>> _recentData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final days = int.parse(_selectedPeriod);
    final startDate = DateTime.now().subtract(Duration(days: days));
    final endDate = DateTime.now();
    
    // Charger les données d'entraînement
    _totalSessions = await WorkoutTrackingService.getTotalSessionsCount();
    _totalWorkoutTime = await WorkoutTrackingService.getTotalWorkoutTime();
    
    // Charger les données nutrition
    final nutritionAverages = await _foodService.getAverages(startDate, endDate);
    
    // Charger les données combinées pour le graphique
    final workoutSessions = await WorkoutTrackingService.getAllSessions();
    final foodLogs = await _foodService.getAllLogs();
    
    // Combiner les données par date
    final combinedData = <String, Map<String, dynamic>>{};
    
    for (var session in workoutSessions) {
      final dateKey = _getDateKey(session.startTime);
      if (session.startTime.isAfter(startDate)) {
        combinedData[dateKey] = {
          'date': session.startTime,
          'hasWorkout': true,
          'workoutDuration': session.durationSeconds ~/ 60,
          'calories': 0.0,
          'protein': 0.0,
        };
      }
    }
    
    for (var log in foodLogs) {
      final dateKey = _getDateKey(log.date);
      if (log.date.isAfter(startDate)) {
        if (combinedData.containsKey(dateKey)) {
          combinedData[dateKey]!['calories'] = log.totalCalories;
          combinedData[dateKey]!['protein'] = log.totalProtein;
        } else {
          combinedData[dateKey] = {
            'date': log.date,
            'hasWorkout': false,
            'workoutDuration': 0,
            'calories': log.totalCalories,
            'protein': log.totalProtein,
          };
        }
      }
    }
    
    // Trier par date
    final sortedData = combinedData.values.toList();
    sortedData.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));
    
    setState(() {
      _nutritionAverages = nutritionAverages;
      _recentData = sortedData;
      _isLoading = false;
    });
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'VUE D\'ENSEMBLE',
          style: TextStyle(
            color: AppTheme.neonGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.neonPurple),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppTheme.neonGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 20),
                    _buildSummaryCards(),
                    const SizedBox(height: 20),
                    _buildCombinedChart(),
                    const SizedBox(height: 20),
                    _buildCorrelationInsights(),
                    const SizedBox(height: 20),
                    _buildQuickAccessButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _buildPeriodButton('7', '7 jours'),
          _buildPeriodButton('14', '14 jours'),
          _buildPeriodButton('30', '30 jours'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String value, String label) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: TextButton(
        onPressed: () {
          setState(() => _selectedPeriod = value);
          _loadData();
        },
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.neonGreen.withValues(alpha: 0.2) : Colors.transparent,
          foregroundColor: isSelected ? AppTheme.neonGreen : AppTheme.textSecondary,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '$_totalSessions',
                'Séances',
                AppTheme.neonGreen,
                Icons.fitness_center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '${_totalWorkoutTime}min',
                'Temps total',
                AppTheme.neonBlue,
                Icons.timer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '${_nutritionAverages['calories']?.toInt() ?? 0}',
                'Kcal/jour',
                AppTheme.neonOrange,
                Icons.local_fire_department,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '${_nutritionAverages['protein']?.toInt() ?? 0}g',
                'Protéines/jour',
                AppTheme.neonPink,
                Icons.restaurant,
              ),
            ),
          ],
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
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedChart() {
    if (_recentData.isEmpty) {
      return const SizedBox.shrink();
    }

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
          const Text(
            'ACTIVITÉ & NUTRITION',
            style: TextStyle(
              color: AppTheme.neonPurple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 3000,
                barTouchData: BarTouchData(enabled: false),
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
                          value.toInt().toString(),
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
                        if (value.toInt() >= 0 && value.toInt() < _recentData.length) {
                          final date = _recentData[value.toInt()]['date'] as DateTime;
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
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.textDisabled.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: _recentData.asMap().entries.map((entry) {
                  final data = entry.value;
                  final hasWorkout = data['hasWorkout'] as bool;
                  final calories = (data['calories'] as double?) ?? 0;
                  
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: calories,
                        color: hasWorkout ? AppTheme.neonGreen : AppTheme.neonOrange,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Avec entraînement', AppTheme.neonGreen),
              const SizedBox(width: 16),
              _buildLegendItem('Sans entraînement', AppTheme.neonOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCorrelationInsights() {
    // Calculer les jours avec entraînement
    final daysWithWorkout = _recentData.where((d) => d['hasWorkout'] == true).length;
    final avgCaloriesWithWorkout = _recentData
        .where((d) => d['hasWorkout'] == true)
        .fold(0.0, (sum, d) => sum + (d['calories'] as double? ?? 0)) / (daysWithWorkout > 0 ? daysWithWorkout : 1);
    
    final daysWithoutWorkout = _recentData.where((d) => d['hasWorkout'] == false).length;
    final avgCaloriesWithoutWorkout = _recentData
        .where((d) => d['hasWorkout'] == false)
        .fold(0.0, (sum, d) => sum + (d['calories'] as double? ?? 0)) / (daysWithoutWorkout > 0 ? daysWithoutWorkout : 1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonPurple.withValues(alpha: 0.1),
            AppTheme.neonBlue.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: AppTheme.neonPurple, size: 24),
              SizedBox(width: 12),
              Text(
                'ANALYSE',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightRow(
            'Jours d\'entraînement',
            '$daysWithWorkout jours',
            AppTheme.neonGreen,
          ),
          const SizedBox(height: 8),
          _buildInsightRow(
            'Calories moyenne (avec training)',
            '${avgCaloriesWithWorkout.toInt()} kcal',
            AppTheme.neonOrange,
          ),
          const SizedBox(height: 8),
          _buildInsightRow(
            'Calories moyenne (sans training)',
            '${avgCaloriesWithoutWorkout.toInt()} kcal',
            AppTheme.neonBlue,
          ),
          if (avgCaloriesWithWorkout > avgCaloriesWithoutWorkout + 200) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bon ! Vous augmentez votre apport calorique les jours d\'entraînement.',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ACCÈS RAPIDE',
          style: TextStyle(
            color: AppTheme.neonBlue,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAccessButton(
                'Séances',
                Icons.fitness_center,
                AppTheme.neonGreen,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkoutStatsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAccessButton(
                'Nutrition',
                Icons.restaurant,
                AppTheme.neonOrange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FoodHistoryScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccessButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
