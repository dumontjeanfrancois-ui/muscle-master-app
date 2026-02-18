import 'package:flutter/material.dart';
import '../services/flexo_mascot_service.dart';
import '../utils/theme.dart';
import '../screens/nutrition_screen.dart';
import '../screens/programs_screen.dart';
import '../screens/exercise_library_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/calculators_screen.dart';

/// Dialogue de recherche interactif de Flexo
class FlexoSearchDialog extends StatefulWidget {
  const FlexoSearchDialog({super.key});

  @override
  State<FlexoSearchDialog> createState() => _FlexoSearchDialogState();
}

class _FlexoSearchDialogState extends State<FlexoSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<FlexoSearchResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Recherche dans toutes les catégories
    final results = FlexoSearchEngine.search(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.neonOrange,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonOrange.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header avec Flexo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonOrange,
                    AppTheme.neonOrange.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  // Avatar Flexo
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Text(
                        '🦁', // On changera selon ton choix
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Flexo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Que cherches-tu ?',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ex: journal alimentaire, exercices, programmes...',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppTheme.neonOrange,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppTheme.backgroundLight.withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.neonOrange),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.neonOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.neonOrange, width: 2),
                  ),
                ),
                onChanged: _performSearch,
              ),
            ),

            // Résultats de recherche
            Flexible(
              child: _isSearching
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: AppTheme.neonOrange,
                        ),
                      ),
                    )
                  : _searchResults.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return _buildSearchResultTile(context, result);
                          },
                        ),
            ),

            // Suggestions populaires (si pas de recherche)
            if (_searchController.text.isEmpty && _searchResults.isEmpty)
              _buildPopularSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun résultat pour "${_searchController.text}"',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essaie avec d\'autres mots-clés',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultTile(BuildContext context, FlexoSearchResult result) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: result.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          result.icon,
          color: result.color,
          size: 24,
        ),
      ),
      title: Text(
        result.title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        result.description,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppTheme.neonOrange,
        size: 16,
      ),
      onTap: () {
        Navigator.pop(context);
        result.onTap(context);
      },
    );
  }

  Widget _buildPopularSuggestions() {
    final suggestions = FlexoSearchEngine.getPopularSuggestions();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.neonOrange.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppTheme.neonOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recherches populaires',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return InkWell(
                onTap: () {
                  _searchController.text = suggestion;
                  _performSearch(suggestion);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.neonOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.neonOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Résultat de recherche
class FlexoSearchResult {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Function(BuildContext) onTap;

  FlexoSearchResult({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// Moteur de recherche de Flexo
class FlexoSearchEngine {
  static List<FlexoSearchResult> search(String query) {
    final lowercaseQuery = query.toLowerCase().trim();
    final results = <FlexoSearchResult>[];

    // Base de données de recherche
    final searchDatabase = _getSearchDatabase();

    // Recherche dans tous les items
    for (final item in searchDatabase) {
      // Recherche dans le titre
      if (item.title.toLowerCase().contains(lowercaseQuery)) {
        results.add(item);
        continue;
      }

      // Recherche dans la description
      if (item.description.toLowerCase().contains(lowercaseQuery)) {
        results.add(item);
        continue;
      }

      // Recherche dans les mots-clés
      for (final keyword in item.keywords) {
        if (keyword.toLowerCase().contains(lowercaseQuery)) {
          results.add(item);
          break;
        }
      }
    }

    return results;
  }

  static List<String> getPopularSuggestions() {
    return [
      'journal alimentaire',
      'exercices',
      'programmes',
      'statistiques',
      'coach IA',
      'calculateurs',
    ];
  }

  static List<_SearchItem> _getSearchDatabase() {
    return [
      // Nutrition
      _SearchItem(
        title: 'Journal Alimentaire',
        description: 'Enregistre tes repas et suis tes macros',
        icon: Icons.restaurant,
        color: AppTheme.neonGreen,
        keywords: ['nutrition', 'repas', 'manger', 'calories', 'macros', 'aliments', 'nourriture'],
        onTap: (context) => Navigator.pushNamed(context, '/nutrition'),
      ),
      _SearchItem(
        title: 'Calculateur de Macros',
        description: 'Calcule tes besoins caloriques et macros',
        icon: Icons.calculate,
        color: AppTheme.neonBlue,
        keywords: ['calculer', 'calories', 'protéines', 'glucides', 'lipides', 'IMC'],
        onTap: (context) => Navigator.pushNamed(context, '/calculators'),
      ),

      // Programmes
      _SearchItem(
        title: 'Programmes d\'Entraînement',
        description: 'Programmes prédéfinis et personnalisés',
        icon: Icons.fitness_center,
        color: AppTheme.neonOrange,
        keywords: ['workout', 'entraînement', 'musculation', 'programme', 'séance'],
        onTap: (context) => Navigator.pushNamed(context, '/programs'),
      ),
      _SearchItem(
        title: 'Générateur de Programme IA',
        description: 'Crée un programme personnalisé avec l\'IA',
        icon: Icons.auto_awesome,
        color: AppTheme.neonPurple,
        keywords: ['IA', 'intelligence artificielle', 'personnalisé', 'créer', 'générer'],
        onTap: (context) => Navigator.pushNamed(context, '/ai_program_generator'),
      ),

      // Exercices
      _SearchItem(
        title: 'Bibliothèque d\'Exercices',
        description: 'Plus de 115 exercices avec vidéos',
        icon: Icons.library_books,
        color: AppTheme.neonGreen,
        keywords: ['exercice', 'mouvement', 'vidéo', 'technique', 'bibliothèque'],
        onTap: (context) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen()),
        ),
      ),

      // Suivi
      _SearchItem(
        title: 'Suivi des Progrès',
        description: 'Statistiques et évolution de tes performances',
        icon: Icons.trending_up,
        color: AppTheme.neonBlue,
        keywords: ['statistiques', 'progrès', 'évolution', 'performance', 'graphique', 'suivi'],
        onTap: (context) => Navigator.pushNamed(context, '/progress'),
      ),

      // Coach IA
      _SearchItem(
        title: 'Coach IA',
        description: 'Pose des questions à ton coach virtuel',
        icon: Icons.chat,
        color: AppTheme.neonPurple,
        keywords: ['coach', 'assistant', 'question', 'aide', 'conseil', 'IA'],
        onTap: (context) => Navigator.pushNamed(context, '/ai_coach'),
      ),

      // Calculateurs
      _SearchItem(
        title: 'Calculateurs',
        description: 'IMC, 1RM, besoins caloriques',
        icon: Icons.calculate,
        color: AppTheme.neonOrange,
        keywords: ['calculer', 'IMC', '1RM', 'calories', 'charge maximale'],
        onTap: (context) => Navigator.pushNamed(context, '/calculators'),
      ),

      // Profil
      _SearchItem(
        title: 'Profil',
        description: 'Gérer ton compte et tes paramètres',
        icon: Icons.person,
        color: AppTheme.neonGreen,
        keywords: ['profil', 'compte', 'paramètres', 'réglages', 'photo'],
        onTap: (context) => Navigator.pushNamed(context, '/profile'),
      ),
    ];
  }
}

class _SearchItem extends FlexoSearchResult {
  final List<String> keywords;

  _SearchItem({
    required super.title,
    required super.description,
    required super.icon,
    required super.color,
    required super.onTap,
    required this.keywords,
  });
}
