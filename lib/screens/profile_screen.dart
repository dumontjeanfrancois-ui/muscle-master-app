import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/theme.dart';
import '../services/vip_service.dart';
import '../services/profile_service.dart';
import 'ai_coach_screen.dart';
import 'real_video_analysis_screen.dart';
import 'login_screen.dart';
import 'account_deletion_screen.dart';
import 'mascot_settings_screen.dart';
import 'mascot_chat_screen.dart';

import 'personal_info_screen.dart';
import 'goals_screen.dart';
import 'coach_advice_history_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';
import 'notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath;
  String _username = 'Champion';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    final imagePath = await ProfileService.getProfileImagePath();
    final username = await ProfileService.getUsername();

    setState(() {
      _profileImagePath = imagePath ?? '';
      _username = username ?? 'Utilisateur';
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        await ProfileService.setProfileImagePath(image.path);
        setState(() {
          _profileImagePath = image.path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo de profil mise à jour'),
              backgroundColor: AppTheme.neonGreen,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur lors de la sélection de l\'image: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de la sélection de l\'image'),
            backgroundColor: AppTheme.neonOrange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _removeProfileImage() async {
    await _profileService.removeProfileImage();
    setState(() {
      _profileImagePath = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Photo de profil supprimée'),
          backgroundColor: AppTheme.neonPink,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textDisabled,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'PHOTO DE PROFIL',
                style: TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: AppTheme.neonBlue),
                title: Text(
                  'Choisir une photo',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              if (_profileImagePath != null)
                ListTile(
                  leading: Icon(Icons.delete_rounded, color: AppTheme.neonOrange),
                  title: Text(
                    'Supprimer la photo',
                    style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeProfileImage();
                  },
                ),
              ListTile(
                leading: Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                title: Text(
                  'Annuler',
                  style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

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
                // COMPLIANCE: Suppression de compte obligatoire
                _buildMenuItem(
                  context, 
                  Icons.delete_forever_rounded, 
                  'Supprimer mon compte', 
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AccountDeletionScreen()),
                    );
                  },
                  color: Colors.red,
                ),
              ]),
              const SizedBox(height: 24),
              
              _buildMenuSection(context, 'Coach IA', [
                _buildMenuItem(context, Icons.pets_rounded, 'Chat avec Flexo/Flexa', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MascotChatScreen()),
                  );
                }, color: AppTheme.neonPurple),
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
                _buildMenuItem(context, Icons.tune_rounded, 'Paramètres Mascotte', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MascotSettingsScreen()),
                  );
                }, color: AppTheme.primaryOrange),
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
    return Consumer<VipService>(
      builder: (context, vipService, _) {
        return Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  // Photo de profil
                  GestureDetector(
                    onTap: () => _showProfileOptions(context),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: vipService.isVip ? Colors.amber : AppTheme.neonBlue,
                          width: 3,
                        ),
                        gradient: _profileImagePath == null
                            ? LinearGradient(
                                colors: vipService.isVip
                                    ? [
                                        Colors.amber.withValues(alpha: 0.3),
                                        Colors.orange.withValues(alpha: 0.3),
                                      ]
                                    : [
                                        AppTheme.neonBlue.withValues(alpha: 0.3),
                                        AppTheme.neonPurple.withValues(alpha: 0.3),
                                      ],
                              )
                            : null,
                        image: _profileImagePath != null
                            ? DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(_profileImagePath!) as ImageProvider
                                    : FileImage(File(_profileImagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImagePath == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 50,
                              color: vipService.isVip ? Colors.amber : AppTheme.neonBlue,
                            )
                          : null,
                    ),
                  ),
                  // Bouton d'édition
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showProfileOptions(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.neonPurple,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryDark, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Badge VIP
                  if (vipService.isVip)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryDark, width: 2),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _username,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (vipService.isVip) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'VIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                vipService.isVip
                    ? 'VIP depuis ${_formatDate(vipService.activationDate)}'
                    : 'Membre depuis Nov 2024',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'récemment';
    final months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'];
    return '${months[date.month - 1]} ${date.year}';
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
