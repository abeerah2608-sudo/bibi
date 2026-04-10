import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../mixins/onboarding_audio_mixin.dart';
import 'onboarding_page_4iii.dart';
import 'onboarding_page_6.dart';

class OnboardingPage5 extends StatefulWidget {
  const OnboardingPage5({super.key});

  @override
  State<OnboardingPage5> createState() => _OnboardingPage5State();
}

class _OnboardingPage5State extends State<OnboardingPage5>
    with OnboardingAudioMixin<OnboardingPage5> {
  bool _showText = false;

  /// ✅ Provide audio paths for this page
  @override
  String get englishAudioPath => 'assets/audio/onboarding_8.mp3';
  @override
  String get urduAudioPath => 'assets/audio/onboarding_8_urdu.mp3';

  @override
  void initState() {
super.initState();
    final state = context.read<LanguageBloc>().state;
    String initialLanguage = 'English';
    if (state is LanguageSelected) {
      initialLanguage = state.language;
    }

    // Initialize audio with the correct language
    initAudio(initialLanguage); 

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showText = true);
    });
  }

  @override
  void dispose() {
    disposeAudio(); // ✅ dispose audio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
          onLanguageChanged(currentLanguage); // ✅ handle language change
        }

        final title = LanguageStrings.getTranslation(currentLanguage, 'cancer_cell');
        final isUrdu = currentLanguage == 'اردو';

        return Scaffold(
          body: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFFFF4F4),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  Image.asset(
                    'assets/images/Bibi_Logo_Vector 1.png',
                    height: 72,
                    width: 72,
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: Stack(
                      children: [
                        // Cancer cell animation
                        const OnboardingAnimation(
                          assetPath:
                              'assets/images/Cancer Cell Animation from Bibi Project (1).lottie',
                          translateX: 0,
                          translateY: -40,
                          repeat: false,
                        ),

                        Positioned(
                          top: 80,
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
                                  child: Directionality(
                                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
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
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                  OnboardingPageIndicator(currentPage: 7, totalPages: 14),
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OnboardingNavigationButtons(
                      onBackPressed: () {
                        stopAudio(); // ✅ stop audio before navigating
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage4iii(),
                          ),
                        );
                      },
                      onNextPressed: () {
                        stopAudio(); // ✅ stop audio before navigating
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage6(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}