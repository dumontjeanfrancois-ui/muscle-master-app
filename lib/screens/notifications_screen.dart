import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _workoutReminders = true;
  bool _nutritionReminders = true;
  bool _progressReminders = true;
  bool _coachTips = true;
  
  TimeOfDay _workoutTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 12, minute: 30);
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 19, minute: 0);

  List<String> _selectedDays = ['Lundi', 'Mercredi', 'Vendredi'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _workoutReminders = prefs.getBool('notif_workout') ?? true;
      _nutritionReminders = prefs.getBool('notif_nutrition') ?? true;
      _progressReminders = prefs.getBool('notif_progress') ?? true;
      _coachTips = prefs.getBool('notif_coach') ?? true;
      
      final workoutHour = prefs.getInt('workout_hour') ?? 18;
      final workoutMinute = prefs.getInt('workout_minute') ?? 0;
      _workoutTime = TimeOfDay(hour: workoutHour, minute: workoutMinute);
      
      final daysJson = prefs.getString('workout_days');
      if (daysJson != null) {
        _selectedDays = List<String>.from(jsonDecode(daysJson));
      }
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_workout', _workoutReminders);
    await prefs.setBool('notif_nutrition', _nutritionReminders);
    await prefs.setBool('notif_progress', _progressReminders);
    await prefs.setBool('notif_coach', _coachTips);
    await prefs.setInt('workout_hour', _workoutTime.hour);
    await prefs.setInt('workout_minute', _workoutTime.minute);
    await prefs.setString('workout_days', jsonEncode(_selectedDays));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notifications configurées !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isWorkout) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isWorkout ? _workoutTime : _breakfastTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isWorkout) {
          _workoutTime = picked;
        }
      });
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOTIFICATIONS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.neonOrange.withOpacity(0.2),
                    AppTheme.neonPurple.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonOrange.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.notifications_active, color: AppTheme.neonOrange, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RAPPELS PERSONNALISÉS',
                          style: TextStyle(
                            color: AppTheme.neonOrange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configurez vos rappels pour ne jamais manquer une séance',
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
            const SizedBox(height: 32),

            // Types de notifications
            _buildSection(
              'TYPES DE NOTIFICATIONS',
              Icons.category,
              AppTheme.neonBlue,
              [
                SwitchListTile(
                  value: _workoutReminders,
                  onChanged: (value) {
                    setState(() {
                      _workoutReminders = value;
                    });
                    _saveSettings();
                  },
                  title: const Text('Rappels d\'entraînement'),
                  subtitle: const Text('Notification avant chaque séance'),
                  activeColor: AppTheme.neonGreen,
                  tileColor: AppTheme.cardDark,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _nutritionReminders,
                  onChanged: (value) {
                    setState(() {
                      _nutritionReminders = value;
                    });
                    _saveSettings();
                  },
                  title: const Text('Rappels nutrition'),
                  subtitle: const Text('Hydratation et repas'),
                  activeColor: AppTheme.neonGreen,
                  tileColor: AppTheme.cardDark,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _progressReminders,
                  onChanged: (value) {
                    setState(() {
                      _progressReminders = value;
                    });
                    _saveSettings();
                  },
                  title: const Text('Rappels progression'),
                  subtitle: const Text('Suivi poids et records'),
                  activeColor: AppTheme.neonGreen,
                  tileColor: AppTheme.cardDark,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  value: _coachTips,
                  onChanged: (value) {
                    setState(() {
                      _coachTips = value;
                    });
                    _saveSettings();
                  },
                  title: const Text('Conseils du Coach IA'),
                  subtitle: const Text('Astuces quotidiennes'),
                  activeColor: AppTheme.neonGreen,
                  tileColor: AppTheme.cardDark,
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Horaires
            _buildSection(
              'HORAIRES D\'ENTRAÎNEMENT',
              Icons.access_time,
              AppTheme.neonPurple,
              [
                ListTile(
                  tileColor: AppTheme.cardDark,
                  leading: Icon(Icons.fitness_center, color: AppTheme.neonPurple),
                  title: const Text('Heure préférée'),
                  subtitle: Text('${_workoutTime.hour}:${_workoutTime.minute.toString().padLeft(2, '0')}'),
                  trailing: Icon(Icons.edit, color: AppTheme.textSecondary),
                  onTap: () => _selectTime(context, true),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Jours d'entraînement
            _buildSection(
              'JOURS D\'ENTRAÎNEMENT',
              Icons.calendar_today,
              AppTheme.neonGreen,
              [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche']
                      .map((day) {
                    final isSelected = _selectedDays.contains(day);
                    return FilterChip(
                      label: Text(day),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                        _saveSettings();
                      },
                      selectedColor: AppTheme.neonGreen,
                      backgroundColor: AppTheme.cardDark,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Aperçu
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.neonBlue, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'APERÇU DES NOTIFICATIONS',
                        style: TextStyle(
                          color: AppTheme.neonBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_workoutReminders)
                    _buildNotificationExample(
                      '💪 Séance d\'entraînement',
                      '${_workoutTime.hour}:${_workoutTime.minute.toString().padLeft(2, '0')} - C\'est l\'heure de votre entraînement !',
                    ),
                  if (_nutritionReminders) ...[
                    const SizedBox(height: 8),
                    _buildNotificationExample(
                      '💧 Hydratation',
                      '10:00 - N\'oubliez pas de boire de l\'eau !',
                    ),
                  ],
                  if (_coachTips) ...[
                    const SizedBox(height: 8),
                    _buildNotificationExample(
                      '🎯 Conseil du Coach',
                      '09:00 - Augmentez progressivement vos charges de 2.5kg',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildNotificationExample(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications, color: AppTheme.neonGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
