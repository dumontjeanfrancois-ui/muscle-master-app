import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

class ProgramImportExportScreen extends StatefulWidget {
  const ProgramImportExportScreen({super.key});

  @override
  State<ProgramImportExportScreen> createState() => _ProgramImportExportScreenState();
}

class _ProgramImportExportScreenState extends State<ProgramImportExportScreen> {
  final TextEditingController _importController = TextEditingController();
  List<Map<String, dynamic>> _customPrograms = [];
  List<Map<String, dynamic>> _blankPrograms = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger programmes personnalisés
    final customJson = prefs.getString('custom_programs');
    if (customJson != null) {
      final List<dynamic> decoded = jsonDecode(customJson);
      _customPrograms = decoded.cast<Map<String, dynamic>>();
    }

    // Charger templates vierges
    final blankJson = prefs.getString('blank_programs');
    if (blankJson != null) {
      final List<dynamic> decoded = jsonDecode(blankJson);
      _blankPrograms = decoded.cast<Map<String, dynamic>>();
    }

    setState(() {});
  }

  Future<void> _exportProgram(Map<String, dynamic> program) async {
    final json = jsonEncode(program);
    final qrCode = _generateShareCode(program);
    
    await Share.share(
      '🏋️ MUSCLE MASTER - Programme "${program['name']}"\n\n'
      '📋 Code de partage: $qrCode\n\n'
      '💾 JSON:\n$json',
      subject: 'Programme ${program['name']} - Muscle Master',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Programme partagé !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _generateShareCode(Map<String, dynamic> program) {
    // Générer un code court (6 caractères)
    final id = program['id'].toString();
    return id.substring(id.length - 6).toUpperCase();
  }

  Future<void> _importFromJson() async {
    try {
      final json = _importController.text.trim();
      if (json.isEmpty) {
        throw Exception('Veuillez coller un JSON de programme');
      }

      final Map<String, dynamic> program = jsonDecode(json);
      
      // Valider la structure
      if (!program.containsKey('name') || !program.containsKey('days')) {
        throw Exception('Format de programme invalide');
      }

      // Ajouter un nouvel ID
      program['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      program['importedAt'] = DateTime.now().toIso8601String();

      // Sauvegarder
      _customPrograms.insert(0, program);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_programs', jsonEncode(_customPrograms));

      setState(() {
        _importController.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Programme "${program['name']}" importé !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard(Map<String, dynamic> program) async {
    final json = jsonEncode(program);
    await Clipboard.setData(ClipboardData(text: json));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ JSON copié dans le presse-papiers !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showTutorial() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppTheme.neonBlue),
            const SizedBox(width: 12),
            Text(
              'TUTORIEL IMPORT/EXPORT',
              style: TextStyle(color: AppTheme.neonBlue, fontSize: 16),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTutorialStep(
                '1',
                'TÉLÉCHARGER UN PROGRAMME EXEMPLE',
                'Téléchargez un des programmes exemples fournis par Muscle Master (voir GitHub ou lien ci-dessous).',
                Icons.download,
                AppTheme.neonBlue,
              ),
              const SizedBox(height: 16),
              _buildTutorialStep(
                '2',
                'OUVRIR LE FICHIER JSON',
                'Ouvrez le fichier .json avec n\'importe quel éditeur de texte (Notepad, VS Code, etc.).',
                Icons.text_snippet,
                AppTheme.neonPurple,
              ),
              const SizedBox(height: 16),
              _buildTutorialStep(
                '3',
                'COPIER TOUT LE CONTENU',
                'Sélectionnez tout le texte JSON (Ctrl+A) et copiez-le (Ctrl+C).',
                Icons.copy,
                AppTheme.neonGreen,
              ),
              const SizedBox(height: 16),
              _buildTutorialStep(
                '4',
                'COLLER DANS L\'APP',
                'Revenez dans l\'app, collez le JSON dans le champ ci-dessus et cliquez sur IMPORTER.',
                Icons.upload,
                AppTheme.accentOrange,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: AppTheme.neonGreen, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'PROGRAMMES EXEMPLES',
                          style: TextStyle(
                            color: AppTheme.neonGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Programme-Force-Puissance.json\n• Programme-Debutant-FullBody.json',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Disponibles sur GitHub :\ngithub.com/dumontjeanfrancois-ui/muscle-master-app',
                      style: TextStyle(
                        color: AppTheme.neonBlue,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'COMPRIS !',
              style: TextStyle(color: AppTheme.neonBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep(String number, String title, String description, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPrograms = [..._customPrograms, ..._blankPrograms];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMPORT/EXPORT PROGRAMMES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showTutorial,
            tooltip: 'Tutoriel Import/Export',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Import
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonBlue.withOpacity(0.2),
                    AppTheme.neonPurple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonBlue.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.download, color: AppTheme.neonBlue, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'IMPORTER UN PROGRAMME',
                        style: TextStyle(
                          color: AppTheme.neonBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Collez le code JSON d\'un programme partagé',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showTutorial,
                        icon: Icon(Icons.help_outline, size: 16, color: AppTheme.neonBlue),
                        label: Text(
                          'Aide',
                          style: TextStyle(color: AppTheme.neonBlue, fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _importController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: '{"name": "Mon Programme", "days": [...]}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _importFromJson,
                      icon: const Icon(Icons.upload),
                      label: const Text(
                        'IMPORTER',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Section Export
            Row(
              children: [
                Icon(Icons.upload, color: AppTheme.neonGreen, size: 24),
                const SizedBox(width: 12),
                Text(
                  'MES PROGRAMMES (${allPrograms.length})',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (allPrograms.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 80,
                        color: AppTheme.textDisabled,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun programme à exporter',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...allPrograms.map((program) => _buildProgramCard(program)),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    final shareCode = _generateShareCode(program);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.neonGreen.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: AppTheme.neonGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program['name'],
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: $shareCode',
                        style: TextStyle(
                          color: AppTheme.neonGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(program),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('COPIER JSON'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.neonBlue,
                      side: BorderSide(color: AppTheme.neonBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _exportProgram(program),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('PARTAGER'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonGreen,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }
}
