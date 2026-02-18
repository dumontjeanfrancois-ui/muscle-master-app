import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../services/workout_recording_service.dart';

/// Widget REC flottant pour enregistrer les exercices pendant les séances
class WorkoutRecButton extends StatefulWidget {
  final VoidCallback? onRecordingComplete;
  final String? exerciseName;

  const WorkoutRecButton({
    super.key,
    this.onRecordingComplete,
    this.exerciseName,
  });

  @override
  State<WorkoutRecButton> createState() => _WorkoutRecButtonState();
}

class _WorkoutRecButtonState extends State<WorkoutRecButton> with SingleTickerProviderStateMixin {
  final _recordingService = WorkoutRecordingService();
  bool _isRecording = false;
  bool _cameraReady = false;
  bool _showPreview = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      // Démarrer l'enregistrement
      await _startRecording();
    } else {
      // Arrêter l'enregistrement
      await _stopRecording();
    }
  }

  Future<void> _startRecording() async {
    // Demander les permissions
    final permissionsGranted = await _recordingService.requestPermissions();
    if (!permissionsGranted) {
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }

    // Initialiser et démarrer la caméra
    final cameraStarted = await _recordingService.startCamera(useFrontCamera: false);
    if (!cameraStarted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Impossible de démarrer la caméra'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _cameraReady = true;
      _showPreview = true;
    });

    // Attendre un peu pour que l'utilisateur se positionne
    await Future.delayed(const Duration(milliseconds: 500));

    // Démarrer l'enregistrement
    final started = await _recordingService.startRecording();
    if (started) {
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });

      // Démarrer le timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingDuration = Duration(seconds: timer.tick);
        });
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();

    final videoPath = await _recordingService.stopRecording();
    
    setState(() {
      _isRecording = false;
      _showPreview = false;
      _cameraReady = false;
      _recordingDuration = Duration.zero;
    });

    await _recordingService.dispose();

    if (videoPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Vidéo enregistrée: ${widget.exerciseName ?? "Exercice"}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Voir',
            onPressed: () {
              // Naviguer vers l'analyse vidéo
              if (widget.onRecordingComplete != null) {
                widget.onRecordingComplete!();
              }
            },
          ),
        ),
      );
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Row(
          children: [
            Icon(Icons.camera_alt, color: Color(0xFFFF6B35)),
            SizedBox(width: 12),
            Text('Permissions requises', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          'Muscle Master a besoin d\'accéder à votre caméra et microphone pour enregistrer vos exercices.\n\n'
          'Ces vidéos restent sur votre appareil et vous permettent d\'analyser votre technique.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleRecording();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text('Autoriser'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Preview caméra en plein écran si enregistrement en cours
        if (_showPreview && _cameraReady) _buildCameraPreview(),
        
        // Bouton REC flottant
        Positioned(
          top: 60,
          right: 16,
          child: _buildRecButton(),
        ),
        
        // Timer si enregistrement en cours
        if (_isRecording) _buildRecordingTimer(),
      ],
    );
  }

  Widget _buildCameraPreview() {
    final controller = _recordingService.cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Center(
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }

  Widget _buildRecButton() {
    return GestureDetector(
      onTap: _toggleRecording,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: _isRecording ? 70 : 60,
        height: _isRecording ? 70 : 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isRecording 
              ? Colors.red 
              : const Color(0xFFFF6B35),
          boxShadow: [
            BoxShadow(
              color: (_isRecording ? Colors.red : const Color(0xFFFF6B35))
                  .withValues(alpha: 0.5),
              blurRadius: _isRecording ? 20 : 10,
              spreadRadius: _isRecording ? 5 : 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animation de pulse si enregistrement
            if (_isRecording)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 70 + (_pulseController.value * 10),
                    height: 70 + (_pulseController.value * 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withValues(
                          alpha: 0.5 - (_pulseController.value * 0.5),
                        ),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),
            
            // Icône/texte
            if (_isRecording)
              const Icon(
                Icons.stop,
                color: Colors.white,
                size: 32,
              )
            else
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    color: Colors.white,
                    size: 24,
                  ),
                  Text(
                    'REC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingTimer() {
    final minutes = _recordingDuration.inMinutes.toString().padLeft(2, '0');
    final seconds = (_recordingDuration.inSeconds % 60).toString().padLeft(2, '0');

    return Positioned(
      top: 150,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Point rouge clignotant
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withValues(
                        alpha: 0.5 + (_pulseController.value * 0.5),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(width: 12),
              
              // Timer
              Text(
                '$minutes:$seconds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Nom de l'exercice
              if (widget.exerciseName != null)
                Text(
                  widget.exerciseName!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
