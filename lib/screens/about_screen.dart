import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('À PROPOS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Logo / Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonBlue.withOpacity(0.3),
                    AppTheme.neonPurple.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.fitness_center,
                size: 80,
                color: AppTheme.neonBlue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'MUSCLE MASTER',
              style: TextStyle(
                color: AppTheme.neonBlue,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonBlue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'APPLICATION ULTIME DE MUSCULATION ET NUTRITION SPORTIVE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.neonBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Muscle Master combine l\'intelligence artificielle et les dernières recherches scientifiques pour vous offrir l\'expérience de coaching la plus complète et personnalisée.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildFeaturesList(),
            const SizedBox(height: 32),
            _buildTechStack(),
            const SizedBox(height: 32),
            _buildCredits(),
            const SizedBox(height: 32),
            _buildSocialLinks(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.auto_awesome,
        'title': 'Coach IA personnalisé',
        'color': AppTheme.neonPurple,
      },
      {
        'icon': Icons.fitness_center,
        'title': 'Programmes sur mesure',
        'color': AppTheme.neonGreen,
      },
      {
        'icon': Icons.calculate,
        'title': 'Calculateurs scientifiques',
        'color': AppTheme.neonBlue,
      },
      {
        'icon': Icons.videocam,
        'title': 'Analyse vidéo IA',
        'color': AppTheme.neonOrange,
      },
      {
        'icon': Icons.restaurant,
        'title': 'Nutrition optimisée',
        'color': AppTheme.neonOrange,
      },
      {
        'icon': Icons.trending_up,
        'title': 'Suivi de progression',
        'color': AppTheme.neonGreen,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FONCTIONNALITÉS',
          style: TextStyle(
            color: AppTheme.neonGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (feature['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      feature['icon'] as IconData,
                      color: feature['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    feature['title'] as String,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildTechStack() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonPurple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.code, color: AppTheme.neonPurple, size: 24),
              const SizedBox(width: 12),
              Text(
                'TECHNOLOGIES',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTechItem('Flutter', '3.35.4'),
          _buildTechItem('Dart', '3.9.2'),
          _buildTechItem('Firebase', 'Core & Firestore'),
          _buildTechItem('Local Storage', 'SharedPreferences & Hive'),
          _buildTechItem('State Management', 'Provider'),
          _buildTechItem('Charts', 'FL Chart'),
          _buildTechItem('Video', 'Camera & Video Player'),
        ],
      ),
    );
  }

  Widget _buildTechItem(String name, String version) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
            ),
          ),
          Text(
            version,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredits() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonOrange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite, color: AppTheme.neonOrange, size: 32),
          const SizedBox(height: 12),
          Text(
            'Conçu avec passion pour les athlètes',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 Muscle Master\nTous droits réservés',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks() {
    final socials = [
      {'icon': Icons.language, 'label': 'Site Web', 'color': AppTheme.neonBlue},
      {'icon': Icons.facebook, 'label': 'Facebook', 'color': Colors.blue},
      {'icon': Icons.camera_alt, 'label': 'Instagram', 'color': Colors.purple},
      {'icon': Icons.play_circle, 'label': 'YouTube', 'color': Colors.red},
    ];

    return Column(
      children: [
        Text(
          'SUIVEZ-NOUS',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: socials.map((social) {
            return IconButton(
              onPressed: () {},
              icon: Icon(
                social['icon'] as IconData,
                color: social['color'] as Color,
                size: 32,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
