import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service d'enregistrement vidéo pour les séances d'entraînement
/// Gère la capture vidéo, les permissions, et la sauvegarde
class WorkoutRecordingService {
  static final WorkoutRecordingService _instance = WorkoutRecordingService._internal();
  factory WorkoutRecordingService() => _instance;
  WorkoutRecordingService._internal();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  String? _currentVideoPath;

  /// État de l'enregistrement
  bool get isRecording => _isRecording;
  String? get currentVideoPath => _currentVideoPath;

  /// Initialiser les caméras disponibles
  Future<bool> initializeCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (kDebugMode) {
          debugPrint('❌ Aucune caméra disponible');
        }
        return false;
      }
      
      if (kDebugMode) {
        debugPrint('✅ ${_cameras!.length} caméra(s) détectée(s)');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur initialisation caméras: $e');
      }
      return false;
    }
  }

  /// Vérifier et demander les permissions nécessaires
  Future<bool> requestPermissions() async {
    try {
      // Demander permission caméra
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        if (kDebugMode) {
          debugPrint('❌ Permission caméra refusée');
        }
        return false;
      }

      // Demander permission microphone
      final microphoneStatus = await Permission.microphone.request();
      if (!microphoneStatus.isGranted) {
        if (kDebugMode) {
          debugPrint('❌ Permission microphone refusée');
        }
        return false;
      }

      // Demander permission storage (Android uniquement)
      if (Platform.isAndroid) {
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted && !storageStatus.isPermanentlyDenied) {
          // Essayer photos permission pour Android 13+
          await Permission.photos.request();
        }
      }

      if (kDebugMode) {
        debugPrint('✅ Toutes les permissions accordées');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur demande permissions: $e');
      }
      return false;
    }
  }

  /// Démarrer la caméra pour la prévisualisation
  Future<bool> startCamera({bool useFrontCamera = false}) async {
    try {
      if (_cameras == null || _cameras!.isEmpty) {
        await initializeCameras();
      }

      if (_cameras == null || _cameras!.isEmpty) {
        return false;
      }

      // Sélectionner la caméra (arrière par défaut)
      final camera = _cameras!.firstWhere(
        (cam) => useFrontCamera 
            ? cam.lensDirection == CameraLensDirection.front
            : cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      // Créer le contrôleur
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialiser
      await _cameraController!.initialize();

      if (kDebugMode) {
        debugPrint('✅ Caméra ${useFrontCamera ? "avant" : "arrière"} démarrée');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur démarrage caméra: $e');
      }
      return false;
    }
  }

  /// Commencer l'enregistrement vidéo
  Future<bool> startRecording() async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        if (kDebugMode) {
          debugPrint('❌ Caméra non initialisée');
        }
        return false;
      }

      if (_isRecording) {
        if (kDebugMode) {
          debugPrint('⚠️ Enregistrement déjà en cours');
        }
        return false;
      }

      // Démarrer l'enregistrement
      await _cameraController!.startVideoRecording();
      _isRecording = true;

      if (kDebugMode) {
        debugPrint('🎥 Enregistrement démarré');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur démarrage enregistrement: $e');
      }
      return false;
    }
  }

  /// Arrêter l'enregistrement et sauvegarder la vidéo
  Future<String?> stopRecording() async {
    try {
      if (_cameraController == null || !_isRecording) {
        if (kDebugMode) {
          debugPrint('⚠️ Aucun enregistrement en cours');
        }
        return null;
      }

      // Arrêter l'enregistrement
      final videoFile = await _cameraController!.stopVideoRecording();
      _isRecording = false;

      // Créer un nom de fichier unique
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/workout_videos');
      
      // Créer le dossier si nécessaire
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      // Copier le fichier avec un nom permanent
      final permanentPath = '${videoDir.path}/workout_$timestamp.mp4';
      final permanentFile = File(permanentPath);
      await File(videoFile.path).copy(permanentPath);

      _currentVideoPath = permanentPath;

      if (kDebugMode) {
        debugPrint('✅ Enregistrement sauvegardé: $permanentPath');
      }

      return permanentPath;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur arrêt enregistrement: $e');
      }
      _isRecording = false;
      return null;
    }
  }

  /// Basculer entre caméra avant/arrière
  Future<bool> switchCamera() async {
    try {
      if (_cameraController == null) return false;

      final isUsingFrontCamera = 
          _cameraController!.description.lensDirection == CameraLensDirection.front;

      // Arrêter la caméra actuelle
      await _cameraController!.dispose();

      // Redémarrer avec l'autre caméra
      return await startCamera(useFrontCamera: !isUsingFrontCamera);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur basculement caméra: $e');
      }
      return false;
    }
  }

  /// Obtenir le contrôleur de caméra (pour affichage preview)
  CameraController? get cameraController => _cameraController;

  /// Libérer les ressources
  Future<void> dispose() async {
    try {
      if (_cameraController != null) {
        if (_isRecording) {
          await stopRecording();
        }
        await _cameraController!.dispose();
        _cameraController = null;
      }

      if (kDebugMode) {
        debugPrint('✅ Service d\'enregistrement nettoyé');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur libération ressources: $e');
      }
    }
  }

  /// Obtenir toutes les vidéos d'entraînement sauvegardées
  Future<List<File>> getSavedVideos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${directory.path}/workout_videos');

      if (!await videoDir.exists()) {
        return [];
      }

      final files = videoDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.mp4'))
          .toList();

      // Trier par date (plus récent en premier)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      if (kDebugMode) {
        debugPrint('📹 ${files.length} vidéo(s) trouvée(s)');
      }

      return files;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur récupération vidéos: $e');
      }
      return [];
    }
  }

  /// Supprimer une vidéo
  Future<bool> deleteVideo(String videoPath) async {
    try {
      final file = File(videoPath);
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          debugPrint('✅ Vidéo supprimée: $videoPath');
        }
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur suppression vidéo: $e');
      }
      return false;
    }
  }
}
