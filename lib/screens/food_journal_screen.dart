import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food_log.dart';
import '../services/food_log_service.dart';
import '../utils/theme.dart';
import 'add_meal_screen.dart';
import 'food_history_screen.dart';

class FoodJournalScreen extends StatefulWidget {
  const FoodJournalScreen({super.key});

  @override
  State<FoodJournalScreen> createState() => _FoodJournalScreenState();
}

class _FoodJournalScreenState extends State<FoodJournalScreen> {
  final FoodLogService _service = FoodLogService();
  DailyFoodLog? _todayLog;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  double _waterIntake = 0;

  // Objectifs quotidiens (peuvent être personnalisés)
  final double _calorieGoal = 2500;
  final double _proteinGoal = 150;
  final double _carbsGoal = 250;
  final double _fatGoal = 80;
  final double _waterGoal = 3.0; // en litres

  @override
  void initState() {
    super.initState();
    _loadTodayLog();
  }

  Future<void> _loadTodayLog() async {
    setState(() => _isLoading = true);
    
    final log = await _service.getDailyLog(_selectedDate);
    
    setState(() {
      _todayLog = log;
      _waterIntake = log?.waterIntake ?? 0;
      _isLoading = false;
    });
  }

  Future<void> _addWater(double amount) async {
    final newAmount = _waterIntake + amount;
    await _service.updateWaterIntake(_selectedDate, newAmount);
    setState(() => _waterIntake = newAmount);
  }

  Future<void> _deleteMeal(String mealId) async {
    await _service.deleteMeal(_selectedDate, mealId);
    _loadTodayLog();
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadTodayLog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'JOURNAL ALIMENTAIRE',
          style: TextStyle(
            color: AppTheme.neonGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppTheme.neonBlue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodHistoryScreen(),
                ),
              ).then((_) => _loadTodayLog());
            },
            tooltip: 'Historique',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.neonPurple),
            onPressed: _loadTodayLog,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonGreen))
          : RefreshIndicator(
              onRefresh: _loadTodayLog,
              color: AppTheme.neonGreen,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateSelector(),
                      const SizedBox(height: 20),
                      _buildMacrosSummary(),
                      const SizedBox(height: 20),
                      _buildWaterTracker(),
                      const SizedBox(height: 20),
                      _buildMealsList(),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMealScreen(date: _selectedDate),
            ),
          ).then((_) => _loadTodayLog());
        },
        backgroundColor: AppTheme.neonGreen,
        icon: const Icon(Icons.add, color: AppTheme.primaryDark),
        label: const Text(
          'AJOUTER REPAS',
          style: TextStyle(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final isToday = _isSameDay(_selectedDate, DateTime.now());
    // Utiliser un format simple sans locale pour éviter les problèmes sur Web
    final dateFormat = DateFormat('dd/MM/yyyy');
    final dayName = _getDayName(_selectedDate.weekday);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppTheme.neonBlue),
            onPressed: () => _changeDate(-1),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  isToday ? "AUJOURD'HUI" : '$dayName ${dateFormat.format(_selectedDate)}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isToday)
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedDate = DateTime.now());
                      _loadTodayLog();
                    },
                    child: const Text(
                      'Revenir à aujourd\'hui',
                      style: TextStyle(color: AppTheme.neonGreen, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isToday ? AppTheme.textDisabled : AppTheme.neonBlue,
            ),
            onPressed: isToday ? null : () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildMacrosSummary() {
    final calories = _todayLog?.totalCalories ?? 0;
    final protein = _todayLog?.totalProtein ?? 0;
    final carbs = _todayLog?.totalCarbs ?? 0;
    final fat = _todayLog?.totalFat ?? 0;

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
        children: [
          const Text(
            'MACROS DU JOUR',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildMacroBar('Calories', calories, _calorieGoal, 'kcal', AppTheme.neonOrange),
          const SizedBox(height: 12),
          _buildMacroBar('Protéines', protein, _proteinGoal, 'g', AppTheme.neonPink),
          const SizedBox(height: 12),
          _buildMacroBar('Glucides', carbs, _carbsGoal, 'g', AppTheme.neonBlue),
          const SizedBox(height: 12),
          _buildMacroBar('Lipides', fat, _fatGoal, 'g', AppTheme.neonPurple),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String label, double value, double goal, String unit, Color color) {
    final percentage = (value / goal * 100).clamp(0, 100);
    final isOver = value > goal;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toInt()} / ${goal.toInt()} $unit',
              style: TextStyle(
                color: isOver ? AppTheme.neonOrange : color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppTheme.textDisabled.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(isOver ? AppTheme.neonOrange : color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterTracker() {
    final glassSize = 0.25; // 250ml = 0.25L
    final glasses = (_waterIntake / glassSize).floor();
    final goalGlasses = (_waterGoal / glassSize).floor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '💧 HYDRATATION',
                style: TextStyle(
                  color: AppTheme.neonBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_waterIntake.toStringAsFixed(1)}L / ${_waterGoal}L',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < goalGlasses; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.water_drop,
                    color: i < glasses ? AppTheme.neonBlue : AppTheme.textDisabled.withValues(alpha: 0.3),
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addWater(glassSize),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonBlue.withValues(alpha: 0.2),
                    foregroundColor: AppTheme.neonBlue,
                    side: BorderSide(color: AppTheme.neonBlue.withValues(alpha: 0.5)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('250ml'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addWater(0.5),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonBlue.withValues(alpha: 0.2),
                    foregroundColor: AppTheme.neonBlue,
                    side: BorderSide(color: AppTheme.neonBlue.withValues(alpha: 0.5)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('500ml'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList() {
    if (_todayLog == null || _todayLog!.meals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
        ),
        child: const Column(
          children: [
            Icon(Icons.restaurant, size: 64, color: AppTheme.textDisabled),
            SizedBox(height: 16),
            Text(
              'Aucun repas enregistré',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Appuyez sur + pour ajouter un repas',
              style: TextStyle(
                color: AppTheme.textDisabled,
                fontSize: 14,
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
          'REPAS DU JOUR',
          style: TextStyle(
            color: AppTheme.neonPurple,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._todayLog!.meals.map((meal) => _buildMealCard(meal)),
      ],
    );
  }

  Widget _buildMealCard(Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Text(
              meal.type.emoji,
              style: const TextStyle(fontSize: 32),
            ),
            title: Text(
              meal.type.label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              DateFormat('HH:mm').format(meal.time),
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.neonPink),
              onPressed: () => _showDeleteDialog(meal),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...meal.foods.map((food) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: AppTheme.neonGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${food.name} (${food.quantity.toInt()}${food.unit})',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                          Text(
                            '${food.calories.toInt()} kcal',
                            style: const TextStyle(
                              color: AppTheme.neonOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(color: AppTheme.textDisabled, height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMealStat('${meal.totalCalories.toInt()} kcal', 'Calories', AppTheme.neonOrange),
                    _buildMealStat('${meal.totalProtein.toInt()}g', 'Protéines', AppTheme.neonPink),
                    _buildMealStat('${meal.totalCarbs.toInt()}g', 'Glucides', AppTheme.neonBlue),
                    _buildMealStat('${meal.totalFat.toInt()}g', 'Lipides', AppTheme.neonPurple),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealStat(String value, String label, Color color) {
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

  void _showDeleteDialog(Meal meal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'Supprimer le repas',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${meal.type.label} ?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: AppTheme.textDisabled)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteMeal(meal.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPink),
            child: const Text('Supprimer', style: TextStyle(color: AppTheme.primaryDark)),
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
