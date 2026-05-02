import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../mixins/onboarding_audio_mixin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/onboarding_models.dart';
import 'onboarding_page_6.dart';
import 'onboarding_flow_dynamic.dart';
import '../services/remote_asset_service.dart';

class OnboardingPage5 extends StatefulWidget {
  const OnboardingPage5({super.key});

  @override
  State<OnboardingPage5> createState() => _OnboardingPage5State();
}

class _OnboardingPage5State extends State<OnboardingPage5>
    with OnboardingAudioMixin, WidgetsBindingObserver {
  int _currentPage = 4; // Start from page 5 (0-indexed as 4)
  bool _showText = false;
  List<OnboardingPageData> _pages = [];
  bool _isInitialized = false;

  static const String _targetPageId = 'page_8';

  int _findTargetPageIndex(List<OnboardingPageData> pages) {
    var idx = pages.indexWhere((page) => page.id == _targetPageId);
    if (idx != -1) return idx;

    idx = pages.indexWhere((page) => page.textKey == 'how_to_treat_title');
    if (idx != -1) return idx;

    idx = pages.indexWhere((page) => page.pageType == 'left_animation_bottom_text');
    if (idx != -1) return idx;

    return 4;
  }

  @override
  void initState() {
    super.initState();
    debugPrint("📦 PAGES HASH: ${_pages.hashCode}");
    debugPrint("📦 PAGE IDS: ${_pages.map((e) => e.id).toList()}");
    WidgetsBinding.instance.addObserver(this);
    
    // Stop any audio from previous page
    stopAudio();

    // Fetch onboarding flow from Firebase on next frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        debugPrint("📱 Page5: Fetching onboarding flow from Firebase...");
        context.read<OnboardingBloc>().add(const FetchOnboardingFlowEvent());
      } catch (e) {
        debugPrint("❌ Page5: Error fetching onboarding flow: $e");
      }
    });

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

  @override
  String get englishAudioPath =>
      _isInitialized && _currentPage < _pages.length ? _pages[_currentPage].englishAudio : '';

  @override
  String get urduAudioPath =>
      _isInitialized && _currentPage < _pages.length ? _pages[_currentPage].urduAudio : '';

  Future<void> _goToNextPage(String currentLanguage) async {
    if (_currentPage < _pages.length - 1) {
      stopAudio();
      setState(() {
        _showText = false;
        _currentPage++;
      });
      if (_isInitialized) {
        initAudio(currentLanguage);
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showText = true);
      });
    } else {
      stopAudio();
      await disposeAudio();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const OnboardingPage6()),
      );
    }
  }

  Future<void> _goToPreviousPage(String currentLanguage) async {
    if (_currentPage > 4) {
      // Still in page 5+ pages, just go back within page 5
      stopAudio();
      setState(() {
        _showText = false;
        _currentPage--;
      });
      debugPrint("📄 Going back within Page5: now at index $_currentPage");
      if (_isInitialized) {
        initAudio(currentLanguage);
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showText = true);
      });
    } else if (_currentPage == 4) {
      // At page 5 (index 4), go back to OnboardingFlowDynamic (pages 1-4)
      stopAudio();
      await disposeAudio();
      debugPrint("🔙 Going back from Page5 to OnboardingFlowDynamic");
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OnboardingFlowDynamic()),
        );
      }
    }
  }

  Color _parseColor(String? value, Color fallback) {
    if (value == null || value.isEmpty) return fallback;
    try {
      return Color(int.parse(value.replaceFirst('#', '0xff')));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoaded) {
          debugPrint("🎯 OnboardingPage5: Received ${state.pages.length} pages from Firebase");
          for (int i = 0; i < state.pages.length; i++) {
            final page = state.pages[i];
            debugPrint("  [$i] order=${page.order}, textKey=${page.textKey}, anim=${page.animationPath}");
          }
          
          setState(() {
            _pages = state.pages;
            _currentPage = _findTargetPageIndex(_pages);
            debugPrint('📌 Page5 target page index=$_currentPage id=${_pages[_currentPage].id} textKey=${_pages[_currentPage].textKey}');
            _isInitialized = true;
          });

          // Initialize audio with current language at page 5
          final languageState = context.read<LanguageBloc>().state;
          String currentLanguage = 'English';
          if (languageState is LanguageSelected) {
            currentLanguage = languageState.language;
          }
          initAudio(currentLanguage);

          () async {
            try {
              final page = _pages[_currentPage];
              debugPrint('🔎 Page5 debug page id=${page.id}, textKey=${page.textKey}, audio(en)=${page.englishAudio}, audio(ur)=${page.urduAudio}, logo=${page.logoUrl}, anim=${page.animationPath}');
              if (page.animationPath.isNotEmpty) {
                final resolvedAnimation = await RemoteAssetService.resolveDownloadUrl(page.animationPath);
                debugPrint('🔀 Page5 animation resolved: ${page.animationPath} -> $resolvedAnimation');
              }
              if (page.englishAudio.isNotEmpty) {
                final resolvedEnglish = await RemoteAssetService.resolveDownloadUrl(page.englishAudio);
                debugPrint('🔀 Page5 english audio resolved: ${page.englishAudio} -> $resolvedEnglish');
              }
              if (page.urduAudio.isNotEmpty) {
                final resolvedUrdu = await RemoteAssetService.resolveDownloadUrl(page.urduAudio);
                debugPrint('🔀 Page5 urdu audio resolved: ${page.urduAudio} -> $resolvedUrdu');
              }
            } catch (e, st) {
              debugPrint('⚠️ Page5 asset debug failed: $e');
              debugPrint('   stack: $st');
            }
          }();
        }
      },
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          String currentLanguage = 'English';
          if (languageState is LanguageSelected) {
            currentLanguage = languageState.language;
            if (_isInitialized) {
              onLanguageChanged(currentLanguage);
            }
          }

          return BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, onboardingState) {
              if (onboardingState is OnboardingLoading) {
                return Scaffold(
                  body: SafeArea(
                    child: Container(
                      color: const Color(0xFFFFF4F4),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFFE91E8C),
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (onboardingState is OnboardingError) {
                return Scaffold(
                  body: SafeArea(
                    child: Container(
                      color: const Color(0xFFFFF4F4),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Color(0xFFE91E8C),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Error loading onboarding',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(height: 8.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              child: Text(
                                onboardingState.message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<OnboardingBloc>()
                                    .add(const FetchOnboardingFlowEvent());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (!_isInitialized || _pages.isEmpty || _currentPage >= _pages.length) {
                return Scaffold(
                  body: SafeArea(
                    child: Container(
                      color: const Color(0xFFFFF4F4),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: const Color(0xFFE91E8C),
                        ),
                      ),
                    ),
                  ),
                );
              }

              final currentPageData = _pages[_currentPage];
              
              // Debug logs with full animation config
              debugPrint("═" * 60);
              debugPrint("📄 PAGE5: ${currentPageData.textKey} (index $_currentPage)");
              debugPrint("🎬 Animation: ${currentPageData.animationPath}");
              debugPrint("📏 Scale (from Firebase): ${currentPageData.animation.scale}");
              debugPrint("📍 TranslateX: ${currentPageData.animation.translateXPercent}");
              debugPrint("📍 TranslateY: ${currentPageData.animation.translateYPercent}");
              debugPrint("🧭 Alignment: ${currentPageData.animation.alignment}");
              debugPrint("🔤 TextStyle: ${currentPageData.textStyle.toJson()}");
              debugPrint("🗣️ Language: '$currentLanguage'");
              debugPrint("═" * 60);
              
              final title = currentPageData.translations[currentLanguage] ??
                  currentPageData.translations['English'] ??
                  currentPageData.textKey;

              final isUrdu = currentLanguage == 'اردو';
              
              debugPrint("🔤 TEXT TO DISPLAY: '$title'");
              debugPrint("📍 TEXT POSITION: Bottom Center");

              // Parse text color from Firebase
              Color textColor = const Color(0xFF8B5E3C); // Default
              if (currentPageData.textStyle.color != null) {
                try {
                  textColor = Color(int.parse(
                    currentPageData.textStyle.color!.replaceFirst('#', '0xff'),
                  ));
                } catch (e) {
                  debugPrint('❌ Error parsing text color: $e');
                }
              }

              // Parse font weight
              FontWeight fontWeight = FontWeight.w800; // Default
              if (currentPageData.textStyle.fontWeight != null) {
                switch (currentPageData.textStyle.fontWeight) {
                  case 'w400':
                    fontWeight = FontWeight.w400;
                    break;
                  case 'w500':
                    fontWeight = FontWeight.w500;
                    break;
                  case 'w600':
                    fontWeight = FontWeight.w600;
                    break;
                  case 'w700':
                    fontWeight = FontWeight.w700;
                    break;
                  case 'w800':
                    fontWeight = FontWeight.w800;
                    break;
                  case 'w900':
                    fontWeight = FontWeight.w900;
                    break;
                }
              }

              // Get text size from Firebase
              double fontSize = currentPageData.textStyle.fontSize?.toDouble() ?? 32.0;
              debugPrint("🔢 TEXT SIZE: ${fontSize.sp}sp");

              // Get text alignment
              TextAlign textAlign = TextAlign.center;
              if (currentPageData.textStyle.textAlign != null) {
                switch (currentPageData.textStyle.textAlign) {
                  case 'left':
                    textAlign = TextAlign.left;
                    break;
                  case 'right':
                    textAlign = TextAlign.right;
                    break;
                  case 'center':
                    textAlign = TextAlign.center;
                    break;
                }
              }

              return Scaffold(
                body: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFFFFF4F4),
                    child: Column(
                      children: [
                        // Logo at top
                        SizedBox(height: 12.h),
                        CachedLogoImage(height: 72.h, width: 72.w),
                        SizedBox(height: 8.h),

                        // Animation takes all available space
                        Expanded(
                          child: Center(
                            child: OnboardingAnimation(
                              key: ValueKey('page5_${_currentPage}_${currentPageData.animationPath}'),
                              assetPath: currentPageData.animationPath,
                              scale: currentPageData.animation.scale,
                              translateXPercent:
                                  currentPageData.animation.translateXPercent,
                              translateYPercent:
                                  currentPageData.animation.translateYPercent,
                              alignment:
                                  currentPageData.animation.getAlignment(),
                              repeat: currentPageData.repeat,
                            ),
                          ),
                        ),

                        // Bottom section: Text + Buttons (fixed at bottom)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 16.h),
                            ],
                          ),
                        ),

                        // Bottom Title similar to Page7/8 layout
                        SizedBox(height: 8.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              title.isNotEmpty ? title : 'Onboarding',
                              style: TextStyle(
                                fontFamily: currentPageData.textStyle.titleFontFamily ?? 'Inter',
                                fontSize: (currentPageData.textStyle.bottomTitleFontSize ?? currentPageData.textStyle.titleFontSize ?? 24).sp,
                                fontWeight: FontWeight.w800,
                                color: _parseColor(currentPageData.textStyle.titleColor ?? currentPageData.textStyle.color, const Color(0xFF8B5E3C)),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: OnboardingNavigationButtons(
                            showBackButton: _currentPage > 4,
                            onBackPressed: _currentPage > 4
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
        },
      ),
    );
  }
}