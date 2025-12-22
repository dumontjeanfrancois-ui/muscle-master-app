import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/theme.dart';

class OneRMCalculatorScreen extends StatefulWidget {
  const OneRMCalculatorScreen({super.key});

  @override
  State<OneRMCalculatorScreen> createState() => _OneRMCalculatorScreenState();
}

class _OneRMCalculatorScreenState extends State<OneRMCalculatorScreen> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  String? _selectedExercise;
  double? _calculated1RM;
  List<String> _savedExercises = [];
  Map<String, double> _exerciseHistory = {};

  final List<String> _commonExercises = [
    'Développé couché',
    'Squat',
    'Soulevé de terre',
    'Développé militaire',
    'Rowing barre',
    'Tractions',
    'Dips',
    'Développé incliné',
    'Hack squat',
    'Leg press',
    'Curl barre',
    'Extension triceps',
  ];

  final _customExerciseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('1rm_history');
    if (historyJson != null) {
      setState(() {
        _exerciseHistory = Map<String, double>.from(jsonDecode(historyJson));
        _savedExercises = _exerciseHistory.keys.toList();
      });
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('1rm_history', jsonEncode(_exerciseHistory));
  }

  void _calculate1RM() {
    final weight = double.tryParse(_weightController.text);
    final reps = int.tryParse(_repsController.text);

    if (weight == null || reps == null || reps < 1 || reps > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poids et reps (1-12) requis')),
      );
      return;
    }

    if (_selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un exercice')),
      );
      return;
    }

    // Formule d'Epley : 1RM = poids × (1 + 0.0333 × reps)
    final oneRM = weight * (1 + 0.0333 * reps);

    setState(() {
      _calculated1RM = oneRM;
      _exerciseHistory[_selectedExercise!] = oneRM;
      if (!_savedExercises.contains(_selectedExercise)) {
        _savedExercises.add(_selectedExercise!);
      }
    });

    _saveHistory();
  }

  void _deleteExercise(String exercise) {
    setState(() {
      _exerciseHistory.remove(exercise);
      _savedExercises.remove(exercise);
    });
    _saveHistory();
  }

  void _showExerciseSuggestions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exercices courants'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _commonExercises.length,
            itemBuilder: (context, index) {
              final exercise = _commonExercises[index];
              return ListTile(
                title: Text(exercise),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  setState(() {
                    _customExerciseController.text = exercise;
                    _selectedExercise = exercise;
                    if (_exerciseHistory.containsKey(exercise)) {
                      _calculated1RM = _exerciseHistory[exercise];
                    }
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('FERMER'),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageTable() {
    if (_calculated1RM == null) return const SizedBox.shrink();

    final percentages = [95, 90, 85, 80, 75, 70, 65, 60];
    final repsRanges = ['1-2', '2-3', '3-5', '5-7', '7-9', '9-11', '11-13', '13-15'];

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TABLE D\'ENTRAÎNEMENT',
            style: TextStyle(
              color: AppTheme.neonPurple,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(
              color: AppTheme.textDisabled.withOpacity(0.2),
              width: 1,
            ),
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue.withOpacity(0.1),
                ),
                children: [
                  _buildTableCell('% 1RM', isHeader: true),
                  _buildTableCell('Poids', isHeader: true),
                  _buildTableCell('Reps', isHeader: true),
                ],
              ),
              ...List.generate(percentages.length, (index) {
                final pct = percentages[index];
                final weight = (_calculated1RM! * pct / 100).toStringAsFixed(1);
                final reps = repsRanges[index];
                return TableRow(
                  children: [
                    _buildTableCell('$pct%'),
                    _buildTableCell('$weight kg'),
                    _buildTableCell(reps),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          color: isHeader ? AppTheme.neonBlue : AppTheme.textPrimary,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14 : 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CALCULATEUR 1RM'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.neonBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.neonBlue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Calcule ton 1RM (répétition maximale) pour chaque exercice',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sélection exercice - Simple TextField avec bouton info
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customExerciseController,
                    decoration: InputDecoration(
                      labelText: 'NOM DE L\'EXERCICE',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.fitness_center),
                      hintText: 'Ex: Squat, Front Squat, Bulgarian Split...',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedExercise = value.trim();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.info_outline, color: AppTheme.neonBlue),
                  onPressed: () {
                    _showExerciseSuggestions();
                  },
                  tooltip: 'Voir suggestions',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '💡 Tapez n\'importe quel exercice (pas de limite)',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),

            // Poids
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'POIDS SOULEVÉ (kg)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.monitor_weight),
              ),
            ),
            const SizedBox(height: 16),

            // Reps
            TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'RÉPÉTITIONS (1-12)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.repeat),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton calcul
            ElevatedButton(
              onPressed: _calculate1RM,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'CALCULER 1RM',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // Résultat
            if (_calculated1RM != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.neonGreen.withOpacity(0.2),
                      AppTheme.neonBlue.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.neonGreen, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'TON 1RM',
                      style: TextStyle(
                        color: AppTheme.neonGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_calculated1RM!.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedExercise != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _selectedExercise!,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildPercentageTable(),
            ],

            // Historique
            if (_savedExercises.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'HISTORIQUE DES 1RM',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              ..._savedExercises.map((exercise) {
                final oneRM = _exerciseHistory[exercise]!;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.neonBlue.withOpacity(0.2),
                      child: const Icon(Icons.fitness_center),
                    ),
                    title: Text(exercise),
                    subtitle: Text('${oneRM.toStringAsFixed(1)} kg'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteExercise(exercise),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedExercise = exercise;
                        _calculated1RM = oneRM;
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
