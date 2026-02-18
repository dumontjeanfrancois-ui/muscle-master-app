import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/mascot_settings.dart';

/// Service de gestion des paramètres de la mascotte
/// Utilise Hive pour la persistance locale
class MascotService {
  static const String _boxName = 'mascotSettings';
  static Box<MascotSettings>? _box;

  /// Initialiser le service Hive pour les paramètres de mascotte
  static Future<void> initialize() async {
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<MascotSettings>(_boxName);
    } else {
      _box = Hive.box<MascotSettings>(_boxName);
    }
  }

  /// Obtenir les paramètres actuels de la mascotte
  static MascotSettings getSettings() {
    if (_box == null) {
      throw Exception('MascotService not initialized. Call initialize() first.');
    }

    // Si aucune configuration n'existe, créer une configuration par défaut
    if (_box!.isEmpty) {
      final defaultSettings = MascotSettings();
      _box!.put('current', defaultSettings);
      return defaultSettings;
    }

    return _box!.get('current', defaultValue: MascotSettings())!;
  }

  /// Mettre à jour les paramètres de la mascotte
  static Future<void> updateSettings(MascotSettings settings) async {
    if (_box == null) {
      throw Exception('MascotService not initialized. Call initialize() first.');
    }

    await _box!.put('current', settings);
  }

  /// Changer le type de mascotte
  static Future<void> setMascotType(String type) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(mascotType: type);
    await updateSettings(updatedSettings);
  }

  /// Basculer la visibilité de la mascotte
  static Future<void> toggleVisibility() async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(isVisible: !currentSettings.isVisible);
    await updateSettings(updatedSettings);
  }

  /// Définir un nom personnalisé pour la mascotte
  static Future<void> setCustomName(String? name) async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(customName: name);
    await updateSettings(updatedSettings);
  }

  /// Enregistrer une interaction avec la mascotte
  static Future<void> recordInteraction() async {
    final currentSettings = getSettings();
    final updatedSettings = currentSettings.copyWith(lastInteraction: DateTime.now());
    await updateSettings(updatedSettings);
  }

  /// Réinitialiser les paramètres par défaut
  static Future<void> resetToDefaults() async {
    final defaultSettings = MascotSettings();
    await updateSettings(defaultSettings);
  }

  /// Obtenir un ValueListenable pour écouter les changements
  static ValueListenable<Box<MascotSettings>> getListenable() {
    if (_box == null) {
      throw Exception('MascotService not initialized. Call initialize() first.');
    }
    return _box!.listenable();
  }

  /// Fermer la box Hive
  static Future<void> dispose() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}
