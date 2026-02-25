import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/social_service.dart';

/// Bottom Sheet Social Modern
/// Remplace l'ancien GymCrushBottomSheet
class SocialBottomSheet extends StatefulWidget {
  const SocialBottomSheet({super.key});

  /// Méthode statique pour afficher le bottom sheet
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (_) => const SocialBottomSheet(),
    );
  }

  @override
  State<SocialBottomSheet> createState() => _SocialBottomSheetState();
}

class _SocialBottomSheetState extends State<SocialBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  
  int _activeConnectionsCount = 0;
  bool _isInvisible = false;
  bool _isLoading = true;

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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final connections = await SocialService.getActiveConnections();
      // TODO: Récupérer l'état du mode invisible depuis les settings
      setState(() {
        _activeConnectionsCount = connections.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
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
                const SizedBox(height: 20),
                
                // En-tête Social
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Réseau Social',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryOrange,
                        ),
                      ),
                      // Badge connections actives
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryOrange.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          '$_activeConnectionsCount connexions',
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Actions rapides
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildActionButton(
                        icon: Icons.people_rounded,
                        label: 'Utilisateurs proches',
                        description: 'Voir qui est en salle',
                        color: AppTheme.neonBlue,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigation vers liste utilisateurs proches
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: Icons.connect_without_contact_rounded,
                        label: 'Mes connexions',
                        description: 'Gérer mes amis sportifs',
                        color: AppTheme.neonPurple,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigation vers liste connexions
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: _isInvisible 
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        label: _isInvisible 
                            ? 'Mode invisible activé' 
                            : 'Mode visible',
                        description: _isInvisible
                            ? 'Tu es invisible pour les autres'
                            : 'Les autres peuvent te voir',
                        color: _isInvisible 
                            ? AppTheme.textSecondary 
                            : AppTheme.neonGreen,
                        onTap: () async {
                          await SocialService.toggleInvisibleMode(!_isInvisible);
                          setState(() {
                            _isInvisible = !_isInvisible;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: Icons.chat_bubble_rounded,
                        label: 'Messages',
                        description: 'Chatter avec tes amis',
                        color: AppTheme.primaryOrange,
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Navigation vers liste messages
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: Icons.close_rounded,
                        label: 'Fermer',
                        description: '',
                        color: AppTheme.textSecondary,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
