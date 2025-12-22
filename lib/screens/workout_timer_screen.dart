import 'package:flutter/material.dart';
import 'dart:async';
import '../utils/theme.dart';

class WorkoutTimerScreen extends StatefulWidget {
  final String workoutName;
  final List<Map<String, dynamic>> exercises;

  const WorkoutTimerScreen({
    super.key,
    required this.workoutName,
    required this.exercises,
  });

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  bool _isResting = false;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isPaused = false;
  DateTime? _workoutStartTime;
  int _totalWorkoutTime = 0;

  @override
  void initState() {
    super.initState();
    _workoutStartTime = DateTime.now();
    _startWorkoutTimer();
  }

  void _startWorkoutTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && mounted) {
        setState(() {
          _totalWorkoutTime++;
        });
      }
    });
  }

  Map<String, dynamic> get _currentExercise => widget.exercises[_currentExerciseIndex];

  void _startRestTimer() {
    setState(() {
      _isResting = true;
      _remainingSeconds = _currentExercise['rest'] ?? 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          if (_remainingSeconds > 0) {
            _remainingSeconds--;
          } else {
            _timer?.cancel();
            _isResting = false;
            _nextSet();
          }
        });
      }
    });
  }

  void _nextSet() {
    if (_currentSet < _currentExercise['sets']) {
      setState(() {
        _currentSet++;
      });
    } else {
      _nextExercise();
    }
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSet = 1;
      });
    } else {
      _finishWorkout();
    }
  }

  void _skipRest() {
    _timer?.cancel();
    setState(() {
      _isResting = false;
      _nextSet();
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _finishWorkout() {
    _timer?.cancel();
    final duration = Duration(seconds: _totalWorkoutTime);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.celebration, color: AppTheme.neonGreen, size: 32),
            const SizedBox(width: 12),
            const Text('SÉANCE TERMINÉE !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bravo ! Tu as terminé ta séance "${widget.workoutName}"'),
            const SizedBox(height: 16),
            _buildStat('Durée totale', '${duration.inMinutes}min ${duration.inSeconds % 60}s'),
            _buildStat('Exercices', '${widget.exercises.length}'),
            _buildStat('Séries totales', '${widget.exercises.fold<int>(0, (sum, ex) => sum + (ex['sets'] as int))}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonBlue),
            child: const Text('TERMINER'),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary)),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.neonBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _currentExercise;
    final progress = (_currentExerciseIndex + 1) / widget.exercises.length;
    final workoutDuration = Duration(seconds: _totalWorkoutTime);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutName),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '${workoutDuration.inMinutes}:${(workoutDuration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de progression
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.cardDark,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonBlue),
            minHeight: 6,
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info exercice
                  Text(
                    'EXERCICE ${_currentExerciseIndex + 1}/${widget.exercises.length}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    exercise['name'],
                    style: TextStyle(
                      color: AppTheme.neonBlue,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // État actuel
                  if (_isResting)
                    _buildRestingCard()
                  else
                    _buildWorkingCard(),

                  const SizedBox(height: 32),

                  // Liste des exercices restants
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXERCICES RESTANTS',
                          style: TextStyle(
                            color: AppTheme.neonPurple,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.exercises.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ex = entry.value;
                          final isDone = index < _currentExerciseIndex;
                          final isCurrent = index == _currentExerciseIndex;

                          return ListTile(
                            dense: true,
                            leading: Icon(
                              isDone ? Icons.check_circle : (isCurrent ? Icons.play_circle : Icons.circle_outlined),
                              color: isDone ? AppTheme.neonGreen : (isCurrent ? AppTheme.neonBlue : AppTheme.textDisabled),
                            ),
                            title: Text(
                              ex['name'],
                              style: TextStyle(
                                color: isCurrent ? AppTheme.textPrimary : AppTheme.textSecondary,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text('${ex['sets']} × ${ex['reps']}'),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Boutons de contrôle
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _togglePause,
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(_isPaused ? 'REPRENDRE' : 'PAUSE'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppTheme.neonOrange),
                      foregroundColor: AppTheme.neonOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isResting ? _skipRest : _startRestTimer,
                    icon: Icon(_isResting ? Icons.skip_next : Icons.check),
                    label: Text(_isResting ? 'SKIP REPOS' : 'SÉRIE OK'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _isResting ? AppTheme.neonOrange : AppTheme.neonGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonBlue.withOpacity(0.2),
            AppTheme.neonPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonBlue, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'SÉRIE $_currentSet/${_currentExercise['sets']}',
            style: TextStyle(
              color: AppTheme.neonBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${_currentExercise['reps']}',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'RÉPÉTITIONS',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Appuie sur "SÉRIE OK" quand tu as terminé',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRestingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonOrange.withOpacity(0.2),
            AppTheme.neonGreen.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.neonOrange, width: 2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.hourglass_bottom,
            color: AppTheme.neonOrange,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'REPOS',
            style: TextStyle(
              color: AppTheme.neonOrange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '$_remainingSeconds',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 80,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'SECONDES',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: 1 - (_remainingSeconds / (_currentExercise['rest'] ?? 60)),
            backgroundColor: AppTheme.cardDark,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonOrange),
          ),
        ],
      ),
    );
  }
}
