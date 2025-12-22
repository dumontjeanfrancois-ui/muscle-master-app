import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/theme.dart';
import 'workout_timer_screen.dart';
import 'blank_program_editor_screen.dart';

class CustomProgramsScreen extends StatefulWidget {
  const CustomProgramsScreen({super.key});

  @override
  State<CustomProgramsScreen> createState() => _CustomProgramsScreenState();
}

class _CustomProgramsScreenState extends State<CustomProgramsScreen> {
  List<Map<String, dynamic>> _programs = [];
  
  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    final programsJson = prefs.getString('custom_programs');
    if (programsJson != null) {
      setState(() {
        _programs = List<Map<String, dynamic>>.from(jsonDecode(programsJson));
      });
    }
  }

  Future<void> _savePrograms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_programs', jsonEncode(_programs));
  }

  void _createProgramFromTemplate(String templateName) {
    Map<String, dynamic> program;
    
    switch (templateName) {
      case 'blank_3day':
        program = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': '',
          'description': '',
          'days': [
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
          ],
        };
        break;
        
      case 'blank_4day':
        program = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': '',
          'description': '',
          'days': [
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
          ],
        };
        break;
        
      case 'blank_5day':
        program = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': '',
          'description': '',
          'days': [
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
          ],
        };
        break;
        
      case 'blank_6day':
        program = {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'name': '',
          'description': '',
          'days': [
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
            {'name': '', 'exercises': []},
          ],
        };
        break;
        
      default:
        return;
    }
    
    setState(() {
      _programs.add(program);
    });
    _savePrograms();
    
    // Navigate to editor immediately
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlankProgramEditorScreen(
          programId: program['id'],
          programData: program,
          onSave: (updatedProgram) {
            setState(() {
              final index = _programs.indexWhere((p) => p['id'] == updatedProgram['id']);
              if (index != -1) {
                _programs[index] = updatedProgram;
                _savePrograms();
              }
            });
          },
        ),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feuille vierge créée ! Remplissez-la maintenant'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteProgram(int index) {
    setState(() {
      _programs.removeAt(index);
    });
    _savePrograms();
  }

  void _startWorkout(Map<String, dynamic> program, int dayIndex) {
    final day = program['days'][dayIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutTimerScreen(
          workoutName: '${program['name']} - ${day['name']}',
          exercises: List<Map<String, dynamic>>.from(day['exercises']),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MES PROGRAMMES'),
      ),
      body: _programs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppTheme.neonBlue.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun programme personnalisé',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez-en un à partir d\'un template',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDisabled,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _programs.length,
              itemBuilder: (context, index) {
                final program = _programs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(
                      program['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(program['description']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProgram(index),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${program['days'].length} jour(s) d\'entraînement',
                              style: TextStyle(
                                color: AppTheme.neonBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...List.generate(program['days'].length, (dayIndex) {
                              final day = program['days'][dayIndex];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: AppTheme.secondaryDark,
                                child: ListTile(
                                  title: Text(day['name']),
                                  subtitle: Text('${day['exercises'].length} exercices'),
                                  trailing: ElevatedButton(
                                    onPressed: () => _startWorkout(program, dayIndex),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.neonGreen,
                                    ),
                                    child: const Text('DÉMARRER'),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showTemplateDialog();
        },
        backgroundColor: AppTheme.neonBlue,
        icon: const Icon(Icons.add),
        label: const Text('NOUVEAU'),
      ),
    );
  }

  void _showTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir un template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.description, color: AppTheme.neonBlue),
              title: const Text('Feuille vierge 3 jours'),
              subtitle: const Text('Template à compléter manuellement'),
              onTap: () {
                Navigator.pop(context);
                _createProgramFromTemplate('blank_3day');
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: AppTheme.neonPurple),
              title: const Text('Feuille vierge 4 jours'),
              subtitle: const Text('Template à compléter manuellement'),
              onTap: () {
                Navigator.pop(context);
                _createProgramFromTemplate('blank_4day');
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: AppTheme.neonGreen),
              title: const Text('Feuille vierge 5 jours'),
              subtitle: const Text('Template à compléter manuellement'),
              onTap: () {
                Navigator.pop(context);
                _createProgramFromTemplate('blank_5day');
              },
            ),
            ListTile(
              leading: Icon(Icons.description, color: Colors.orange),
              title: const Text('Feuille vierge 6 jours'),
              subtitle: const Text('Template à compléter manuellement'),
              onTap: () {
                Navigator.pop(context);
                _createProgramFromTemplate('blank_6day');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER'),
          ),
        ],
      ),
    );
  }
}
