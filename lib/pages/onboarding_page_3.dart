import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import 'onboarding_page_4.dart';

class OnboardingPage3 extends StatelessWidget {
  final String language;

  const OnboardingPage3({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final title = LanguageStrings.getTranslation(
      language,
      'smart_shopping_summaries',
    );
    final subtitle = LanguageStrings.getTranslation(
      language,
      'make_smarter_purchase_decisions',
    );
    final skipText = LanguageStrings.getTranslation(language, 'skip');
    final nextText = LanguageStrings.getTranslation(language, 'next');

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
                    style: TextStyle(
                      fontSize: 32,
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
                      // Skip Button
                      OutlinedButton(
                        onPressed: () {
                          // Skip logic
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
                          skipText,
                          style: TextStyle(
                            color: Color(0xFFE85B99),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      // Next Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OnboardingPage4(
                                language: language,
                              ),
                            ),
                          );
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
                          nextText,
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
