import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../utils/theme.dart';
import '../models/custom_program.dart';

class CustomProgramCreatorScreen extends StatefulWidget {
  final CustomProgram? existingProgram;

  const CustomProgramCreatorScreen({super.key, this.existingProgram});

  @override
  State<CustomProgramCreatorScreen> createState() => _CustomProgramCreatorScreenState();
}

class _CustomProgramCreatorScreenState extends State<CustomProgramCreatorScreen> {
  late CustomProgram _program;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _program = widget.existingProgram ?? CustomProgram.empty();
    _nameController.text = _program.name;
    _descController.text = _program.description;
  }

  Future<void> _saveProgram() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez donner un nom au programme')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      _program.name = _nameController.text.trim();
      _program.description = _descController.text.trim();
      _program.lastModified = DateTime.now();

      final box = await Hive.openBox<CustomProgram>('custom_programs');
      await box.put(_program.id, _program);

      if (!mounted) return;
      
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Programme enregistré !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _exportProgram() async {
    final json = jsonEncode(_program.toJson());
    await Share.share(
      json,
      subject: 'Programme ${_program.name}',
    );
  }

  void _addDay() {
    setState(() {
      _program.days.add(CustomWorkoutDay(
        dayName: 'Jour ${_program.days.length + 1}',
        exercises: [],
      ));
    });
  }

  void _removeDay(int index) {
    setState(() {
      _program.days.removeAt(index);
    });
  }

  void _addExercise(int dayIndex) {
    showDialog(
      context: context,
      builder: (context) => _ExerciseDialog(
        onSave: (exercise) {
          setState(() {
            _program.days[dayIndex].exercises.add(exercise);
          });
        },
      ),
    );
  }

  void _editExercise(int dayIndex, int exIndex) {
    showDialog(
      context: context,
      builder: (context) => _ExerciseDialog(
        exercise: _program.days[dayIndex].exercises[exIndex],
        onSave: (exercise) {
          setState(() {
            _program.days[dayIndex].exercises[exIndex] = exercise;
          });
        },
      ),
    );
  }

  void _removeExercise(int dayIndex, int exIndex) {
    setState(() {
      _program.days[dayIndex].exercises.removeAt(exIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingProgram == null ? 'CRÉER PROGRAMME' : 'ÉDITER PROGRAMME',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportProgram,
            tooltip: 'Partager',
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProgram,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informations du programme
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom du programme',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.fitness_center),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Séances par semaine
            Row(
              children: [
                const Text(
                  'Séances/semaine:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                ...List.generate(7, (index) {
                  final sessions = index + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('$sessions'),
                      selected: _program.sessionsPerWeek == sessions,
                      onSelected: (selected) {
                        setState(() {
                          _program.sessionsPerWeek = sessions;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Jours d'entraînement
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'JOURS D\'ENTRAÎNEMENT',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonPurple,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _addDay,
                  icon: const Icon(Icons.add),
                  label: const Text('AJOUTER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_program.days.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Aucun jour d\'entraînement.\nAjoutez-en un pour commencer !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            // Liste des jours
            ...List.generate(_program.days.length, (dayIndex) {
              final day = _program.days[dayIndex];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(
                    day.dayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${day.exercises.length} exercices'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeDay(dayIndex),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Nom du jour éditable
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Nom du jour',
                              border: OutlineInputBorder(),
                            ),
                            controller: TextEditingController(text: day.dayName),
                            onChanged: (value) {
                              day.dayName = value;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Exercices
                          if (day.exercises.isEmpty)
                            Center(
                              child: Text(
                                'Aucun exercice',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            )
                          else
                            ...day.exercises.asMap().entries.map((entry) {
                              final exIndex = entry.key;
                              final exercise = entry.value;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.neonPurple.withValues(alpha: 0.2),
                                  child: Text('${exIndex + 1}'),
                                ),
                                title: Text(exercise.name),
                                subtitle: Text(
                                  '${exercise.sets} × ${exercise.reps} | Repos: ${exercise.rest}s',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _editExercise(dayIndex, exIndex),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () => _removeExercise(dayIndex, exIndex),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),

                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _addExercise(dayIndex),
                            icon: const Icon(Icons.add),
                            label: const Text('AJOUTER EXERCICE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.neonGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ExerciseDialog extends StatefulWidget {
  final CustomExercise? exercise;
  final Function(CustomExercise) onSave;

  const _ExerciseDialog({
    this.exercise,
    required this.onSave,
  });

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _restController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _setsController = TextEditingController(text: widget.exercise?.sets.toString() ?? '3');
    _repsController = TextEditingController(text: widget.exercise?.reps.toString() ?? '10');
    _restController = TextEditingController(text: widget.exercise?.rest.toString() ?? '60');
    _notesController = TextEditingController(text: widget.exercise?.notes ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise == null ? 'Ajouter exercice' : 'Modifier exercice'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'exercice',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    decoration: const InputDecoration(
                      labelText: 'Séries',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _restController,
              decoration: const InputDecoration(
                labelText: 'Repos (secondes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
            if (_nameController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Veuillez entrer un nom')),
              );
              return;
            }

            final exercise = CustomExercise(
              name: _nameController.text.trim(),
              sets: int.tryParse(_setsController.text) ?? 3,
              reps: int.tryParse(_repsController.text) ?? 10,
              rest: int.tryParse(_restController.text) ?? 60,
              notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            );

            widget.onSave(exercise);
            Navigator.pop(context);
          },
          child: const Text('ENREGISTRER'),
        ),
      ],
    );
  }
}
