import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/bloc_exports.dart';
import '../mixins/onboarding_audio_mixin.dart';
import '../models/onboarding_models.dart';
import '../services/app_route_observer.dart';
import '../services/onboarding_service.dart';
import '../services/remote_asset_service.dart';
import '../utils/text_parsing_utils.dart';
import '../widgets/cached_logo_image.dart';
import '../widgets/onboarding_widgets_exports.dart';
import 'dashboard.dart';
import 'privacy_policy.dart';
import 'onboarding_page_10.dart';

class OnboardingPage11 extends StatefulWidget {
  const OnboardingPage11({super.key});

  @override
  State<OnboardingPage11> createState() => _OnboardingPage11State();
}

class _OnboardingPage11State extends State<OnboardingPage11>
    with OnboardingAudioMixin<OnboardingPage11>, WidgetsBindingObserver, RouteAware {
  static const String _targetPageId = 'page_14';

  OnboardingPageData? _page;
  bool _showText = false;
  bool _isRouteSubscribed = false;

  @override
  String get englishAudioPath => _page?.englishAudio ?? '';

  @override
  String get urduAudioPath => _page?.urduAudio ?? '';

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

  int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  Color _parseHexColor(String? value, Color fallback) {
    if (value == null || value.isEmpty) return fallback;
    try {
      return Color(int.parse(value.replaceFirst('#', '0xff')));
    } catch (_) {
      return fallback;
    }
  }

  FontWeight _fontWeight(String? value, {FontWeight fallback = FontWeight.w800}) {
    switch ((value ?? '').toLowerCase()) {
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
      case 'normal':
        return FontWeight.w400;
      case 'w500':
      case 'medium':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
      case 'bold':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return fallback;
    }
  }

  String _localizedText(Map<String, String> values, String language, String fallback) {
    return (values[language] ?? values['English'] ?? values['Roman Urdu'] ?? values['اردو'] ?? fallback).trim();
  }

  Curve _curveFromName(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'linear':
        return Curves.linear;
      case 'easeoutcubic':
      case 'ease_out_cubic':
        return Curves.easeOutCubic;
      case 'easein':
      case 'ease_in':
        return Curves.easeIn;
      case 'easeout':
      case 'ease_out':
        return Curves.easeOut;
      case 'easeinout':
      case 'ease_in_out':
        return Curves.easeInOut;
      default:
        return Curves.easeOutCubic;
    }
  }

  OnboardingPageData? _findTargetPage(List<OnboardingPageData> pages) {
    for (final page in pages) {
      if (page.id == _targetPageId ||
          page.pageType == 'left_animation_with_text_overlay' ||
          page.textKey == 'hope') {
        return page;
      }
    }
    return null;
  }

  void _hydrateFromLoaded(OnboardingLoaded state) {
    final found = _findTargetPage(state.pages);
    if (found == null) {
      debugPrint('⚠️ Page11 could not find page_14 / left_animation_with_text_overlay');
      return;
    }

    setState(() {
      _page = found;
      _showText = false;
    });

    final languageState = context.read<LanguageBloc>().state;
    var currentLanguage = 'English';
    if (languageState is LanguageSelected) {
      currentLanguage = languageState.language;
    }

    initAudio(currentLanguage);
    _primeAssets(found);

    final fadeInDelay = _asInt(found.rawData['animation'] is Map ? (found.rawData['animation'] as Map)['textFadeInDelay'] : null, 300);
    Future.delayed(Duration(milliseconds: fadeInDelay), () {
      if (mounted) setState(() => _showText = true);
    });

    debugPrint('✅ Page11 hydrated from Firestore: id=${found.id}, type=${found.pageType}, textKey=${found.textKey}');
  }

  void _restartAudioFromCurrentLanguage() {
    final languageState = context.read<LanguageBloc>().state;
    var currentLanguage = 'English';
    if (languageState is LanguageSelected) {
      currentLanguage = languageState.language;
    }
    initAudio(currentLanguage);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final onboardingState = context.read<OnboardingBloc>().state;
      if (onboardingState is OnboardingLoaded) {
        _hydrateFromLoaded(onboardingState);
      } else {
        context.read<OnboardingBloc>().add(const FetchOnboardingFlowEvent());
      }
    });
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
    _restartAudioFromCurrentLanguage();
  }

  @override
  void didPushNext() {
    debugPrint('⏹️ Page11 didPushNext: stopping onboarding audio');
    stopAudio();
  }

  @override
  void deactivate() {
    // Covers gesture/back/system route transitions where buttons are not tapped.
    stopAudio();
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      stopAudio();
    }
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

  Future<void> _primeAssets(OnboardingPageData page) async {
    try {
      final assets = <String>[];
      if (page.logoUrl != null && page.logoUrl!.isNotEmpty) {
        assets.add(page.logoUrl!);
      }
      if (page.animationPath.isNotEmpty) {
        assets.add(page.animationPath);
      }
      for (final asset in assets) {
        await RemoteAssetService.resolveDownloadUrl(asset).timeout(const Duration(seconds: 10));
      }
    } catch (e) {
      debugPrint('⚠️ Page11 asset priming failed: $e');
    }
  }

  String _navigationTarget(Map<String, dynamic> buttons, String key) {
    return buttons[key]?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingLoaded) {
          _hydrateFromLoaded(state);
        }
      },
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          var currentLanguage = 'English';
          if (state is LanguageSelected) {
            currentLanguage = state.language;
            if (_page != null) {
              onLanguageChanged(currentLanguage);
            }
          }

          final page = _page;
          if (page == null) {
            return Scaffold(
              body: SafeArea(
                child: Container(
                  color: const Color(0xFFFFF4F4),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE91E8C)),
                  ),
                ),
              ),
            );
          }

          final raw = page.rawData;
          final animationConfig = _asMap(raw['animationConfig']);
          final textAnimation = _asMap(raw['animation']);
final gradient = _asMap(raw['gradient']);          final navigationButtons = _asMap(raw['navigationButtons']);
          final textOverlay = _asMap(raw['textOverlay']);
          final title = _localizedText(page.translations, currentLanguage, page.textKey);
          final isUrdu = currentLanguage == 'اردو';
          final animation = AnimationConfig.fromJson(animationConfig);

          final animationScale = animation.scale;
          final translateX = animation.translateXPercent;
          final translateY = animation.translateYPercent;
          final alignmentValue = animation.getAlignment();

          final textFadeInDelay = _asInt(textAnimation['textFadeInDelay'], 300);
          final textOpacityDuration = _asInt(textAnimation['textOpacityDuration'], 500);
          final textSlideDuration = _asInt(textAnimation['textSlideDuration'], 600);
          final slideOffset = _asMap(textAnimation['textSlideOffset']);
          final slideX = _asDouble(slideOffset['x'], 0.0);
          final slideY = _asDouble(slideOffset['y'], 0.15);

          final titleColor = _parseHexColor(page.textStyle.color, const Color(0xFF8B5E3C));
          final titleFontSize = (page.textStyle.fontSize ?? 24).sp;
          final titleWeight = _fontWeight(page.textStyle.fontWeight, fallback: FontWeight.w800);
          final titleFontFamily = page.textStyle.titleFontFamily ?? 'Edu';
          final titleTextAlign = (page.textStyle.textAlign ?? 'left').toLowerCase();

          final logo = _asMap(raw['logo']);
          final logoTopMargin = _asDouble(logo['topMargin'], 12).h;
          final logoBottomMargin = _asDouble(logo['bottomMargin'], 8).h;
          final logoHeight = _asDouble(logo['height'], 72).h;
          final logoWidth = _asDouble(logo['width'], 72).w;

          final bgColor = _parseHexColor(page.backgroundColor, const Color(0xFFFFF4F4));
         final gradientColors = (gradient['colors'] as List<dynamic>?)
        ?.map((value) => _parseHexColor(value?.toString(), const Color(0xFFFFFFFF)))
        .toList() ??
    <Color>[
      const Color(0x00FFF4F4),
      const Color(0x18FFF4F4),
      const Color(0x55FFF4F4),
      const Color(0xAAFFF4F4),
      const Color(0xF2FFF4F4),
      const Color(0xFFFFFFFF),
    ];
    
final gradientStops = (gradient['stops'] as List<dynamic>?)
        ?.map((value) => _asDouble(value))
        .toList() ??
    const [0.0, 0.2, 0.42, 0.64, 0.84, 1.0];

final bottomOffset = _asDouble(gradient['bottomOffset'], 85).h;
final gradientHeightPercent = _asDouble(gradient['height'], 0.2); // ✅ Get percentage from Firebase

          final backDestination = _navigationTarget(navigationButtons, 'backDestination');
          final nextDestination = _navigationTarget(navigationButtons, 'nextDestination');
          final nextAction = _navigationTarget(navigationButtons, 'nextAction');
          final hasBack = navigationButtons['hasBack'] != false;
          final hasNext = navigationButtons['hasNext'] != false;
          final supportsBoldParsing = raw['supportsBoldParsing'] == true;
          final supportsRtl = raw['supportsRTL'] == true;
          final overlayLeftOffset = (() {
            final rawLeft = textOverlay['leftOffset']?.toString() ?? '';
            if (rawLeft.contains('50%_plus_')) {
              final pixels = double.tryParse(rawLeft.split('50%_plus_').last) ?? 0.0;
              return MediaQuery.of(context).size.width * 0.5 + pixels.w;
            }
            return MediaQuery.of(context).size.width * 0.5;
          })();

          return Scaffold(
            body: SafeArea(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: bgColor,
                child: Column(
                  children: [
                    SizedBox(height: logoTopMargin),
                    CachedLogoImage(height: logoHeight, width: logoWidth, imageUrl: page.logoUrl),
                    SizedBox(height: logoBottomMargin),
                    Expanded(
                      child: Stack(
                        children: [
                          OnboardingAnimation(
                            assetPath: page.animationPath,
                            scale: animationScale,
                            translateXPercent: translateX,
                            translateYPercent: translateY,
                            alignment: alignmentValue,
                          ),
                         Positioned(
  left: 0,
  right: 0,
  bottom: bottomOffset,
  child: IgnorePointer(
    child: Container(
      height: gradientHeightPercent.sh,  // ✅ Use ScreenUtil's .sh (20% of screen height)
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
          stops: gradientStops,
        ),
      ),
    ),
  ),
),

                          Positioned(
                            top: _asDouble(textOverlay['topOffset'], 110).h,
                            left: overlayLeftOffset,
                            right: _asDouble(textOverlay['rightOffset'], 20).w,
                            child: AnimatedSlide(
                              offset: _showText ? Offset.zero : Offset(slideX, slideY),
                              duration: Duration(milliseconds: textSlideDuration),
                              curve: _curveFromName(textAnimation['animationCurve']?.toString()),
                              child: AnimatedOpacity(
                                opacity: _showText ? 1 : 0,
                                duration: Duration(milliseconds: textOpacityDuration),
                                child: Directionality(
                                  textDirection: (supportsRtl && isUrdu) ? TextDirection.rtl : TextDirection.ltr,
                                  child: supportsBoldParsing
                                      ? TextParsingUtils.parseBold(
                                          title,
                                          isUrdu: supportsRtl && isUrdu,
                                          isRoman: currentLanguage == 'Roman Urdu',
                                        )
                                      : Text(
                                          title,
                                          textAlign: titleTextAlign == 'right'
                                              ? TextAlign.right
                                              : titleTextAlign == 'center'
                                                  ? TextAlign.center
                                                  : TextAlign.left,
                                          style: TextStyle(
                                            color: titleColor,
                                            fontFamily: titleFontFamily,
                                            fontSize: titleFontSize,
                                            fontWeight: titleWeight,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: OnboardingNavigationButtons(
                        showBackButton: hasBack,
                        onBackPressed: hasBack
                            ? () {
                                stopAudio();
                                if (Navigator.of(context).canPop()) {
                                  Navigator.of(context).pop();
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const OnboardingPage10()),
                                  );
                                }
                              }
                            : null,
                        onNextPressed: hasNext
                            ? () async {
                                stopAudio();
                                if (nextAction == 'complete_onboarding' || nextDestination == 'dashboard') {
                                  await OnboardingService.markOnboardingCompleted();
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                                  );
                                  return;
                                }
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                                );
                              }
                            : null,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
