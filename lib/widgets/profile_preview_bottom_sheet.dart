import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/social_model.dart';
import '../services/social_service.dart';

/// Bottom Sheet d'aperçu du profil d'un utilisateur
/// Affiche les informations et permet d'envoyer une demande de connexion
class ProfilePreviewBottomSheet extends StatefulWidget {
  final GymPresence user;

  const ProfilePreviewBottomSheet({
    super.key,
    required this.user,
  });

  /// Méthode statique pour afficher le bottom sheet
  static Future<void> show(BuildContext context, GymPresence user) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => ProfilePreviewBottomSheet(user: user),
    );
  }

  @override
  State<ProfilePreviewBottomSheet> createState() => 
      _ProfilePreviewBottomSheetState();
}

class _ProfilePreviewBottomSheetState extends State<ProfilePreviewBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isConnected = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
    _checkConnectionStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final connections = await SocialService.getActiveConnections();
      final isConnected = connections.any(
        (conn) => conn.friendId == widget.user.userId,
      );
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _sendConnectionRequest() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await SocialService.createConnection(
        friendId: widget.user.userId,
        friendPseudo: widget.user.pseudo,
        friendMascotType: widget.user.mascotType,
      );

      if (mounted) {
        setState(() {
          _isConnected = true;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connexion envoyée à ${widget.user.pseudo}'),
            backgroundColor: AppTheme.neonGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                // Poignée de fermeture
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Photo de profil (Mascotte)
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        _getMascotAssetPath(widget.user.mascotType),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.cardDark,
                            child: Icon(
                              Icons.sports_martial_arts,
                              color: AppTheme.primaryOrange,
                              size: 60,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pseudo
                Center(
                  child: Text(
                    widget.user.pseudo,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Statut
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.user.isActive 
                          ? AppTheme.neonGreen.withValues(alpha: 0.2)
                          : AppTheme.textDisabled.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.user.isActive 
                            ? AppTheme.neonGreen.withValues(alpha: 0.5)
                            : AppTheme.textDisabled.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.user.isActive 
                                ? AppTheme.neonGreen 
                                : AppTheme.textDisabled,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.user.isActive 
                              ? 'En ligne' 
                              : 'Hors ligne',
                          style: TextStyle(
                            color: widget.user.isActive 
                                ? AppTheme.neonGreen 
                                : AppTheme.textDisabled,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Informations
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.fitness_center,
                        'Salle de sport',
                        widget.user.gymId,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.sports_martial_arts,
                        'Mascotte',
                        widget.user.mascotType,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Boutons d'action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (!_isConnected)
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _sendConnectionRequest,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.person_add),
                          label: Text(_isLoading 
                              ? 'Envoi en cours...' 
                              : 'Devenir ami'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryOrange,
                            minimumSize: const Size.fromHeight(50),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.neonGreen.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppTheme.neonGreen,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Vous êtes déjà connectés',
                                  style: TextStyle(
                                    color: AppTheme.neonGreen,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.textSecondary),
                          minimumSize: const Size.fromHeight(50),
                        ),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryOrange, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
