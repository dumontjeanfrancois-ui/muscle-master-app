import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';
import '../services/mascot_service.dart';
import '../models/mascot_settings.dart';

/// Widget Mascotte 3D Premium
/// Rendu pseudo-3D avec profondeur, ombre, glow et animations fluides
class FlexoMascot3DWidget extends StatefulWidget {
  final bool isMoving;
  final VoidCallback? onTap;

  const FlexoMascot3DWidget({
    super.key,
    this.isMoving = false,
    this.onTap,
  });

  @override
  State<FlexoMascot3DWidget> createState() => _FlexoMascot3DWidgetState();
}

class _FlexoMascot3DWidgetState extends State<FlexoMascot3DWidget>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _glowController;
  late AnimationController _tapController;
  late Animation<double> _floatAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  String _mascotImage = 'assets/mascots/flexo_lion_male.png';
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadMascotImage();
    _setupAnimations();
  }

  void _loadMascotImage() {
    try {
      final settings = MascotService.getSettings();
      setState(() {
        _mascotImage = settings.selectedMascot == 'female'
            ? 'assets/mascots/flexa_lioness_female.png'
            : 'assets/mascots/flexo_lion_male.png';
        _imageLoaded = true;
      });
    } catch (e) {
      // Fallback sur mascotte masculine par défaut
      setState(() {
        _mascotImage = 'assets/mascots/flexo_lion_male.png';
        _imageLoaded = true;
      });
    }
  }

  void _setupAnimations() {
    // Animation flottante (mouvement vertical doux)
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    // Animation glow pulsation
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Animation tap (rebond au clic)
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeOut,
    ));

    if (widget.isMoving) {
      _floatController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FlexoMascot3DWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMoving != oldWidget.isMoving) {
      if (widget.isMoving) {
        _floatController.repeat(reverse: true);
        _glowController.repeat(reverse: true);
      } else {
        _floatController.stop();
        _glowController.stop();
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _glowController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    MascotService.recordInteraction();
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      _showMascotBottomSheet();
    }
  }

  /// Afficher le bottom sheet animé premium
  void _showMascotBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => MascotBottomSheet(
        mascotImage: _mascotImage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_imageLoaded) {
      return const SizedBox(
        width: 90,
        height: 90,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryOrange,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _floatAnimation,
        _glowAnimation,
        _scaleAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Effet de profondeur avec ombres multiples
                  boxShadow: [
                    // Ombre principale (profondeur)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    // Glow animé (effet néon)
                    BoxShadow(
                      color: AppTheme.primaryOrange.withOpacity(_glowAnimation.value),
                      blurRadius: 25,
                      spreadRadius: 5,
                      offset: const Offset(0, 0),
                    ),
                    // Highlight supérieur (effet 3D)
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: -2,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fond dégradé
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.cardDark,
                              AppTheme.cardDark.withOpacity(0.8),
                            ],
                            stops: const [0.3, 1.0],
                          ),
                        ),
                      ),
                      // Image mascotte
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          _mascotImage,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback icon si image non trouvée
                            return const Icon(
                              Icons.sports_martial_arts,
                              color: AppTheme.primaryOrange,
                              size: 50,
                            );
                          },
                        ),
                      ),
                      // Overlay highlight 3D
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Bottom Sheet Animé Premium pour la Mascotte
class MascotBottomSheet extends StatefulWidget {
  final String mascotImage;

  const MascotBottomSheet({
    super.key,
    required this.mascotImage,
  });

  @override
  State<MascotBottomSheet> createState() => _MascotBottomSheetState();
}

class _MascotBottomSheetState extends State<MascotBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
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

  @override
  Widget build(BuildContext context) {
    final mascotSettings = MascotService.getSettings();
    final mascotName = mascotSettings.displayName;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
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
                  color: AppTheme.primaryOrange.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                // Poignée de fermeture (centrée)
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textSecondary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Mascotte en grand avec animation (centrée)
                Center(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          widget.mascotImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppTheme.cardDark,
                              child: const Icon(
                                Icons.sports_martial_arts,
                                color: AppTheme.primaryOrange,
                                size: 80,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Nom mascotte
                Text(
                  mascotName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Votre coach personnel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                // Boutons d'action
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildActionButton(
                        icon: Icons.chat_bubble_rounded,
                        label: 'Chat IA',
                        color: AppTheme.neonPurple,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed('/mascot_chat');
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: Icons.settings_rounded,
                        label: 'Paramètres mascotte',
                        color: AppTheme.neonBlue,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).pushNamed('/mascot_settings');
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: Icons.close_rounded,
                        label: 'Fermer',
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Overlay Mascotte 3D pour MainScreen
class FlexoMascot3DOverlay extends StatefulWidget {
  final Widget child;

  const FlexoMascot3DOverlay({super.key, required this.child});

  @override
  State<FlexoMascot3DOverlay> createState() => _FlexoMascot3DOverlayState();
}

class _FlexoMascot3DOverlayState extends State<FlexoMascot3DOverlay> {
  bool _showMascot = false;
  bool _mascotEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkMascotSettings();
  }

  void _checkMascotSettings() {
    try {
      final settings = MascotService.getSettings();
      final shouldShow = settings.isVisible && settings.selectedMascot != 'none';
      
      // Délai d'apparition pour éviter conflit Navigator
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showMascot = shouldShow;
            _mascotEnabled = shouldShow;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _showMascot = false;
          _mascotEnabled = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_mascotEnabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (_showMascot)
          Positioned(
            bottom: 100,
            right: 16,
            child: FlexoMascot3DWidget(
              isMoving: true,
            ),
          ),
      ],
    );
  }
}
