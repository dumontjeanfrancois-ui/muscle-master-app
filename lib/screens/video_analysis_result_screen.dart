import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/workout_video.dart';
import '../utils/theme.dart';

class VideoAnalysisResultScreen extends StatelessWidget {
  final WorkoutVideo workoutVideo;

  const VideoAnalysisResultScreen({super.key, required this.workoutVideo});

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.neonGreen;
    if (score >= 60) return AppTheme.neonBlue;
    if (score >= 40) return AppTheme.neonOrange;
    return const Color(0xFFFF3333);
  }

  @override
  Widget build(BuildContext context) {
    final analysis = workoutVideo.analysis;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text(
          'ANALYSE ${workoutVideo.exerciseName.toUpperCase()}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: AppTheme.surfaceDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareResults(context),
          ),
        ],
      ),
      body: analysis == null
          ? const Center(child: Text('Aucune analyse disponible'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score global
                  _buildOverallScore(analysis),
                  const SizedBox(height: 24),

                  // Scores détaillés
                  _buildDetailedScores(analysis),
                  const SizedBox(height: 24),

                  // Points forts
                  _buildSection(
                    title: 'POINTS FORTS',
                    icon: Icons.check_circle,
                    color: AppTheme.neonGreen,
                    items: analysis.strengthPoints,
                  ),
                  const SizedBox(height: 20),

                  // Points d'amélioration
                  _buildSection(
                    title: 'À AMÉLIORER',
                    icon: Icons.warning,
                    color: AppTheme.neonOrange,
                    items: analysis.improvementPoints,
                  ),
                  const SizedBox(height: 20),

                  // Feedback technique
                  _buildTechnicalFeedback(analysis),
                  const SizedBox(height: 24),

                  // Bouton refaire
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam, color: AppTheme.primaryDark),
                        const SizedBox(width: 8),
                        Text(
                          'REFAIRE UNE VIDÉO',
                          style: TextStyle(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
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

  Widget _buildOverallScore(WorkoutAnalysis analysis) {
    final scoreColor = _getScoreColor(analysis.overallScore);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scoreColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'SCORE GLOBAL',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: analysis.overallScore / 100,
                  strokeWidth: 12,
                  backgroundColor: AppTheme.surfaceDark,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${analysis.overallScore}',
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/100',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getScoreLabel(analysis.overallScore),
            style: TextStyle(
              color: scoreColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreLabel(int score) {
    if (score >= 90) return 'EXCELLENT';
    if (score >= 80) return 'TRÈS BIEN';
    if (score >= 70) return 'BIEN';
    if (score >= 60) return 'CORRECT';
    if (score >= 40) return 'MOYEN';
    return 'À RETRAVAILLER';
  }

  Widget _buildDetailedScores(WorkoutAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonBlue.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppTheme.neonBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'SCORES DÉTAILLÉS',
                style: TextStyle(
                  color: AppTheme.neonBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...analysis.detailedScores.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildScoreBar(
                label: entry.key.toUpperCase(),
                score: entry.value,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScoreBar({required String label, required int score}) {
    final scoreColor = _getScoreColor(score);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$score/100',
              style: TextStyle(
                color: scoreColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: AppTheme.surfaceDark,
            valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTechnicalFeedback(WorkoutAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonPurple.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment, color: AppTheme.neonPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'FEEDBACK TECHNIQUE',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            analysis.technicalFeedback,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _shareResults(BuildContext context) {
    final analysis = workoutVideo.analysis;
    if (analysis == null) return;

    final text = '''
🏋️ MUSCLE MASTER - Analyse ${workoutVideo.exerciseName}

📊 Score global: ${analysis.overallScore}/100 - ${_getScoreLabel(analysis.overallScore)}

✅ Points forts:
${analysis.strengthPoints.map((p) => '• $p').join('\n')}

⚠️ À améliorer:
${analysis.improvementPoints.map((p) => '• $p').join('\n')}

💡 ${analysis.technicalFeedback}

#MuscleMaster #Fitness #Musculation
    ''';

    Share.share(text);
  }
}
