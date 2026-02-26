import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/social_service.dart';
import '../models/social_model.dart';
import 'profile_preview_bottom_sheet.dart';

/// Grid affichant les utilisateurs actifs en salle de sport
/// Récupère les données via SocialService.getActiveUsers()
class ActiveMascotsGrid extends StatefulWidget {
  const ActiveMascotsGrid({super.key});

  @override
  State<ActiveMascotsGrid> createState() => _ActiveMascotsGridState();
}

class _ActiveMascotsGridState extends State<ActiveMascotsGrid> {
  List<GymPresence> _activeUsers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActiveUsers();
  }

  Future<void> _loadActiveUsers() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final users = await SocialService.getActiveUsers();
      
      setState(() {
        _activeUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryOrange,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppTheme.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadActiveUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
              ),
            ),
          ],
        ),
      );
    }

    if (_activeUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              color: AppTheme.textSecondary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur actif',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sois le premier à t\'entraîner !',
              style: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActiveUsers,
      color: AppTheme.primaryOrange,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: _activeUsers.length,
        itemBuilder: (context, index) {
          final user = _activeUsers[index];
          return _buildMascotCard(context, user);
        },
      ),
    );
  }

  Widget _buildMascotCard(BuildContext context, GymPresence user) {
    return GestureDetector(
      onTap: () {
        ProfilePreviewBottomSheet.show(context, user);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.cardDark,
              AppTheme.primaryDark.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryOrange.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryOrange.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mascotte Image (PNG transparent)
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  _getMascotAssetPath(user.mascotType),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.cardDark,
                      child: Icon(
                        Icons.sports_martial_arts,
                        color: AppTheme.primaryOrange,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Pseudo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                user.pseudo,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            
            // Gym
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: AppTheme.textSecondary,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      user.gymId,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            
            // État actif
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user.isActive 
                    ? AppTheme.neonGreen.withValues(alpha: 0.2)
                    : AppTheme.textDisabled.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: user.isActive 
                      ? AppTheme.neonGreen.withValues(alpha: 0.5)
                      : AppTheme.textDisabled.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: user.isActive ? AppTheme.neonGreen : AppTheme.textDisabled,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.isActive ? 'En ligne' : 'Hors ligne',
                    style: TextStyle(
                      color: user.isActive ? AppTheme.neonGreen : AppTheme.textDisabled,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

  String _getMascotAssetPath(String mascotType) {
    switch (mascotType.toLowerCase()) {
      case 'male':
      case 'flexo':
        return 'assets/mascots/flexo_lion_male.png';
      case 'female':
      case 'flexa':
        return 'assets/mascots/flexa_lioness_female.png';
      default:
        return 'assets/mascots/flexo_lion_male.png';
    }
  }
}
