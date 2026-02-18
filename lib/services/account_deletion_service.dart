import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de suppression de compte
/// COMPLIANCE: Requis par Google Play et Apple App Store
/// Supprime TOUTES les données utilisateur de manière irréversible
class AccountDeletionService {
  static final AccountDeletionService _instance = AccountDeletionService._internal();
  factory AccountDeletionService() => _instance;
  AccountDeletionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Supprime définitivement le compte utilisateur et toutes ses données
  /// Retourne true si succès, false si échec
  /// Lance une exception en cas d'erreur critique
  Future<bool> deleteAccountCompletely(String userId) async {
    try {
      if (kDebugMode) {
        debugPrint('🗑️ Début de la suppression du compte: $userId');
      }

      // 1. Supprimer les programmes créés par l'utilisateur
      await _deleteUserPrograms(userId);

      // 2. Supprimer l'historique des séances
      await _deleteWorkoutHistory(userId);

      // 3. Supprimer le journal alimentaire
      await _deleteFoodLogs(userId);

      // 4. Supprimer les données de progression
      await _deleteProgressData(userId);

      // 5. Supprimer les préférences et paramètres
      await _deleteUserPreferences(userId);

      // 6. Supprimer le document utilisateur principal
      await _deleteUserDocument(userId);

      // 7. Supprimer les données locales
      await _deleteLocalData();

      // 8. Supprimer le compte Firebase Auth
      await _deleteFirebaseAuthAccount();

      if (kDebugMode) {
        debugPrint('✅ Compte supprimé avec succès: $userId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur lors de la suppression du compte: $e');
      }
      rethrow;
    }
  }

  /// Supprime tous les programmes créés par l'utilisateur
  Future<void> _deleteUserPrograms(String userId) async {
    try {
      final programsQuery = await _firestore
          .collection('programs')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in programsQuery.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        debugPrint('✅ ${programsQuery.docs.length} programmes supprimés');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur suppression programmes: $e');
      }
    }
  }

  /// Supprime l'historique complet des séances
  Future<void> _deleteWorkoutHistory(String userId) async {
    try {
      final workoutsQuery = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in workoutsQuery.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        debugPrint('✅ ${workoutsQuery.docs.length} séances supprimées');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur suppression séances: $e');
      }
    }
  }

  /// Supprime le journal alimentaire complet
  Future<void> _deleteFoodLogs(String userId) async {
    try {
      final foodLogsQuery = await _firestore
          .collection('food_logs')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in foodLogsQuery.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        debugPrint('✅ ${foodLogsQuery.docs.length} entrées alimentaires supprimées');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur suppression journal alimentaire: $e');
      }
    }
  }

  /// Supprime les données de progression (poids, mensurations, etc.)
  Future<void> _deleteProgressData(String userId) async {
    try {
      final progressQuery = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in progressQuery.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        debugPrint('✅ ${progressQuery.docs.length} données de progression supprimées');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur suppression progression: $e');
      }
    }
  }

  /// Supprime les préférences et paramètres utilisateur
  Future<void> _deleteUserPreferences(String userId) async {
    try {
      final prefsQuery = await _firestore
          .collection('user_preferences')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in prefsQuery.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        debugPrint('✅ Préférences utilisateur supprimées');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur suppression préférences: $e');
      }
    }
  }

  /// Supprime le document utilisateur principal
  Future<void> _deleteUserDocument(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();

      if (kDebugMode) {
        debugPrint('✅ Document utilisateur principal supprimé');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur suppression document utilisateur: $e');
      }
    }
  }

  /// Supprime toutes les données locales (SharedPreferences)
  Future<void> _deleteLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (kDebugMode) {
        debugPrint('✅ Données locales supprimées');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur suppression données locales: $e');
      }
    }
  }

  /// Supprime le compte Firebase Authentication
  Future<void> _deleteFirebaseAuthAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        if (kDebugMode) {
          debugPrint('✅ Compte Firebase Auth supprimé');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ Erreur suppression compte Firebase Auth: $e');
      }
      rethrow; // Important : relancer l'exception pour authentification requise
    }
  }

  /// Vérifie si l'utilisateur peut supprimer son compte
  /// (connexion récente requise par Firebase)
  Future<bool> canDeleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Vérifier la dernière connexion
      final metadata = user.metadata;
      final lastSignIn = metadata.lastSignInTime;
      
      if (lastSignIn == null) return false;

      // Firebase requiert une connexion récente (< 5 min) pour supprimer
      final now = DateTime.now();
      final difference = now.difference(lastSignIn);
      
      return difference.inMinutes < 5;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur vérification suppression: $e');
      }
      return false;
    }
  }

  /// Réauthentifie l'utilisateur avant suppression
  /// Nécessaire si la dernière connexion est ancienne
  Future<bool> reauthenticateUser(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      
      if (kDebugMode) {
        debugPrint('✅ Réauthentification réussie');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur réauthentification: $e');
      }
      return false;
    }
  }
}
