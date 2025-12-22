import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../models/user_subscription.dart';

class SubscriptionService extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  UserSubscription? _currentSubscription;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  bool _purchasePending = false;

  // IDs des produits (à configurer sur Google Play Console)
  static const String monthlySubscriptionId = 'muscle_master_premium_monthly';
  static const String yearlySubscriptionId = 'muscle_master_premium_yearly';
  static const String trialSubscriptionId = 'muscle_master_premium_trial';

  // Getters
  UserSubscription? get currentSubscription => _currentSubscription;
  bool get isPremium => _currentSubscription?.isPremium ?? false;
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;
  bool get purchasePending => _purchasePending;

  /// Initialisation du service
  Future<void> initialize(String userId) async {
    // Vérifier disponibilité des achats in-app
    _isAvailable = await _iap.isAvailable();
    
    if (!_isAvailable) {
      if (kDebugMode) {
        print('⚠️ In-app purchases not available');
      }
      return;
    }

    // Charger les produits disponibles
    await _loadProducts();

    // Écouter les achats
    _subscription = _iap.purchaseStream.listen(
      (purchases) => _handlePurchaseUpdates(purchases, userId),
      onError: (error) {
        if (kDebugMode) {
          print('❌ Purchase stream error: $error');
        }
      },
    );

    // Charger l'abonnement actuel depuis Firestore
    await loadSubscription(userId);

    // Restaurer les achats précédents
    await _iap.restorePurchases();
  }

  /// Charger les produits depuis les stores
  Future<void> _loadProducts() async {
    const productIds = {
      monthlySubscriptionId,
      yearlySubscriptionId,
      trialSubscriptionId,
    };

    try {
      final response = await _iap.queryProductDetails(productIds);
      
      if (response.error != null) {
        if (kDebugMode) {
          print('❌ Error loading products: ${response.error}');
        }
        return;
      }

      _products = response.productDetails;
      if (kDebugMode) {
        print('✅ Loaded ${_products.length} products');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception loading products: $e');
      }
    }
  }

  /// Charger l'abonnement depuis Firestore
  Future<void> loadSubscription(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('subscription')
          .doc('current')
          .get();

      if (doc.exists) {
        _currentSubscription = UserSubscription.fromMap(doc.data()!, userId);
      } else {
        _currentSubscription = UserSubscription.free(userId);
        // Créer le document par défaut
        await _saveSubscription(_currentSubscription!);
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading subscription: $e');
      }
      _currentSubscription = UserSubscription.free(userId);
      notifyListeners();
    }
  }

  /// Sauvegarder l'abonnement dans Firestore
  Future<void> _saveSubscription(UserSubscription subscription) async {
    try {
      await _firestore
          .collection('users')
          .doc(subscription.userId)
          .collection('subscription')
          .doc('current')
          .set(subscription.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving subscription: $e');
      }
    }
  }

  /// Acheter un abonnement
  Future<void> buySubscription(ProductDetails product) async {
    if (!_isAvailable) {
      if (kDebugMode) {
        print('⚠️ In-app purchases not available');
      }
      return;
    }

    _purchasePending = true;
    notifyListeners();

    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error buying subscription: $e');
      }
      _purchasePending = false;
      notifyListeners();
    }
  }

  /// Gérer les mises à jour d'achats
  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
    String userId,
  ) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        _purchasePending = true;
        notifyListeners();
      } else if (purchase.status == PurchaseStatus.error) {
        _purchasePending = false;
        notifyListeners();
        if (kDebugMode) {
          print('❌ Purchase error: ${purchase.error}');
        }
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Vérifier la validité de l'achat (à faire côté serveur en production)
        await _verifyAndActivatePurchase(purchase, userId);
        _purchasePending = false;
        notifyListeners();
      }

      // Confirmer l'achat pour éviter les remboursements automatiques
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Vérifier et activer l'achat
  Future<void> _verifyAndActivatePurchase(
    PurchaseDetails purchase,
    String userId,
  ) async {
    try {
      // En production, vérifier côté serveur avec Firebase Cloud Functions
      // Pour le moment, activation directe
      
      DateTime expiryDate;
      String productId = purchase.productID;

      if (productId == monthlySubscriptionId) {
        expiryDate = DateTime.now().add(const Duration(days: 30));
      } else if (productId == yearlySubscriptionId) {
        expiryDate = DateTime.now().add(const Duration(days: 365));
      } else if (productId == trialSubscriptionId) {
        expiryDate = DateTime.now().add(const Duration(days: 7));
      } else {
        expiryDate = DateTime.now().add(const Duration(days: 30));
      }

      final updatedSubscription = UserSubscription(
        userId: userId,
        status: productId == trialSubscriptionId ? 'trial' : 'premium',
        expiryDate: expiryDate,
        platform: 'android',
        subscriptionId: purchase.purchaseID,
        productId: productId,
        startDate: DateTime.now(),
      );

      await _saveSubscription(updatedSubscription);
      _currentSubscription = updatedSubscription;
      notifyListeners();

      if (kDebugMode) {
        print('✅ Subscription activated: $productId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error activating purchase: $e');
      }
    }
  }

  /// Restaurer les achats
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
      if (kDebugMode) {
        print('✅ Purchases restored');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error restoring purchases: $e');
      }
    }
  }

  /// Nettoyer les ressources
  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
