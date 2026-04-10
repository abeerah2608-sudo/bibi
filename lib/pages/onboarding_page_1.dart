import 'package:bibi/pages/onboarding_page_5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../utils/text_parsing_utils.dart';
import '../mixins/onboarding_audio_mixin.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with OnboardingAudioMixin, WidgetsBindingObserver {
  int _currentPage = 0;
  bool _showText = false;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      textKey: 'assalam_o_alaikum',
      englishAudio: 'assets/audio/onboarding_1.mp3',
      urduAudio: 'assets/audio/onboarding_1_urdu.mp3',
        assetPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',

        scale: 2.0,

  translateXPercent: -0.08, // move left
  translateYPercent: 0.05, 
    alignment: Alignment.centerLeft,


    ),
    OnboardingPageData(
      textKey: 'im_bibi',
      englishAudio: 'assets/audio/onboarding_2.mp3',
      urduAudio: 'assets/audio/onboarding_2_urdu.mp3',
      scale: 1.3,
        assetPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',

      translateXPercent: -0.08,
      translateYPercent: 0.05,
      alignment: Alignment.centerLeft,
    ),
    OnboardingPageData(
      textKey: 'breast_cancer',
      englishAudio: 'assets/audio/onboarding_3.mp3',
      urduAudio: 'assets/audio/onboarding_3_urdu.mp3',
      assetPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',
        translateXPercent: -0.08, // move left
  translateYPercent: 0.05, 
    alignment: Alignment.centerLeft,
    scale: 1.3,
    ),
    OnboardingPageData(
      textKey: 'welcome',
      englishAudio: 'assets/audio/onboarding_4.mp3',
      urduAudio: 'assets/audio/onboarding_4_urdu.mp3',
        assetPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',

      scale: 1.3,
      translateXPercent: -0.08,
      translateYPercent: 0.05,
      alignment: Alignment.centerLeft,
    ),
    OnboardingPageData(
      textKey: 'life',
      englishAudio: 'assets/audio/onboarding_5.mp3',
      urduAudio: 'assets/audio/onboarding_5_urdu.mp3',
        assetPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',

           translateXPercent: -0.08, // move left
  translateYPercent: 0.05, 
    alignment: Alignment.centerLeft,
    scale: 1.3,
    ),
    OnboardingPageData(
      textKey: 'awareness',
      englishAudio: 'assets/audio/onboarding_6.mp3',
      urduAudio: 'assets/audio/onboarding_6_urdu.mp3',
        assetPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',

           translateXPercent: -0.08, // move left
  translateYPercent: 0.05, 
    alignment: Alignment.centerLeft,
    scale: 1.3,
    ),
    OnboardingPageData(
      textKey: 'fulfill',
      englishAudio: 'assets/audio/onboarding_7.mp3',
      urduAudio: 'assets/audio/onboarding_7_urdu.mp3',
        assetPath: 'assets/images/Bibi_Onboarding_Leftt.lottie',

      scale: 2.3,
      translateXPercent: -0.08,
      translateYPercent: 0.05,
      alignment: Alignment.centerLeft,
    ),
  ];

  @override
  String get englishAudioPath => _pages[_currentPage].englishAudio;

  @override
  String get urduAudioPath => _pages[_currentPage].urduAudio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final state = context.read<LanguageBloc>().state;
    String initialLanguage = 'English';
    if (state is LanguageSelected) {
      initialLanguage = state.language;
    }
    initAudio(initialLanguage);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showText = true);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      stopAudio();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disposeAudio();
    super.dispose();
  }

  void _goToNextPage(String currentLanguage) {
    if (_currentPage < _pages.length - 1) {
      setState(() {
        _showText = false;
        _currentPage++;
      });
      stopAudio();
      initAudio(currentLanguage);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showText = true);
      });
    } else {
      stopAudio();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingPage5()),
      );
    }
  }

  void _goToPreviousPage(String currentLanguage) {
    if (_currentPage > 0) {
      setState(() {
        _showText = false;
        _currentPage--;
      });
      stopAudio();
      initAudio(currentLanguage);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showText = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
          onLanguageChanged(currentLanguage);
        }

        final currentPageData = _pages[_currentPage];
        final title = LanguageStrings.getTranslation(
          currentLanguage,
          currentPageData.textKey,
        );

        final isUrdu = currentLanguage == 'اردو';
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

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
                      clipBehavior: Clip.hardEdge,
                      children: [

                        // ── ANIMATION ──────────────────────────────────────
                        // Vanilla call — all sizing is now handled inside
                        // onboarding_animation.dart (height = screenHeight*0.80)
                       OnboardingAnimation(
  assetPath: currentPageData.assetPath ?? 'assets/images/Bibi_Onboarding_Leftt.lottie',
  scale: currentPageData.scale,
  translateXPercent: currentPageData.translateXPercent,
  translateYPercent: currentPageData.translateYPercent,
  alignment: currentPageData.alignment,
),

                        // ── FADE ───────────────────────────────────────────
                        // screenHeight * 0.45 means the fade starts roughly
                        // at the character's waist and fades to solid at the
                        // bottom of the Expanded area, covering the feet and
                        // the hard bottom edge of the enlarged Lottie box.
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: IgnorePointer(
                            child: Container(
                              height: screenHeight * 0.45,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0x00FFF4F4),
                                    Color(0x18FFF4F4),
                                    Color(0x55FFF4F4),
                                    Color(0xAAFFF4F4),
                                    Color(0xF2FFF4F4),
                                    Color(0xFFFFF4F4),
                                  ],
                                  stops: [0.0, 0.2, 0.42, 0.64, 0.84, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── TEXT ───────────────────────────────────────────
                        Positioned(
                          top: 120,
                          left: screenWidth * 0.5+30 ,
                          right: 30,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Directionality(
                              key: ValueKey<int>(_currentPage),
                              textDirection: isUrdu
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: TextParsingUtils.parseBold(title),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OnboardingNavigationButtons(
                      showBackButton: _currentPage > 0,
                      onBackPressed: _currentPage > 0
                          ? () => _goToPreviousPage(currentLanguage)
                          : null,
                      onNextPressed: () => _goToNextPage(currentLanguage),
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

class OnboardingPageData {
  final String textKey;
  final String englishAudio;
  final String urduAudio;
final double scale;
final double translateXPercent;
final double translateYPercent;
final Alignment alignment;
final String ?assetPath;

  const OnboardingPageData({
    required this.textKey,
    required this.englishAudio,
    required this.assetPath,
    required this.urduAudio,
    required this.scale,
    required this.translateXPercent,
    required this.translateYPercent,
    required this.alignment,
  });
}