import 'package:flutter/material.dart';
import '../utils/theme.dart';

class BlankProgramEditorScreen extends StatefulWidget {
  final String programId;
  final Map<String, dynamic> programData;
  final Function(Map<String, dynamic>) onSave;

  const BlankProgramEditorScreen({
    super.key,
    required this.programId,
    required this.programData,
    required this.onSave,
  });

  @override
  State<BlankProgramEditorScreen> createState() => _BlankProgramEditorScreenState();
}

class _BlankProgramEditorScreenState extends State<BlankProgramEditorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<Map<String, dynamic>> _days;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.programData['name']);
    _descriptionController = TextEditingController(text: widget.programData['description']);
    _days = List<Map<String, dynamic>>.from(widget.programData['days']);
  }

  void _addExercise(int dayIndex) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final setsController = TextEditingController(text: '3');
        final repsController = TextEditingController(text: '10');
        final restController = TextEditingController(text: '60');

        return AlertDialog(
          title: const Text('AJOUTER UN EXERCICE'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'exercice',
                    hintText: 'Ex: Développé couché',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: setsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Séries',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Répétitions',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: restController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Repos (secondes)',
                  ),
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
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le nom est requis')),
                  );
                  return;
                }
                setState(() {
                  _days[dayIndex]['exercises'].add({
                    'name': nameController.text.trim(),
                    'sets': int.tryParse(setsController.text) ?? 3,
                    'reps': int.tryParse(repsController.text) ?? 10,
                    'rest': int.tryParse(restController.text) ?? 60,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('AJOUTER'),
            ),
          ],
        );
      },
    );
  }

  void _editDayName(int dayIndex) {
    final controller = TextEditingController(text: _days[dayIndex]['name']);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('NOM DU JOUR'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Ex: Push, Pull, Jambes, Jour A...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _days[dayIndex]['name'] = controller.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteExercise(int dayIndex, int exerciseIndex) {
    setState(() {
      _days[dayIndex]['exercises'].removeAt(exerciseIndex);
    });
  }

  void _saveProgram() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le nom du programme est requis')),
      );
      return;
    }

    final updatedProgram = {
      'id': widget.programId,
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'days': _days,
    };

    widget.onSave(updatedProgram);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Programme sauvegardé !'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ÉDITER LE PROGRAMME'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProgram,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nom du programme
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'NOM DU PROGRAMME',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.edit),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'DESCRIPTION (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Jours d'entraînement
            Text(
              'JOURS D\'ENTRAÎNEMENT',
              style: TextStyle(
                color: AppTheme.neonPurple,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),

            ...List.generate(_days.length, (dayIndex) {
              final day = _days[dayIndex];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          day['name'].isEmpty ? 'Jour ${dayIndex + 1} (sans nom)' : day['name'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: AppTheme.neonBlue),
                        onPressed: () => _editDayName(dayIndex),
                        tooltip: 'Renommer',
                      ),
                    ],
                  ),
                  subtitle: Text('${day['exercises'].length} exercice(s)'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Liste des exercices
                          if (day['exercises'].isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTheme.neonBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.neonBlue.withOpacity(0.3),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: 48,
                                    color: AppTheme.textDisabled,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aucun exercice',
                                    style: TextStyle(color: AppTheme.textDisabled),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...List.generate(day['exercises'].length, (exerciseIndex) {
                              final exercise = day['exercises'][exerciseIndex];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: AppTheme.secondaryDark,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppTheme.neonBlue.withOpacity(0.2),
                                    child: Text('${exerciseIndex + 1}'),
                                  ),
                                  title: Text(
                                    exercise['name'],
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    '${exercise['sets']} séries × ${exercise['reps']} reps | Repos: ${exercise['rest']}s',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteExercise(dayIndex, exerciseIndex),
                                  ),
                                ),
                              );
                            }),

                          const SizedBox(height: 12),

                          // Bouton ajouter exercice
                          ElevatedButton.icon(
                            onPressed: () => _addExercise(dayIndex),
                            icon: const Icon(Icons.add),
                            label: const Text('AJOUTER UN EXERCICE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonGreen,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),

            // Bouton sauvegarder
            ElevatedButton(
              onPressed: _saveProgram,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'SAUVEGARDER LE PROGRAMME',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
