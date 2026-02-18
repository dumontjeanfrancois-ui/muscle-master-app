import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/gym_crush_model.dart';
import '../services/gym_crush_service.dart';

/// Bottom Sheet d'interaction Gym Crush
/// Affiche un utilisateur détecté à proximité avec actions possibles
class GymCrushBottomSheet extends StatefulWidget {
  final GymCrushUser user;
  final String currentUserId;
  final VoidCallback? onInteractionCreated;

  const GymCrushBottomSheet({
    super.key,
    required this.user,
    required this.currentUserId,
    this.onInteractionCreated,
  });

  @override
  State<GymCrushBottomSheet> createState() => _GymCrushBottomSheetState();
}

class _GymCrushBottomSheetState extends State<GymCrushBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleInteraction(GymCrushStatus status, String actionName) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await GymCrushService.createInteraction(
        targetUser: widget.user,
        status: status,
      );

      if (!mounted) return;
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(actionName),
          backgroundColor: AppTheme.neonGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      widget.onInteractionCreated?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.neonRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleGymCrush() async {
    final canCreate = await GymCrushService.canCreateNewCrush();
    if (!canCreate) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limite de gym crush atteinte (max 2)'),
          backgroundColor: AppTheme.neonRed,
        ),
      );
      return;
    }

    await _handleInteraction(
      GymCrushStatus.pending,
      '❤️ Gym Crush envoyé !',
    );
  }

  @override
  Widget build(BuildContext context) {
    final mascotImage = widget.user.mascotType == 'female'
        ? 'assets/mascots/flexa_lioness_female.png'
        : 'assets/mascots/flexo_lion_male.png';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonPurple.withOpacity(0.3),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: _isProcessing
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.neonPurple,
                ),
              )
            : Column(
                children: [
                  // Poignée
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Titre
                  const Text(
                    'Quelqu\'un dans ta salle ! 💪',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.neonPurple,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Mascotte
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.neonPurple.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          mascotImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.cardDark,
                              child: const Icon(
                                Icons.sports_martial_arts,
                                color: AppTheme.neonPurple,
                                size: 70,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Pseudo
                  Text(
                    widget.user.pseudo,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.user.mascotName != null)
                    Text(
                      'Mascotte: ${widget.user.mascotName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🏋️ En entraînement',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.neonGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Boutons d'action
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildActionButton(
                            icon: Icons.favorite_rounded,
                            label: 'Gym Crush ❤️',
                            color: AppTheme.neonPink,
                            description: 'Max 2 actifs',
                            onTap: _handleGymCrush,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            icon: Icons.chat_bubble_rounded,
                            label: 'Envoyer message 💬',
                            color: AppTheme.neonBlue,
                            description: 'Message direct',
                            onTap: () {
                              // TODO: Implémenter message direct
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Fonction à venir'),
                                  backgroundColor: AppTheme.neonBlue,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            icon: Icons.person_add_rounded,
                            label: 'Ami 🤝',
                            color: AppTheme.neonGreen,
                            description: 'Sans gym crush',
                            onTap: () => _handleInteraction(
                              GymCrushStatus.friend,
                              '🤝 Demande d\'ami envoyée',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            icon: Icons.close_rounded,
                            label: 'Ignorer ❌',
                            color: AppTheme.textSecondary,
                            description: '',
                            onTap: () async {
                              await GymCrushService.ignoreUser(
                                widget.user.userId,
                              );
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
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
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withOpacity(0.7),
                      ),
                    ),
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
