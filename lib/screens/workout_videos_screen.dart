import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../services/workout_recording_service.dart';

/// Écran de gestion des vidéos d'entraînement enregistrées
class WorkoutVideosScreen extends StatefulWidget {
  const WorkoutVideosScreen({super.key});

  @override
  State<WorkoutVideosScreen> createState() => _WorkoutVideosScreenState();
}

class _WorkoutVideosScreenState extends State<WorkoutVideosScreen> {
  final _recordingService = WorkoutRecordingService();
  List<File> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
    });

    final videos = await _recordingService.getSavedVideos();
    
    setState(() {
      _videos = videos;
      _isLoading = false;
    });
  }

  Future<void> _deleteVideo(File video) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        title: const Text('Supprimer la vidéo', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette vidéo ?\n\nCette action est irréversible.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleted = await _recordingService.deleteVideo(video.path);
      if (deleted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Vidéo supprimée'),
            backgroundColor: Colors.green,
          ),
        );
        _loadVideos();
      }
    }
  }

  Future<void> _shareVideo(File video) async {
    try {
      await Share.shareXFiles(
        [XFile(video.path)],
        text: 'Ma vidéo d\'entraînement Muscle Master 💪',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur partage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadToGallery(File video) async {
    try {
      // Pour Android/iOS, copier dans le dossier Downloads ou DCIM
      final downloadsDir = Platform.isAndroid
          ? Directory('/storage/emulated/0/Download')
          : await getApplicationDocumentsDirectory();

      final fileName = video.path.split('/').last;
      final destination = File('${downloadsDir.path}/$fileName');
      
      await video.copy(destination.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Vidéo téléchargée: ${destination.path}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur téléchargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _analyzeVideo(File video) {
    // Navigation vers l'écran d'analyse vidéo existant
    Navigator.pushNamed(
      context,
      '/video-analysis',
      arguments: video.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Mes Vidéos d\'Entraînement'),
        backgroundColor: const Color(0xFF1D1E33),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVideos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _videos.isEmpty
              ? _buildEmptyState()
              : _buildVideoList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.videocam_off,
            size: 80,
            color: Colors.white38,
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucune vidéo enregistrée',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Utilisez le bouton REC pendant vos séances pour enregistrer vos exercices',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(File video) {
    final fileName = video.path.split('/').last;
    final fileSize = (video.lengthSync() / 1024 / 1024).toStringAsFixed(2); // MB
    final date = video.lastModifiedSync();

    return Card(
      color: const Color(0xFF1D1E33),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail vidéo
            _buildVideoThumbnail(video),
            
            const SizedBox(height: 12),
            
            // Infos vidéo
            Text(
              fileName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.storage, size: 16, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  '$fileSize MB',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  icon: Icons.analytics,
                  label: 'Analyser',
                  color: const Color(0xFF00D4AA),
                  onPressed: () => _analyzeVideo(video),
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Partager',
                  color: const Color(0xFF4A90E2),
                  onPressed: () => _shareVideo(video),
                ),
                _buildActionButton(
                  icon: Icons.download,
                  label: 'Télécharger',
                  color: const Color(0xFFFF6B35),
                  onPressed: () => _downloadToGallery(video),
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Supprimer',
                  color: Colors.red,
                  onPressed: () => _deleteVideo(video),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(File video) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Placeholder ou thumbnail
            const Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white54,
            ),
            
            // Badge REC
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.fiber_manual_record, size: 12, color: Colors.white),
                    SizedBox(width: 4),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
