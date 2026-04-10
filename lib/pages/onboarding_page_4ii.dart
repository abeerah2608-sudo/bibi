import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../utils/text_parsing_utils.dart';
import 'onboarding_page_4iii.dart';
import 'onboarding_4i.dart';
import '../mixins/onboarding_audio_mixin.dart'; // ✅ import mixin

class OnboardingPage4ii extends StatefulWidget {
  const OnboardingPage4ii({super.key});

  @override
  State<OnboardingPage4ii> createState() => _OnboardingPage4iiState();
}

class _OnboardingPage4iiState extends State<OnboardingPage4ii>
    with OnboardingAudioMixin<OnboardingPage4ii> {
  bool _showText = false;

  /// ✅ Provide audio paths for this page
  @override
  String get englishAudioPath => 'assets/audio/onboarding_6.mp3';
  @override
  String get urduAudioPath => 'assets/audio/onboarding_6_urdu.mp3';

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

        final title = LanguageStrings.getTranslation(currentLanguage, 'awareness');
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
                        Align(
                          alignment: Alignment.center,
                          child: const OnboardingAnimation(
                            assetPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',
                          ),
                        ),

                        // ANIMATED TEXT
                        Positioned(
                          top: 170,
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
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OnboardingNavigationButtons(
                      onBackPressed: () {
                        stopAudio(); // ✅ stop audio before navigating
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage4i(),
                          ),
                        );
                      },
                      onNextPressed: () {
                        stopAudio(); // ✅ stop audio before navigating
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage4iii(),
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