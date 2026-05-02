import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../mixins/onboarding_audio_mixin.dart';
import '../models/onboarding_models.dart';
import 'onboarding_page_5.dart';
import 'onboarding_page_7.dart';
import '../services/remote_asset_service.dart';
import '../services/app_route_observer.dart';

class OnboardingPage6 extends StatefulWidget {
  const OnboardingPage6({super.key});

  @override
  State<OnboardingPage6> createState() => _OnboardingPage6State();
}

class _OnboardingPage6State extends State<OnboardingPage6>
  with OnboardingAudioMixin, WidgetsBindingObserver, RouteAware {
  int _currentPage = 5; // page 6 is index 5 (0-based)
  bool _showText = false;
  List<OnboardingPageData> _pages = [];
  bool _isInitialized = false;
  bool _isRouteSubscribed = false;

  static const String _targetPageId = 'page_9';

  void _hydrateFromLoadedState(OnboardingLoaded state) {
    _pages = state.pages;
    final idx = _findTargetPageIndex(_pages);

    if (idx != -1) {
      _currentPage = idx;
      final matched = _pages[_currentPage];
      debugPrint('📌 Page6: hydrated target page at index $_currentPage (id=${matched.id}, textKey=${matched.textKey})');
    } else {
      _currentPage = 5;
      debugPrint('⚠️ Page6: hydrate target not found, fallback index=$_currentPage');
    }

    _isInitialized = true;

    final languageState = context.read<LanguageBloc>().state;
    String currentLanguage = 'English';
    if (languageState is LanguageSelected) {
      currentLanguage = languageState.language;
    }
    initAudio(currentLanguage);
  }

  int _findTargetPageIndex(List<OnboardingPageData> pages) {
    int idx = pages.indexWhere((page) => page.id == _targetPageId);
    if (idx != -1) return idx;

    idx = pages.indexWhere((page) => page.textKey == 'family_tree');
    if (idx != -1) return idx;

    idx = pages.indexWhere((page) =>
        page.translations['English'] == 'Are you at risk?');
    if (idx != -1) return idx;

    idx = pages.indexWhere((page) =>
        (page.animationPath).contains('family_tree'));
    if (idx != -1) return idx;

    final candidates = pages
        .asMap()
        .entries
        .where((entry) => entry.value.pageType == 'left_animation_bottom_text')
        .toList();
    if (candidates.length == 1) {
      return candidates.first.key;
    }

    return -1;
  }

  @override
  void initState() {
    super.initState();
    debugPrint("📦 PAGES HASH: ${_pages.hashCode}");
debugPrint("📦 PAGE IDS: ${_pages.map((e) => e.id).toList()}");
    WidgetsBinding.instance.addObserver(this);

    // Stop any previous audio
    stopAudio();

    // Fetch onboarding flow from Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final onboardingState = context.read<OnboardingBloc>().state;
        if (onboardingState is OnboardingLoaded && onboardingState.pages.isNotEmpty) {
          debugPrint('⚡ Page6: using existing OnboardingLoaded state (no refetch)');
          setState(() {
            _hydrateFromLoadedState(onboardingState);
          });
        } else {
          context.read<OnboardingBloc>().add(const FetchOnboardingFlowEvent());
        }
      } catch (e) {
        debugPrint('❌ Page6: error fetching onboarding flow: $e');
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_isRouteSubscribed && route is PageRoute) {
      appRouteObserver.subscribe(this, route);
      _isRouteSubscribed = true;
    }
  }

  @override
  void didPopNext() {
    final languageState = context.read<LanguageBloc>().state;
    var currentLanguage = 'English';
    if (languageState is LanguageSelected) {
      currentLanguage = languageState.language;
    }

    initAudio(currentLanguage);
  }

  @override
  void didPushNext() {
    stopAudio();
  }

  @override
  void dispose() {
    if (_isRouteSubscribed) {
      appRouteObserver.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    disposeAudio();
    super.dispose();
  }

  @override
  String get englishAudioPath =>
      _isInitialized && _currentPage < _pages.length
          ? _pages[_currentPage].englishAudio
          : '';

  @override
  String get urduAudioPath =>
      _isInitialized && _currentPage < _pages.length
          ? _pages[_currentPage].urduAudio
          : '';

  Future<void> _goToNext(String currentLanguage) async {
    final currentId = (_currentPage >= 0 && _currentPage < _pages.length)
        ? _pages[_currentPage].id
        : 'out_of_bounds';
    debugPrint('➡️ Page6 _goToNext tapped | currentPage=$_currentPage | currentId=$currentId | totalPages=${_pages.length} | isInitialized=$_isInitialized');

    // Page6 is the family_tree screen (Firestore id page_9). Next should open page 7.
    if (currentId == _targetPageId) {
      stopAudio();
      debugPrint('➡️ Page6 currentId is $_targetPageId, navigating directly to OnboardingPage7');
      await disposeAudio();
      if (!mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const OnboardingPage7(),
        ),
      );
      return;
    }

    if (_currentPage < _pages.length - 1) {
      stopAudio();
      setState(() {
        _showText = false;
        _currentPage++;
      });
      debugPrint('➡️ Page6 moved to next local page index=$_currentPage');
      if (_isInitialized) initAudio(currentLanguage);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showText = true);
      });
    } else {
      stopAudio();
      debugPrint('➡️ Page6 navigating to OnboardingPage7 with pushReplacement');
      await disposeAudio();
      if (!mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const OnboardingPage7(),
        ),
      );
    }
  }

  String _foodLabel(FoodItemConfig item, String currentLanguage) {
    return item.translations[currentLanguage] ??
        item.translations['English'] ??
        item.labelKey;
  }

  Color _parseColor(String? value, Color fallback) {
    if (value == null || value.isEmpty) return fallback;
    try {
      return Color(int.parse(value.replaceFirst('#', '0xff')));
    } catch (_) {
      return fallback;
    }
  }

  Widget _buildFoodItem(FoodItemConfig item, String currentLanguage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: item.circleDiameter.w,
          height: item.circleDiameter.h,
          decoration: BoxDecoration(
            color: _parseColor(item.circleColor, const Color(0xFFF68AA8)),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Image.asset(
              item.asset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: (item.circleDiameter + 12).w,
          child: Text(
            _foodLabel(item, currentLanguage),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Edu',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5A3E2B),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage9(OnboardingPageData page, String currentLanguage) {
    final title = page.translations[currentLanguage] ??
        page.translations['English'] ??
        page.textKey;

    final titleStyle = page.textStyle;
    final titleColor = _parseColor(
      titleStyle.titleColor ?? titleStyle.color ?? '#8B5E3C',
      const Color(0xFF8B5E3C),
    );

    final topMargin = 12.0.h;
    final titleFontFamily = titleStyle.titleFontFamily ?? 'Inter';
    final titleFontSize = (titleStyle.titleFontSize ?? titleStyle.fontSize ?? 24).sp;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: _parseColor(page.backgroundColor, const Color(0xFFFFF4F4)),
          child: Column(
            children: [
              SizedBox(height: topMargin),

              CachedLogoImage(
                height: 72.h,
                width: 72.w,
                imageUrl: page.logoUrl,
              ),

              SizedBox(height: 8.h),

              Expanded(
                child: AnimatedOpacity(
                  opacity: _showText ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Center(
                              child: _buildFoodItem(
                                page.foodItems.isNotEmpty
                                    ? page.foodItems[0]
                                    : const FoodItemConfig(
                                        id: 'item_0',
                                        asset: '',
                                        labelKey: '',
                                        position: 'center_top',
                                        circleColor: '#F68AA8',
                                        circleDiameter: 112,
                                        translations: {},
                                      ),
                                currentLanguage,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (page.foodItems.length > 1)
                                  _buildFoodItem(page.foodItems[1], currentLanguage),
                                if (page.foodItems.length > 2)
                                  _buildFoodItem(page.foodItems[2], currentLanguage),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (page.foodItems.length > 3)
                                  _buildFoodItem(page.foodItems[3], currentLanguage),
                                if (page.foodItems.length > 4)
                                  _buildFoodItem(page.foodItems[4], currentLanguage),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                              opacity: _showText ? 1 : 0,
                              duration: const Duration(milliseconds: 500),
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 26.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF8B5E3C),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8.h),
              SizedBox(height: 10.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: OnboardingNavigationButtons(
                  showBackButton: true,
                  onBackPressed: () {
                    stopAudio();
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OnboardingPage5(),
                        ),
                      );
                    }
                  },
                  onNextPressed: () => _goToNext(currentLanguage),
                ),
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  void _goToPrevious(String currentLanguage) {
    if (_currentPage > 5) {
      stopAudio();
      setState(() {
        _showText = false;
        _currentPage--;
      });
      if (_isInitialized) initAudio(currentLanguage);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showText = true);
      });
    } else if (_currentPage == 5) {
      stopAudio();
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const OnboardingPage5()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoaded) {
          setState(() {
            _hydrateFromLoadedState(state);

            debugPrint('📦 Loaded page ids/order/textKeys:');
            for (var i = 0; i < _pages.length; i++) {
              final p = _pages[i];
              debugPrint('  [$i] id=${p.id}, order=${p.order}, textKey=${p.textKey}, pageType=${p.pageType}');
            }
          });

          // Fire-and-forget: resolve and log remote asset download URLs for this page
          () async {
            try {
              final page = _pages[_currentPage];
              final anim = page.animationPath ?? '';
              final eng = page.englishAudio ?? '';
              final urd = page.urduAudio ?? '';

              if (anim.isNotEmpty) {
                final r = await RemoteAssetService.resolveDownloadUrl(anim);
                debugPrint('🔀 Page6 resolved animation: $anim -> $r');
              }
              if (eng.isNotEmpty) {
                final r = await RemoteAssetService.resolveDownloadUrl(eng);
                debugPrint('🔀 Page6 resolved englishAudio: $eng -> $r');
              }
              if (urd.isNotEmpty) {
                final r = await RemoteAssetService.resolveDownloadUrl(urd);
                debugPrint('🔀 Page6 resolved urduAudio: $urd -> $r');
              }
            } catch (e, st) {
              debugPrint('⚠️ Page6 asset resolution error: $e');
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
              if (onboardingState is OnboardingLoading && !_isInitialized) {
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

            debugPrint("📄 RENDER PAGE ID: ${currentPageData.id}");
debugPrint("🎬 ANIMATION PATH: '${currentPageData.animationPath}'");
debugPrint("📦 PAGE TYPE: ${currentPageData.pageType}");
debugPrint("📍 CURRENT INDEX: $_currentPage");
debugPrint("📊 TOTAL PAGES: ${_pages.length}");


              final title = currentPageData.translations[currentLanguage] ??
                  currentPageData.translations['English'] ??
                  currentPageData.textKey;

              final isUrdu = currentLanguage == 'اردو';

              // Parse text color
              Color textColor = const Color(0xFF8B5E3C);
              if (currentPageData.textStyle.color != null) {
                try {
                  textColor = Color(int.parse(
                    currentPageData.textStyle.color!.replaceFirst('#', '0xff'),
                  ));
                } catch (e) {
                  debugPrint('❌ Error parsing text color: $e');
                }
              }

              double fontSize = currentPageData.textStyle.fontSize?.toDouble() ?? 30.0;

              return Scaffold(
                body: SafeArea(
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFFFFF4F4),
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),

                        // Logo (uses cached network image if available)
                        CachedLogoImage(height: 72.h, width: 72.w, imageUrl: currentPageData.logoUrl),
                        SizedBox(height: 8.h),
                        

                    // Animation area
Expanded(
  child: Center(
    child: Builder(
      builder: (_) {
        if (currentPageData.animationPath.isEmpty) {
          debugPrint("⚠️ NO ANIMATION FOR PAGE: ${currentPageData.id}");
          return const SizedBox.shrink();
        }

        return OnboardingAnimation(
          key: ValueKey('page_${currentPageData.id}'),
          assetPath: currentPageData.animationPath,
          scale: currentPageData.animation.scale,
          translateXPercent: currentPageData.animation.translateXPercent,
          translateYPercent: currentPageData.animation.translateYPercent,
          alignment: currentPageData.animation.getAlignment(),
          repeat: currentPageData.repeat,
        );
      },
    ),
  ),
),
                        // Bottom title and navigation (match Page8/9 layout)
                        SizedBox(height: 8.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Align(
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                              opacity: _showText ? 1 : 0,
                              duration: const Duration(milliseconds: 400),
                              child: Directionality(
                                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: fontSize.sp,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: OnboardingNavigationButtons(
                            showBackButton: true,
                            onBackPressed: () {
                              stopAudio();
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const OnboardingPage5(),
                                  ),
                                );
                              }
                            },
                            onNextPressed: () => _goToNext(currentLanguage),
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