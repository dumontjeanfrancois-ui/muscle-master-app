import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'ai_coach_screen.dart';
import 'real_video_analysis_screen.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';
import '../services/auth_service.dart';
import 'personal_info_screen.dart';
import 'goals_screen.dart';
import 'coach_advice_history_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PROFIL',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.neonPurple,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 24),
              
              // Avatar et info
              _buildProfileHeader(),
              const SizedBox(height: 32),
              
              // Statistiques utilisateur
              _buildUserStats(),
              const SizedBox(height: 32),
              
              // Menu options
              _buildMenuSection(context, 'Paramètres', [
                _buildMenuItem(context, Icons.person_rounded, 'Informations personnelles', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
                  );
                }),
                _buildMenuItem(context, Icons.flag_rounded, 'Mes objectifs', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GoalsScreen()),
                  );
                }),
                _buildMenuItem(context, Icons.notifications_rounded, 'Notifications', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                }),
              ]),
              const SizedBox(height: 24),
              
              _buildMenuSection(context, 'Coach IA', [
                _buildMenuItem(context, Icons.chat_bubble_rounded, 'Chat avec le coach', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AICoachScreen()),
                  );
                }, color: AppTheme.neonGreen),
                _buildMenuItem(context, Icons.videocam_rounded, 'Analyse vidéo technique', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RealVideoAnalysisScreen()),
                  );
                }, color: AppTheme.neonPurple),
                _buildMenuItem(context, Icons.history_rounded, 'Historique des conseils', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CoachAdviceHistoryScreen()),
                  );
                }),
              ]),
              const SizedBox(height: 24),
              
              _buildMenuSection(context, 'Application', [
                _buildMenuItem(context, Icons.login_rounded, 'Connexion / Inscription', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }, color: AppTheme.neonBlue),
                _buildMenuItem(context, Icons.help_rounded, 'Aide & Support', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                  );
                }),
                _buildMenuItem(context, Icons.info_rounded, 'À propos', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutScreen()),
                  );
                }),
                _buildMenuItem(context, Icons.logout_rounded, 'Déconnexion', () {}, color: AppTheme.neonOrange),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.neonBlue,
                width: 3,
              ),
              gradient: LinearGradient(
                colors: [
                  AppTheme.neonBlue.withOpacity(0.3),
                  AppTheme.neonPurple.withOpacity(0.3),
                ],
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 50,
              color: AppTheme.neonBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Champion',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Membre depuis Nov 2024',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.neonBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatColumn('82.5', 'kg', 'Poids'),
          _buildDivider(),
          _buildStatColumn('178', 'cm', 'Taille'),
          _buildDivider(),
          _buildStatColumn('26.0', 'IMC', 'Indice'),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String unit, String label) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                unit,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.textDisabled.withOpacity(0.3),
    );
  }

  Widget _buildMenuSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.textDisabled.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    final itemColor = color ?? AppTheme.textPrimary;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: itemColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: itemColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
