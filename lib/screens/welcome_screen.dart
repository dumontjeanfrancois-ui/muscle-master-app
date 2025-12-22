import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../main.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryDark,
              AppTheme.secondaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo et titre
                Icon(
                  Icons.fitness_center,
                  size: 100,
                  color: AppTheme.neonBlue,
                ),
                const SizedBox(height: 24),
                Text(
                  'MUSCLE MASTER',
                  style: TextStyle(
                    color: AppTheme.neonBlue,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Ton coach personnel de musculation',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Bouton Google
                _buildSocialButton(
                  context,
                  label: 'Continuer avec Google',
                  icon: Icons.g_mobiledata,
                  color: Colors.white,
                  textColor: Colors.black87,
                  onPressed: () => _loginWithGoogle(context),
                ),
                const SizedBox(height: 16),

                // Bouton Apple
                _buildSocialButton(
                  context,
                  label: 'Continuer avec Apple',
                  icon: Icons.apple,
                  color: Colors.black,
                  textColor: Colors.white,
                  onPressed: () => _loginWithApple(context),
                ),
                const SizedBox(height: 16),

                // Bouton Email
                _buildSocialButton(
                  context,
                  label: 'Continuer avec Email',
                  icon: Icons.email_outlined,
                  color: AppTheme.neonBlue,
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                ),
                const SizedBox(height: 32),

                // Séparateur
                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.textDisabled)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU',
                        style: TextStyle(color: AppTheme.textDisabled),
                      ),
                    ),
                    Expanded(child: Divider(color: AppTheme.textDisabled)),
                  ],
                ),
                const SizedBox(height: 32),

                // Bouton Mode Démo
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppTheme.neonGreen, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline, color: AppTheme.neonGreen),
                      const SizedBox(width: 12),
                      Text(
                        'ESSAYER SANS COMPTE',
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Termes et conditions
                Text(
                  'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité',
                  style: TextStyle(
                    color: AppTheme.textDisabled,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _loginWithGoogle(BuildContext context) {
    // Simuler connexion Google
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🔐 Connexion Google en cours... (Mode démo)'),
        backgroundColor: AppTheme.neonBlue,
      ),
    );
    
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }

  void _loginWithApple(BuildContext context) {
    // Simuler connexion Apple
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🍎 Connexion Apple en cours... (Mode démo)'),
        backgroundColor: Colors.black,
      ),
    );
    
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    });
  }
}
