import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:developer' as developer;
import '../utils/theme.dart';
import '../models/workout_session.dart';
import '../services/workout_tracking_service.dart';
import '../services/social_service.dart';
import '../services/mascot_service.dart';
import '../widgets/flexo_mascot_3d_widget.dart';
import 'workout_summary_screen.dart';

class WorkoutTimerScreen extends StatefulWidget {
  final String workoutName;
  final List<Map<String, dynamic>> exercises;
  final String? programId; // Pour lier la session au programme
  final String? programName;

  const WorkoutTimerScreen({
    super.key,
    required this.workoutName,
    required this.exercises,
    this.programId,
    this.programName,
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

  // 📊 Tracking des séries
  final Map<int, Map<int, SetLog>> _setLogs = {}; // exerciseIndex -> setNumber -> SetLog
  final Map<int, TextEditingController> _weightControllers = {};
  final Map<int, TextEditingController> _repsControllers = {};

  @override
  void initState() {
    super.initState();
    _workoutStartTime = DateTime.now();
    _startWorkoutTimer();
    _initializeTracking();
    _startGymCrushPresence();
  }

  Future<void> _startGymCrushPresence() async {
    if (SocialService.isSocialEnabled()) {
      try {
        final mascotSettings = MascotService.getSettings();
        await SocialService.startPresenceHeartbeat(
          pseudo: mascotSettings.displayName,
          mascotType: mascotSettings.mascotType,
          mascotName: mascotSettings.customName,
          gymId: 'default_gym',
        );
        debugPrint('✅ Social: Présence démarrée pour l\'entraînement');
      } catch (e) {
        debugPrint('❌ Social: Erreur démarrage présence: $e');
      }
    }
  }

  /// Initialiser le tracking pour tous les exercices
  void _initializeTracking() {
    for (int i = 0; i < widget.exercises.length; i++) {
      final exercise = widget.exercises[i];
      final sets = exercise['sets'] as int;
      
      _setLogs[i] = {};
      for (int setNum = 1; setNum <= sets; setNum++) {
        _setLogs[i]![setNum] = SetLog(
          setNumber: setNum,
          completed: false,
          targetReps: exercise['reps']?.toString() ?? '10',
          restSeconds: exercise['restSeconds'] ?? exercise['rest'] ?? 60,
        );
      }
      
      // Créer les controllers pour poids et reps
      _weightControllers[i] = TextEditingController();
      _repsControllers[i] = TextEditingController();
    }
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
    // ✅ Marquer la série comme complétée avec poids et reps
    final currentSetLog = _setLogs[_currentExerciseIndex]?[_currentSet];
    if (currentSetLog != null) {
      final weightController = _weightControllers[_currentExerciseIndex];
      final repsController = _repsControllers[_currentExerciseIndex];
      
      _setLogs[_currentExerciseIndex]![_currentSet] = currentSetLog.copyWith(
        completed: true,
        weight: weightController != null && weightController.text.isNotEmpty 
            ? double.tryParse(weightController.text)
            : null,
        actualReps: repsController != null && repsController.text.isNotEmpty
            ? int.tryParse(repsController.text)
            : null,
        completedAt: DateTime.now(),
      );
    }
    
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

  Future<void> _finishWorkout() async {
    _timer?.cancel();
    
    // 💾 Sauvegarder la session de tracking
    WorkoutSession? savedSession;
    try {
      // Construire la liste des exercices avec leurs logs
      final List<ExerciseLog> exerciseLogs = [];
      
      for (int i = 0; i < widget.exercises.length; i++) {
        final exercise = widget.exercises[i];
        final sets = _setLogs[i] ?? {};
        
        exerciseLogs.add(ExerciseLog(
          exerciseName: exercise['exerciseName'] ?? exercise['name'] ?? 'Exercice',
          sets: sets.values.toList(),
          notes: null,
        ));
      }
      
      savedSession = WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        programId: widget.programId ?? 'unknown',
        programName: widget.workoutName,
        startTime: _workoutStartTime!,
        endTime: DateTime.now(),
        durationSeconds: _totalWorkoutTime,
        exercises: exerciseLogs,
        notes: null,
      );
      
      await WorkoutTrackingService.saveSession(savedSession);
      if (kDebugMode) {
        developer.log('✅ Session sauvegardée: ${savedSession.programName}', name: 'WorkoutTimer');
      }
    } catch (e) {
      if (kDebugMode) {
        developer.log('❌ Erreur sauvegarde session: $e', name: 'WorkoutTimer');
      }
    }
    
    if (!mounted) return;
    
    // 🎉 Naviguer vers l'écran de résumé au lieu du dialogue
    if (savedSession != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WorkoutSummaryScreen(
            session: savedSession!,
            programId: widget.programId ?? 'unknown',
          ),
        ),
      );
    } else {
      // Fallback si la sauvegarde a échoué
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
          content: Text('Bravo ! Tu as terminé ta séance "${widget.workoutName}"'),
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
    _stopGymCrushPresence();
    for (var controller in _weightControllers.values) {
      controller.dispose();
    }
    for (var controller in _repsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _stopGymCrushPresence() async {
    if (SocialService.isSocialEnabled()) {
      try {
        await SocialService.deactivatePresence();
        debugPrint('✅ Social: Présence arrêtée après entraînement');
      } catch (e) {
        debugPrint('❌ Social: Erreur arrêt présence: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercise = _currentExercise;
    final progress = (_currentExerciseIndex + 1) / widget.exercises.length;
    final workoutDuration = Duration(seconds: _totalWorkoutTime);

    return FlexoMascot3DOverlay(
      child: Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutName),
        actions: [
          // Chronomètre total de la séance - AGRANDI
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.neonBlue, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: AppTheme.neonBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${workoutDuration.inMinutes}:${(workoutDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonBlue,
                  ),
                ),
              ],
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
    ),
    );
  }

  Widget _buildWorkingCard() {
    final workoutDuration = Duration(seconds: _totalWorkoutTime);
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
          // ⏱️ CHRONOMÈTRE GÉANT - IMPOSSIBLE À MANQUER !
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.neonBlue.withOpacity(0.3),
                  AppTheme.neonPurple.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.neonBlue, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonBlue.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.timer, color: AppTheme.neonBlue, size: 48),
                const SizedBox(height: 16),
                Text(
                  '${workoutDuration.inMinutes}:${(workoutDuration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 72,  // ← ÉNORME !
                    fontWeight: FontWeight.w900,
                    color: AppTheme.neonBlue,
                    letterSpacing: 4,
                    height: 1,
                    shadows: [
                      Shadow(
                        color: AppTheme.neonBlue.withOpacity(0.8),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'TEMPS TOTAL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
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
          
          // 📝 Champs de saisie pour tracking
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                // Poids
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.fitness_center, color: AppTheme.neonBlue, size: 24),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _weightControllers[_currentExerciseIndex],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: AppTheme.textDisabled),
                          suffixText: 'kg',
                          suffixStyle: TextStyle(color: AppTheme.neonBlue),
                          filled: true,
                          fillColor: AppTheme.primaryDark,
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
                            borderSide: BorderSide(color: AppTheme.neonBlue, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'POIDS',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Reps
                Expanded(
                  child: Column(
                    children: [
                      Icon(Icons.repeat, color: AppTheme.neonPurple, size: 24),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _repsControllers[_currentExerciseIndex],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: AppTheme.textDisabled),
                          suffixText: 'reps',
                          suffixStyle: TextStyle(color: AppTheme.neonPurple),
                          filled: true,
                          fillColor: AppTheme.primaryDark,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppTheme.neonPurple, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'REPS FAITS',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
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
