import 'package:flutter/material.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../utils/text_parsing_utils.dart';
import 'onboarding_page_3.dart';
import 'onboarding_page_5.dart';

class OnboardingPage4 extends StatefulWidget {
  final String language;

  const OnboardingPage4({
    super.key,
    required this.language,
  });

  @override
  State<OnboardingPage4> createState() => _OnboardingPage4State();
}

class _OnboardingPage4State extends State<OnboardingPage4> {
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
    final title = LanguageStrings.getTranslation(widget.language, 'life');

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
                  // ANIMATED TEXT
                  Positioned(
                    top: 150,
                    left: MediaQuery.of(context).size.width * 0.5 + 16,
                    right: 1,
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
                    child: OnboardingPageIndicator(currentPage: 3, totalPages: 10),
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
                            builder: (context) => OnboardingPage3(language: widget.language),
                          ),
                        );
                      },
                      onNextPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => OnboardingPage5(language: widget.language),
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
