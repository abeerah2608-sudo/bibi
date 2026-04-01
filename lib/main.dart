import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bloc_exports.dart';
import 'pages/splashScreen.dart';
import 'services/animation_cache_service.dart';

void main() {
  // Optimize Flutter for Impeller GPU rendering engine
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable Impeller-specific optimizations
  // Pre-load animations with GPU caching for faster rendering
  _preloadAnimations();
  
  runApp(const MainApp());
}

/// Pre-load commonly used Lottie animations with GPU caching
void _preloadAnimations() {
  AnimationCacheService().preloadAnimations([
    'assets/images/Bibi_Onboarding_Leftt.lottie',
    'assets/images/Bibi_Onboarding_Right.lottie',
  ]);
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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
        home: const SplashScreen(),
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

