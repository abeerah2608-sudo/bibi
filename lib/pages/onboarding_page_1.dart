import 'package:bibi/pages/onboarding_page_5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../utils/text_parsing_utils.dart';
import '../mixins/onboarding_audio_mixin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      englishAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1.mp3',
      urduAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_1_urdu.mp3',
      assetPath:
          'gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie',
      scale: 3.7,
      translateXPercent: 0.75,
      translateYPercent: -0.10,
      alignment: Alignment.centerLeft,
    ),
    OnboardingPageData(
      textKey: 'im_bibi',
      englishAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_2.mp3',
      urduAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_2_urdu.mp3',
      assetPath:
          'gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie',
      scale: 3.7,
      translateXPercent: 0.75,
      translateYPercent: -0.10,
      alignment: Alignment.centerLeft,
    ),
    OnboardingPageData(
      textKey: 'breast_cancer',
      englishAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_3.mp3',
      urduAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_3_urdu.mp3',
      assetPath:
          'gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie',
      scale: 3.7,
      translateXPercent: 0.75,
      translateYPercent: -0.10,
      alignment: Alignment.centerLeft,
    ),
    OnboardingPageData(
      textKey: 'welcome',
      englishAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_4.mp3',
      urduAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_4_urdu.mp3',
      assetPath:
          'gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie',
      scale: 3.7,
      translateXPercent: 0.75,
      translateYPercent: -0.10,
      alignment: Alignment.centerLeft,
    ),
    OnboardingPageData(
      textKey: 'life',
      englishAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_5.mp3',
      urduAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_5_urdu.mp3',
      assetPath:
          'gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie',
      scale: 3.7,
      translateXPercent: 0.75,
      translateYPercent: -0.10,
      alignment: Alignment.centerLeft,
    ),
    OnboardingPageData(
      textKey: 'awareness',
      englishAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_6.mp3',
      urduAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_6_urdu.mp3',
      assetPath:
          'gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie',
      scale: 3.7,
      translateXPercent: 0.75,
      translateYPercent: -0.10,
      alignment: Alignment.centerLeft,
    ),
    OnboardingPageData(
      textKey: 'fulfill',
      englishAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_7.mp3',
      urduAudio: 'gs://bibi-app-d41a0.firebasestorage.app/audio/onboarding_7_urdu.mp3',
      assetPath:
          'gs://bibi-app-d41a0.firebasestorage.app/animations/Bibi_Onboarding_Leftt.lottie',
      scale: 3.7,
      translateXPercent: 0.75,
      translateYPercent: -0.10,
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
      Navigator.of(context).push(
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

        return Scaffold(
          body: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFFFF4F4),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  CachedLogoImage(height: 72.h, width: 72.w),
                  SizedBox(height: 8.h),

                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [

                        // ── ANIMATION ──────────────────────────────────────
                        OnboardingAnimation(
                          assetPath: currentPageData.assetPath ??
                              'assets/images/Bibi_Onboarding_Leftt.lottie',
                          scale: currentPageData.scale,
                          translateXPercent: currentPageData.translateXPercent,
                          translateYPercent: currentPageData.translateYPercent,
                          alignment: currentPageData.alignment,
                        ),

                        // ── FADE ───────────────────────────────────────────
                       Positioned(
  left: 0,
  right: 0,
  bottom: 95.h, // ✅ anchor to bottom of Stack
  child: IgnorePointer(
    child: Container(
      height: 0.20.sh, // ✅ slightly taller to compensate
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
                          top: 0.10.sh,
                          left: 0.50.sw + 30.w,
                          right: 20.w,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Directionality(
                              key: ValueKey<int>(_currentPage),
                              textDirection: isUrdu
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: DefaultTextStyle(
                                style: TextStyle(
                                                                      fontFamily: 'Inter',

                                  fontWeight: FontWeight.w800,
                                  fontSize: 18.sp,
                                  color: Colors.black,
                                ),
                                child: TextParsingUtils.parseBold(title),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: OnboardingNavigationButtons(
                      showBackButton: _currentPage > 0,
                      onBackPressed: _currentPage > 0
                          ? () => _goToPreviousPage(currentLanguage)
                          : null,
                      onNextPressed: () => _goToNextPage(currentLanguage),
                    ),
                  ),

                  SizedBox(height: 8.h),
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
  final String? assetPath;

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