// Type de repas
enum MealType {
  breakfast('Petit-déjeuner', '🌅'),
  lunch('Déjeuner', '☀️'),
  snack('Collation', '🍎'),
  dinner('Dîner', '🌙'),
  other('Autre', '🍽️');

  final String label;
  final String emoji;
  const MealType(this.label, this.emoji);
}

/// Aliment consommé
class FoodItem {
  final String id;
  final String name;
  final double quantity; // en grammes ou ml
  final String unit; // 'g', 'ml', 'portion'
  final double calories;
  final double protein; // protéines en g
  final double carbs; // glucides en g
  final double fat; // lipides en g
  final double fiber; // fibres en g (optionnel)
  
  FoodItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
  });

  /// Constructeur depuis JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : 0,
    );
  }

  /// Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
    };
  }

  /// Copie avec modifications
  FoodItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
    );
  }
}

/// Repas (ensemble d'aliments)
class Meal {
  final String id;
  final MealType type;
  final DateTime time;
  final List<FoodItem> foods;
  final String? notes;

  Meal({
    required this.id,
    required this.type,
    required this.time,
    required this.foods,
    this.notes,
  });

  /// Calories totales du repas
  double get totalCalories => foods.fold(0, (sum, food) => sum + food.calories);

  /// Protéines totales (g)
  double get totalProtein => foods.fold(0, (sum, food) => sum + food.protein);

  /// Glucides totaux (g)
  double get totalCarbs => foods.fold(0, (sum, food) => sum + food.carbs);

  /// Lipides totaux (g)
  double get totalFat => foods.fold(0, (sum, food) => sum + food.fat);

  /// Fibres totales (g)
  double get totalFiber => foods.fold(0, (sum, food) => sum + food.fiber);

  /// Constructeur depuis JSON
  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      type: MealType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => MealType.other,
      ),
      time: DateTime.parse(json['time'] as String),
      foods: (json['foods'] as List)
          .map((f) => FoodItem.fromJson(f as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }

  /// Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'time': time.toIso8601String(),
      'foods': foods.map((f) => f.toJson()).toList(),
      'notes': notes,
    };
  }

  /// Copie avec modifications
  Meal copyWith({
    String? id,
    MealType? type,
    DateTime? time,
    List<FoodItem>? foods,
    String? notes,
  }) {
    return Meal(
      id: id ?? this.id,
      type: type ?? this.type,
      time: time ?? this.time,
      foods: foods ?? this.foods,
      notes: notes ?? this.notes,
    );
  }
}

/// Journal alimentaire quotidien
class DailyFoodLog {
  final String id;
  final DateTime date;
  final List<Meal> meals;
  final double? waterIntake; // en litres
  final String? notes;

  DailyFoodLog({
    required this.id,
    required this.date,
    required this.meals,
    this.waterIntake,
    this.notes,
  });

  /// Calories totales de la journée
  double get totalCalories => meals.fold(0, (sum, meal) => sum + meal.totalCalories);

  /// Protéines totales (g)
  double get totalProtein => meals.fold(0, (sum, meal) => sum + meal.totalProtein);

  /// Glucides totaux (g)
  double get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.totalCarbs);

  /// Lipides totaux (g)
  double get totalFat => meals.fold(0, (sum, meal) => sum + meal.totalFat);

  /// Fibres totales (g)
  double get totalFiber => meals.fold(0, (sum, meal) => sum + meal.totalFiber);

  /// Nombre de repas
  int get mealsCount => meals.length;

  /// Date au format "yyyy-MM-dd"
  String get dateKey {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Constructeur depuis JSON
  factory DailyFoodLog.fromJson(Map<String, dynamic> json) {
    return DailyFoodLog(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      meals: (json['meals'] as List)
          .map((m) => Meal.fromJson(m as Map<String, dynamic>))
          .toList(),
      waterIntake: json['waterIntake'] != null 
          ? (json['waterIntake'] as num).toDouble() 
          : null,
      notes: json['notes'] as String?,
    );
  }

  /// Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'waterIntake': waterIntake,
      'notes': notes,
    };
  }

  /// Copie avec modifications
  DailyFoodLog copyWith({
    String? id,
    DateTime? date,
    List<Meal>? meals,
    double? waterIntake,
    String? notes,
  }) {
    return DailyFoodLog(
      id: id ?? this.id,
      date: date ?? this.date,
      meals: meals ?? this.meals,
      waterIntake: waterIntake ?? this.waterIntake,
      notes: notes ?? this.notes,
    );
  }
}
