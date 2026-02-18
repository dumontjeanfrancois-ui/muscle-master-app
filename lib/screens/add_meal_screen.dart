import 'package:flutter/material.dart';
import '../models/food_log.dart';
import '../services/food_log_service.dart';
import '../utils/theme.dart';

class AddMealScreen extends StatefulWidget {
  final DateTime date;
  
  const AddMealScreen({super.key, required this.date});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final FoodLogService _service = FoodLogService();
  final List<FoodItem> _selectedFoods = [];
  final List<FoodItem> _commonFoods = FoodLogService.getCommonFoods();
  
  MealType _selectedMealType = MealType.lunch;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _searchQuery = '';

  void _addFood(FoodItem food) {
    setState(() {
      _selectedFoods.add(food);
    });
  }

  void _removeFood(int index) {
    setState(() {
      _selectedFoods.removeAt(index);
    });
  }

  void _updateFoodQuantity(int index, double newQuantity) {
    final food = _selectedFoods[index];
    final ratio = newQuantity / food.quantity;
    
    setState(() {
      _selectedFoods[index] = FoodItem(
        id: food.id,
        name: food.name,
        quantity: newQuantity,
        unit: food.unit,
        calories: food.calories * ratio,
        protein: food.protein * ratio,
        carbs: food.carbs * ratio,
        fat: food.fat * ratio,
        fiber: food.fiber * ratio,
      );
    });
  }

  Future<void> _saveMeal() async {
    if (_selectedFoods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez ajouter au moins un aliment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final mealTime = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedMealType,
      time: mealTime,
      foods: _selectedFoods,
    );

    final success = await _service.addMealToToday(meal);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Repas ajouté avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors de l\'ajout du repas'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double get _totalCalories => _selectedFoods.fold(0, (sum, f) => sum + f.calories);
  double get _totalProtein => _selectedFoods.fold(0, (sum, f) => sum + f.protein);
  double get _totalCarbs => _selectedFoods.fold(0, (sum, f) => sum + f.carbs);
  double get _totalFat => _selectedFoods.fold(0, (sum, f) => sum + f.fat);

  @override
  Widget build(BuildContext context) {
    final filteredFoods = _commonFoods.where((food) {
      return food.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.cardDark,
        title: const Text(
          'AJOUTER UN REPAS',
          style: TextStyle(
            color: AppTheme.neonGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveMeal,
            icon: const Icon(Icons.check, color: AppTheme.neonGreen),
            label: const Text(
              'ENREGISTRER',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration du repas
          Container(
            color: AppTheme.cardDark,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Type de repas
                Row(
                  children: [
                    const Text(
                      'Type :',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<MealType>(
                        value: _selectedMealType,
                        isExpanded: true,
                        dropdownColor: AppTheme.cardDark,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        items: MealType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text('${type.emoji} ${type.label}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedMealType = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Heure du repas
                Row(
                  children: [
                    const Text(
                      'Heure :',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (time != null) {
                            setState(() => _selectedTime = time);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          foregroundColor: AppTheme.neonBlue,
                        ),
                        child: Text(
                          _selectedTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Résumé des macros
          if (_selectedFoods.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonGreen.withValues(alpha: 0.1),
                    AppTheme.neonBlue.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroStat('${_totalCalories.toInt()}', 'kcal', AppTheme.neonOrange),
                  _buildMacroStat('${_totalProtein.toInt()}g', 'Prot', AppTheme.neonPink),
                  _buildMacroStat('${_totalCarbs.toInt()}g', 'Gluc', AppTheme.neonBlue),
                  _buildMacroStat('${_totalFat.toInt()}g', 'Lip', AppTheme.neonPurple),
                ],
              ),
            ),

          // Liste des aliments sélectionnés
          if (_selectedFoods.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'ALIMENTS SÉLECTIONNÉS',
                      style: TextStyle(
                        color: AppTheme.neonPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ..._selectedFoods.asMap().entries.map((entry) {
                    return _buildSelectedFoodTile(entry.key, entry.value);
                  }),
                ],
              ),
            ),

          // Recherche d'aliments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Rechercher un aliment...',
                hintStyle: const TextStyle(color: AppTheme.textDisabled),
                prefixIcon: const Icon(Icons.search, color: AppTheme.neonBlue),
                filled: true,
                fillColor: AppTheme.cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.neonBlue),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          const SizedBox(height: 16),

          // Liste des aliments disponibles
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredFoods.length,
              itemBuilder: (context, index) {
                return _buildFoodTile(filteredFoods[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textDisabled,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFoodTile(int index, FoodItem food) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: TextField(
                        style: const TextStyle(color: AppTheme.neonGreen, fontSize: 12),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(8),
                          hintText: food.quantity.toInt().toString(),
                          hintStyle: TextStyle(color: AppTheme.textDisabled),
                          suffix: Text(food.unit, style: const TextStyle(color: AppTheme.textDisabled, fontSize: 11)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          final newQuantity = double.tryParse(value);
                          if (newQuantity != null && newQuantity > 0) {
                            _updateFoodQuantity(index, newQuantity);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
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
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: AppTheme.neonPink),
            onPressed: () => _removeFood(index),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodTile(FoodItem food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        title: Text(
          food.name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '${food.quantity.toInt()}${food.unit} - ${food.calories.toInt()} kcal',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: AppTheme.neonGreen),
          onPressed: () => _addFood(food),
        ),
      ),
    );
  }
}
