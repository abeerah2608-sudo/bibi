import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';

class OnboardingPage4 extends StatelessWidget {
  final String language;

  const OnboardingPage4({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final title = LanguageStrings.getTranslation(language, 'life_is_too_short');
    final subtitle = LanguageStrings.getTranslation(language, 'choose_wisely');
    final backText = LanguageStrings.getTranslation(language, 'back');
    final getStartedText =
        LanguageStrings.getTranslation(language, 'get_started');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFE6ED), Color(0xFFfffdfd)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // BIBI Logo
                  Image.asset(
                    'assets/images/Bibi_Logo_Vector 1.png',
                    height: 60,
                    width: 60,
                  ),
                  SizedBox(height: 24),

                  // Illustration
                  Image.asset(
                    'assets/images/amico.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 32),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B5E3C),
                    ),
                  ),
                  SizedBox(height: 8),

                  // Subtitle
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8B6F47),
                    ),
                  ),
                  SizedBox(height: 48),

                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Color(0xFFE85B99),
                            width: 2,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          backText,
                          style: TextStyle(
                            color: Color(0xFFE85B99),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Get Started Button
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to dashboard or main app
                          // Navigator.of(context).pushReplacementNamed('/dashboard');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE85B99),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          getStartedText,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
