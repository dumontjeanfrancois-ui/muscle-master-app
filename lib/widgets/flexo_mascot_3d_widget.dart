import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/theme.dart';
import '../services/mascot_service.dart';
import '../models/mascot_settings.dart';
import 'social_bottom_sheet.dart';

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
    }
    // Ne rien faire par défaut, l'action est gérée par le parent
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
        _scaleAnimation,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: _handleTap,
              child: SizedBox(
                width: 90,
                height: 90,
                child: Image.asset(
                  _mascotImage,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.sports_martial_arts,
                      color: AppTheme.primaryOrange,
                      size: 50,
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
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
              onTap: () => SocialBottomSheet.show(context),
            ),
          ),
      ],
    );
  }
}
