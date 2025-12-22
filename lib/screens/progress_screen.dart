import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/theme.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Map<String, dynamic>> _records = [];
  List<Map<String, dynamic>> _weightHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger records
    final recordsJson = prefs.getString('personal_records');
    if (recordsJson != null) {
      setState(() {
        _records = List<Map<String, dynamic>>.from(jsonDecode(recordsJson));
      });
    } else {
      // Records par défaut
      _records = [
        {'name': 'Squat', 'value': 140.0, 'date': '12 Nov 2024', 'color': 'blue'},
        {'name': 'Développé couché', 'value': 100.0, 'date': '08 Nov 2024', 'color': 'orange'},
        {'name': 'Soulevé de terre', 'value': 180.0, 'date': '15 Nov 2024', 'color': 'purple'},
      ];
    }

    // Charger historique poids
    final weightJson = prefs.getString('weight_history');
    if (weightJson != null) {
      setState(() {
        _weightHistory = List<Map<String, dynamic>>.from(jsonDecode(weightJson));
      });
    }
  }

  Future<void> _saveRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('personal_records', jsonEncode(_records));
  }

  Future<void> _saveWeightHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight_history', jsonEncode(_weightHistory));
  }

  void _showAddWeightDialog() {
    final TextEditingController weightController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AJOUTER VOTRE POIDS'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Poids (kg)',
                hintText: 'Ex: 82.5',
                prefixIcon: Icon(Icons.monitor_weight, color: AppTheme.neonGreen),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () {
              if (weightController.text.trim().isNotEmpty) {
                final weight = double.tryParse(weightController.text);
                if (weight != null) {
                  setState(() {
                    _weightHistory.add({
                      'weight': weight,
                      'date': DateTime.now().toIso8601String(),
                    });
                  });
                  _saveWeightHistory();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ Poids ${weight} kg enregistré !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreen,
            ),
            child: const Text('ENREGISTRER'),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController valueController = TextEditingController();
    String selectedColor = 'blue';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('AJOUTER UN RECORD'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Exercice',
                    hintText: 'Ex: Squat',
                    prefixIcon: Icon(Icons.fitness_center, color: AppTheme.neonBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Charge (kg)',
                    hintText: 'Ex: 140',
                    prefixIcon: Icon(Icons.monitor_weight, color: AppTheme.neonOrange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Couleur', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['blue', 'orange', 'purple', 'green', 'pink'].map((color) {
                    return ChoiceChip(
                      label: Text(color),
                      selected: selectedColor == color,
                      onSelected: (selected) {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULER'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty && valueController.text.trim().isNotEmpty) {
                  final value = double.tryParse(valueController.text);
                  if (value != null) {
                    setState(() {
                      _records.add({
                        'name': nameController.text.trim(),
                        'value': value,
                        'date': '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                        'color': selectedColor,
                      });
                    });
                    _saveRecords();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ Record ajouté : ${nameController.text} - $value kg'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonGreen),
              child: const Text('AJOUTER'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRecordDialog(int index) {
    final record = _records[index];
    final TextEditingController nameController = TextEditingController(text: record['name']);
    final TextEditingController valueController = TextEditingController(text: record['value'].toString());
    String selectedColor = record['color'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('MODIFIER LE RECORD'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Exercice',
                    prefixIcon: Icon(Icons.fitness_center, color: AppTheme.neonBlue),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Charge (kg)',
                    prefixIcon: Icon(Icons.monitor_weight, color: AppTheme.neonOrange),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Couleur', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['blue', 'orange', 'purple', 'green', 'pink'].map((color) {
                    return ChoiceChip(
                      label: Text(color),
                      selected: selectedColor == color,
                      onSelected: (selected) {
                        setDialogState(() {
                          selectedColor = color;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ANNULER'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _records.removeAt(index);
                });
                _saveRecords();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗑️ Record supprimé'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('SUPPRIMER', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(valueController.text);
                if (value != null && nameController.text.trim().isNotEmpty) {
                  setState(() {
                    _records[index] = {
                      'name': nameController.text.trim(),
                      'value': value,
                      'date': '${DateTime.now().day} ${_getMonthName(DateTime.now().month)} ${DateTime.now().year}',
                      'color': selectedColor,
                    };
                  });
                  _saveRecords();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Record modifié'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonBlue),
              child: const Text('MODIFIER'),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return months[month - 1];
  }

  Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue': return AppTheme.neonBlue;
      case 'orange': return AppTheme.neonOrange;
      case 'purple': return AppTheme.neonPurple;
      case 'green': return AppTheme.neonGreen;
      case 'pink': return Colors.pink;
      default: return AppTheme.neonBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROGRESSION',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.neonGreen,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Suivez votre évolution',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              // Stats du mois
              _buildMonthStats(),
              const SizedBox(height: 24),
              
              // Graphique poids
              _buildWeightChart(context),
              const SizedBox(height: 24),
              
              // Records personnels
              _buildPersonalRecords(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_record',
            onPressed: _showAddRecordDialog,
            backgroundColor: AppTheme.neonOrange,
            child: const Icon(Icons.emoji_events),
            tooltip: 'Ajouter un record',
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'add_weight',
            onPressed: _showAddWeightDialog,
            backgroundColor: AppTheme.neonGreen,
            child: const Icon(Icons.add_rounded),
            tooltip: 'Ajouter un poids',
          ),
        ],
      ),
    );
  }

  Widget _buildMonthStats() {
    double currentWeight = _weightHistory.isNotEmpty ? _weightHistory.last['weight'] : 82.5;
    double previousWeight = _weightHistory.length > 1 ? _weightHistory[_weightHistory.length - 2]['weight'] : 80.2;
    double weightChange = currentWeight - previousWeight;

    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            'Poids',
            '${currentWeight.toStringAsFixed(1)} kg',
            '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
            AppTheme.neonGreen,
            weightChange >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatBox(
            'Records',
            '${_records.length}',
            'exercices',
            AppTheme.neonBlue,
            Icons.emoji_events,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonGreen.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ÉVOLUTION DU POIDS',
            style: TextStyle(
              color: AppTheme.neonGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 80),
                      const FlSpot(1, 80.5),
                      const FlSpot(2, 81),
                      const FlSpot(3, 81.5),
                      const FlSpot(4, 82),
                      const FlSpot(5, 82.5),
                    ],
                    isCurved: true,
                    color: AppTheme.neonGreen,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.neonGreen,
                          strokeWidth: 2,
                          strokeColor: AppTheme.primaryDark,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.neonGreen.withOpacity(0.2),
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

  Widget _buildPersonalRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECORDS PERSONNELS',
              style: TextStyle(
                color: AppTheme.neonOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            TextButton.icon(
              onPressed: _showAddRecordDialog,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('AJOUTER'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.neonOrange),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_records.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.emoji_events, size: 64, color: AppTheme.textDisabled),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun record enregistré',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          ..._records.asMap().entries.map((entry) {
            final index = entry.key;
            final record = entry.value;
            final color = _getColorFromString(record['color']);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => _showEditRecordDialog(index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record['name'],
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              record['date'],
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${record['value']} kg',
                        style: TextStyle(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.edit, size: 18, color: AppTheme.textDisabled),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}
