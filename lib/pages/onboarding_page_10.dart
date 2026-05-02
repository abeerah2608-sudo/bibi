import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/bloc_exports.dart';
import '../mixins/onboarding_audio_mixin.dart';
import '../models/onboarding_models.dart';
import '../services/app_route_observer.dart';
import '../services/remote_asset_service.dart';
import '../widgets/cached_logo_image.dart';
import '../widgets/onboarding_widgets_exports.dart';
import 'onboarding_page_9.dart';
import 'onboarding_page_11.dart';

class OnboardingPage10 extends StatefulWidget {
  const OnboardingPage10({super.key});

  @override
  State<OnboardingPage10> createState() => _OnboardingPage10State();
}

class _OnboardingPage10State extends State<OnboardingPage10>
    with TickerProviderStateMixin, OnboardingAudioMixin<OnboardingPage10>, WidgetsBindingObserver, RouteAware {
  static const String _targetPageId = 'page_13';

  OnboardingPageData? _page;
  bool _isInitialized = false;
  bool _isRouteSubscribed = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<AnimationController> _itemControllers = [];
  final List<Animation<double>> _itemAnimations = [];

  @override
  String get englishAudioPath => _page?.englishAudio ?? '';

  @override
  String get urduAudioPath => _page?.urduAudio ?? '';

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  int _asInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  double _asDouble(dynamic value, [double fallback = 0.0]) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
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

  FontWeight _fontWeight(String? value, {FontWeight fallback = FontWeight.w500}) {
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

  String _localizedFoodLabel(FoodItemConfig item, String language) {
    return _localizedText(item.translations, language, item.labelKey);
  }

  Curve _curveFromName(String? name) {
    switch ((name ?? '').toLowerCase()) {
      case 'linear':
        return Curves.linear;
      case 'easein':
      case 'ease_in':
        return Curves.easeIn;
      case 'easeout':
      case 'ease_out':
        return Curves.easeOut;
      case 'easeinout':
      case 'ease_in_out':
        return Curves.easeInOut;
      case 'elasticin':
      case 'elastic_in':
        return Curves.elasticIn;
      case 'elasticout':
      case 'elastic_out':
        return Curves.elasticOut;
      default:
        return Curves.elasticOut;
    }
  }

  FoodItemConfig? _itemForPosition(List<FoodItemConfig> items, String position) {
    for (final item in items) {
      if (item.position == position) return item;
    }
    return null;
  }

  OnboardingPageData? _findTargetPage(List<OnboardingPageData> pages) {
    for (final page in pages) {
      if (page.id == _targetPageId ||
          page.textKey == 'how_to_support_title') {
        return page;
      }
    }
    return null;
  }

  void _ensureItemControllers(int itemCount, Curve curve, int durationMs) {
    if (_itemControllers.length == itemCount) {
      for (var i = 0; i < _itemControllers.length; i++) {
        _itemControllers[i].duration = Duration(milliseconds: durationMs);
        _itemAnimations[i] = CurvedAnimation(parent: _itemControllers[i], curve: curve);
      }
      return;
    }

    for (final controller in _itemControllers) {
      controller.dispose();
    }
    _itemControllers.clear();
    _itemAnimations.clear();

    for (var i = 0; i < itemCount; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: durationMs),
      );
      _itemControllers.add(controller);
      _itemAnimations.add(CurvedAnimation(parent: controller, curve: curve));
    }
  }

  void _startAnimations(OnboardingPageData page) {
    final raw = page.rawData;
    final fadeInDelay = _asInt(raw['fadeInDelay'], 150);
    final fadeInDuration = _asInt(raw['fadeInDuration'], 600);
    final itemStartDelay = _asInt(raw['itemStartDelay'], 300);
    final staggerDelay = _asInt(raw['staggerDelay'], 180);
    final itemDuration = _asInt(raw['itemAnimationDuration'], 550);
    final curve = _curveFromName(raw['animationCurve']?.toString());

    _fadeController.duration = Duration(milliseconds: fadeInDuration);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: curve);
    _fadeController.forward(from: 0);

    for (final controller in _itemControllers) {
      controller.duration = Duration(milliseconds: itemDuration);
      controller.reset();
    }

    Future.delayed(Duration(milliseconds: fadeInDelay), () {
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    });

    for (var i = 0; i < _itemControllers.length; i++) {
      final delay = Duration(milliseconds: itemStartDelay + i * staggerDelay);
      Future.delayed(delay, () {
        if (mounted) {
          _itemControllers[i].forward();
        }
      });
    }
  }

  Future<void> _primeAssets(OnboardingPageData page) async {
    try {
      final urls = <String>[];
      if (page.logoUrl != null && page.logoUrl!.isNotEmpty) {
        urls.add(page.logoUrl!);
      }
      for (final item in page.foodItems) {
        if (item.asset.isNotEmpty) {
          urls.add(item.asset);
        }
      }

      for (final url in urls) {
        final resolved = await RemoteAssetService.resolveDownloadUrl(url)
            .timeout(const Duration(seconds: 10));
        if (!mounted) return;
        try {
          await precacheImage(NetworkImage(resolved), context)
              .timeout(const Duration(seconds: 10));
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('⚠️ Page10 asset priming failed: $e');
    }
  }

  void _hydrateFromLoaded(OnboardingLoaded state) {
    final found = _findTargetPage(state.pages);
    if (found == null) {
      debugPrint('⚠️ Page10 could not find page_13 / food_items_grid');
      return;
    }

    if (found.id != _targetPageId) {
      debugPrint('⚠️ Page10 matched a non-page_13 document (${found.id}); ignoring it');
      return;
    }

    final curve = _curveFromName(found.rawData['animationCurve']?.toString());
    _ensureItemControllers(
      found.foodItems.length,
      curve,
      _asInt(found.rawData['itemAnimationDuration'], 550),
    );

    setState(() {
      _page = found;
      _isInitialized = false;
    });

    final languageState = context.read<LanguageBloc>().state;
    var currentLanguage = 'English';
    if (languageState is LanguageSelected) {
      currentLanguage = languageState.language;
    }

    initAudio(currentLanguage);
    _primeAssets(found);
    _startAnimations(found);
    debugPrint('✅ Page10 hydrated from Firestore: id=${found.id}, type=${found.pageType}, textKey=${found.textKey}');
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

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

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
    stopAudio();
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
    _fadeController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    disposeAudio();
    super.dispose();
  }

  Widget _buildFoodItem(FoodItemConfig item, String currentLanguage, int index) {
    final anim = _itemAnimations[index];
    final circleColor = _parseHexColor(item.circleColor, const Color(0xFFF68AA8));
    final labelColor = _parseHexColor(_page?.textStyle.labelColor, const Color(0xFF5A3E2B));
    final labelFontFamily = _page?.textStyle.labelFontFamily ?? 'Edu';
    final labelFontSize = _page?.textStyle.labelFontSize ?? 12;
    final labelLineHeight = _page?.textStyle.labelLineHeight ?? 1.35;
    final asset = item.asset.isEmpty ? '' : RemoteAssetService.convertGsUrlToHttps(item.asset);

    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final progress = anim.value.clamp(0.0, 1.15);
        return Opacity(
          opacity: progress.clamp(0.0, 1.0),
          child: Transform.scale(scale: progress, child: child),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: item.circleDiameter.w,
            height: item.circleDiameter.h,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: asset.isEmpty
                  ? const SizedBox.shrink()
                  : Image.network(
                      asset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: (item.circleDiameter + 12).w,
            child: Text(
              _localizedFoodLabel(item, currentLanguage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: labelFontFamily,
                fontSize: labelFontSize.sp,
                fontWeight: FontWeight.w500,
                color: labelColor,
                height: labelLineHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, OnboardingPageData page, String currentLanguage) {
    final raw = page.rawData;
    final layout = _asMap(raw['layout']);
    final horizontalPadding = _asDouble(layout['horizontalPadding'], 20);
    final itemSpacing = _asDouble(layout['itemSpacing'], 20);
    final topItemSpacing = _asDouble(layout['topItemSpacing'], 20);

    final title = _localizedText(page.translations, currentLanguage, page.textKey);
    final isUrdu = currentLanguage == 'اردو';

    final titleStyle = page.textStyle;
    final titleColor = _parseHexColor(titleStyle.titleColor ?? titleStyle.color, const Color(0xFF8B5E3C));
    final titleFontFamily = titleStyle.titleFontFamily ?? 'Inter';
    final titleFontSize = (titleStyle.titleFontSize ?? titleStyle.fontSize ?? 24).sp;
    final titleHorizontalPadding = (titleStyle.titleHorizontalPadding ?? 24).w;
    final titleWeight = _fontWeight(titleStyle.titleFontWeight, fallback: FontWeight.w800);
    final titleAlignment = (titleStyle.titleTextAlign ?? 'center').toLowerCase();

    final logo = _asMap(raw['logo']);
    final logoTopMargin = _asDouble(logo['topMargin'], 12).h;
    final logoBottomMargin = _asDouble(logo['bottomMargin'], 8).h;
    final logoHeight = _asDouble(logo['height'], 72).h;
    final logoWidth = _asDouble(logo['width'], 72).w;

    final topItem = _itemForPosition(page.foodItems, 'center_top');
    final row2Left = _itemForPosition(page.foodItems, 'row_2_left');
    final row2Right = _itemForPosition(page.foodItems, 'row_2_right');
    final row3Left = _itemForPosition(page.foodItems, 'row_3_left');
    final row3Right = _itemForPosition(page.foodItems, 'row_3_right');

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: _parseHexColor(page.backgroundColor, const Color(0xFFFFF4F4)),
          child: Column(
            children: [
              SizedBox(height: logoTopMargin),
              CachedLogoImage(
                height: logoHeight,
                width: logoWidth,
                imageUrl: page.logoUrl,
              ),
              SizedBox(height: logoBottomMargin),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            if (topItem != null)
                              Center(
                                child: _buildFoodItem(
                                  topItem,
                                  currentLanguage,
                                  page.foodItems.indexOf(topItem),
                                ),
                              ),
                            SizedBox(height: topItemSpacing.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (row2Left != null)
                                  _buildFoodItem(
                                    row2Left,
                                    currentLanguage,
                                    page.foodItems.indexOf(row2Left),
                                  ),
                                if (row2Right != null)
                                  _buildFoodItem(
                                    row2Right,
                                    currentLanguage,
                                    page.foodItems.indexOf(row2Right),
                                  ),
                              ],
                            ),
                            SizedBox(height: itemSpacing.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (row3Left != null)
                                  _buildFoodItem(
                                    row3Left,
                                    currentLanguage,
                                    page.foodItems.indexOf(row3Left),
                                  ),
                                if (row3Right != null)
                                  _buildFoodItem(
                                    row3Right,
                                    currentLanguage,
                                    page.foodItems.indexOf(row3Right),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: titleHorizontalPadding),
                          child: Text(
                            title,
                            textAlign: titleAlignment == 'left'
                                ? TextAlign.left
                                : titleAlignment == 'right'
                                    ? TextAlign.right
                                    : TextAlign.center,
                            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                            style: TextStyle(
                              fontFamily: titleFontFamily,
                              fontSize: titleFontSize,
                              fontWeight: titleWeight,
                              color: titleColor,
                              height: 1.2,
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
                  onBackPressed: () {
                    stopAudio();
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const OnboardingPage9()),
                      );
                    }
                  },
                  onNextPressed: () {
                    stopAudio();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OnboardingPage11()),
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
            if (_isInitialized) {
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

          return _buildGrid(context, page, currentLanguage);
        },
      ),
    );
  }
}
