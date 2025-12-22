import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  bool _isInitialized = false;
  bool _isPremium = false;

  // IDs AdMob (à remplacer par vos vrais IDs après création compte AdMob)
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';

  // IDs production (à configurer après création compte AdMob)
  static const String _prodBannerId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
  static const String _prodInterstitialId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';

  String get bannerId => kDebugMode ? _testBannerId : _prodBannerId;
  String get interstitialId => kDebugMode ? _testInterstitialId : _prodInterstitialId;

  InterstitialAd? _interstitialAd;
  int _interstitialLoadAttempts = 0;
  int _actionsSinceLastAd = 0;

  /// Initialiser AdMob
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      if (kDebugMode) {
        print('✅ AdMob initialized');
      }

      // Pré-charger une pub interstitielle
      _loadInterstitialAd();
    } catch (e) {
      if (kDebugMode) {
        print('❌ AdMob initialization error: $e');
      }
    }
  }

  /// Définir le statut premium (désactive les pubs)
  void setPremiumStatus(bool isPremium) {
    _isPremium = isPremium;
  }

  /// Vérifier si les pubs doivent être affichées
  bool get shouldShowAds => !_isPremium && _isInitialized;

  /// Créer une bannière publicitaire
  BannerAd? createBannerAd() {
    if (!shouldShowAds) return null;

    return BannerAd(
      adUnitId: bannerId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (kDebugMode) {
            print('✅ Banner ad loaded');
          }
        },
        onAdFailedToLoad: (ad, error) {
          if (kDebugMode) {
            print('❌ Banner ad failed to load: $error');
          }
          ad.dispose();
        },
      ),
    );
  }

  /// Charger une pub interstitielle
  void _loadInterstitialAd() {
    if (!shouldShowAds) return;

    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
          if (kDebugMode) {
            print('✅ Interstitial ad loaded');
          }

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // Recharger pour la prochaine fois
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              if (kDebugMode) {
                print('❌ Interstitial ad failed to show: $error');
              }
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          if (kDebugMode) {
            print('❌ Interstitial ad failed to load: $error (attempt $_interstitialLoadAttempts)');
          }

          // Réessayer avec délai exponentiel
          if (_interstitialLoadAttempts < 3) {
            Future.delayed(
              Duration(seconds: _interstitialLoadAttempts * 2),
              _loadInterstitialAd,
            );
          }
        },
      ),
    );
  }

  /// Afficher une pub interstitielle (toutes les 3 actions)
  Future<void> showInterstitialAd() async {
    if (!shouldShowAds) return;

    _actionsSinceLastAd++;

    // Afficher toutes les 3 actions
    if (_actionsSinceLastAd < 3) return;

    if (_interstitialAd != null) {
      await _interstitialAd!.show();
      _actionsSinceLastAd = 0;
    } else {
      _loadInterstitialAd(); // Charger si pas prête
    }
  }

  /// Incrémenter le compteur d'actions (sans afficher)
  void incrementActionCount() {
    if (shouldShowAds) {
      _actionsSinceLastAd++;
    }
  }

  /// Nettoyer les ressources
  void dispose() {
    _interstitialAd?.dispose();
  }
}

/// Widget helper pour afficher une bannière
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final ad = AdService.instance.createBannerAd();
    if (ad == null) return;

    ad.load().then((_) {
      setState(() {
        _bannerAd = ad;
        _isLoaded = true;
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
