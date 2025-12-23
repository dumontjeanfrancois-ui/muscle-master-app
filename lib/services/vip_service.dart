import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🎮 Easter Egg VIP Service
/// 
/// Système d'accès VIP caché pour le créateur et les influenceurs
/// Activation : 12 clics sur le logo + code secret "MUSCLE2025MASTER"
/// 
/// Avantages VIP :
/// - Premium illimité sans abonnement
/// - Pas de publicités AdMob
/// - Badge VIP dans l'interface
/// - Toutes les fonctionnalités IA Coach illimitées
/// - Analyse vidéo illimitée
class VipService extends ChangeNotifier {
  static final VipService _instance = VipService._internal();
  factory VipService() => _instance;
  VipService._internal();

  static const String _vipKey = 'muscle_master_vip_status';
  static const String _vipActivationDateKey = 'muscle_master_vip_activation_date';
  static const String _secretCode = 'MUSCLE2025MASTER';
  
  bool _isVip = false;
  DateTime? _activationDate;

  /// Vérifie si l'utilisateur a le statut VIP
  bool get isVip => _isVip;
  
  /// Date d'activation du statut VIP
  DateTime? get activationDate => _activationDate;

  /// Initialise le service VIP (à appeler au démarrage de l'app)
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isVip = prefs.getBool(_vipKey) ?? false;
    
    final timestamp = prefs.getInt(_vipActivationDateKey);
    if (timestamp != null) {
      _activationDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    
    if (_isVip && kDebugMode) {
      debugPrint('🌟 VIP MODE ACTIVATED depuis ${_activationDate?.toString() ?? "date inconnue"}');
    }
    
    notifyListeners();
  }

  /// Tente d'activer le statut VIP avec un code secret
  /// Retourne true si le code est correct
  Future<bool> activateVip(String code) async {
    // Vérification du code secret
    if (code.trim().toUpperCase() != _secretCode) {
      return false;
    }

    // Activation du statut VIP
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vipKey, true);
    await prefs.setInt(_vipActivationDateKey, DateTime.now().millisecondsSinceEpoch);
    
    _isVip = true;
    _activationDate = DateTime.now();
    
    if (kDebugMode) {
      debugPrint('🎉 VIP MODE ACTIVÉ avec succès !');
    }
    
    notifyListeners();
    return true;
  }

  /// Désactive le statut VIP (pour tests uniquement)
  Future<void> deactivateVip() async {
    if (!kDebugMode) return; // Seulement en mode debug
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_vipKey);
    await prefs.remove(_vipActivationDateKey);
    
    _isVip = false;
    _activationDate = null;
    
    debugPrint('🔒 VIP MODE DÉSACTIVÉ');
    notifyListeners();
  }

  /// Vérifie si l'utilisateur a accès aux fonctionnalités premium
  /// (soit via VIP, soit via abonnement normal)
  bool hasPremiumAccess(bool isSubscribed) {
    return _isVip || isSubscribed;
  }

  /// Vérifie si les publicités doivent être affichées
  /// (VIP = pas de publicités)
  bool shouldShowAds(bool isSubscribed) {
    if (_isVip) return false;
    return !isSubscribed;
  }
}
