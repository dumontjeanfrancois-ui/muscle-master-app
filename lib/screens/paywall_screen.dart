import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../services/subscription_service.dart';
import '../utils/theme.dart';

class PaywallScreen extends StatefulWidget {
  final String? feature; // Fonctionnalité qui a déclenché le paywall

  const PaywallScreen({super.key, this.feature});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedPlan = SubscriptionService.yearlySubscriptionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Consumer<SubscriptionService>(
          builder: (context, subscriptionService, _) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bouton fermer
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: AppTheme.textPrimary),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // Titre
                    Text(
                      '🔥 MUSCLE MASTER',
                      style: TextStyle(
                        color: AppTheme.neonOrange,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'VERSION PREMIUM',
                      style: TextStyle(
                        color: AppTheme.neonPurple,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (widget.feature != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.neonBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.neonBlue.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '🔒 ${widget.feature} nécessite un abonnement Premium',
                          style: TextStyle(
                            color: AppTheme.neonBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Avantages Premium
                    _buildFeatureItem('✨', 'IA Chef Illimité', 'Recettes personnalisées infinies'),
                    _buildFeatureItem('🎯', 'IA Programme Avancé', 'Programmes 100% sur mesure'),
                    _buildFeatureItem('🎥', 'Analyse Vidéo IA', 'TEMPO, POSTURE, CHARGE'),
                    _buildFeatureItem('📸', 'Photo Calories IA', 'Analyse illimitée de plats'),
                    _buildFeatureItem('📊', 'Records Illimités', 'Suivi complet sans limite'),
                    _buildFeatureItem('🚫', 'Sans Publicités', 'Expérience premium pure'),
                    _buildFeatureItem('💾', 'Import/Export JSON', 'Sauvegarde et partage'),
                    _buildFeatureItem('🔔', 'Notifications Pro', 'Rappels intelligents'),

                    const SizedBox(height: 40),

                    // Plans de prix
                    if (subscriptionService.products.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else
                      ...subscriptionService.products.map((product) {
                        final isYearly = product.id == SubscriptionService.yearlySubscriptionId;
                        final isSelected = _selectedPlan == product.id;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPlan = product.id;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppTheme.neonPurple.withValues(alpha: 0.2)
                                  : AppTheme.cardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected 
                                    ? AppTheme.neonPurple
                                    : AppTheme.textSecondary.withValues(alpha: 0.3),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Radio button
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected 
                                          ? AppTheme.neonPurple 
                                          : AppTheme.textSecondary,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppTheme.neonPurple,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),

                                // Plan info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            isYearly ? 'ANNUEL' : 'MENSUEL',
                                            style: TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (isYearly) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppTheme.neonGreen,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                'ÉCONOMIE 40%',
                                                style: TextStyle(
                                                  color: AppTheme.primaryDark,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        product.price,
                                        style: TextStyle(
                                          color: AppTheme.neonOrange,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (isYearly)
                                        Text(
                                          'Soit 4,17€/mois',
                                          style: TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 24),

                    // Bouton S'abonner
                    ElevatedButton(
                      onPressed: subscriptionService.purchasePending
                          ? null
                          : () async {
                              final product = subscriptionService.products
                                  .firstWhere((p) => p.id == _selectedPlan);
                              await subscriptionService.buySubscription(product);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: subscriptionService.purchasePending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'DEVENIR PREMIUM 🚀',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),

                    const SizedBox(height: 16),

                    // Bouton Restaurer les achats
                    TextButton(
                      onPressed: () async {
                        await subscriptionService.restorePurchases();
                      },
                      child: Text(
                        'Restaurer mes achats',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Informations légales
                    Text(
                      '• Essai gratuit 7 jours\n'
                      '• Renouvellement automatique\n'
                      '• Annulation à tout moment\n'
                      '• Conditions générales et politique de confidentialité',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.neonBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
