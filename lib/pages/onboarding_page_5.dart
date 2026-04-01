import 'package:flutter/material.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/onboarding_widgets_exports.dart';
import 'onboarding_page_4.dart';
import 'onboarding_page_6.dart';

class OnboardingPage5 extends StatefulWidget {
  final String language;

  const OnboardingPage5({super.key, required this.language});

  @override
  State<OnboardingPage5> createState() => _OnboardingPage5State();
}

class _OnboardingPage5State extends State<OnboardingPage5> {
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showText = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = LanguageStrings.getTranslation(widget.language, 'cancer_cell');

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
                  // Cancer cell animation
                  const OnboardingAnimation(
                    assetPath: 'assets/images/Cancer Cell Animation from Bibi Project (1).lottie',
                    translateX: 0,
                    translateY: -40,
                    repeat: false,
                  ),

                  Positioned(
                    bottom: 130,
                    left: 0,
                    right: 0,
                    child: AnimatedSlide(
                      offset: _showText ? Offset.zero : const Offset(0, 0.15),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: _showText ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF8B5E3C),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Page indicator
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: OnboardingPageIndicator(currentPage: 4, totalPages: 10),
                  ),

                  // Navigation buttons
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: OnboardingNavigationButtons(
                      onBackPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => OnboardingPage4(language: widget.language),
                          ),
                        );
                      },
                      onNextPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => OnboardingPage6(language: widget.language),
                          ),
                        );
                      },
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
