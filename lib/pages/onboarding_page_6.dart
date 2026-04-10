import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../mixins/onboarding_audio_mixin.dart';
import 'onboarding_page_5.dart';
import 'onboarding_page_7.dart';

class OnboardingPage6 extends StatefulWidget {
  const OnboardingPage6({super.key});

  @override
  State<OnboardingPage6> createState() => _OnboardingPage6State();
}

class _OnboardingPage6State extends State<OnboardingPage6>
    with OnboardingAudioMixin<OnboardingPage6> {
  bool _showText = false;

  /// ✅ Provide audio paths for this page
  @override
  String get englishAudioPath => 'assets/audio/onboarding_9.mp3';
  @override
  String get urduAudioPath => 'assets/audio/onboarding_9_urdu.mp3';

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

        final title = LanguageStrings.getTranslation(currentLanguage, 'family_tree');
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
                          bottom: 20,
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
                                    textDirection:
                                        isUrdu ? TextDirection.rtl : TextDirection.ltr,
                                    child: Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 32,
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
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OnboardingNavigationButtons(
                      showBackButton: true,
                      onBackPressed: () {
                        stopAudio(); // ✅ stop audio before navigating
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage5(),
                          ),
                        );
                      },
                      onNextPressed: () {
                        stopAudio(); // ✅ stop audio before navigating
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage7(),
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