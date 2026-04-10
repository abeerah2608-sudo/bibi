import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import 'package:bibi/pages/dashboard.dart';

import '../services/language_strings.dart';
import '../services/onboarding_service.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../utils/text_parsing_utils.dart';
import 'onboarding_page_10.dart';
import '../mixins/onboarding_audio_mixin.dart'; // ✅ import mixin

class OnboardingPage11 extends StatefulWidget {
  const OnboardingPage11({super.key});

  @override
  State<OnboardingPage11> createState() => _OnboardingPage11State();
}

class _OnboardingPage11State extends State<OnboardingPage11>
    with OnboardingAudioMixin {
  bool _showText = false;

  /// ✅ Provide audio paths for this page
  @override
  String get englishAudioPath => 'assets/audio/onboarding_13.mp3';
  @override
  String get urduAudioPath => 'assets/audio/onboarding_13_urdu.mp3';

  @override
  void initState() {
    super.initState();
    initAudio(); // ✅ initialize audio
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
            LanguageStrings.getTranslation(currentLanguage, 'hope');
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
                              textDirection:
                                  isUrdu ? TextDirection.rtl : TextDirection.ltr,
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
                       onNextPressed: () async {
                         stopAudio();
                        await OnboardingService.markOnboardingCompleted();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        );
                      },
                    onBackPressed: () {
                      stopAudio(); // ✅ stop audio before navigating
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const OnboardingPage10(),
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