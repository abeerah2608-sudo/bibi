import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../utils/text_parsing_utils.dart';
import 'onboarding_page_2.dart';
import 'onboarding_page_4.dart';

class OnboardingPage3 extends StatefulWidget {
  const OnboardingPage3({super.key});

  @override
  State<OnboardingPage3> createState() => _OnboardingPage3State();
}

class _OnboardingPage3State extends State<OnboardingPage3> {
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
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
        }

        final title = LanguageStrings.getTranslation(currentLanguage, 'breast_cancer');

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
                    top: 175,
                    left: MediaQuery.of(context).size.width * 0.5 + 16,
                    right: 8,
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
                    child: OnboardingPageIndicator(currentPage: 2, totalPages: 10),
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
                            builder: (context) => const OnboardingPage2(),
                          ),
                        );
                      },
                      onNextPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage4(),
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
      },
    );
  }
}
