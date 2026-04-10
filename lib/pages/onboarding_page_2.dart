import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../utils/text_parsing_utils.dart';
import 'onboarding_page_1.dart';
import 'onboarding_page_3.dart';
import '../mixins/onboarding_audio_mixin.dart'; // ✅ import mixin

// ✅ Audio paths


class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2> with OnboardingAudioMixin<OnboardingPage2>{
  bool _showText = false;

 /// ✅ Provide audio paths for this page
  @override
  String get englishAudioPath => 'assets/audio/onboarding_2.mp3';
  @override
  String get urduAudioPath => 'assets/audio/onboarding_2_urdu.mp3';

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

        final title =
            LanguageStrings.getTranslation(currentLanguage, 'im_bibi');
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
                  const CachedLogoImage(height: 72, width: 72),
                  const SizedBox(height: 8),
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
                              child: Directionality(
                                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                                child: TextParsingUtils.parseBold(title),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  OnboardingPageIndicator(currentPage: 1, totalPages: 14),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OnboardingNavigationButtons(
                      onBackPressed: () {
                        stopAudio(); // ✅ Stop audio before navigating
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage1(),
                          ),
                        );
                      },
                      onNextPressed: () {
                        stopAudio(); // ✅ Stop audio before navigating
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage3(),
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