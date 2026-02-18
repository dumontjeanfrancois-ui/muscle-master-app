import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/gym_crush_service.dart';
import '../models/gym_crush_model.dart';

/// Écran de paramètres du module Gym Crush
/// Permet d'activer/désactiver le mode et de configurer les préférences
class GymCrushSettingsScreen extends StatefulWidget {
  const GymCrushSettingsScreen({super.key});

  @override
  State<GymCrushSettingsScreen> createState() => _GymCrushSettingsScreenState();
}

class _GymCrushSettingsScreenState extends State<GymCrushSettingsScreen> {
  late GymCrushSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = GymCrushService.getSettings();
      setState(() {
        _settings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _settings = GymCrushSettings();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleGymCrushMode(bool value) async {
    setState(() {
      _settings = _settings.copyWith(isEnabled: value);
    });

    try {
      await GymCrushService.toggleGymCrushMode(value);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? '🎉 Gym Crush Mode activé !' : 'Gym Crush Mode désactivé',
          ),
          backgroundColor: value ? AppTheme.neonGreen : AppTheme.textSecondary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.neonRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.primaryDark,
        appBar: AppBar(
          title: const Text('GYM CRUSH MODE'),
          backgroundColor: AppTheme.cardDark,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.neonPurple,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('GYM CRUSH MODE'),
        backgroundColor: AppTheme.cardDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activation principale
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.neonPurple.withOpacity(0.2),
                      AppTheme.neonPink.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.neonPurple.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.neonPurple.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: AppTheme.neonPink,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Activer Gym Crush',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Module social activable',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _settings.isEnabled,
                          onChanged: _toggleGymCrushMode,
                          activeColor: AppTheme.neonPink,
                          activeTrackColor: AppTheme.neonPurple.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rencontre d\'autres pratiquants dans ta salle de sport !',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Fonctionnalités
              if (_settings.isEnabled) ...[
                const Text(
                  '🎯 Fonctionnalités',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonPurple,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  icon: Icons.location_on_rounded,
                  title: 'Détection intelligente',
                  description: 'Trouve des personnes dans ta salle en temps réel',
                  color: AppTheme.neonGreen,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  icon: Icons.favorite_rounded,
                  title: 'Max 2 Gym Crush',
                  description: 'Limite de 2 gym crush actifs simultanés',
                  color: AppTheme.neonPink,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Chat débloqué si mutuel',
                  description: 'Discussion possible si 2 gym crush mutuels',
                  color: AppTheme.neonBlue,
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  icon: Icons.security_rounded,
                  title: 'Respect & Sécurité',
                  description: 'Pas de photo réelle, seulement mascotte + pseudo',
                  color: AppTheme.neonOrange,
                ),
                const SizedBox(height: 32),
                // Paramètres avancés
                const Text(
                  '⚙️ Paramètres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSettingCard(
                  icon: Icons.straighten_rounded,
                  title: 'Distance maximale',
                  value: '${_settings.maxDistance}m',
                  color: AppTheme.neonBlue,
                ),
                const SizedBox(height: 12),
                _buildSettingCard(
                  icon: Icons.groups_rounded,
                  title: 'Gym crush max',
                  value: '${_settings.maxActiveCrushes}',
                  color: AppTheme.neonPink,
                ),
                const SizedBox(height: 32),
                // Confidentialité
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.neonOrange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.privacy_tip_rounded,
                        color: AppTheme.neonOrange,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aucune géolocalisation précise affichée. Données anonymisées.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Mode désactivé
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.heart_broken_rounded,
                          size: 80,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Gym Crush Mode désactivé',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Active-le pour rencontrer d\'autres pratiquants',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
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
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
