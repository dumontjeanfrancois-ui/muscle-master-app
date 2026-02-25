import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/mascot_service.dart';

class FlexoMascotWidget extends StatefulWidget {
  final bool showMessage;
  final String message;
  final bool isMoving;

  const FlexoMascotWidget({
    super.key,
    this.showMessage = false,
    this.message = '',
    this.isMoving = false,
  });

  @override
  State<FlexoMascotWidget> createState() => _FlexoMascotWidgetState();
}

class _FlexoMascotWidgetState extends State<FlexoMascotWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    if (widget.isMoving) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(FlexoMascotWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMoving && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isMoving && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () {
          // Navigation sécurisée vers le chat mascotte
          Navigator.of(context).pushNamed('/mascot_chat');
        },
        child: SizedBox(
          width: 80,
          height: 80,
          child: Image.asset(
            MascotService.getSettings().assetPath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class FlexoMascotOverlay extends StatefulWidget {
  final Widget child;

  const FlexoMascotOverlay({super.key, required this.child});

  @override
  State<FlexoMascotOverlay> createState() => _FlexoMascotOverlayState();
}

class _FlexoMascotOverlayState extends State<FlexoMascotOverlay> {
  bool _showMascot = false; // Commencer caché
  bool _mascotEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkMascotSettings();
  }

  // Vérifier les paramètres de visibilité de la mascotte
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
      // Si erreur, ne pas afficher la mascotte
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
    // Ne pas afficher la mascotte si désactivée
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
            child: const FlexoMascotWidget(
              isMoving: true,
            ),
          ),
      ],
    );
  }
}
