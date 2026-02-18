# 🍎 SIGN IN WITH APPLE - GUIDE COMPLET

## ⚠️ COMPLIANCE APPLE
**OBLIGATOIRE** si vous proposez :
- Google Sign In
- Email/Password authentication
- Toute autre méthode de connexion tierce

Apple **REJETTE** les apps qui n'incluent pas Sign in With Apple.

---

## 📦 1. DÉPENDANCES FLUTTER

Ajouter dans `pubspec.yaml` :

```yaml
dependencies:
  sign_in_with_apple: ^6.1.2  # Version testée avec Flutter 3.35.4
  crypto: ^3.0.3  # Pour le nonce
```

---

## 🔧 2. CONFIGURATION iOS

### 2.1 Activer Sign in With Apple Capability

Dans Xcode :
1. Ouvrir `ios/Runner.xcworkspace`
2. Sélectionner le target "Runner"
3. Onglet "Signing & Capabilities"
4. Cliquer sur "+ Capability"
5. Ajouter **"Sign in With Apple"**

### 2.2 Ajouter Entitlements

Fichier `ios/Runner/Runner.entitlements` (créer si absent) :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.applesignin</key>
	<array>
		<string>Default</string>
	</array>
</dict>
</plist>
```

### 2.3 Modifier Info.plist

Ajouter dans `ios/Runner/Info.plist` :

```xml
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<string>com.musclemaster.fitness</string>
		</array>
	</dict>
</array>
```

---

## 🔐 3. CONFIGURATION FIREBASE

### 3.1 Activer Sign in With Apple dans Firebase Console

1. Aller sur https://console.firebase.google.com/
2. Sélectionner votre projet
3. **Authentication** → **Sign-in method**
4. Activer **"Apple"**
5. Configurer :
   - **Service ID** : com.musclemaster.fitness.signin
   - **OAuth Redirect URI** : Copier l'URL fournie par Firebase

### 3.2 Configuration Apple Developer

1. Aller sur https://developer.apple.com/account/
2. **Certificates, IDs & Profiles** → **Identifiers**
3. Créer un **Service ID** :
   - Identifier : `com.musclemaster.fitness.signin`
   - Description : "Muscle Master Sign In"
4. Cocher **"Sign in With Apple"**
5. **Configure** → Ajouter :
   - **Primary App ID** : com.musclemaster.fitness
   - **Redirect URL** : L'URL Firebase copiée plus tôt

---

## 💻 4. CODE FLUTTER

### 4.1 Service d'Authentification Apple

Créer `lib/services/apple_auth_service.dart` :

```dart
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';

class AppleAuthService {
  static final AppleAuthService _instance = AppleAuthService._internal();
  factory AppleAuthService() => _instance;
  AppleAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Génère un nonce sécurisé pour Sign in With Apple
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Hash le nonce avec SHA256
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Connexion avec Sign in With Apple
  Future<UserCredential?> signInWithApple() async {
    try {
      // Vérifier la disponibilité de Sign in With Apple
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        if (kDebugMode) {
          debugPrint('❌ Sign in With Apple non disponible sur cet appareil');
        }
        throw Exception('Sign in With Apple non disponible');
      }

      // Générer un nonce
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Demander les credentials Apple
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Créer les credentials Firebase
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      // Se connecter à Firebase
      final userCredential = await _auth.signInWithCredential(oauthCredential);

      if (kDebugMode) {
        debugPrint('✅ Connexion Apple réussie: ${userCredential.user?.uid}');
      }

      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur Sign in With Apple: $e');
      }
      rethrow;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Utilisateur connecté actuel
  User? get currentUser => _auth.currentUser;
}
```

### 4.2 Bouton Sign in With Apple

Créer `lib/widgets/apple_sign_in_button.dart` :

```dart
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../services/apple_auth_service.dart';

class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;

  const AppleSignInButton({
    super.key,
    this.onSuccess,
    this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return SignInWithAppleButton(
      text: 'Continuer avec Apple',
      height: 50,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      onPressed: () async {
        try {
          final authService = AppleAuthService();
          final userCredential = await authService.signInWithApple();
          
          if (userCredential != null && onSuccess != null) {
            onSuccess!();
          }
        } catch (e) {
          if (onError != null) {
            onError!(e.toString());
          }
        }
      },
    );
  }
}
```

### 4.3 Intégration dans LoginScreen

Ajouter dans votre écran de connexion :

```dart
import '../widgets/apple_sign_in_button.dart';
import 'dart:io' show Platform;

// Dans le build method, AVANT les autres boutons de connexion :

if (Platform.isIOS) ...[
  AppleSignInButton(
    onSuccess: () {
      // Navigation vers l'écran principal
      Navigator.pushReplacementNamed(context, '/main');
    },
    onError: (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur connexion Apple: $error'),
          backgroundColor: Colors.red,
        ),
      );
    },
  ),
  const SizedBox(height: 16),
],
```

---

## ✅ 5. CHECKLIST AVANT SOUMISSION

### iOS App Store Connect
- [ ] Sign in With Apple ajouté et testé
- [ ] Bouton Apple **AU-DESSUS ou ÉGAL** aux autres boutons de connexion
- [ ] Testé sur TestFlight avec plusieurs utilisateurs
- [ ] Politique de confidentialité mentionnant Apple Sign In

### Xcode
- [ ] Capability "Sign in With Apple" activée
- [ ] Runner.entitlements configuré
- [ ] Build iOS réussit sans erreur

### Firebase
- [ ] Provider Apple activé
- [ ] Service ID configuré
- [ ] Redirect URI ajouté

### Apple Developer
- [ ] Service ID créé
- [ ] Redirect URL configuré
- [ ] Primary App ID lié

---

## 🚨 ERREURS COURANTES

### 1. "Sign in With Apple is not supported"
- **Cause** : Capability non activée ou entitlements manquants
- **Solution** : Vérifier Xcode Capabilities

### 2. "Invalid client"
- **Cause** : Service ID mal configuré
- **Solution** : Vérifier Firebase Console et Apple Developer Portal

### 3. "Network error"
- **Cause** : Redirect URI non configuré
- **Solution** : Ajouter l'URI Firebase dans Apple Developer

### 4. Rejet App Store "Missing Sign in With Apple"
- **Cause** : Bouton Apple absent ou mal placé
- **Solution** : Bouton Apple doit être visible et prioritaire

---

## 📝 NOTES IMPORTANTES

1. **Obligatoire sur iOS uniquement** : Android n'a pas besoin de Sign in With Apple
2. **Bouton doit être visible** : Apple rejette si caché ou difficile à trouver
3. **Priorité visuelle** : Bouton Apple doit être au même niveau que Google/Email
4. **Gestion de l'email** : Email Apple peut être "relay" (privé)
5. **TestFlight** : Tester IMPÉRATIVEMENT avant soumission

---

## 🔗 RESSOURCES

- **Apple Documentation** : https://developer.apple.com/sign-in-with-apple/
- **Firebase Setup** : https://firebase.google.com/docs/auth/ios/apple
- **Flutter Package** : https://pub.dev/packages/sign_in_with_apple
- **Human Interface Guidelines** : https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple

---

**✅ COMPLETION STATUS** : Documentation créée, code prêt à intégrer
**⚠️ ACTION REQUISE** : Configuration Apple Developer Console + Firebase Console
