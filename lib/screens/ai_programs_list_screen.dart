import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'dart:developer' as developer;
import 'package:intl/intl.dart';
import '../utils/theme.dart';
import '../models/ai_program.dart';
import '../services/ai_program_generator.dart';
import 'ai_program_creator_screen.dart';
import 'ai_program_detail_screen.dart';

class AIProgramsListScreen extends StatefulWidget {
  const AIProgramsListScreen({super.key});

  @override
  State<AIProgramsListScreen> createState() => _AIProgramsListScreenState();
}

class _AIProgramsListScreenState extends State<AIProgramsListScreen> {
  List<AIProgram> _programs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    developer.log('━━━ _loadPrograms() DÉBUT ━━━', name: 'ProgramsList');
    
    final programs = await AIProgramGenerator.getPrograms();
    
    developer.log('📋 Programmes récupérés: ${programs.length}', name: 'ProgramsList');
    developer.log('📋 Avant setState: _programs.length = ${_programs.length}', name: 'ProgramsList');
    
    if (mounted) {
      setState(() {
        _programs = programs;
        _isLoading = false;
      });
      
      developer.log('📋 Après setState: _programs.length = ${_programs.length}', name: 'ProgramsList');
      developer.log('📋 _isLoading = $_isLoading', name: 'ProgramsList');
      developer.log('━━━ _loadPrograms() FIN ━━━', name: 'ProgramsList');
    } else {
      developer.log('⚠️ Widget not mounted, setState skipped', name: 'ProgramsList');
    }
  }

  @override
  Widget build(BuildContext context) {
    developer.log('🎨 Build: _isLoading=$_isLoading, _programs.length=${_programs.length}', name: 'ProgramsList');
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppTheme.neonPurple),
            const SizedBox(width: 12),
            Text(
              'MES PROGRAMMES IA',
              style: TextStyle(
                color: AppTheme.neonPurple,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload_outlined, color: AppTheme.neonGreen),
            onPressed: _showImportDialog,
            tooltip: 'Importer un programme',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.neonPurple))
          : _programs.isEmpty
              ? _buildEmptyState()
              : _buildProgramsList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIProgramCreatorScreen()),
          );
          _loadPrograms();
        },
        backgroundColor: AppTheme.neonPurple,
        icon: const Icon(Icons.add_rounded),
        label: const Text('NOUVEAU'),
      ),
    );
  }

  Widget _buildEmptyState() {
    developer.log('📭 Affichage état vide (_programs.isEmpty=${_programs.isEmpty})', name: 'ProgramsList');
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_rounded,
              size: 80,
              color: AppTheme.textDisabled,
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun programme IA',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Créez votre premier programme personnalisé avec l\'IA !',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AIProgramCreatorScreen()),
                );
                _loadPrograms();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonPurple,
                foregroundColor: AppTheme.primaryDark,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('CRÉER UN PROGRAMME'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsList() {
    developer.log('📋 Affichage liste programmes (${_programs.length} programmes)', name: 'ProgramsList');
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _programs.length,
      itemBuilder: (context, index) {
        return _buildProgramCard(_programs[index]);
      },
    );
  }

  Widget _buildProgramCard(AIProgram program) {
    try {
      developer.log('🎴 Rendu carte: ${program.name}', name: 'ProgramCard');
      developer.log('   ID: ${program.id}', name: 'ProgramCard');
      developer.log('   createdAt: ${program.createdAt}', name: 'ProgramCard');
      developer.log('   description: ${program.description}', name: 'ProgramCard');
      developer.log('   workoutDays: ${program.workoutDays.length}', name: 'ProgramCard');
    } catch (e) {
      developer.log('❌ ERREUR logs carte: $e', name: 'ProgramCard');
    }
    
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AIProgramDetailScreen(program: program),
          ),
        );
        _loadPrograms();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.neonPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.neonPurple, AppTheme.neonBlue],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.primaryDark,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Créé le ${program.createdAt != null ? DateFormat('dd/MM/yyyy').format(program.createdAt) : 'Date inconnue'}',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.neonPurple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              program.description,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildInfoChip(
                  '${program.workoutDays.length} jours',
                  AppTheme.neonGreen,
                ),
                // userProfile peut être simple ou "niveau,objectif"
                if (program.userProfile.isNotEmpty) ..._buildUserProfileChips(program.userProfile),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Widget> _buildUserProfileChips(String userProfile) {
    final parts = userProfile.split(',');
    final chips = <Widget>[];
    
    // Si format "niveau,objectif", créer 2 chips
    if (parts.length >= 2) {
      chips.add(_buildInfoChip(parts[0].trim(), AppTheme.neonBlue));
      chips.add(_buildInfoChip(parts[1].trim(), AppTheme.neonOrange));
    } else {
      // Sinon, un seul chip avec le profil complet
      chips.add(_buildInfoChip(userProfile.trim(), AppTheme.neonBlue));
    }
    
    return chips;
  }

  Future<void> _showImportDialog() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Row(
          children: [
            Icon(Icons.file_upload, color: AppTheme.neonGreen),
            const SizedBox(width: 12),
            const Text('Importer un programme'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choisissez une méthode d\'import :',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '📱 Sur mobile : le copier-coller est recommandé',
              style: TextStyle(color: AppTheme.textDisabled, fontSize: 12, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Bouton 1: Fichier
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, 'file'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonBlue,
                  foregroundColor: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.folder_open, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'CHOISIR UN FICHIER',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Bouton 2: Texte
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, 'paste'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: Colors.black,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.content_paste, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'COLLER DU TEXTE',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
          ),
        ],
      ),
    );

    if (choice == 'file') {
      _importFromFile();
    } else if (choice == 'paste') {
      _showPasteDialog();
    }
  }

  Future<void> _showPasteDialog() async {
    final controller = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Row(
          children: [
            Icon(Icons.content_paste, color: AppTheme.neonGreen),
            const SizedBox(width: 12),
            const Text('Coller le programme'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Collez le contenu de votre programme :',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.neonBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.neonGreen, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Formats acceptés :',
                          style: TextStyle(
                            color: AppTheme.neonBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• JSON (exporté depuis l\'app)\n'
                      '• Texte/Markdown (description libre)\n'
                      '• Contenu copié d\'un fichier',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Collez votre programme ici...',
                  hintStyle: TextStyle(color: AppTheme.textDisabled),
                  filled: true,
                  fillColor: AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.neonGreen),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.neonGreen, width: 2),
                  ),
                ),
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreen,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.check, size: 20),
            label: const Text('IMPORTER'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      _importProgram(controller.text);
    }
  }

  Future<void> _importFromFile() async {
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
              CircularProgressIndicator(color: AppTheme.neonBlue),
              const SizedBox(height: 20),
              Text(
                '📂 Lecture du fichier...',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final result = await AIProgramGenerator.importProgramFromFile();

    // Fermer dialogue de chargement
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Si c'est un PDF non supporté, afficher le message et proposer copier-coller
    if (result['error'] == 'pdf_not_supported') {
      if (mounted) {
        final retry = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardDark,
            title: Row(
              children: [
                Icon(Icons.picture_as_pdf, color: AppTheme.neonOrange),
                const SizedBox(width: 12),
                const Text('PDF non supporté'),
              ],
            ),
            content: Text(
              result['message'] as String,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen,
                  foregroundColor: Colors.black,
                ),
                child: const Text('COPIER-COLLER'),
              ),
            ],
          ),
        );

        if (retry == true) {
          _showPasteDialog();
        }
      }
      return;
    }

    // Afficher résultat
    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String),
            backgroundColor: AppTheme.neonGreen,
          ),
        );
        _loadPrograms(); // Recharger la liste
      } else if (result['error'] != 'cancelled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String),
            backgroundColor: AppTheme.neonOrange,
          ),
        );
      }
    }
  }

  Future<void> _importProgram(String content) async {
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
            const SizedBox(height: 20),
            Text(
              '📥 Import en cours...',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyse du contenu avec l\'IA',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
    }

    final result = await AIProgramGenerator.importProgramAuto(content);

    // Fermer dialogue de chargement
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Afficher résultat
    if (mounted) {
      if (result['success']) {
        developer.log('✅ Import réussi, rechargement de la liste...', name: 'ProgramsList');
        
        // Recharger la liste
        await _loadPrograms();
        
        developer.log('✅ Liste rechargée: ${_programs.length} programmes', name: 'ProgramsList');
        
        // Forcer un rebuild complet du widget
        if (mounted) {
          setState(() {
            // Force rebuild
          });
        }
        
        // Afficher le message de succès
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Programme "${result['program']?.name ?? 'importé'}" ajouté ! Total: ${_programs.length}'),
              backgroundColor: AppTheme.neonGreen,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else if (result['error'] == 'text_format_detected') {
        // Texte libre détecté → Proposer la conversion avec IA
        _showTextConversionDialog(content);
      } else {
        // Autres erreurs
        final errorMsg = result['message'] as String;
        final errorType = result['error'] ?? 'unknown';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMsg, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Type: $errorType', style: const TextStyle(fontSize: 11)),
              ],
            ),
            backgroundColor: AppTheme.neonOrange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Affiche un dialogue proposant de convertir le texte libre en JSON avec IA
  Future<void> _showTextConversionDialog(String textContent) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: Row(
          children: [
            Icon(Icons.auto_fix_high, color: AppTheme.neonPurple),
            const SizedBox(width: 12),
            const Text('Texte libre détecté'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 Votre contenu :',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    textContent.length > 200 
                        ? '${textContent.substring(0, 200)}...' 
                        : textContent,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.neonPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neonPurple.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: AppTheme.neonPurple, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Conversion avec IA',
                            style: TextStyle(
                              color: AppTheme.neonPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'L\'IA va analyser votre texte et le convertir en format JSON structuré.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: AppTheme.neonOrange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nécessite Gemini AI (quota peut être limité)',
                              style: TextStyle(
                                color: AppTheme.neonOrange,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonPurple,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.auto_fix_high, size: 20),
            label: const Text('CONVERTIR AVEC IA'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _convertTextWithAI(textContent);
    }
  }

  /// Convertit le texte libre en JSON avec Gemini AI
  Future<void> _convertTextWithAI(String textContent) async {
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
              CircularProgressIndicator(color: AppTheme.neonPurple),
              const SizedBox(height: 20),
              Text(
                '🤖 Conversion IA en cours...',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Analyse du texte avec Gemini',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Appeler la fonction de conversion avec IA
    final result = await AIProgramGenerator.importProgramFromText(textContent);

    // Fermer dialogue de chargement
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Afficher résultat
    if (mounted) {
      if (result['success']) {
        // Succès : recharger la liste
        await _loadPrograms();
        
        if (mounted) {
          setState(() {});
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Programme "${result['program']?.name ?? 'importé'}" créé avec l\'IA ! Total: ${_programs.length}'),
            backgroundColor: AppTheme.neonGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        // Erreur : afficher le message
        String errorMsg = result['message'] as String;
        
        // Si c'est une erreur 429 (quota), afficher un message spécifique
        if (result['error'] == 'ai_error' || errorMsg.contains('429') || errorMsg.contains('quota')) {
          errorMsg = '⚠️ Quota Gemini AI temporairement dépassé.\n\n'
              '💡 Solutions :\n'
              '1. Réessayez dans quelques minutes\n'
              '2. Formatez votre texte en JSON manuellement\n\n'
              'Exemple de format JSON disponible dans le dialogue d\'import.';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppTheme.neonOrange,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
  }
}
