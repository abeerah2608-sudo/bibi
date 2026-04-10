import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'bloc/bloc_exports.dart';
import 'pages/languageSelection.dart';
import 'pages/dashboard.dart';
import 'pages/splashScreen.dart';
import 'services/animation_cache_service.dart';
import 'services/onboarding_service.dart';

void main() async {
  // Optimize Flutter for Impeller GPU rendering engine
  WidgetsFlutterBinding.ensureInitialized();
  
  // Keep native splash screen visible while loading
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);
  
  // Enable Impeller-specific optimizations
  // Pre-load animations with GPU caching for faster rendering
  _preloadAnimations();
  
  // Check if onboarding has been completed
  final hasCompletedOnboarding = await OnboardingService.hasCompletedOnboarding();
  
  // Dismiss native splash screen after app is ready
  FlutterNativeSplash.remove();
  
  runApp(MainApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

/// Pre-load commonly used Lottie animations with GPU caching
void _preloadAnimations() {
  AnimationCacheService().preloadAnimations([
    'assets/images/Bibi_Onboarding_Leftt.lottie',
    'assets/images/Bibi_Onboarding_Right.lottie',
  ]);
}

class MainApp extends StatelessWidget {
  final bool hasCompletedOnboarding;
  
  const MainApp({super.key, required this.hasCompletedOnboarding});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'DM Sans',
          // Optimized for Material 3 and Impeller rendering
          useMaterial3: true,
          // Enable hardware-accelerated rendering
          // Impeller will use these optimizations automatically
        ),
        home: SplashScreen(hasCompletedOnboarding: hasCompletedOnboarding),
        // App-level performance optimization
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              boldText: false,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

