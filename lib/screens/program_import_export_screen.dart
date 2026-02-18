import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'dart:developer' as developer;
import '../utils/theme.dart';
import '../services/ai_program_generator.dart';

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
      final content = _importController.text.trim();
      if (content.isEmpty) {
        throw Exception('Veuillez coller le contenu du programme');
      }

      // Afficher dialogue de chargement
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardDark,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.neonGreen),
                const SizedBox(height: 16),
                Text(
                  '📥 Import en cours...',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Analyse du contenu avec l\'IA',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      Map<String, dynamic> program;

      // Détecter si c'est du JSON ou du texte libre
      if (content.startsWith('{') && content.endsWith('}')) {
        // C'est du JSON
        try {
          program = jsonDecode(content);
          
          // Valider la structure
          if (!program.containsKey('name') || !program.containsKey('days')) {
            throw Exception('Format de programme invalide');
          }
        } catch (e) {
          if (mounted) Navigator.of(context).pop();
          throw Exception('JSON invalide: $e');
        }
      } else {
        // C'est du texte libre - utiliser l'IA
        final result = await AIProgramGenerator.generateProgram(customPrompt: content);
        
        if (mounted) Navigator.of(context).pop();
        
        if (result['success'] != true) {
          throw Exception(result['message'] ?? 'Échec de la génération du programme');
        }
        
        // Convertir AIProgram en Map
        final aiProgram = result['program'];
        program = {
          'name': aiProgram.name,
          'days': aiProgram.workoutDays.map((day) => {
            'dayName': day.dayName,
            'focus': day.focus,
            'exercises': day.exercises.map((ex) => {
              'exerciseName': ex.exerciseName,
              'sets': ex.sets,
              'reps': ex.reps,
              'restSeconds': ex.restSeconds,
              'notes': ex.notes,
            }).toList(),
          }).toList(),
          'description': aiProgram.description,
        };
      }

      // Fermer le dialogue si encore ouvert
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
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

      // Recharger la liste
      await _loadPrograms();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Programme "${program['name']}" importé et sauvegardé !'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Fermer le dialogue si encore ouvert
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
                AppTheme.neonOrange,
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
                  
                  // Bouton Fichier
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _importFromFile,
                      icon: const Icon(Icons.folder_open),
                      label: const Text(
                        'FICHIER (TXT, JSON, MD)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                  
                  const SizedBox(height: 12),
                  
                  // Bouton Coller
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _importFromJson,
                      icon: const Icon(Icons.content_paste),
                      label: const Text(
                        'COLLER DU TEXTE',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonGreen,
                        foregroundColor: Colors.black,
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

  Future<void> _importFromFile() async {
    try {
      // 📱 ACCEPTER TOUS LES TYPES DE FICHIERS pour compatibilité mobile
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // ✅ Accepter tous les fichiers
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return; // Utilisateur a annulé
      }

      final file = result.files.first;
      String? content;
      
      // 🔍 Afficher message de chargement
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardDark,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppTheme.neonBlue),
                const SizedBox(height: 16),
                Text(
                  '📂 Lecture du fichier...',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nom: ${file.name}',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // 📖 Tentative de lecture du contenu texte
      try {
        if (kIsWeb) {
          if (file.bytes != null) {
            content = String.fromCharCodes(file.bytes!);
          }
        } else {
          if (file.path != null) {
            final fileObj = File(file.path!);
            content = await fileObj.readAsString();
          }
        }
      } catch (e) {
        // Le fichier n'est pas lisible en texte (PDF, image, etc.)
        if (kDebugMode) {
          developer.log('⚠️ Fichier non lisible en texte: $e', name: 'ImportFile');
        }
      }
      
      // Fermer le dialogue de chargement
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // 🔍 Vérifier si on a réussi à lire le contenu
      if (content != null && content.trim().isNotEmpty) {
        // ✅ Contenu texte lisible - le mettre dans le TextField
        _importController.text = content;
        await _importFromJson();
      } else {
        // ❌ Fichier non lisible - proposer conversion IA
        if (mounted) {
          final shouldConvert = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppTheme.cardDark,
              title: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppTheme.neonOrange, size: 28),
                  const SizedBox(width: 12),
                  const Text('Fichier Non Lisible'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ce type de fichier (${file.extension?.toUpperCase() ?? 'INCONNU'}) ne peut pas être lu directement.',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Options :',
                    style: TextStyle(color: AppTheme.neonBlue, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildOptionItem('📋 Copier-coller le texte manuellement (recommandé)'),
                  _buildOptionItem('💡 Décrire ton programme à l\'IA pour génération'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.neonBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '💡 Conseil : Utilise l\'option "COLLER DU TEXTE" pour de meilleurs résultats',
                      style: TextStyle(color: AppTheme.neonBlue, fontSize: 12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('OK', style: TextStyle(color: AppTheme.neonBlue)),
                ),
              ],
            ),
          );
        }
      }

    } catch (e) {
      // Fermer le dialogue si encore ouvert
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lecture fichier : $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
  
  Widget _buildOptionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }
}
