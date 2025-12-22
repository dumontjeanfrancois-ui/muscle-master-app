import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../utils/theme.dart';

class CoachAdviceHistoryScreen extends StatefulWidget {
  const CoachAdviceHistoryScreen({super.key});

  @override
  State<CoachAdviceHistoryScreen> createState() => _CoachAdviceHistoryScreenState();
}

class _CoachAdviceHistoryScreenState extends State<CoachAdviceHistoryScreen> {
  List<Map<String, dynamic>> _adviceHistory = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Simuler un historique de conseils
    setState(() {
      _adviceHistory = [
        {
          'date': DateTime.now().subtract(const Duration(days: 1)),
          'category': 'Entraînement',
          'title': 'Optimisez votre échauffement',
          'advice': 'Un échauffement de 10-15 minutes avant l\'entraînement réduit les risques de blessures de 50%. Concentrez-vous sur la mobilité articulaire et l\'activation des groupes musculaires ciblés.',
          'icon': Icons.fitness_center,
          'color': AppTheme.neonGreen,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 3)),
          'category': 'Nutrition',
          'title': 'Timing des protéines',
          'advice': 'Consommez 20-40g de protéines dans les 2h après l\'entraînement pour optimiser la récupération musculaire. Les sources rapides comme le whey sont idéales post-workout.',
          'icon': Icons.restaurant,
          'color': AppTheme.neonOrange,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 5)),
          'category': 'Récupération',
          'title': 'Importance du sommeil',
          'advice': 'Visez 7-9h de sommeil par nuit. C\'est pendant le sommeil profond que la production d\'hormone de croissance est maximale pour la réparation musculaire.',
          'icon': Icons.bedtime,
          'color': AppTheme.neonPurple,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 7)),
          'category': 'Technique',
          'title': 'Progression au squat',
          'advice': 'Augmentez la charge progressivement : 2.5-5kg par semaine maximum. La qualité du mouvement prime toujours sur la quantité de poids soulevé.',
          'icon': Icons.trending_up,
          'color': AppTheme.neonBlue,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 10)),
          'category': 'Hydratation',
          'title': 'Stratégie d\'hydratation',
          'advice': 'Buvez 500ml d\'eau 2h avant l\'entraînement, puis 150-200ml toutes les 15-20 minutes pendant l\'effort. L\'hydratation impacte directement vos performances.',
          'icon': Icons.water_drop,
          'color': AppTheme.neonBlue,
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HISTORIQUE DES CONSEILS'),
      ),
      body: _adviceHistory.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _adviceHistory.length,
              itemBuilder: (context, index) {
                final advice = _adviceHistory[index];
                return _buildAdviceCard(advice);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: AppTheme.textDisabled,
          ),
          const SizedBox(height: 24),
          Text(
            'AUCUN CONSEIL',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Commencez à discuter avec le coach IA\npour recevoir des conseils personnalisés',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(Map<String, dynamic> advice) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: (advice['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: () => _showAdviceDetails(advice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (advice['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      advice['icon'] as IconData,
                      color: advice['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advice['category'] as String,
                          style: TextStyle(
                            color: advice['color'] as Color,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          advice['title'] as String,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                advice['advice'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.textDisabled,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateFormat.format(advice['date'] as DateTime),
                        style: TextStyle(
                          color: AppTheme.textDisabled,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppTheme.textDisabled,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdviceDetails(Map<String, dynamic> advice) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textDisabled,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (advice['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      advice['icon'] as IconData,
                      color: advice['color'] as Color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          advice['category'] as String,
                          style: TextStyle(
                            color: advice['color'] as Color,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          advice['title'] as String,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                advice['advice'] as String,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppTheme.textDisabled,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd MMMM yyyy', 'fr_FR').format(advice['date'] as DateTime),
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
