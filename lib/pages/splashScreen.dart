import 'package:flutter/material.dart';
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE4F0), Color(0xFFFFCCE0)],
          ),
        ),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFBE4E8),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.all(40.0),
            child: Image.asset(
              'assets/images/Bibi_Logo_Vector 1.png',
              height: 200,
              width: 200,
            ),
          ),
        ),
      ),
    );
  }
}
