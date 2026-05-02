// ============================================================================
// REFACTORED MAIN.DART - FIREBASE-DRIVEN UI SYSTEM
// ============================================================================
// This is the refactored entry point showing proper initialization
// of the new dynamic UI system. Update your current main.dart to include
// this initialization code.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'bloc/language/language_bloc.dart';
import 'bloc/onboarding_bloc.dart';
import 'bloc/dashboard_bloc.dart';
import 'services/dynamic_content_service.dart';
import 'services/animation_cache_service.dart';
import 'pages/onboarding_flow_dynamic_refactored.dart';
import 'pages/dashboard_dynamic_refactored.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =========================================================================
  // 1. INITIALIZE FIREBASE
  // =========================================================================
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // =========================================================================
  // 2. INITIALIZE DYNAMIC CONTENT SERVICE
  // =========================================================================
  final contentService = DynamicContentService();
  //await contentService.initialize();

  // Pre-load animations for GPU optimization
  await AnimationCacheService().preloadAnimations([
    'assets/images/splash.lottie',
    'assets/images/onboarding_5.lottie',
    'assets/images/chemotherapy.lottie',
    'assets/images/ultrasound.lottie',
  ]);

  // =========================================================================
  // 3. RUN APP WITH PROVIDERS
  // =========================================================================
  runApp(
    MultiBlocProvider(
      providers: [
        // Language management
        BlocProvider<LanguageBloc>(
          create: (context) => LanguageBloc(),
        ),

        // Onboarding state (optional - if using BLoC)
        BlocProvider<OnboardingBloc>(
          create: (context) => OnboardingBloc(),
        ),

        // Dashboard state (optional - if using BLoC)
        BlocProvider<DashboardBloc>(
          create: (context) => DashboardBloc(),
        ),
      ],
      child: MyApp(contentService: contentService),
    ),
  );
}

// ============================================================================
// MAIN APP WIDGET
// ============================================================================

class MyApp extends StatelessWidget {
  final DynamicContentService contentService;

  const MyApp({Key? key, required this.contentService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bibi - Dynamic UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(
        timeout: Duration(seconds: 3),
      ),
      routes: {
        '/onboarding': (context) => const DynamicOnboardingFlowPage(),
        '/dashboard': (context) => const DynamicDashboardPage(),
        // Add other routes as needed
      },
    );
  }
}

// ============================================================================
// SPLASH SCREEN (Keep your existing splash or create new)
// ============================================================================

class SplashScreen extends StatefulWidget {
  final Duration timeout;

  const SplashScreen({
    Key? key,
    this.timeout = const Duration(seconds: 3),
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() {
    Future.delayed(widget.timeout, () {
      if (mounted) {
        // Navigate to onboarding (or home if already completed)
        Navigator.of(context).pushNamed('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5E6D3), Color(0xFFFDEDDC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5E3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(75),
                ),
                child: const Center(
                  child: Icon(
                    Icons.favorite,
                    size: 80,
                    color: Color(0xFF8B5E3C),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bibi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B5E3C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
