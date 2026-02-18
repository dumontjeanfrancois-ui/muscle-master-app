import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_favorites_service.dart';
import '../utils/theme.dart';
import '../utils/exercise_videos.dart';
import '../widgets/youtube_player_widget.dart';
import 'exercise_progression_screen.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;
  final VoidCallback? onFavoriteToggle;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
    this.onFavoriteToggle,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  bool _isFavorite = false;
  final ExerciseFavoritesService _favoritesService = ExerciseFavoritesService();

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final isFav = await _favoritesService.isFavorite(widget.exercise.id);
    setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    await _favoritesService.toggleFavorite(widget.exercise.id);
    setState(() => _isFavorite = !_isFavorite);
    if (widget.onFavoriteToggle != null) {
      widget.onFavoriteToggle!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: CustomScrollView(
        slivers: [
          // AppBar avec image
          _buildSliverAppBar(),
          
          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  _buildHeader(),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  _buildSection(
                    title: 'DESCRIPTION',
                    icon: Icons.info_outline,
                    color: AppTheme.neonBlue,
                    child: Text(
                      widget.exercise.description,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Vidéo YouTube (si disponible)
                  if (ExerciseVideos.videoIds.containsKey(widget.exercise.id))
                    _buildSection(
                      title: 'VIDÉO DÉMONSTRATION',
                      icon: Icons.play_circle_outline,
                      color: Colors.red,
                      child: YouTubePlayerWidget(
                        videoId: ExerciseVideos.videoIds[widget.exercise.id]!,
                      ),
                    ),
                  
                  if (ExerciseVideos.videoIds.containsKey(widget.exercise.id))
                    const SizedBox(height: 24),
                  
                  // Muscles ciblés
                  _buildMusclesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Instructions
                  _buildSection(
                    title: 'INSTRUCTIONS',
                    icon: Icons.list_alt,
                    color: AppTheme.neonPurple,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.exercise.instructions.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppTheme.neonPurple.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppTheme.neonPurple),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: TextStyle(
                                      color: AppTheme.neonPurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Conseils
                  if (widget.exercise.tips?.isNotEmpty == true)
                    _buildSection(
                      title: 'CONSEILS',
                      icon: Icons.tips_and_updates,
                      color: AppTheme.neonGreen,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.exercise.tips!.map((tip) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  
                  if (widget.exercise.tips?.isNotEmpty == true)
                    const SizedBox(height: 24),
                  
                  // Erreurs courantes
                  if (widget.exercise.commonMistakes?.isNotEmpty == true)
                    _buildSection(
                      title: 'ERREURS COURANTES',
                      icon: Icons.warning_amber,
                      color: AppTheme.neonOrange,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.exercise.commonMistakes!.map((mistake) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.close, color: AppTheme.neonOrange, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  mistake,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleFavorite,
        backgroundColor: _isFavorite ? AppTheme.neonPink : AppTheme.cardDark,
        label: Text(
          _isFavorite ? 'FAVORI' : 'AJOUTER AUX FAVORIS',
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        icon: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          color: _isFavorite ? Colors.white : AppTheme.neonPink,
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.cardDark,
      actions: [
        IconButton(
          icon: const Icon(Icons.show_chart, color: AppTheme.neonOrange),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseProgressionScreen(exercise: widget.exercise),
              ),
            );
          },
          tooltip: 'Voir la progression',
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.exercise.name,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.neonBlue.withValues(alpha: 0.3),
                AppTheme.neonPurple.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.fitness_center,
              size: 80,
              color: AppTheme.neonBlue.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags principaux
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTag(
              widget.exercise.difficulty,
              _getDifficultyColor(widget.exercise.difficulty),
              Icons.show_chart,
            ),
            _buildTag(
              widget.exercise.equipment,
              AppTheme.neonPurple,
              Icons.sports_gymnastics,
            ),
            _buildTag(
              widget.exercise.category,
              AppTheme.neonBlue,
              Icons.category,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusclesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.accessibility_new, color: AppTheme.neonGreen, size: 24),
              const SizedBox(width: 12),
              const Text(
                'MUSCLES CIBLÉS',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Muscles primaires
          if (widget.exercise.primaryMuscles.isNotEmpty) ...[
            Text(
              'Muscles principaux',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.exercise.primaryMuscles.map((muscle) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    muscle,
                    style: TextStyle(
                      color: AppTheme.neonGreen,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          // Muscles secondaires
          if (widget.exercise.secondaryMuscles.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Muscles secondaires',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.exercise.secondaryMuscles.map((muscle) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    muscle,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Débutant':
        return AppTheme.neonGreen;
      case 'Intermédiaire':
        return AppTheme.neonOrange;
      case 'Avancé':
        return AppTheme.neonRed;
      default:
        return AppTheme.textSecondary;
    }
  }
}
