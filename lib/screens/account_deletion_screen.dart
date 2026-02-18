import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../services/auth_service.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  bool _isDeleting = false;
  bool _confirmDeletion = false;

  Future<void> _deleteAccount() async {
    if (!_confirmDeletion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez confirmer la suppression de votre compte'),
          backgroundColor: AppTheme.neonRed,
        ),
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final result = await AuthService.deleteAccount();
      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte supprimé avec succès'),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erreur lors de la suppression'),
            backgroundColor: AppTheme.neonRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.neonRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('SUPPRIMER MON COMPTE'),
        backgroundColor: AppTheme.cardDark,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_rounded,
                size: 80,
                color: AppTheme.neonRed,
              ),
              const SizedBox(height: 24),
              const Text(
                'Suppression définitive',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.neonRed,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cette action est irréversible. Toutes vos données seront supprimées définitivement :',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoItem('Profil utilisateur'),
              _buildInfoItem('Historique d\'entraînements'),
              _buildInfoItem('Programmes personnalisés'),
              _buildInfoItem('Statistiques de progression'),
              _buildInfoItem('Données nutritionnelles'),
              const SizedBox(height: 32),
              CheckboxListTile(
                value: _confirmDeletion,
                onChanged: (value) {
                  setState(() {
                    _confirmDeletion = value ?? false;
                  });
                },
                title: const Text(
                  'Je confirme vouloir supprimer mon compte',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
                activeColor: AppTheme.neonRed,
                checkColor: Colors.white,
                tileColor: AppTheme.cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isDeleting ? null : _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isDeleting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'SUPPRIMER DÉFINITIVEMENT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isDeleting
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppTheme.textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ANNULER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(
            Icons.cancel,
            color: AppTheme.neonRed,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
