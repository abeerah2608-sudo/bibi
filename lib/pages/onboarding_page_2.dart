import 'package:flutter/material.dart';
import '../services/language_strings.dart';
import '../utils/smooth_page_route.dart';
import 'onboarding_page_1.dart';
import 'onboarding_page_3.dart';

class OnboardingPage2 extends StatelessWidget {
  final String language;

  const OnboardingPage2({
    super.key,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final title = LanguageStrings.getTranslation(language, 'im_bibi');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFFFF4F4),
        child: Column(
          children: [
            const SizedBox(height: 60),

            Image.asset(
              'assets/images/Bibi_Logo_Vector 1.png',
              height: 100,
              width: 100,
            ),

            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..scale(-1.0, 1.0),
                      child: Transform.translate(
                        offset: const Offset(0, -40),
                        child: Image.asset(
                          'assets/images/ms_bibi.png',
                          height: 450,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 165,
                    left: 16,
                    right: MediaQuery.of(context).size.width * 0.5 + 16,
                    child: parseBold(title),
                  ),

                  // BACK button
                  Positioned(
                    bottom: 24,
                    left: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: OnboardingPage1(language: language),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE86A8D), width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFFE86A8D),
                        size: 24,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 24,
                    right: 24,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          SmoothPageRoute(
                            page: OnboardingPage3(language: language),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE86A8D),
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
