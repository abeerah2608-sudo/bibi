import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'bloc/bloc_exports.dart';
import 'pages/languageSelection.dart';
import 'pages/splashScreen.dart';
import 'services/animation_cache_service.dart' hide debugPrint;
import 'services/language_strings.dart';
import 'services/onboarding_service.dart';
import 'pages/onboarding_flow_dynamic.dart';
import 'pages/dashboard.dart';
import 'services/app_route_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("🚀 App initialization started");

  // Initialize Firebase
  debugPrint("🔥 Initializing Firebase...");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("✅ Firebase initialized");

  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  _preloadAnimations();

  final hasCompletedOnboarding =
      await OnboardingService.hasCompletedOnboarding();
  debugPrint("📋 OnboardingService: hasCompletedOnboarding=$hasCompletedOnboarding");

  FlutterNativeSplash.remove();

  debugPrint("🎮 Running MainApp...");
  runApp(MainApp(hasCompletedOnboarding: hasCompletedOnboarding));
}

/// Pre-load commonly used Lottie animations with GPU caching
void _preloadAnimations() {
  AnimationCacheService().preloadAnimations([
    'gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie',
    'gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Right.lottie',
    'assets/images/Cancer Cell Animation from Bibi Project (1).lottie',
    'assets/images/family_tree.lottie',
    'assets/images/ultrasound.lottie',
    'assets/images/chemotherapy.lottie',
    'assets/images/mammogram.lottie',
    'gs://bibi-app-d41a0.firebasestorage.app/animations/Cancer Cell Animation from Bibi Project (1).lottie',
  ]);
}

class MainApp extends StatelessWidget {
  final bool hasCompletedOnboarding;

  const MainApp({super.key, required this.hasCompletedOnboarding});
  
  @override
  Widget build(BuildContext context) {
    debugPrint("🎨 MainApp widget building - hasCompletedOnboarding=$hasCompletedOnboarding");
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          debugPrint("🔧 Creating LanguageBloc");
          return LanguageBloc();
        }),
        BlocProvider(create: (context) {
          debugPrint("🔧 Creating OnboardingBloc");
          return OnboardingBloc();
        }),
        BlocProvider(create: (context) {
          debugPrint("🔧 Creating DashboardBloc");
          return DashboardBloc();
        }),
        BlocProvider(create: (_) {
          debugPrint("🔧 Creating FavoritesBloc");
          return FavoritesBloc();
        }),
        BlocProvider(create: (_) {
          debugPrint("🔧 Creating QuizBloc");
          return QuizBloc();
        }),
      ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: [appRouteObserver],
          theme: ThemeData(
            fontFamily: 'Inter',
            useMaterial3: true,
          ),
          home: SplashScreen(
            hasCompletedOnboarding: kDebugMode ? false : hasCompletedOnboarding,
          ),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(boldText: false),
              child: child!,
            );
          },
        );
      },
    ),
  );
}
}