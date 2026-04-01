import 'package:flutter/material.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../utils/text_parsing_utils.dart';
import 'onboarding_page_2.dart';

class OnboardingPage1 extends StatefulWidget {
  final String language;

  const OnboardingPage1({super.key, required this.language});

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1> {
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
    final title = LanguageStrings.getTranslation(widget.language, 'assalam_o_alaikum');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFFFF4F4),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const CachedLogoImage(height: 100, width: 100),

            Expanded(
              child: Stack(
                children: [
                  const OnboardingAnimation(
                    assetPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',
                  ),

                  Positioned(
                    top: 190,
                    left: MediaQuery.of(context).size.width * 0.5 + 16,
                    right: 16,
                    child: AnimatedSlide(
                      offset: _showText ? Offset.zero : const Offset(0, 0.15),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      child: AnimatedOpacity(
                        opacity: _showText ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: TextParsingUtils.parseBold(title),
                      ),
                    ),
                  ),
                  // Page indicator
                  Positioned(
                    bottom: 50,
                    left: 0,
                    right: 0,
                    child: OnboardingPageIndicator(currentPage: 0, totalPages: 10),
                  ),
                  // Navigation buttons
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: OnboardingNavigationButtons(
                      showBackButton: false,
                      onNextPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                OnboardingPage2(language: widget.language),
                          ),
                        );
                      },
                    ),
                  ),                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}