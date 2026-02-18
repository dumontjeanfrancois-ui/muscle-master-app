import 'package:hive/hive.dart';
import 'dart:io' show Platform;
// import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Désactivé temporairement
import '../models/user.dart';

class AuthService {
  static const String _boxName = 'users';
  static const String _currentUserKey = 'current_user_id';

  /// Vérifie si un utilisateur est déjà connecté
  static Future<bool> isLoggedIn() async {
    final box = await Hive.openBox('app_settings');
    final userId = box.get(_currentUserKey);
    
    if (userId == null) return false;

    final usersBox = await Hive.openBox<AppUser>(_boxName);
    final user = usersBox.get(userId);
    
    return user != null && user.isLoggedIn;
  }

  /// Récupère l'utilisateur actuellement connecté
  static Future<AppUser?> getCurrentUser() async {
    final box = await Hive.openBox('app_settings');
    final userId = box.get(_currentUserKey);
    
    if (userId == null) return null;

    final usersBox = await Hive.openBox<AppUser>(_boxName);
    return usersBox.get(userId);
  }

  /// Inscription d'un nouvel utilisateur
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final usersBox = await Hive.openBox<AppUser>(_boxName);

      // Vérifier si l'email existe déjà
      final existingUser = usersBox.values.firstWhere(
        (user) => user.email == email,
        orElse: () => AppUser(
          id: '',
          email: '',
          password: '',
          name: '',
          createdAt: DateTime.now(),
        ),
      );

      if (existingUser.email.isNotEmpty) {
        return {
          'success': false,
          'message': 'Cet email est déjà utilisé',
        };
      }

      // Créer le nouvel utilisateur
      final user = AppUser(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        password: password, // ⚠️ En production, hash le mot de passe
        name: name,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        isLoggedIn: true,
      );

      await usersBox.put(user.id, user);

      // Définir comme utilisateur actuel
      final settingsBox = await Hive.openBox('app_settings');
      await settingsBox.put(_currentUserKey, user.id);

      return {
        'success': true,
        'message': 'Compte créé avec succès',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de l\'inscription: $e',
      };
    }
  }

  /// Connexion d'un utilisateur
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final usersBox = await Hive.openBox<AppUser>(_boxName);

      // Chercher l'utilisateur
      final user = usersBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => AppUser(
          id: '',
          email: '',
          password: '',
          name: '',
          createdAt: DateTime.now(),
        ),
      );

      if (user.email.isEmpty) {
        return {
          'success': false,
          'message': 'Email ou mot de passe incorrect',
        };
      }

      // Mettre à jour le statut de connexion
      user.isLoggedIn = true;
      user.lastLogin = DateTime.now();
      await user.save();

      // Définir comme utilisateur actuel
      final settingsBox = await Hive.openBox('app_settings');
      await settingsBox.put(_currentUserKey, user.id);

      return {
        'success': true,
        'message': 'Connexion réussie',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur lors de la connexion: $e',
      };
    }
  }

  /// Déconnexion de l'utilisateur actuel
  static Future<void> logout() async {
    final user = await getCurrentUser();
    if (user != null) {
      user.isLoggedIn = false;
      await user.save();
    }

    final settingsBox = await Hive.openBox('app_settings');
    await settingsBox.delete(_currentUserKey);
  }

  /// Supprimer un compte utilisateur
  static Future<void> deleteAccount() async {
    final user = await getCurrentUser();
    if (user != null) {
      await user.delete();
    }

    final settingsBox = await Hive.openBox('app_settings');
    await settingsBox.delete(_currentUserKey);
  }

  /* TEMPORAIREMENT DÉSACTIVÉ - Problème de build Kotlin
  /// Sign in With Apple (COMPLIANCE APPLE APP STORE)
  /// Requis si Email/Password est proposé
  static Future<Map<String, dynamic>> signInWithApple() async {
    try {
      // Vérifier si disponible (iOS uniquement)
      if (!Platform.isIOS) {
        return {
          'success': false,
          'message': 'Sign in With Apple disponible uniquement sur iOS',
        };
      }

      // Demander les credentials Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Extraire les informations
      final appleId = credential.userIdentifier;
      final email = credential.email ?? '$appleId@privaterelay.appleid.com';
      final firstName = credential.givenName ?? '';
      final lastName = credential.familyName ?? '';
      final fullName = '$firstName $lastName'.trim();
      final displayName = fullName.isNotEmpty ? fullName : 'Utilisateur Apple';

      // Vérifier si l'utilisateur existe déjà
      final usersBox = await Hive.openBox<AppUser>(_boxName);
      AppUser? existingUser = usersBox.values.firstWhere(
        (user) => user.email == email,
        orElse: () => AppUser(
          id: '',
          email: '',
          password: '',
          name: '',
          createdAt: DateTime.now(),
        ),
      );

      late AppUser user;

      if (existingUser.email.isEmpty) {
        // Créer nouveau compte
        user = AppUser(
          id: appleId ?? DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          password: 'apple_sign_in', // Pas de mot de passe pour Apple Sign In
          name: displayName,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          isLoggedIn: true,
        );
        await usersBox.put(user.id, user);
      } else {
        // Utilisateur existant
        user = existingUser;
        user.isLoggedIn = true;
        user.lastLogin = DateTime.now();
        await user.save();
      }

      // Définir comme utilisateur actuel
      final settingsBox = await Hive.openBox('app_settings');
      await settingsBox.put(_currentUserKey, user.id);

      return {
        'success': true,
        'message': 'Connexion avec Apple réussie',
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur Sign in With Apple: $e',
      };
    }
  }
  */
}
