import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../utils/theme.dart';
import '../models/video_analysis.dart';
import '../services/video_analysis_service.dart';
import 'video_recorder_screen.dart';

class RealVideoAnalysisScreen extends StatefulWidget {
  const RealVideoAnalysisScreen({super.key});

  @override
  State<RealVideoAnalysisScreen> createState() => _RealVideoAnalysisScreenState();
}

class _RealVideoAnalysisScreenState extends State<RealVideoAnalysisScreen> {
  final VideoAnalysisService _videoService = VideoAnalysisService();
  List<VideoAnalysis> _analyses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    setState(() {
      _isLoading = true;
    });

    final analyses = await _videoService.getAnalyses();
    
    if (mounted) {
      setState(() {
        _analyses = analyses;
        _isLoading = false;
      });
    }
  }

  Future<void> _recordVideo() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const VideoRecorderScreen(),
      ),
    );

    if (result != null) {
      await _loadAnalyses();
      if (mounted) {
        // Trouver la vidéo qui vient d'être enregistrée (la plus récente)
        if (_analyses.isNotEmpty) {
          final latestAnalysis = _analyses.first;
          
          // Afficher immédiatement l'analyse
          _showAnalysisDetails(latestAnalysis);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Vidéo sauvegardée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteAnalysis(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Supprimer la vidéo ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer', style: TextStyle(color: AppTheme.neonRed)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _videoService.deleteAnalysis(id);
      await _loadAnalyses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Vidéo supprimée')),
        );
      }
    }
  }

  void _shareVideo(VideoAnalysis analysis) {
    if (kIsWeb) {
      Share.share(
        'Découvrez mon analyse technique avec Muscle Master ! 💪🏋️\n\nExercice : ${analysis.exerciseName ?? "Non spécifié"}',
        subject: 'Mon entraînement - Muscle Master',
      );
    } else {
      Share.shareXFiles(
        [XFile(analysis.videoPath)],
        text: 'Découvrez mon analyse technique avec Muscle Master ! 💪🏋️',
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('📤 Partage en cours...'),
        backgroundColor: AppTheme.neonBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANALYSE VIDÉO IA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
            tooltip: 'Informations',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalyses,
              child: _analyses.isEmpty
                  ? _buildEmptyState()
                  : _buildAnalysesList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _recordVideo,
        backgroundColor: AppTheme.neonRed,
        icon: const Icon(Icons.videocam, color: Colors.white),
        label: const Text(
          'ENREGISTRER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 120,
              color: AppTheme.textDisabled,
            ),
            const SizedBox(height: 24),
            Text(
              'AUCUNE VIDÉO',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enregistrez votre première vidéo\npour commencer l\'analyse technique',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            _buildAnalysisInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisInfo() {
    return Container(
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
            Icons.auto_awesome,
            size: 48,
            color: AppTheme.neonPurple,
          ),
          const SizedBox(height: 16),
          Text(
            'ANALYSE TECHNIQUE IA',
            style: TextStyle(
              color: AppTheme.neonPurple,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'L\'IA analyse automatiquement :',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalysisFeature(
            icon: Icons.speed,
            title: 'TEMPO',
            description: 'Vitesse et phases du mouvement',
            color: AppTheme.neonBlue,
          ),
          const SizedBox(height: 12),
          _buildAnalysisFeature(
            icon: Icons.accessibility_new,
            title: 'POSTURE',
            description: 'Alignement et position du corps',
            color: AppTheme.neonGreen,
          ),
          const SizedBox(height: 12),
          _buildAnalysisFeature(
            icon: Icons.fitness_center,
            title: 'CHARGE',
            description: 'Recommandations sur le poids',
            color: AppTheme.neonOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisFeature({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _analyses.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildStatsCard(),
          );
        }
        
        final analysis = _analyses[index - 1];
        return _buildAnalysisCard(analysis);
      },
    );
  }

  Widget _buildStatsCard() {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'VIDÉOS',
              value: _analyses.length.toString(),
              color: AppTheme.neonPurple,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.textDisabled.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              label: 'CETTE SEMAINE',
              value: _analyses.where((a) {
                final diff = DateTime.now().difference(a.recordedAt).inDays;
                return diff <= 7;
              }).length.toString(),
              color: AppTheme.neonBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisCard(VideoAnalysis analysis) {
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'fr_FR');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.neonGreen.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showAnalysisDetails(analysis),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.play_circle_filled,
                      color: AppTheme.neonGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          analysis.exerciseName ?? 'Exercice enregistré',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(analysis.recordedAt),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: AppTheme.textSecondary),
                    color: AppTheme.cardDark,
                    onSelected: (value) {
                      if (value == 'share') {
                        _shareVideo(analysis);
                      } else if (value == 'delete') {
                        _deleteAnalysis(analysis.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            Icon(Icons.share, color: AppTheme.neonBlue, size: 20),
                            const SizedBox(width: 12),
                            const Text('Partager'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppTheme.neonRed, size: 20),
                            const SizedBox(width: 12),
                            const Text('Supprimer'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAnalysisTag(
                      icon: Icons.speed,
                      label: 'TEMPO',
                      color: AppTheme.neonBlue,
                    ),
                    _buildAnalysisTag(
                      icon: Icons.accessibility_new,
                      label: 'POSTURE',
                      color: AppTheme.neonGreen,
                    ),
                    _buildAnalysisTag(
                      icon: Icons.fitness_center,
                      label: 'CHARGE',
                      color: AppTheme.neonOrange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  void _showAnalysisDetails(VideoAnalysis analysis) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                analysis.exerciseName ?? 'Exercice enregistré',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('dd MMMM yyyy • HH:mm', 'fr_FR').format(analysis.recordedAt),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              _buildDetailSection(
                icon: Icons.speed,
                title: 'TEMPO',
                description: analysis.analysisResults?['tempo'] ?? 'Analyse en cours...',
                color: AppTheme.neonBlue,
              ),
              const SizedBox(height: 20),
              _buildDetailSection(
                icon: Icons.accessibility_new,
                title: 'POSTURE',
                description: analysis.analysisResults?['posture'] ?? 'Analyse en cours...',
                color: AppTheme.neonGreen,
              ),
              const SizedBox(height: 20),
              _buildDetailSection(
                icon: Icons.fitness_center,
                title: 'CHARGE',
                description: analysis.analysisResults?['charge'] ?? 'Analyse en cours...',
                color: AppTheme.neonOrange,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _shareVideo(analysis);
                  },
                  icon: const Icon(Icons.share),
                  label: const Text(
                    'PARTAGER',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonBlue,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Row(
          children: [
            Icon(Icons.info, color: AppTheme.neonPurple),
            const SizedBox(width: 12),
            const Text('À propos'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ANALYSE VIDÉO IA',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cette fonctionnalité utilise l\'intelligence artificielle pour analyser votre technique d\'exécution.\n\n'
                'Actuellement en version démo, l\'analyse complète avec l\'API Gemini Vision sera disponible prochainement.\n\n'
                'Fonctionnalités actuelles :\n'
                '• Enregistrement vidéo\n'
                '• Sauvegarde locale\n'
                '• Historique des vidéos\n'
                '• Partage sur réseaux sociaux',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'FERMER',
              style: TextStyle(color: AppTheme.neonPurple),
            ),
          ),
        ],
      ),
    );
  }
}
