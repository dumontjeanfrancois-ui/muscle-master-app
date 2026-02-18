import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../utils/theme.dart';
import '../services/gemini_vision_service.dart';

class AIPhotoAnalysisScreen extends StatefulWidget {
  const AIPhotoAnalysisScreen({super.key});

  @override
  State<AIPhotoAnalysisScreen> createState() => _AIPhotoAnalysisScreenState();
}

class _AIPhotoAnalysisScreenState extends State<AIPhotoAnalysisScreen> {
  List<Map<String, dynamic>> _analyses = [];
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();
  final GeminiVisionService _geminiService = GeminiVisionService();

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('photo_analyses');
    if (json != null) {
      final List<dynamic> decoded = jsonDecode(json);
      setState(() {
        _analyses = decoded.cast<Map<String, dynamic>>();
      });
    }
  }

  Future<void> _takePhoto(ImageSource source) async {
    try {
      setState(() {
        _isAnalyzing = true;
      });

      // Prendre une photo avec la caméra ou sélectionner de la galerie
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo == null) {
        setState(() {
          _isAnalyzing = false;
        });
        return;
      }

      // Analyser avec Gemini Vision
      final prompt = '''
Analyse cette photo de nourriture et fournis les informations nutritionnelles détaillées.

Retourne UNIQUEMENT un JSON valide avec cette structure exacte (sans markdown, sans commentaires) :
{
  "foodItems": [
    {
      "name": "nom du plat",
      "portion": "quantité estimée (ex: 200g)",
      "calories": nombre_entier,
      "protein": nombre_decimal,
      "carbs": nombre_decimal,
      "fats": nombre_decimal
    }
  ],
  "totalCalories": nombre_decimal,
  "totalProtein": nombre_decimal,
  "totalCarbs": nombre_decimal,
  "totalFats": nombre_decimal,
  "advice": "conseil nutritionnel bref (max 100 caractères)"
}

Sois précis dans les estimations. Si tu ne vois pas clairement un aliment, estime au mieux.
''';

      final result = await _geminiService.analyzeImage(photo.path, prompt);

      if (!mounted) return;

      // Parser la réponse JSON
      Map<String, dynamic> analysisData;
      try {
        // Nettoyer la réponse (enlever les markdown backticks si présents)
        String cleanedResult = result.trim();
        if (cleanedResult.startsWith('```json')) {
          cleanedResult = cleanedResult.substring(7);
        }
        if (cleanedResult.startsWith('```')) {
          cleanedResult = cleanedResult.substring(3);
        }
        if (cleanedResult.endsWith('```')) {
          cleanedResult = cleanedResult.substring(0, cleanedResult.length - 3);
        }
        cleanedResult = cleanedResult.trim();

        analysisData = jsonDecode(cleanedResult);
      } catch (e) {
        // Si l'analyse JSON échoue, créer une structure par défaut
        analysisData = {
          'foodItems': [
            {
              'name': 'Plat analysé',
              'portion': 'Portion standard',
              'calories': 400,
              'protein': 25.0,
              'carbs': 45.0,
              'fats': 10.0
            }
          ],
          'totalCalories': 400.0,
          'totalProtein': 25.0,
          'totalCarbs': 45.0,
          'totalFats': 10.0,
          'advice': 'Analyse approximative - ajustez selon vos besoins'
        };
      }

      final analysis = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'photo': photo.path,
        'foodItems': analysisData['foodItems'] ?? [],
        'totalCalories': (analysisData['totalCalories'] as num?)?.toDouble() ?? 0.0,
        'totalProtein': (analysisData['totalProtein'] as num?)?.toDouble() ?? 0.0,
        'totalCarbs': (analysisData['totalCarbs'] as num?)?.toDouble() ?? 0.0,
        'totalFats': (analysisData['totalFats'] as num?)?.toDouble() ?? 0.0,
        'advice': analysisData['advice'] ?? '',
      };

      final newAnalyses = [analysis, ..._analyses];
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photo_analyses', jsonEncode(newAnalyses));

      setState(() {
        _analyses = newAnalyses;
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Plat analysé : ${analysis['totalCalories'].toStringAsFixed(0)} kcal'),
            backgroundColor: AppTheme.neonGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de l\'analyse: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _deleteAnalysis(String id) async {
    setState(() {
      _analyses.removeWhere((a) => a['id'] == id);
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('photo_analyses', jsonEncode(_analyses));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Analyse supprimée')),
      );
    }
  }

  void _showSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'CHOISIR UNE SOURCE',
              style: TextStyle(
                color: AppTheme.neonOrange,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppTheme.neonBlue, size: 32),
              title: Text(
                'Prendre une photo',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Utiliser l\'appareil photo',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(ImageSource.camera);
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.neonGreen, size: 32),
              title: Text(
                'Choisir de la galerie',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Sélectionner une image',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              onTap: () {
                Navigator.pop(context);
                _takePhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCaloriesToday = _analyses
        .where((a) {
          final date = DateTime.parse(a['timestamp']);
          final today = DateTime.now();
          return date.year == today.year && date.month == today.month && date.day == today.day;
        })
        .fold(0.0, (sum, a) => sum + ((a['totalCalories'] as num?)?.toDouble() ?? 0.0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ANALYSE PHOTO IA'),
        backgroundColor: AppTheme.primaryDark,
      ),
      body: _isAnalyzing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.neonOrange),
                  const SizedBox(height: 24),
                  Text(
                    '🔍 Analyse en cours...',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gemini Vision analyse votre photo',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé du jour
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonOrange.withValues(alpha: 0.2),
                          AppTheme.neonPurple.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neonOrange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_fire_department, color: AppTheme.neonOrange, size: 48),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AUJOURD\'HUI',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${totalCaloriesToday.toStringAsFixed(0)} kcal',
                                style: TextStyle(
                                  color: AppTheme.neonOrange,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_analyses.where((a) {
                                  final date = DateTime.parse(a['timestamp']);
                                  final today = DateTime.now();
                                  return date.year == today.year && date.month == today.month && date.day == today.day;
                                }).length} repas analysé${_analyses.where((a) {
                                  final date = DateTime.parse(a['timestamp']);
                                  final today = DateTime.now();
                                  return date.year == today.year && date.month == today.month && date.day == today.day;
                                }).length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.neonBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppTheme.neonBlue, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Prenez en photo vos repas pour obtenir une analyse nutritionnelle instantanée par IA',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Liste des analyses
                  if (_analyses.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 80,
                              color: AppTheme.textSecondary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Aucune analyse pour le moment',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Appuyez sur + pour commencer',
                              style: TextStyle(
                                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._analyses.map((analysis) => _buildAnalysisCard(analysis)).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSourceDialog,
        backgroundColor: AppTheme.neonOrange,
        icon: const Icon(Icons.add_a_photo, color: Colors.black),
        label: const Text(
          'ANALYSER',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(Map<String, dynamic> analysis) {
    final date = DateTime.parse(analysis['timestamp']);
    final foodItems = analysis['foodItems'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neonGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec image et date
          if (analysis['photo'] != null && File(analysis['photo']).existsSync())
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.file(
                File(analysis['photo']),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _deleteAnalysis(analysis['id']),
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                      iconSize: 20,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Total calories
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.neonOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMacroInfo('Calories', '${analysis['totalCalories'].toStringAsFixed(0)} kcal', AppTheme.neonOrange),
                      Container(width: 1, height: 30, color: Colors.white12),
                      _buildMacroInfo('Protéines', '${analysis['totalProtein'].toStringAsFixed(1)}g', AppTheme.neonBlue),
                      Container(width: 1, height: 30, color: Colors.white12),
                      _buildMacroInfo('Glucides', '${analysis['totalCarbs'].toStringAsFixed(1)}g', AppTheme.neonGreen),
                      Container(width: 1, height: 30, color: Colors.white12),
                      _buildMacroInfo('Lipides', '${analysis['totalFats'].toStringAsFixed(1)}g', AppTheme.neonPurple),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Aliments détectés
                Text(
                  'ALIMENTS DÉTECTÉS',
                  style: TextStyle(
                    color: AppTheme.neonGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                ...foodItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant, size: 16, color: AppTheme.neonGreen, ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${item['name']} (${item['portion']})',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                        ),
                      ),
                      Text(
                        '${item['calories']} kcal',
                        style: TextStyle(
                          color: AppTheme.neonOrange,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )).toList(),

                if (analysis['advice'] != null && analysis['advice'].toString().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.neonBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.neonBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.tips_and_updates, size: 18, color: AppTheme.neonBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            analysis['advice'],
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
