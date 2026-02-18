import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/food_log.dart';
import '../services/food_log_service.dart';
import '../utils/theme.dart';

class FoodHistoryScreen extends StatefulWidget {
  const FoodHistoryScreen({super.key});

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  final FoodLogService _service = FoodLogService();
  List<DailyFoodLog> _logs = [];
  bool _isLoading = true;
  String _selectedPeriod = '7'; // jours
  Map<String, double> _averages = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    
    final logs = await _service.getAllLogs();
    final days = int.parse(_selectedPeriod);
    final startDate = DateTime.now().subtract(Duration(days: days));
    
    final averages = await _service.getAverages(startDate, DateTime.now());
    
    setState(() {
      _logs = logs;
      _averages = averages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'HISTORIQUE NUTRITIONNEL',
          style: TextStyle(
            color: AppTheme.neonGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.neonPurple),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
          : RefreshIndicator(
              onRefresh: _loadHistory,
              color: AppTheme.neonGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodSelector(),
                      const SizedBox(height: 20),
                      if (_logs.isNotEmpty) ...[
                        _buildAveragesCard(),
                        const SizedBox(height: 20),
                        _buildCaloriesChart(),
                        const SizedBox(height: 20),
                        _buildMacrosChart(),
                        const SizedBox(height: 20),
                      ],
                      _buildHistoryList(),
                    ],
                  ),
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
          _loadHistory();
        },
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? AppTheme.neonGreen.withValues(alpha: 0.2) : Colors.transparent,
          foregroundColor: isSelected ? AppTheme.neonGreen : AppTheme.textSecondary,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAveragesCard() {
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
            'MOYENNES SUR $_selectedPeriod JOURS',
            style: const TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAvgStat(
                '${_averages['calories']?.toInt() ?? 0}',
                'kcal/jour',
                AppTheme.neonOrange,
              ),
              _buildAvgStat(
                '${_averages['protein']?.toInt() ?? 0}g',
                'Protéines',
                AppTheme.neonPink,
              ),
              _buildAvgStat(
                '${_averages['carbs']?.toInt() ?? 0}g',
                'Glucides',
                AppTheme.neonBlue,
              ),
              _buildAvgStat(
                '${_averages['fat']?.toInt() ?? 0}g',
                'Lipides',
                AppTheme.neonPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvgStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textDisabled,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCaloriesChart() {
    final days = int.parse(_selectedPeriod);
    final recentLogs = _logs.take(days).toList().reversed.toList();
    
    if (recentLogs.isEmpty) return const SizedBox.shrink();

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
          const Text(
            'CALORIES QUOTIDIENNES',
            style: TextStyle(
              color: AppTheme.neonOrange,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
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
                        if (value.toInt() >= 0 && value.toInt() < recentLogs.length) {
                          final log = recentLogs[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd/MM').format(log.date),
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
                    spots: recentLogs.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.totalCalories,
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

  Widget _buildMacrosChart() {
    if (_averages.isEmpty) return const SizedBox.shrink();

    final protein = _averages['protein'] ?? 0;
    final carbs = _averages['carbs'] ?? 0;
    final fat = _averages['fat'] ?? 0;
    final total = protein + carbs + fat;

    if (total == 0) return const SizedBox.shrink();

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
            'RÉPARTITION DES MACROS',
            style: TextStyle(
              color: AppTheme.neonPurple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                        value: protein,
                        color: AppTheme.neonPink,
                        title: '${(protein / total * 100).toInt()}%',
                        radius: 45,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: carbs,
                        color: AppTheme.neonBlue,
                        title: '${(carbs / total * 100).toInt()}%',
                        radius: 45,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: fat,
                        color: AppTheme.neonPurple,
                        title: '${(fat / total * 100).toInt()}%',
                        radius: 45,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMacroLegend('Protéines', protein.toInt(), AppTheme.neonPink),
                    const SizedBox(height: 8),
                    _buildMacroLegend('Glucides', carbs.toInt(), AppTheme.neonBlue),
                    const SizedBox(height: 8),
                    _buildMacroLegend('Lipides', fat.toInt(), AppTheme.neonPurple),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLegend(String label, int value, Color color) {
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
          '$label: ${value}g',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
        ),
        child: const Column(
          children: [
            Icon(Icons.history, size: 64, color: AppTheme.textDisabled),
            SizedBox(height: 16),
            Text(
              'Aucun historique disponible',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

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
        ..._logs.map((log) => _buildLogCard(log)),
      ],
    );
  }

  Widget _buildLogCard(DailyFoodLog log) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayName = _getDayName(log.date.weekday);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: ExpansionTile(
        title: Text(
          '$dayName ${dateFormat.format(log.date)}',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${log.mealsCount} repas - ${log.totalCalories.toInt()} kcal',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        trailing: const Icon(Icons.expand_more, color: AppTheme.neonBlue),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLogStat('${log.totalProtein.toInt()}g', 'Protéines', AppTheme.neonPink),
                    _buildLogStat('${log.totalCarbs.toInt()}g', 'Glucides', AppTheme.neonBlue),
                    _buildLogStat('${log.totalFat.toInt()}g', 'Lipides', AppTheme.neonPurple),
                  ],
                ),
                const SizedBox(height: 12),
                ...log.meals.map((meal) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(meal.type.emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              meal.type.label,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                          Text(
                            '${meal.totalCalories.toInt()} kcal',
                            style: const TextStyle(
                              color: AppTheme.neonOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textDisabled,
            fontSize: 11,
          ),
        ),
      ],
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
