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
       color : Color(0xFFFFF5F5),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFFFFF5F5),
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
