import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import 'onboarding_page_5.dart';
import 'onboarding_page_7.dart';

class OnboardingPage6 extends StatefulWidget {
  const OnboardingPage6({super.key});

  @override
  State<OnboardingPage6> createState() => _OnboardingPage6State();
}

class _OnboardingPage6State extends State<OnboardingPage6> {
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

        final title = LanguageStrings.getTranslation(currentLanguage, 'family_tree');

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
                    alignment: Alignment.centerLeft,
                    child: Transform.translate(
                      offset: const Offset(0, -50),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 450,
                        child: DotLottieLoader.fromAsset(
                          'assets/images/family_tree.lottie',
                          frameBuilder: (ctx, dotLottie) {
                            if (dotLottie != null &&
                                dotLottie.animations.isNotEmpty) {
                              return Lottie.memory(
                                dotLottie.animations.values.first,
                                fit: BoxFit.cover,
                                repeat: true,
                                imageProviderFactory: (asset) =>
                                    MemoryImage(dotLottie.images[asset.fileName]!),
                              );
                            }

                            return const Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (ctx, err, stack) {
                            debugPrint("DotLottie error: $err");
                            return const Center(
                              child: Text(
                                "Animation failed",
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 100,
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
                    child: OnboardingPageIndicator(currentPage: 5, totalPages: 10),
                  ),

                  // Navigation buttons
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: OnboardingNavigationButtons(
                      showBackButton: true,
                      onBackPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage5(),
                          ),
                        );
                      },
                      onNextPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage7(),
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
