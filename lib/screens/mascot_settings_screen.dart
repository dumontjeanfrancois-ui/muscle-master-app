import 'package:flutter/material.dart';
import '../services/mascot_service.dart';
import '../models/mascot_settings.dart';
import '../utils/theme.dart';

/// Écran de paramètres de la mascotte
/// Permet à l'utilisateur de choisir entre Flexo (masculin), Flexa (féminin) ou aucune mascotte
class MascotSettingsScreen extends StatefulWidget {
  const MascotSettingsScreen({super.key});

  @override
  State<MascotSettingsScreen> createState() => _MascotSettingsScreenState();
}

class _MascotSettingsScreenState extends State<MascotSettingsScreen> {
  late MascotSettings _currentSettings;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _currentSettings = MascotService.getSettings();
      _nameController.text = _currentSettings.customName ?? '';
    });
  }

  Future<void> _updateMascotType(String type) async {
    await MascotService.setMascotType(type);
    _loadSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            type == 'none'
                ? 'Mascotte désactivée'
                : 'Mascotte changée : ${_currentSettings.defaultName}',
          ),
          backgroundColor: AppTheme.primaryOrange,
        ),
      );
    }
  }

  Future<void> _toggleVisibility() async {
    await MascotService.toggleVisibility();
    _loadSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _currentSettings.isVisible
                ? 'Mascotte affichée'
                : 'Mascotte masquée',
          ),
          backgroundColor: AppTheme.primaryOrange,
        ),
      );
    }
  }

  Future<void> _saveCustomName() async {
    final name = _nameController.text.trim();
    await MascotService.setCustomName(name.isEmpty ? null : name);
    _loadSettings();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nom personnalisé enregistré'),
          backgroundColor: AppTheme.primaryOrange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Paramètres Mascotte'),
        backgroundColor: AppTheme.backgroundDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section de prévisualisation de la mascotte actuelle
            _buildMascotPreview(),
            const SizedBox(height: 32),

            // Section de choix du type de mascotte
            _buildMascotTypeSelection(),
            const SizedBox(height: 32),

            // Section de visibilité
            _buildVisibilityToggle(),
            const SizedBox(height: 32),

            // Section de nom personnalisé
            _buildCustomNameSection(),
            const SizedBox(height: 32),

            // Informations supplémentaires
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotPreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryOrange, width: 2),
      ),
      child: Column(
        children: [
          Text(
            'Mascotte Actuelle',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(height: 16),
          if (_currentSettings.mascotType != 'none' && _currentSettings.isVisible)
            Column(
              children: [
                Image.asset(
                  _currentSettings.assetPath,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  _currentSettings.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            )
          else
            const Column(
              children: [
                Icon(
                  Icons.visibility_off,
                  size: 100,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Aucune mascotte affichée',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMascotTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choisir votre mascotte',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildMascotOption(
          type: 'male',
          name: 'Flexo Lion',
          description: 'Le coach musclé avec tête de lion',
          assetPath: 'assets/mascots/flexo_lion_male.png',
        ),
        const SizedBox(height: 12),
        _buildMascotOption(
          type: 'female',
          name: 'Flexa Lioness',
          description: 'La coach athlétique avec tête de lionne',
          assetPath: 'assets/mascots/flexa_lioness_female.png',
        ),
        const SizedBox(height: 12),
        _buildMascotOption(
          type: 'none',
          name: 'Aucune mascotte',
          description: 'Désactiver l\'affichage de la mascotte',
          assetPath: '',
        ),
      ],
    );
  }

  Widget _buildMascotOption({
    required String type,
    required String name,
    required String description,
    required String assetPath,
  }) {
    final isSelected = _currentSettings.mascotType == type;
    
    return GestureDetector(
      onTap: () => _updateMascotType(type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withValues(alpha: 0.2) : AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : Colors.grey.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            if (assetPath.isNotEmpty)
              Image.asset(
                assetPath,
                height: 80,
                width: 80,
                fit: BoxFit.contain,
              )
            else
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.block,
                  size: 40,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryOrange : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryOrange,
                size: 32,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.visibility,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Afficher la mascotte',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Masquer temporairement la mascotte',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _currentSettings.isVisible,
            onChanged: (_) => _toggleVisibility(),
            activeColor: AppTheme.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomNameSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nom personnalisé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Donnez un nom unique à votre mascotte',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Ex: Mon coach musclé',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: AppTheme.backgroundDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.save, color: AppTheme.primaryOrange),
                onPressed: _saveCustomName,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 24),
              SizedBox(width: 12),
              Text(
                'À propos des mascottes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '• Flexo Lion et Flexa Lioness sont vos coachs virtuels\n'
            '• Ils répondent à vos questions sur la musculation et la nutrition\n'
            '• Vous pouvez les masquer à tout moment\n'
            '• Personnalisez leur nom selon vos préférences',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
