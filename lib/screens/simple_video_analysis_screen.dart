import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/theme.dart';

class SimpleVideoAnalysisScreen extends StatefulWidget {
  const SimpleVideoAnalysisScreen({super.key});

  @override
  State<SimpleVideoAnalysisScreen> createState() => _SimpleVideoAnalysisScreenState();
}

class _SimpleVideoAnalysisScreenState extends State<SimpleVideoAnalysisScreen> {
  bool _isRecording = false;
  String? _recordedVideoPath;

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    
    // Simuler un enregistrement de 3 secondes
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _recordedVideoPath = '/simulated/path/video.mp4';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Vidéo enregistrée ! (Mode démo)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _shareVideo() {
    if (_recordedVideoPath != null) {
      // Note: En production, share_plus partagerait le vrai fichier
      Share.share(
        'Découvrez mon analyse technique avec Muscle Master ! 💪🏋️',
        subject: 'Mon entraînement - Muscle Master',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('📤 Partage en cours...'),
          backgroundColor: AppTheme.neonBlue,
        ),
      );
    }
  }

  void _editWithExternalApp(String appName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎬 Ouverture de $appName... (Mode démo)'),
        backgroundColor: AppTheme.neonPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANALYSE VIDÉO IA'),
        actions: [
          if (_recordedVideoPath != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareVideo,
              tooltip: 'Partager',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Zone d'enregistrement
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonPurple.withOpacity(0.2),
                    AppTheme.neonBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonPurple.withOpacity(0.5)),
              ),
              child: Column(
                children: [
                  Icon(
                    _isRecording ? Icons.videocam : Icons.video_camera_front,
                    size: 64,
                    color: _isRecording ? Colors.red : AppTheme.neonPurple,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isRecording ? 'ENREGISTREMENT...' : 'ANALYSE TECHNIQUE IA',
                    style: TextStyle(
                      color: _isRecording ? Colors.red : AppTheme.neonPurple,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isRecording 
                        ? 'Filmez votre série en cours...'
                        : 'L\'intelligence artificielle analyse votre mouvement pour détecter :',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isRecording) ...[
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bouton enregistrement
            SizedBox(
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _isRecording ? null : _startRecording,
                icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
                label: Text(
                  _isRecording ? 'ENREGISTREMENT...' : 'ENREGISTRER UNE VIDÉO',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRecording ? Colors.grey : Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            if (_recordedVideoPath != null) ...[
              const SizedBox(height: 16),
              // Boutons de partage
              _buildShareButtons(),
              const SizedBox(height: 16),
              // Boutons d'édition
              _buildEditButtons(),
            ],

            const SizedBox(height: 24),

            // Points d'analyse
            _buildAnalysisPoint(
              icon: Icons.speed,
              title: 'TEMPO',
              description: 'Vitesse du mouvement (phases excentrique, isométrique, concentrique)',
              color: AppTheme.neonBlue,
            ),
            const SizedBox(height: 16),
            _buildAnalysisPoint(
              icon: Icons.accessibility_new,
              title: 'POSTURE',
              description: 'Alignement du corps, position du dos, des hanches, des genoux',
              color: AppTheme.neonGreen,
            ),
            const SizedBox(height: 16),
            _buildAnalysisPoint(
              icon: Icons.fitness_center,
              title: 'CHARGE',
              description: 'Recommandations sur la charge selon votre technique',
              color: AppTheme.neonOrange,
            ),
            const SizedBox(height: 32),

            // Note technique
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.neonBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mode démo : L\'enregistrement réel nécessite une caméra mobile et l\'API Gemini Vision',
                      style: TextStyle(
                        color: AppTheme.textDisabled,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
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

  Widget _buildShareButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PARTAGER SUR',
            style: TextStyle(
              color: AppTheme.neonBlue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSocialButton('Instagram', Icons.camera_alt, Colors.purple, () => _shareVideo()),
              _buildSocialButton('TikTok', Icons.music_note, Colors.black, () => _shareVideo()),
              _buildSocialButton('YouTube', Icons.play_circle, Colors.red, () => _shareVideo()),
              _buildSocialButton('Facebook', Icons.facebook, Colors.blue, () => _shareVideo()),
              _buildSocialButton('Twitter', Icons.tag, Colors.lightBlue, () => _shareVideo()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MODIFIER AVEC',
            style: TextStyle(
              color: AppTheme.neonPurple,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildEditAppButton('CapCut', Icons.cut, Colors.black, () => _editWithExternalApp('CapCut')),
              _buildEditAppButton('InShot', Icons.videocam, Colors.orange, () => _editWithExternalApp('InShot')),
              _buildEditAppButton('VN', Icons.video_collection, Colors.teal, () => _editWithExternalApp('VN')),
              _buildEditAppButton('Adobe', Icons.auto_awesome, Colors.blue, () => _editWithExternalApp('Adobe Premiere Rush')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildEditAppButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildAnalysisPoint({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
