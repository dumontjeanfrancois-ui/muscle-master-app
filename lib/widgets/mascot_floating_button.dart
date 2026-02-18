import 'package:flutter/material.dart';
import '../services/mascot_service.dart';
import '../models/mascot_settings.dart';
import '../screens/mascot_chat_screen.dart';
import '../utils/theme.dart';

/// Bouton flottant de la mascotte dans l'écran d'accueil
/// S'affiche si la mascotte est visible dans les paramètres
class MascotFloatingButton extends StatelessWidget {
  const MascotFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = MascotService.getSettings();

    // N'afficher le bouton que si la mascotte est visible
    if (!settings.isVisible || settings.mascotType == 'none') {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 80,
      right: 16,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MascotChatScreen(),
            ),
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryOrange.withValues(alpha: 0.2),
            border: Border.all(
              color: AppTheme.primaryOrange,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryOrange.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              settings.assetPath,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
