import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'languageSelection.dart';
import 'dashboard.dart';

class SplashScreen extends StatefulWidget {
  final bool hasCompletedOnboarding;
  
  const SplashScreen({super.key, required this.hasCompletedOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLanguageSelection();
  }

  _navigateToLanguageSelection() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget.hasCompletedOnboarding
              ? const DashboardScreen()
              : const LanguageSelectionPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RepaintBoundary(
        child: DotLottieLoader.fromAsset(
          'assets/images/splash.lottie',
          frameBuilder: (context, dotLottie) {
            if (dotLottie == null) {
              return const SizedBox.shrink(); // silent wait, no spinner on splash
            }

            if (dotLottie.animations.isEmpty) {
              return const SizedBox.shrink();
            }

            return Lottie.memory(
              dotLottie.animations.values.first,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,        // fills entire screen
              alignment: Alignment.center,
              repeat: true,
              animate: true,
              imageProviderFactory: (asset) {
                if (dotLottie.images.containsKey(asset.fileName)) {
                  return MemoryImage(dotLottie.images[asset.fileName]!);
                }
                return null;
              },
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}