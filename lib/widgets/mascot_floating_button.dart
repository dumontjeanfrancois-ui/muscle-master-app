import 'package:flutter/material.dart';
import '../services/mascot_service.dart';
import '../models/mascot_settings.dart';
import 'social_bottom_sheet.dart';

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

    return GestureDetector(
      onTap: () => SocialBottomSheet.show(context),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Image.asset(
          settings.assetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
