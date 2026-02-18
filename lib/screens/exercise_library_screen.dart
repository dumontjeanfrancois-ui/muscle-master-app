import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../services/exercise_database.dart';
import '../services/exercise_favorites_service.dart';
import '../utils/theme.dart';
import 'exercise_detail_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedMuscle;
  String? _selectedEquipment;
  String? _selectedDifficulty;
  bool _showFavoritesOnly = false;
  
  final ExerciseFavoritesService _favoritesService = ExerciseFavoritesService();

  final List<String> _muscleGroups = [
    'Pectoraux',
    'Grand dorsal',
    'Trapèzes',
    'Quadriceps',
    'Ischio-jambiers',
    'Fessiers',
    'Épaules (deltoïdes)',
    'Biceps',
    'Triceps',
    'Abdominaux',
    'Lombaires',
  ];

  final List<String> _equipmentTypes = [
    'Barre',
    'Haltères',
    'Poids du corps',
    'Barres parallèles',
    'Barre de traction',
    'Machine',
  ];

  final List<String> _difficultyLevels = [
    'Débutant',
    'Intermédiaire',
    'Avancé',
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _isLoading = true);
    
    final exercises = await ExerciseDatabase.getAllExercises();
    final favoriteIds = await _favoritesService.getFavorites();
    
    setState(() {
      _exercises = exercises;
      _favoriteIds = favoriteIds;
      _filteredExercises = exercises;
      _isLoading = false;
    });
  }

  void _applyFilters() async {
    setState(() => _isLoading = true);
    
    List<Exercise> filtered = List.from(_exercises);
    
    // Filtre favoris
    if (_showFavoritesOnly) {
      filtered = filtered.where((ex) => _favoriteIds.contains(ex.id)).toList();
    }
    
    // Filtre recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((ex) => ex.matchesQuery(_searchQuery)).toList();
    }
    
    // Filtre muscle
    if (_selectedMuscle != null) {
      filtered = filtered.where((ex) =>
        ex.primaryMuscles.contains(_selectedMuscle) ||
        ex.secondaryMuscles.contains(_selectedMuscle)
      ).toList();
    }
    
    // Filtre équipement
    if (_selectedEquipment != null) {
      filtered = filtered.where((ex) => ex.equipment == _selectedEquipment).toList();
    }
    
    // Filtre difficulté
    if (_selectedDifficulty != null) {
      filtered = filtered.where((ex) => ex.difficulty == _selectedDifficulty).toList();
    }
    
    setState(() {
      _filteredExercises = filtered;
      _isLoading = false;
    });
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedMuscle = null;
      _selectedEquipment = null;
      _selectedDifficulty = null;
      _showFavoritesOnly = false;
      _filteredExercises = _exercises;
    });
  }

  Future<void> _toggleFavorite(String exerciseId) async {
    await _favoritesService.toggleFavorite(exerciseId);
    final favoriteIds = await _favoritesService.getFavorites();
    setState(() {
      _favoriteIds = favoriteIds;
    });
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('BIBLIOTHÈQUE D\'EXERCICES'),
        backgroundColor: AppTheme.cardDark,
        actions: [
          // Bouton favoris
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? AppTheme.neonPink : Colors.white,
            ),
            onPressed: () {
              setState(() => _showFavoritesOnly = !_showFavoritesOnly);
              _applyFilters();
            },
            tooltip: 'Favoris uniquement',
          ),
          // Menu export/import
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'export') {
                _exportFavorites();
              } else if (value == 'import') {
                _importFavorites();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.upload, color: AppTheme.neonGreen),
                    SizedBox(width: 12),
                    Text('Exporter favoris'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: Row(
                  children: [
                    Icon(Icons.download, color: AppTheme.neonBlue),
                    SizedBox(width: 12),
                    Text('Importer favoris'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          _buildSearchBar(),
          
          // Filtres
          _buildFilters(),
          
          // Compteur de résultats
          _buildResultsCount(),
          
          // Liste des exercices
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExercises.isEmpty
                    ? _buildEmptyState()
                    : _buildExercisesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _applyFilters();
        },
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Rechercher un exercice...',
          hintStyle: TextStyle(color: AppTheme.textSecondary),
          prefixIcon: Icon(Icons.search, color: AppTheme.neonBlue),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                    _applyFilters();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final hasActiveFilters = _selectedMuscle != null || 
                            _selectedEquipment != null || 
                            _selectedDifficulty != null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtre muscle
                _buildFilterChip(
                  label: _selectedMuscle ?? 'Muscle',
                  icon: Icons.fitness_center,
                  isSelected: _selectedMuscle != null,
                  onTap: () => _showMuscleFilter(),
                ),
                const SizedBox(width: 8),
                
                // Filtre équipement
                _buildFilterChip(
                  label: _selectedEquipment ?? 'Équipement',
                  icon: Icons.sports_gymnastics,
                  isSelected: _selectedEquipment != null,
                  onTap: () => _showEquipmentFilter(),
                ),
                const SizedBox(width: 8),
                
                // Filtre difficulté
                _buildFilterChip(
                  label: _selectedDifficulty ?? 'Difficulté',
                  icon: Icons.show_chart,
                  isSelected: _selectedDifficulty != null,
                  onTap: () => _showDifficultyFilter(),
                ),
                
                if (hasActiveFilters) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: Icon(Icons.clear_all, size: 16, color: AppTheme.neonRed),
                    label: Text('Effacer', style: TextStyle(color: AppTheme.neonRed)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonBlue.withValues(alpha: 0.2) : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.neonBlue : AppTheme.textDisabled.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.neonBlue : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.neonBlue : AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.list, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Text(
            '${_filteredExercises.length} exercice${_filteredExercises.length > 1 ? 's' : ''}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppTheme.textDisabled),
          const SizedBox(height: 16),
          Text(
            'Aucun exercice trouvé',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez de modifier vos filtres',
            style: TextStyle(
              color: AppTheme.textDisabled,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: Icon(Icons.refresh, color: AppTheme.neonBlue),
            label: Text('Réinitialiser les filtres', style: TextStyle(color: AppTheme.neonBlue)),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        final exercise = _filteredExercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    final isFavorite = _favoriteIds.contains(exercise.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExerciseDetailScreen(
                  exercise: exercise,
                  onFavoriteToggle: () => _toggleFavorite(exercise.id),
                ),
              ),
            ).then((_) async {
              // Rafraîchir les favoris après retour
              final favoriteIds = await _favoritesService.getFavorites();
              setState(() {
                _favoriteIds = favoriteIds;
              });
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icône de difficulté
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(exercise.difficulty).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: _getDifficultyColor(exercise.difficulty),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Nom
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    // Bouton favori
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite ? Colors.amber : AppTheme.textSecondary,
                      ),
                      onPressed: () => _toggleFavorite(exercise.id),
                    ),
                  ],
                ),
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    Text(
                      exercise.description,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTag(exercise.difficulty, _getDifficultyColor(exercise.difficulty)),
                        _buildTag(exercise.equipment, AppTheme.neonPurple),
                        ...exercise.primaryMuscles.map((muscle) => _buildTag(muscle, AppTheme.neonGreen)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
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

  void _showMuscleFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(
        title: 'Sélectionner un muscle',
        options: _muscleGroups,
        selectedOption: _selectedMuscle,
        onSelect: (value) {
          setState(() => _selectedMuscle = value);
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showEquipmentFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(
        title: 'Sélectionner un équipement',
        options: _equipmentTypes,
        selectedOption: _selectedEquipment,
        onSelect: (value) {
          setState(() => _selectedEquipment = value);
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showDifficultyFilter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterSheet(
        title: 'Sélectionner une difficulté',
        options: _difficultyLevels,
        selectedOption: _selectedDifficulty,
        onSelect: (value) {
          setState(() => _selectedDifficulty = value);
          _applyFilters();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildFilterSheet({
    required String title,
    required List<String> options,
    required String? selectedOption,
    required Function(String?) onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) {
            final isSelected = option == selectedOption;
            return ListTile(
              title: Text(
                option,
                style: TextStyle(
                  color: isSelected ? AppTheme.neonBlue : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? AppTheme.neonBlue : AppTheme.textDisabled,
              ),
              onTap: () => onSelect(isSelected ? null : option),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _exportFavorites() async {
    final jsonString = await _favoritesService.exportFavorites();
    
    if (jsonString == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun favori à exporter'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Créer un fichier temporaire avec le contenu
    final fileName = 'favoris_exercices_${DateTime.now().millisecondsSinceEpoch}.json';
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardDark,
          title: const Text('Favoris exportés', style: TextStyle(color: AppTheme.neonGreen)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vos favoris ont été exportés avec succès.',
                style: TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
                ),
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Copiez ce texte et sauvegardez-le dans un fichier.',
                style: TextStyle(color: AppTheme.textDisabled, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer', style: TextStyle(color: AppTheme.neonGreen)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _importFavorites() async {
    final controller = TextEditingController();
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Importer favoris', style: TextStyle(color: AppTheme.neonBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Collez le contenu JSON de vos favoris exportés :',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 10,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: '{"version": "1.0", ...}',
                hintStyle: const TextStyle(color: AppTheme.textDisabled),
                filled: true,
                fillColor: AppTheme.primaryDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: AppTheme.textDisabled)),
          ),
          ElevatedButton(
            onPressed: () async {
              final jsonString = controller.text.trim();
              if (jsonString.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez coller le contenu JSON'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final success = await _favoritesService.importFavorites(jsonString, merge: true);
              
              Navigator.pop(context);
              
              if (success) {
                await _loadExercises(); // Recharger pour mettre à jour les favoris
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Favoris importés avec succès'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Erreur lors de l\'import'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonBlue),
            child: const Text('Importer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
