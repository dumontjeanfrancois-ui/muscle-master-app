import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'screens/public_welcome_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/nutrition_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/calculators_screen.dart';
import 'screens/mascot_chat_screen.dart';
import 'screens/mascot_settings_screen.dart';
import 'screens/account_deletion_screen.dart';
import 'services/subscription_service.dart';
import 'services/ad_service.dart';
import 'services/vip_service.dart';
import 'services/mascot_service.dart';
import 'services/gym_crush_service.dart';
import 'models/mascot_settings.dart';
import 'widgets/flexo_mascot_3d_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialiser Hive pour les paramètres de la mascotte
  await Hive.initFlutter();
  Hive.registerAdapter(MascotSettingsAdapter());
  await MascotService.initialize();
  
  // Initialiser AdMob (uniquement sur mobile, pas sur Web)
  if (!kIsWeb) {
    await AdService.instance.initialize();
  }
  
  // Initialiser VIP Service (Easter Egg)
  await VipService().initialize();
  
  runApp(const MuscleMasterApp());
}

class MuscleMasterApp extends StatelessWidget {
  const MuscleMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SubscriptionService()..initialize('default_user'),
        ),
        ChangeNotifierProvider(
          create: (_) => VipService(),
        ),
      ],
      child: MaterialApp(
        title: 'Muscle Master',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        // COMPLIANCE: Écran public SANS login requis par Apple
        home: const PublicWelcomeScreen(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/main': (context) => const MainScreen(),
          '/mascot_chat': (context) => const MascotChatScreen(),
          '/mascot_settings': (context) => const MascotSettingsScreen(),
          '/account_deletion': (context) => const AccountDeletionScreen(),
        },
        onGenerateRoute: (settings) {
          // Sécurité: route generator pour éviter les erreurs
          if (kDebugMode) {
            debugPrint('🔍 Navigation tentée vers: ${settings.name}');
          }
          return null; // Laisse le système utiliser les routes définies
        },
        onUnknownRoute: (settings) {
          // Fallback sécurisé pour les routes inconnues
          if (kDebugMode) {
            debugPrint('⚠️ Route inconnue: ${settings.name}');
          }
          return MaterialPageRoute(
            builder: (context) => const PublicWelcomeScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const ProgramsScreen(),
    const NutritionScreen(),
    const CalculatorsScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!GymCrushService.isGymCrushEnabled()) return;

    if (state == AppLifecycleState.paused) {
      GymCrushService.stopPresenceHeartbeat();
      debugPrint('🛑 GymCrush: Heartbeat pause (app background)');
    }

    if (state == AppLifecycleState.resumed) {
      final mascotSettings = MascotService.getSettings();
      GymCrushService.startPresenceHeartbeat(
        pseudo: mascotSettings.displayName,
        mascotType: mascotSettings.mascotType,
        mascotName: mascotSettings.customName,
        gymId: 'default_gym',
      );
      debugPrint('✅ GymCrush: Heartbeat reprise (app foreground)');
    }
  }

  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlexoMascot3DOverlay(
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Programmes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progrès',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    ),
    );
  }
}
