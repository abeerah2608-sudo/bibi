import 'package:flutter/material.dart';
import '../widgets/cached_logo_image.dart';
import 'languageSelection.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
        MaterialPageRoute(builder: (context) => const LanguageSelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFFFF5F5),
        child: const Center(
          child: CachedLogoImage(height: 200, width: 200),
        ),
      ),
    );
  }
}
