import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';
import '../main.dart';
import '../services/vip_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  int _logoClickCount = 0;
  DateTime? _lastClickTime;

  /// 🎮 Easter Egg : Détection des 12 clics sur le logo
  void _onLogoTap() {
    final now = DateTime.now();
    
    // Reset si plus de 3 secondes entre les clics
    if (_lastClickTime != null && now.difference(_lastClickTime!).inSeconds > 3) {
      _logoClickCount = 0;
    }
    
    _lastClickTime = now;
    _logoClickCount++;

    // Animation de feedback
    if (_logoClickCount > 0 && _logoClickCount < 12) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎮 ${_logoClickCount}/12'),
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black54,
        ),
      );
    }

    // Activation du dialogue secret après 12 clics
    if (_logoClickCount >= 12) {
      _logoClickCount = 0;
      _showVipDialog();
    }
  }

  /// 🔐 Dialogue secret pour entrer le code VIP
  void _showVipDialog() {
    final TextEditingController codeController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.neonBlue, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.stars, color: AppTheme.neonBlue, size: 28),
            const SizedBox(width: 12),
            Text(
              'Accès VIP',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entrez le code secret pour activer le mode VIP illimité 🚀',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, letterSpacing: 2),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'CODE SECRET',
                hintStyle: TextStyle(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                filled: true,
                fillColor: AppTheme.primaryDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.neonBlue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.textSecondary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.neonBlue, width: 2),
                ),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text;
              final vipService = VipService();
              final success = await vipService.activateVip(code);
              
              if (!context.mounted) return;
              Navigator.of(context).pop();
              
              if (success) {
                _showVipSuccessDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('❌ Code incorrect'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  /// 🎉 Dialogue de confirmation d'activation VIP
  void _showVipSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppTheme.neonBlue, width: 3),
        ),
        title: Column(
          children: [
            Icon(Icons.workspace_premium, color: AppTheme.neonBlue, size: 80),
            const SizedBox(height: 16),
            Text(
              '🎉 VIP ACTIVÉ !',
              style: TextStyle(
                color: AppTheme.neonBlue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVipFeature('✅ Premium illimité à vie'),
            _buildVipFeature('✅ Zéro publicité'),
            _buildVipFeature('✅ IA Coach illimité'),
            _buildVipFeature('✅ Analyse vidéo illimitée'),
            _buildVipFeature('✅ Badge VIP exclusif'),
            const SizedBox(height: 20),
            Text(
              'Bienvenue dans la team VIP ! 🚀',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('C\'EST PARTI ! 💪', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildVipFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      ),
    );
  }

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
                // 🎮 Logo cliquable pour Easter Egg
                GestureDetector(
                  onTap: _onLogoTap,
                  child: Icon(
                    Icons.fitness_center,
                    size: 100,
                    color: AppTheme.neonBlue,
                  ),
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
                  onPressed: () => _navigateToLogin(context),
                ),
                const SizedBox(height: 40),

                // Conditions d'utilisation
                Text(
                  'En continuant, vous acceptez nos Conditions d\'utilisation\net notre Politique de confidentialité',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
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
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _loginWithGoogle(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connexion Google en cours...')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _loginWithApple(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connexion Apple en cours...')),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
