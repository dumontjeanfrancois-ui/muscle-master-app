import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/theme.dart';

class AIPhotoAnalysisScreen extends StatefulWidget {
  const AIPhotoAnalysisScreen({super.key});

  @override
  State<AIPhotoAnalysisScreen> createState() => _AIPhotoAnalysisScreenState();
}

class _AIPhotoAnalysisScreenState extends State<AIPhotoAnalysisScreen> {
  List<Map<String, dynamic>> _analyses = [];
  bool _isAnalyzing = false;

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

  Future<void> _takePhoto(String source) async {
    try {
      // Simulation: Dans une app réelle, utilisez image_picker
      setState(() {
        _isAnalyzing = true;
      });

      // Simulation d'analyse IA
      await Future.delayed(const Duration(seconds: 2));

      final analysis = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().toIso8601String(),
        'photo': 'https://via.placeholder.com/400', // Placeholder
        'foodItems': [
          {
            'name': 'Poulet grillé',
            'portion': '200g',
            'calories': 330,
            'protein': 62.0,
            'carbs': 0.0,
            'fats': 7.4
          },
          {
            'name': 'Riz basmati',
            'portion': '150g',
            'calories': 195,
            'protein': 4.1,
            'carbs': 43.0,
            'fats': 0.4
          },
          {
            'name': 'Brocoli vapeur',
            'portion': '100g',
            'calories': 34,
            'protein': 2.8,
            'carbs': 7.0,
            'fats': 0.4
          }
        ],
        'totalCalories': 559.0,
        'totalProtein': 68.9,
        'totalCarbs': 50.0,
        'totalFats': 8.2
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
            content: Text('✅ Plat analysé : ${analysis['totalCalories']} kcal'),
            backgroundColor: AppTheme.neonGreen,
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
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    final totalCaloriesToday = _analyses
        .where((a) {
          final date = DateTime.parse(a['timestamp']);
          final today = DateTime.now();
          return date.year == today.year && date.month == today.month && date.day == today.day;
        })
        .fold(0.0, (sum, a) => sum + (a['totalCalories'] as num));

    return Scaffold(
      appBar: AppBar(
        title: const Text('ANALYSE PHOTO IA'),
      ),
      body: _isAnalyzing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    'ANALYSE EN COURS...',
                    style: TextStyle(
                      color: AppTheme.neonPurple,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reconnaissance des aliments avec IA',
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.neonPurple.withOpacity(0.2),
                          AppTheme.neonOrange.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neonPurple.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, color: AppTheme.neonPurple, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'IA NUTRITION VISION',
                                style: TextStyle(
                                  color: AppTheme.neonPurple,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Photographiez votre plat, l\'IA calcule automatiquement les calories',
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

                  // Stats du jour
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.neonOrange.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'AUJOURD\'HUI',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalCaloriesToday',
                          style: TextStyle(
                            color: AppTheme.neonOrange,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'CALORIES',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Boutons photo
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _takePhoto('camera'),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('CAMÉRA'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _takePhoto('gallery'),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('GALERIE'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.neonBlue,
                            side: BorderSide(color: AppTheme.neonBlue),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Historique
                  if (_analyses.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.history, color: AppTheme.neonGreen, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'HISTORIQUE (${_analyses.length})',
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
                    ..._analyses.map((analysis) => _buildAnalysisCard(analysis)),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 80,
                              color: AppTheme.textDisabled,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune photo analysée',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildAnalysisCard(Map<String, dynamic> analysis) {
    final date = DateTime.parse(analysis['analyzedAt']);
    final dateStr = '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';

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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.restaurant, color: AppTheme.neonOrange, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analysis['mealType'],
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.neonOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${analysis['totalCalories']} kcal',
                    style: TextStyle(
                      color: AppTheme.neonOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: AppTheme.neonRed),
                  onPressed: () => _deleteAnalysis(analysis['id']),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMacroTag('${analysis['totalProtein']}g P', AppTheme.neonGreen),
                _buildMacroTag('${analysis['totalCarbs']}g G', AppTheme.neonBlue),
                _buildMacroTag('${analysis['totalFat']}g L', AppTheme.neonPurple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
