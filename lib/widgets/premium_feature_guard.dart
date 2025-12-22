import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../screens/paywall_screen.dart';
import '../utils/theme.dart';

/// Widget qui protège les fonctionnalités premium
class PremiumFeatureGuard extends StatelessWidget {
  final Widget child;
  final String featureName;
  final bool showBadge;

  const PremiumFeatureGuard({
    super.key,
    required this.child,
    required this.featureName,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        // Si l'utilisateur est premium, afficher la fonctionnalité
        if (subscriptionService.isPremium) {
          return child;
        }

        // Sinon, afficher le widget bloqué
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaywallScreen(feature: featureName),
              ),
            );
          },
          child: Stack(
            children: [
              // Contenu flouté
              AbsorbPointer(
                child: Opacity(
                  opacity: 0.3,
                  child: child,
                ),
              ),

              // Overlay avec badge premium
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.neonPurple,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: AppTheme.neonPurple,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            featureName,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaywallScreen(
                                  feature: featureName,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'DÉBLOQUER 🔓',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Badge Premium pour les fonctionnalités payantes
class PremiumBadge extends StatelessWidget {
  final double size;

  const PremiumBadge({super.key, this.size = 60});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size * 0.15,
        vertical: size * 0.08,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.neonPurple, AppTheme.neonOrange],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: size * 0.3,
          ),
          SizedBox(width: size * 0.1),
          Text(
            'PREMIUM',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton pour accéder au paywall
class UpgradeToPremiumButton extends StatelessWidget {
  final String? feature;

  const UpgradeToPremiumButton({super.key, this.feature});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionService>(
      builder: (context, subscriptionService, _) {
        // Ne pas afficher si déjà premium
        if (subscriptionService.isPremium) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaywallScreen(feature: feature),
                ),
              );
            },
            icon: const Icon(Icons.workspace_premium),
            label: const Text(
              'PASSER À PREMIUM',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}
