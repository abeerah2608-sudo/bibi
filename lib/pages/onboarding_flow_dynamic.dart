import 'dart:math' as math;
import 'package:bibi/pages/onboarding_page_5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../widgets/cached_logo_image.dart';
import '../utils/text_parsing_utils.dart';
import '../services/remote_asset_service.dart';
import '../mixins/onboarding_audio_mixin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/onboarding_models.dart';
import 'onboarding_page_7.dart';
import 'onboarding_page_9.dart';
import 'dashboard.dart';

class OnboardingFlowDynamic extends StatefulWidget {
  const OnboardingFlowDynamic({super.key});

  @override
  State<OnboardingFlowDynamic> createState() => _OnboardingFlowDynamicState();
}

class _OnboardingFlowDynamicState extends State<OnboardingFlowDynamic>
    with OnboardingAudioMixin, WidgetsBindingObserver {
  int _currentPage = 0;
  bool _showText = false;
  List<OnboardingPageData> _pages = [];
  bool _isInitialized = false;

  void _hydrateFromLoadedState(OnboardingLoaded state) {
    setState(() {
      _pages = state.pages;
      _isInitialized = true;
    });

    _preloadAnimationsAroundCurrentPage();

    final languageState = context.read<LanguageBloc>().state;
    String currentLanguage = 'English';
    if (languageState is LanguageSelected) {
      currentLanguage = languageState.language;
    }
    initAudio(currentLanguage);
  }

  Future<void> _preloadAnimationsAroundCurrentPage() async {
    if (_pages.isEmpty || _currentPage < 0 || _currentPage >= _pages.length) {
      return;
    }

    final urls = <String>{};
    final currentAnimation = _pages[_currentPage].animationPath;
    if (currentAnimation.isNotEmpty) {
      urls.add(currentAnimation);
    }

    if (_currentPage + 1 < _pages.length) {
      final nextAnimation = _pages[_currentPage + 1].animationPath;
      if (nextAnimation.isNotEmpty) {
        urls.add(nextAnimation);
      }
    }

    if (urls.isEmpty) return;

    try {
      final resolved = await Future.wait(
        urls.map(RemoteAssetService.resolveDownloadUrl),
      );
      await RemoteAssetService().preloadAssets(resolved);
      debugPrint('⚡ FlowDynamic animation warm-up done for page=$_currentPage');
    } catch (e) {
      debugPrint('⚠️ FlowDynamic animation warm-up failed: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    debugPrint("🎯 OnboardingFlowDynamic initialized, starting at page index $_currentPage");

    // Fetch onboarding flow from Firebase on next frame to ensure context is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final onboardingState = context.read<OnboardingBloc>().state;
        if (onboardingState is OnboardingLoaded && onboardingState.pages.isNotEmpty) {
          debugPrint('⚡ OnboardingFlowDynamic: using existing OnboardingLoaded state (no refetch)');
          _hydrateFromLoadedState(onboardingState);
        } else {
          debugPrint("📱 Fetching onboarding flow from Firebase...");
          context.read<OnboardingBloc>().add(const FetchOnboardingFlowEvent());
        }
      } catch (e) {
        debugPrint("❌ Error fetching onboarding flow: $e");
      }
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _showText = true);
    });
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
      _isInitialized ? _pages[_currentPage].englishAudio : '';

  @override
  String get urduAudioPath =>
      _isInitialized ? _pages[_currentPage].urduAudio : '';

  Future<void> _goToNextPage(String currentLanguage) async {
    final currentPageData =
        (_currentPage >= 0 && _currentPage < _pages.length) ? _pages[_currentPage] : null;
    debugPrint(
      '➡️ FlowDynamic next tapped | index=$_currentPage | id=${currentPageData?.id} | type=${currentPageData?.pageType}',
    );

    // Route to dedicated video-card screen instead of trying to render it in animation layout.
    if (currentPageData?.id == 'page_9' || currentPageData?.textKey == 'family_tree') {
      stopAudio();
      debugPrint('➡️ FlowDynamic routing family_tree -> OnboardingPage7');
      await disposeAudio();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingPage7()),
      );
      return;
    }

    if (currentPageData?.pageType == 'treatment_labels') {
      stopAudio();
      debugPrint('➡️ FlowDynamic routing treatment_labels -> DashboardScreen');
      await disposeAudio();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
      return;
    }

    if (currentPageData?.id == 'page_12' || currentPageData?.pageType == 'food_items_grid') {
      stopAudio();
      debugPrint('➡️ FlowDynamic routing food_items_grid -> OnboardingPage9');
      await disposeAudio();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const OnboardingPage9()),
      );
      return;
    }

    if (_currentPage < _pages.length - 1) {
      setState(() {
        _showText = false;
        _currentPage++;
      });
      stopAudio();
      if (_isInitialized) {
        initAudio(currentLanguage);
        _preloadAnimationsAroundCurrentPage();
      }
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showText = true);
      });
    } else {
      stopAudio();
      debugPrint("🚀 Navigating to OnboardingPage5");
      await disposeAudio();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const OnboardingPage5()),
      );
    }
  }

  Future<void> _goToPreviousPage(String currentLanguage) async {
    final currentPageData =
        (_currentPage >= 0 && _currentPage < _pages.length) ? _pages[_currentPage] : null;

    if (currentPageData?.pageType == 'treatment_labels') {
      stopAudio();
      debugPrint('⬅️ FlowDynamic routing treatment_labels -> OnboardingPage7');
      await disposeAudio();
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OnboardingPage7()),
        );
      }
      return;
    }

    if (_currentPage > 0) {
      setState(() {
        _showText = false;
        _currentPage--;
      });
      stopAudio();
      if (_isInitialized) {
        initAudio(currentLanguage);
        _preloadAnimationsAroundCurrentPage();
      }
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showText = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoaded) {
          _hydrateFromLoadedState(state);
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

              if (!_isInitialized || _pages.isEmpty) {
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
              
              // Debug logs
              debugPrint("📄 PAGE: ${currentPageData.textKey}");
              debugPrint("🆔 PAGE ID: ${currentPageData.id}");
              debugPrint("🧩 PAGE TYPE: ${currentPageData.pageType}");
              debugPrint("🗣️ LANG: '$currentLanguage'");
              debugPrint("🔑 TRANSLATIONS: ${currentPageData.translations.keys.toList()}");

              // Safety: if a video card page is reached in this dynamic flow, move to dedicated page.
              if (currentPageData.pageType == 'video_card') {
                debugPrint('⚠️ FlowDynamic encountered video_card in generic renderer. Redirecting to OnboardingPage7...');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  () async {
                    stopAudio();
                    await disposeAudio();
                    if (!mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OnboardingPage7()),
                    );
                  }();
                });

                return Scaffold(
                  body: SafeArea(
                    child: Container(
                      color: const Color(0xFFFFF4F4),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFFE91E8C),
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              'Opening video card...',
                              style: TextStyle(fontSize: 13.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              if (currentPageData.pageType == 'treatment_labels') {
                debugPrint('🧪 FlowDynamic rendering treatment_labels from Firestore for ${currentPageData.id}');
                return _buildTreatmentLabelsPage(currentPageData, currentLanguage);
              }
              
              final title = currentPageData.translations[currentLanguage] ??
                  currentPageData.translations['English'] ??
                  currentPageData.textKey;

              final isUrdu = currentLanguage == 'اردو';

              return Scaffold(
                body: SafeArea(
                  child: Stack(
                    children: [
                      if (currentPageData.backgroundImageUrl != null &&
                          currentPageData.backgroundImageUrl!.isNotEmpty)
                        Positioned.fill(
                          child: Image.network(
                            RemoteAssetService.convertGsUrlToHttps(
                              currentPageData.backgroundImageUrl!,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const ColoredBox(
                                color: Color(0xFFFFF4F4),
                              );
                            },
                          ),
                        ),
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: const Color(0xFFFFF4F4).withOpacity(0.90),
                        child: Column(
                          children: [
                            SizedBox(height: 12.h),
                            CachedLogoImage(
                              height: 72.h,
                              width: 72.w,
                              imageUrl: currentPageData.logoUrl,
                            ),
                            SizedBox(height: 8.h),

                            Expanded(
                              child: Stack(
                                clipBehavior: Clip.hardEdge,
                                children: [
                              // ── ANIMATION ──────────────────────────────────────
                              OnboardingAnimation(
                                key: ValueKey('flow_${_currentPage}_${currentPageData.animationPath}'),
                                assetPath: currentPageData.animationPath,
                                scale: currentPageData.animation.scale,
                                translateXPercent:
                                    currentPageData.animation.translateXPercent,
                                translateYPercent:
                                    currentPageData.animation.translateYPercent,
                                alignment:
                                    currentPageData.animation.getAlignment(),
                              ),

                              // ── FADE ───────────────────────────────────────────
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 95.h,
                                child: IgnorePointer(
                                  child: Container(
                                    height: 0.20.sh,
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
                                        stops: [
                                          0.0,
                                          0.2,
                                          0.42,
                                          0.64,
                                          0.84,
                                          1.0,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // ── TEXT: choose layout based on page type/id ─────
                              if (currentPageData.pageType == 'left_animation_bottom_text' ||
                                  currentPageData.id == 'page_8' ||
                                  currentPageData.id == 'page_9')
                                Positioned(
                                  bottom: 24.h,
                                  left: 24.w,
                                  right: 24.w,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 400),
                                    child: Directionality(
                                      key: ValueKey<int>(_currentPage),
                                      textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                                      child: DefaultTextStyle(
                                        style: TextStyle(
                                          fontFamily: currentPageData.textStyle.titleFontFamily ?? 'Inter',
                                          fontWeight: FontWeight.w800,
                                          fontSize: (currentPageData.textStyle.bottomTitleFontSize ?? currentPageData.textStyle.titleFontSize ?? currentPageData.textStyle.fontSize ?? 18).sp,
                                          color: _parseColor(currentPageData.textStyle.titleColor ?? currentPageData.textStyle.color ?? '#8B5E3C', Colors.black),
                                        ),
                                        child: TextParsingUtils.parseBold(title),
                                      ),
                                    ),
                                  ),
                                )
                              else
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
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  double _asDouble(dynamic value, [double fallback = 0.0]) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  String _localizedNestedText(
    Map<String, dynamic> root,
    String key,
    String language, {
    String fallback = '',
  }) {
    final dynamic value = root[key];
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final chosen = map[language] ?? map['English'] ?? map['Roman Urdu'] ?? map['اردو'];
      return chosen?.toString().trim() ?? fallback;
    }
    return value?.toString().trim() ?? fallback;
  }

  Widget _buildTreatmentLabelsPage(OnboardingPageData page, String currentLanguage) {
    final data = page.rawData;
    debugPrint('🧪 rawData keys: ${data.keys.toList()}');
    final translations = _asMap(data['translations']);
    final labels = _asMap(translations['labels']);
    final title = _localizedNestedText(translations, 'title', currentLanguage, fallback: page.textKey);
    final isUrdu = currentLanguage == 'اردو';

    final backgroundImage =
        page.backgroundImageUrl ?? _asMap(data['backgroundImage'])['asset']?.toString() ?? '';
    final logoUrl = page.logoUrl ?? _asMap(data['logo'])['asset']?.toString() ?? '';

    final arrowConfig = _asMap(data['arrowConfig']);
    final arrowList = (arrowConfig['arrows'] as List<dynamic>?) ?? const [];

    final navigationButtons = _asMap(data['navigationButtons']);
    final nextDestination = navigationButtons['nextDestination']?.toString() ?? '';
    final nextAction = navigationButtons['nextAction']?.toString() ?? '';

    final textStyle = page.textStyle;
    final titleColor = textStyle.color ?? '#8B5E3C';
    final titleFontSize = textStyle.titleFontSize ?? 26;
    final labelFontFamily = textStyle.labelFontFamily ?? 'Edu';
    final labelFontSize = textStyle.labelFontSize ?? 13;
    final labelColor = textStyle.labelColor ?? '#8B5E3C';

    debugPrint('🧪 treatment_labels title=$title');
    debugPrint('🧪 treatment_labels backgroundImage=$backgroundImage');
    debugPrint('🧪 treatment_labels logoUrl=$logoUrl');
    debugPrint('🧪 treatment_labels labels keys=${labels.keys.toList()}');
    debugPrint('🧪 treatment_labels arrows=${arrowList.length}');

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: _parseHexColor(page.backgroundColor, const Color(0xFFFFF4F4)),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              CachedLogoImage(
                height: 72.h,
                width: 72.w,
                imageUrl: logoUrl,
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.biggest;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          if (backgroundImage.isNotEmpty)
                            Positioned.fill(
                              child: Image.network(
                                RemoteAssetService.convertGsUrlToHttps(backgroundImage),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('❌ treatment_labels background load failed: $error');
                                  return const SizedBox.shrink();
                                },
                              ),
                            ),
                          if (arrowList.isNotEmpty)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _TreatmentArrowPainter(
                                  arrows: arrowList,
                                  color: _parseHexColor(arrowConfig['color']?.toString(), const Color(0xFF8B5E3C)),
                                  opacity: _asDouble(arrowConfig['opacity'], 0.6),
                                  strokeWidth: _asDouble(arrowConfig['strokeWidth'], 1.0),
                                ),
                              ),
                            ),
                          _buildTreatmentLabel(
                            labels: labels,
                            labelPositions: _asMap(data['labelPositions']),
                            labelKey: 'radiation',
                            size: size,
                            language: currentLanguage,
                            isUrdu: isUrdu,
                            fontFamily: labelFontFamily,
                            fontSize: labelFontSize,
                            color: labelColor,
                            defaultAnchor: Alignment.topLeft,
                          ),
                          _buildTreatmentLabel(
                            labels: labels,
                            labelPositions: _asMap(data['labelPositions']),
                            labelKey: 'chemotherapy',
                            size: size,
                            language: currentLanguage,
                            isUrdu: isUrdu,
                            fontFamily: labelFontFamily,
                            fontSize: labelFontSize,
                            color: labelColor,
                            defaultAnchor: Alignment.topRight,
                          ),
                          _buildTreatmentLabel(
                            labels: labels,
                            labelPositions: _asMap(data['labelPositions']),
                            labelKey: 'hormonal_tablets',
                            size: size,
                            language: currentLanguage,
                            isUrdu: isUrdu,
                            fontFamily: labelFontFamily,
                            fontSize: labelFontSize,
                            color: labelColor,
                            defaultAnchor: Alignment.bottomLeft,
                          ),
                          _buildTreatmentLabel(
                            labels: labels,
                            labelPositions: _asMap(data['labelPositions']),
                            labelKey: 'surgery',
                            size: size,
                            language: currentLanguage,
                            isUrdu: isUrdu,
                            fontFamily: labelFontFamily,
                            fontSize: labelFontSize,
                            color: labelColor,
                            defaultAnchor: Alignment.bottomRight,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: textStyle.titleFontFamily ?? 'Inter',
                    fontSize: titleFontSize.sp,
                    fontWeight: FontWeight.w800,
                    color: _parseHexColor(titleColor, const Color(0xFF8B5E3C)),
                    height: 1.2,
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
                    if (navigationButtons['backDestination']?.toString() == 'page_10') {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OnboardingPage7()),
                        );
                      }
                      return;
                    }
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OnboardingPage7()),
                      );
                    }
                  },
                  onNextPressed: () {
                    stopAudio();
                    if (nextAction == 'complete_onboarding' || nextDestination == 'dashboard') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DashboardScreen()),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const DashboardScreen()),
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTreatmentLabel({
    required Map<String, dynamic> labels,
    required Map<String, dynamic> labelPositions,
    required String labelKey,
    required Size size,
    required String language,
    required bool isUrdu,
    required String fontFamily,
    required double fontSize,
    required String color,
    required Alignment defaultAnchor,
  }) {
final languageMap = _asMap(labels[language]) 
    .isNotEmpty 
        ? _asMap(labels[language]) 
        : _asMap(labels['English']);

final text = languageMap[labelKey] ?? labelKey;
    final positionData = _asMap(labelPositions[labelKey]);
    final anchor = positionData['anchor']?.toString() ?? _anchorName(defaultAnchor);
    final topFraction = _asDouble(positionData['topFraction'], 0.0);
    final bottomPx = _asDouble(positionData['bottomPx'], 0.0);
    final leftPx = _asDouble(positionData['leftPx'], 0.0);
    final rightPx = _asDouble(positionData['rightPx'], 0.0);

    return Positioned(
      top: anchor.startsWith('top') ? size.height * topFraction : null,
      bottom: anchor.startsWith('bottom') ? bottomPx : null,
      left: anchor.endsWith('left') ? leftPx : null,
      right: anchor.endsWith('right') ? rightPx : null,
      child: Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Text(
          text?.toString() ?? labelKey,
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w500,
            color: _parseHexColor(color, const Color(0xFF8B5E3C)),
          ),
        ),
      ),
    );
  }

  Color _parseHexColor(String? value, Color fallback) {
    if (value == null || value.isEmpty) return fallback;
    try {
      return Color(int.parse(value.replaceFirst('#', '0xff')));
    } catch (_) {
      return fallback;
    }
  }

  String _anchorName(Alignment alignment) {
    if (alignment == Alignment.topLeft) return 'top_left';
    if (alignment == Alignment.topRight) return 'top_right';
    if (alignment == Alignment.bottomLeft) return 'bottom_left';
    if (alignment == Alignment.bottomRight) return 'bottom_right';
    return 'top_left';
  }
}

class _TreatmentArrowPainter extends CustomPainter {
  final List<dynamic> arrows;
  final Color color;
  final double opacity;
  final double strokeWidth;

  const _TreatmentArrowPainter({
    required this.arrows,
    required this.color,
    required this.opacity,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final arrow in arrows) {
      if (arrow is! Map) continue;
      final map = Map<String, dynamic>.from(arrow);
      final start = _fractionOffset(map['startFraction'], size);
      final control = _fractionOffset(map['controlFraction'], size);
      final end = _fractionOffset(map['endFraction'], size);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      canvas.drawPath(path, paint);

      final angle = (end - control).direction;
      const len = 5.0;
      const spread = 0.42;
      final arrowHead = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - len * math.cos(angle - spread), end.dy - len * math.sin(angle - spread))
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - len * math.cos(angle + spread), end.dy - len * math.sin(angle + spread));
      canvas.drawPath(arrowHead, paint);
    }
  }

  Offset _fractionOffset(dynamic value, Size size) {
    final map = value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
    final x = (map['x'] as num?)?.toDouble() ?? 0.0;
    final y = (map['y'] as num?)?.toDouble() ?? 0.0;
    return Offset(size.width * x, size.height * y);
  }

  @override
  bool shouldRepaint(covariant _TreatmentArrowPainter oldDelegate) {
    return oldDelegate.arrows != arrows ||
        oldDelegate.color != color ||
        oldDelegate.opacity != opacity ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}