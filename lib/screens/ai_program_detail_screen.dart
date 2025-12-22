import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/ai_program.dart';
import '../services/ai_program_generator.dart';

class AIProgramDetailScreen extends StatefulWidget {
  final AIProgram program;

  const AIProgramDetailScreen({super.key, required this.program});

  @override
  State<AIProgramDetailScreen> createState() => _AIProgramDetailScreenState();
}

class _AIProgramDetailScreenState extends State<AIProgramDetailScreen> {
  late AIProgram _program;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _program = widget.program;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _program.name,
              style: TextStyle(
                color: AppTheme.neonPurple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _program.userProfile,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: AppTheme.neonOrange),
            onPressed: () => _confirmDelete(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélecteur de jour
          _buildDaySelector(),
          
          // Tableau d'entraînement
          Expanded(
            child: _buildWorkoutTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.neonPurple.withOpacity(0.3)),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _program.workoutDays.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.neonPurple : AppTheme.cardDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.neonPurple
                      : AppTheme.textDisabled.withOpacity(0.3),
                ),
              ),
              child: Center(
                child: Text(
                  _program.workoutDays[index].dayName,
                  style: TextStyle(
                    color: isSelected ? AppTheme.primaryDark : AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkoutTable() {
    final workoutDay = _program.workoutDays[_selectedDayIndex];
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info du jour
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonPurple.withOpacity(0.2),
                    AppTheme.neonBlue.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: AppTheme.neonPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Focus: ${workoutDay.focus}',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Tableau des exercices
            ...workoutDay.exercises.asMap().entries.map((entry) {
              return _buildExerciseCard(entry.key, entry.value);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(int exerciseIndex, AIExerciseEntry exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête exercice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.neonBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${exerciseIndex + 1}',
                          style: TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        exercise.exerciseName,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip('${exercise.sets} séries', AppTheme.neonGreen),
                    const SizedBox(width: 8),
                    _buildInfoChip('${exercise.reps} reps', AppTheme.neonOrange),
                    const SizedBox(width: 8),
                    _buildInfoChip('${exercise.restSeconds}s repos', AppTheme.neonPurple),
                  ],
                ),
                if (exercise.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppTheme.neonGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          exercise.notes,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          // Tableau de suivi des séries
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SUIVI DES SÉRIES',
                  style: TextStyle(
                    color: AppTheme.neonBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                
                // En-têtes tableau
                Row(
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        'Série',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Poids (kg)',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Reps',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Lignes de séries
                ...List.generate(exercise.sets, (setIndex) {
                  final existingSet = exercise.completedSets.firstWhere(
                    (s) => s.setNumber == setIndex + 1,
                    orElse: () => SetEntry(
                      setNumber: setIndex + 1,
                      weight: 0,
                      reps: 0,
                    ),
                  );
                  
                  return _buildSetRow(exerciseIndex, setIndex, existingSet);
                }),
                
                const SizedBox(height: 16),
                
                // Annotations utilisateur
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Notes personnelles...',
                    hintStyle: TextStyle(color: AppTheme.textDisabled),
                    filled: true,
                    fillColor: AppTheme.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.edit_note, color: AppTheme.neonGreen),
                  ),
                  maxLines: 2,
                  style: TextStyle(color: AppTheme.textPrimary),
                  onChanged: (value) {
                    _updateUserNotes(exerciseIndex, value);
                  },
                  controller: TextEditingController(text: exercise.userNotes),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, SetEntry setEntry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '${setIndex + 1}',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _buildInputField(
              value: setEntry.weight > 0 ? setEntry.weight.toString() : '',
              hint: '0',
              onChanged: (value) {
                _updateSetWeight(exerciseIndex, setIndex, double.tryParse(value) ?? 0);
              },
            ),
          ),
          Expanded(
            child: _buildInputField(
              value: setEntry.reps > 0 ? setEntry.reps.toString() : '',
              hint: '0',
              onChanged: (value) {
                _updateSetReps(exerciseIndex, setIndex, int.tryParse(value) ?? 0);
              },
            ),
          ),
          SizedBox(
            width: 40,
            child: Checkbox(
              value: setEntry.completed,
              onChanged: (value) {
                _toggleSetCompleted(exerciseIndex, setIndex, value ?? false);
              },
              activeColor: AppTheme.neonGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String value,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textDisabled),
          filled: true,
          fillColor: AppTheme.surfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: TextInputType.number,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        textAlign: TextAlign.center,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _updateSetWeight(int exerciseIndex, int setIndex, double weight) {
    setState(() {
      final exercise = _program.workoutDays[_selectedDayIndex].exercises[exerciseIndex];
      final setNumber = setIndex + 1;
      
      final existingSetIndex = exercise.completedSets.indexWhere((s) => s.setNumber == setNumber);
      
      if (existingSetIndex != -1) {
        exercise.completedSets[existingSetIndex].weight = weight;
      } else {
        exercise.completedSets.add(SetEntry(
          setNumber: setNumber,
          weight: weight,
          reps: 0,
        ));
      }
    });
    _saveProgram();
  }

  void _updateSetReps(int exerciseIndex, int setIndex, int reps) {
    setState(() {
      final exercise = _program.workoutDays[_selectedDayIndex].exercises[exerciseIndex];
      final setNumber = setIndex + 1;
      
      final existingSetIndex = exercise.completedSets.indexWhere((s) => s.setNumber == setNumber);
      
      if (existingSetIndex != -1) {
        exercise.completedSets[existingSetIndex].reps = reps;
      } else {
        exercise.completedSets.add(SetEntry(
          setNumber: setNumber,
          weight: 0,
          reps: reps,
        ));
      }
    });
    _saveProgram();
  }

  void _toggleSetCompleted(int exerciseIndex, int setIndex, bool completed) {
    setState(() {
      final exercise = _program.workoutDays[_selectedDayIndex].exercises[exerciseIndex];
      final setNumber = setIndex + 1;
      
      final existingSetIndex = exercise.completedSets.indexWhere((s) => s.setNumber == setNumber);
      
      if (existingSetIndex != -1) {
        exercise.completedSets[existingSetIndex].completed = completed;
        exercise.completedSets[existingSetIndex].timestamp = completed ? DateTime.now() : null;
      } else {
        exercise.completedSets.add(SetEntry(
          setNumber: setNumber,
          weight: 0,
          reps: 0,
          completed: completed,
          timestamp: completed ? DateTime.now() : null,
        ));
      }
    });
    _saveProgram();
  }

  void _updateUserNotes(int exerciseIndex, String notes) {
    setState(() {
      _program.workoutDays[_selectedDayIndex].exercises[exerciseIndex].userNotes = notes;
    });
    _saveProgram();
  }

  Future<void> _saveProgram() async {
    await AIProgramGenerator.updateProgram(_program);
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Text('Supprimer le programme ?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Cette action est irréversible.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer', style: TextStyle(color: AppTheme.neonOrange)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AIProgramGenerator.deleteProgram(_program.id);
      Navigator.pop(context);
    }
  }
}
