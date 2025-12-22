import 'package:flutter/material.dart';
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
    final programs = await AIProgramGenerator.getPrograms();
    setState(() {
      _programs = programs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _programs.length,
      itemBuilder: (context, index) {
        return _buildProgramCard(_programs[index]);
      },
    );
  }

  Widget _buildProgramCard(AIProgram program) {
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
                        'Créé le ${DateFormat('dd/MM/yyyy').format(program.createdAt)}',
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
                _buildInfoChip(
                  program.userProfile.split(',')[0].trim(),
                  AppTheme.neonBlue,
                ),
                _buildInfoChip(
                  program.userProfile.split(',')[1].trim(),
                  AppTheme.neonOrange,
                ),
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
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
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
}
