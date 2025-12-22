import 'package:flutter/material.dart';
import '../utils/theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AIDE & SUPPORT'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'QUESTIONS FRÉQUENTES',
            icon: Icons.help_outline,
            color: AppTheme.neonBlue,
            children: [
              _buildFAQItem(
                question: 'Comment créer un programme personnalisé ?',
                answer: 'Allez dans l\'onglet "Programmes", puis cliquez sur "CRÉER UN PROGRAMME". Vous pouvez choisir entre un programme IA personnalisé ou créer votre propre programme à partir de templates vierges.',
              ),
              _buildFAQItem(
                question: 'Comment utiliser le calculateur de macros ?',
                answer: 'Dans l\'onglet "Nutrition" → "CALCULATEURS" → "MACROS AVANCÉES". Remplissez vos informations personnelles pour obtenir des recommandations précises basées sur les formules scientifiques Mifflin-St Jeor et Katch-McArdle.',
              ),
              _buildFAQItem(
                question: 'Comment enregistrer une analyse vidéo ?',
                answer: 'Allez dans "Profil" → "Analyse vidéo technique". Cliquez sur "ENREGISTRER UNE VIDÉO" pour filmer votre série. L\'IA analysera automatiquement votre tempo, posture et vous donnera des recommandations sur la charge.',
              ),
              _buildFAQItem(
                question: 'Mes données sont-elles sauvegardées ?',
                answer: 'Oui, toutes vos données (programmes, records, poids, macros, vidéos) sont sauvegardées localement sur votre appareil de manière sécurisée avec SharedPreferences.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'CONTACT',
            icon: Icons.mail_outline,
            color: AppTheme.neonGreen,
            children: [
              _buildContactOption(
                icon: Icons.email,
                title: 'Email',
                subtitle: 'support@musclemaster.app',
                color: AppTheme.neonGreen,
                onTap: () {
                  // Ouvrir l'application email
                },
              ),
              _buildContactOption(
                icon: Icons.chat,
                title: 'Chat en direct',
                subtitle: 'Disponible 24/7',
                color: AppTheme.neonBlue,
                onTap: () {
                  // Ouvrir le chat
                },
              ),
              _buildContactOption(
                icon: Icons.phone,
                title: 'Téléphone',
                subtitle: '+33 1 23 45 67 89',
                color: AppTheme.neonOrange,
                onTap: () {
                  // Ouvrir le téléphone
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            title: 'GUIDES & TUTORIELS',
            icon: Icons.school_outlined,
            color: AppTheme.neonPurple,
            children: [
              _buildGuideItem(
                icon: Icons.video_library,
                title: 'Vidéos tutoriels',
                subtitle: '20+ vidéos d\'explication',
                color: AppTheme.neonPurple,
              ),
              _buildGuideItem(
                icon: Icons.menu_book,
                title: 'Guide complet',
                subtitle: 'PDF de 50 pages',
                color: AppTheme.neonBlue,
              ),
              _buildGuideItem(
                icon: Icons.tips_and_updates,
                title: 'Astuces & conseils',
                subtitle: 'Optimisez votre utilisation',
                color: AppTheme.neonOrange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.neonBlue.withOpacity(0.3)),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconColor: AppTheme.neonBlue,
        collapsedIconColor: AppTheme.textSecondary,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: color,
            fontSize: 13,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: color, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: color, size: 16),
        onTap: () {},
      ),
    );
  }
}
