import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../widgets/onboarding_widgets_exports.dart';
import 'onboarding_page_7.dart';
import 'onboarding_page_9.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../mixins/onboarding_audio_mixin.dart';
import '../models/onboarding_models.dart';
import '../services/remote_asset_service.dart';
import '../widgets/cached_logo_image.dart';
import '../services/app_route_observer.dart';

class OnboardingPage8 extends StatefulWidget {
  const OnboardingPage8({super.key});

  @override
  State<OnboardingPage8> createState() => _OnboardingPage8State();
}

class _OnboardingPage8State extends State<OnboardingPage8>
  with TickerProviderStateMixin, OnboardingAudioMixin<OnboardingPage8>, WidgetsBindingObserver, RouteAware {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<AnimationController> _itemControllers = [];
  final List<Animation<double>> _itemAnimations = [];
  static const String _targetPageId = 'page_11';

  OnboardingPageData? _page;
  String? _resolvedBackgroundUrl;
  bool _isInitialized = false;
  bool _isRouteSubscribed = false;

  static const _staggerDelay = Duration(milliseconds: 350);
  static const _itemDuration = Duration(milliseconds: 500);

  @override
  String get englishAudioPath => _page?.englishAudio ?? '';

  @override
  String get urduAudioPath => _page?.urduAudio ?? '';

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    return const [];
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

  String _localizedNestedText(Map<String, dynamic> root, String key, String language, {String fallback = ''}) {
    final dynamic value = root[key];
    if (value is Map) {
      final map = Map<String, dynamic>.from(value);
      final chosen = map[language] ?? map['English'] ?? map['Roman Urdu'] ?? map['اردو'];
      return chosen?.toString().trim() ?? fallback;
    }
    return value?.toString().trim() ?? fallback;
  }

  OnboardingPageData? _findTargetPage(List<OnboardingPageData> pages) {
    OnboardingPageData? found = pages.cast<OnboardingPageData?>().firstWhere(
      (page) =>
          page != null &&
          (page.id == _targetPageId ||
              page.pageType == 'treatment_labels' ||
              page.textKey == 'how_to_treat_title'),
      orElse: () => null,
    );
    return found;
  }

  Future<void> _primeAssets(OnboardingPageData page) async {
    final raw = page.rawData;
    final backgroundImage =
        page.backgroundImageUrl ??
        (raw['backgroundImage'] as String?) ??
        _asMap(raw['backgroundImage'])['asset']?.toString() ??
        '';

    if (backgroundImage.isNotEmpty) {
      try {
        final resolved = await RemoteAssetService.resolveDownloadUrl(backgroundImage)
            .timeout(const Duration(seconds: 10));
        if (mounted) {
          setState(() {
            _resolvedBackgroundUrl = resolved;
          });
        }
      } catch (e) {
        debugPrint('⚠️ Page8 background resolve failed: $e');
      }
    }

    final preload = <String>[];
    if (page.englishAudio.isNotEmpty) preload.add(page.englishAudio);
    if (page.urduAudio.isNotEmpty) preload.add(page.urduAudio);
    if (backgroundImage.isNotEmpty) preload.add(backgroundImage);

    if (preload.isNotEmpty) {
      try {
        final resolved = await Future.wait(preload.map(RemoteAssetService.resolveDownloadUrl));
        await RemoteAssetService().preloadAssets(resolved);
      } catch (e) {
        debugPrint('⚠️ Page8 preload failed: $e');
      }
    }
  }

  void _hydrateFromLoaded(OnboardingLoaded state) {
    final found = _findTargetPage(state.pages);
    if (found == null) {
      debugPrint('⚠️ Page8 could not find page_11 / treatment_labels');
      return;
    }

    setState(() {
      _page = found;
      _isInitialized = true;
    });

    final languageState = context.read<LanguageBloc>().state;
    var currentLanguage = 'English';
    if (languageState is LanguageSelected) {
      currentLanguage = languageState.language;
    }
    initAudio(currentLanguage);
    _primeAssets(found);
    debugPrint('✅ Page8 hydrated from Firestore: id=${found.id}, type=${found.pageType}, textKey=${found.textKey}');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    for (int i = 0; i < 4; i++) {
      final ctrl = AnimationController(vsync: this, duration: _itemDuration);
      final anim = CurvedAnimation(parent: ctrl, curve: Curves.easeOut);
      _itemControllers.add(ctrl);
      _itemAnimations.add(anim);
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });
    for (int i = 0; i < 4; i++) {
      final delay =
          Duration(milliseconds: 400 + i * _staggerDelay.inMilliseconds);
      Future.delayed(delay, () {
        if (mounted) _itemControllers[i].forward();
      });
    }

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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
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
    for (final c in _itemControllers) {
      c.dispose();
    }
    disposeAudio(); // Clean up mixin audio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, onboardingState) {
        if (onboardingState is OnboardingLoaded) {
          _hydrateFromLoaded(onboardingState);
        }
      },
      child: BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
          if (_isInitialized) {
            onLanguageChanged(currentLanguage);
          }
        }

        if (!_isInitialized || _page == null) {
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

        final page = _page!;
        final raw = page.rawData;
        final translations = _asMap(raw['translations']);
        final labelsRoot = _asMap(translations['labels']);
        final title = _localizedNestedText(
          translations,
          'title',
          currentLanguage,
          fallback: page.translations[currentLanguage] ??
              page.translations['English'] ??
              page.textKey,
        );

        final labelMap = _asMap(labelsRoot[currentLanguage].toString() == 'null'
            ? labelsRoot['English']
            : labelsRoot[currentLanguage]);
        final englishLabelMap = _asMap(labelsRoot['English']);

        final arrowConfig = _asMap(raw['arrowConfig']);
        final arrows = _asList(arrowConfig['arrows']);
        final labelPositions = _asMap(raw['labelPositions']);

        final textStyle = page.textStyle;
        final titleColor = _parseHexColor(textStyle.color, const Color(0xFF8B5E3C));
        final titleFontSize = textStyle.titleFontSize ?? 26;
        final labelColor = _parseHexColor(textStyle.labelColor ?? textStyle.color, const Color(0xFF8B5E3C));
        final labelFontSize = textStyle.labelFontSize ?? 13;
        final labelFontFamily = textStyle.labelFontFamily ?? 'Edu';

        final logoUrl = page.logoUrl ?? _asMap(raw['logo'])['asset']?.toString();
        final backgroundUrl = _resolvedBackgroundUrl ??
            (page.backgroundImageUrl?.isNotEmpty == true
                ? RemoteAssetService.convertGsUrlToHttps(page.backgroundImageUrl!)
                : ((raw['backgroundImage'] as String?) ??
                    RemoteAssetService.convertGsUrlToHttps(
                      _asMap(raw['backgroundImage'])['asset']?.toString() ?? '',
                    )));

        final labels = [
          (labelMap['radiation'] ?? englishLabelMap['radiation'] ?? 'Radiation').toString(),
          (labelMap['chemotherapy'] ?? englishLabelMap['chemotherapy'] ?? 'Chemotherapy').toString(),
          (labelMap['hormonal_tablets'] ?? englishLabelMap['hormonal_tablets'] ?? 'Hormonal Tablets').toString(),
          (labelMap['surgery'] ?? englishLabelMap['surgery'] ?? 'Surgery').toString(),
        ];

        debugPrint('🧪 Page8 Firestore title: $title');
        debugPrint('🧪 Page8 Firestore labels: $labels');

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
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final h = constraints.maxHeight;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                if (backgroundUrl.isNotEmpty)
                                  Positioned.fill(
                                    child: Image.network(
                                      backgroundUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        debugPrint('❌ Page8 background load failed: $error');
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    child: Container(
                                      height: 0.45.sh,
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
                                Positioned.fill(
                                  child: AnimatedBuilder(
                                    animation: Listenable.merge(_itemControllers),
                                    builder: (context, _) {
                                      final values = List<double>.unmodifiable(
                                        _itemAnimations.map((a) => a.value),
                                      );
                                      if (values.length < 4) {
                                        return const SizedBox.shrink();
                                      }
                                      return CustomPaint(
                                        painter: _ArrowPainter(
                                          progresses: values,
                                          color: _parseHexColor(
                                            arrowConfig['color']?.toString(),
                                            const Color(0xFF8B5E3C),
                                          ).withOpacity(
                                            _asDouble(arrowConfig['opacity'], 0.6),
                                          ),
                                          arrows: arrows,
                                          strokeWidth: _asDouble(arrowConfig['strokeWidth'], 1.0),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Labels
                                _buildPositionedLabel(
                                  labelKey: 'radiation',
                                  label: labels[0],
                                  positions: labelPositions,
                                  animation: _itemAnimations[0],
                                  height: h,
                                  isLeft: true,
                                  textStyle: TextStyle(
                                    fontFamily: labelFontFamily,
                                    fontSize: labelFontSize.sp,
                                    fontWeight: FontWeight.w500,
                                    color: labelColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                _buildPositionedLabel(
                                  labelKey: 'chemotherapy',
                                  label: labels[1],
                                  positions: labelPositions,
                                  animation: _itemAnimations[1],
                                  height: h,
                                  isLeft: false,
                                  textStyle: TextStyle(
                                    fontFamily: labelFontFamily,
                                    fontSize: labelFontSize.sp,
                                    fontWeight: FontWeight.w500,
                                    color: labelColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                _buildPositionedLabel(
                                  labelKey: 'hormonal_tablets',
                                  label: labels[2],
                                  positions: labelPositions,
                                  animation: _itemAnimations[2],
                                  height: h,
                                  isLeft: true,
                                  textStyle: TextStyle(
                                    fontFamily: labelFontFamily,
                                    fontSize: labelFontSize.sp,
                                    fontWeight: FontWeight.w500,
                                    color: labelColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                _buildPositionedLabel(
                                  labelKey: 'surgery',
                                  label: labels[3],
                                  positions: labelPositions,
                                  animation: _itemAnimations[3],
                                  height: h,
                                  isLeft: false,
                                  textStyle: TextStyle(
                                    fontFamily: labelFontFamily,
                                    fontSize: labelFontSize.sp,
                                    fontWeight: FontWeight.w500,
                                    color: labelColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Align(
                      alignment: Alignment.center,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: textStyle.titleFontFamily ?? 'Inter',
                            fontSize: titleFontSize.sp,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
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
                            MaterialPageRoute(builder: (_) => const OnboardingPage7()),
                          );
                        }
                      },
                      onNextPressed: () {
                        stopAudio();
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const OnboardingPage9()),
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
      },
    ),
    );
  }

  Widget _buildPositionedLabel({
    required String labelKey,
    required String label,
    required Map<String, dynamic> positions,
    required Animation<double> animation,
    required double height,
    required bool isLeft,
    required TextStyle textStyle,
  }) {
    final pos = _asMap(positions[labelKey]);
    final anchor = (pos['anchor']?.toString() ?? '').toLowerCase();
    final isTop = anchor.startsWith('top');
    final useLeft = anchor.endsWith('left');

    final top = isTop ? height * _asDouble(pos['topFraction'], 0.10) : null;
    final bottom = isTop ? null : _asDouble(pos['bottomPx'], 30).h;
    final left = useLeft ? _asDouble(pos['leftPx'], isLeft ? 4 : 0).w : null;
    final right = useLeft ? null : _asDouble(pos['rightPx'], isLeft ? 0 : 20).w;

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: isLeft ? const Offset(-0.3, 0) : const Offset(0.3, 0),
            end: Offset.zero,
          ).animate(animation),
          child: Text(label, style: textStyle),
        ),
      ),
    );
  }
}

// ArrowPainter and _ArrowDef remain exactly as your original code
// ── Bezier arrow painter with staggered draw-on effect ────────────────────────
class _ArrowPainter extends CustomPainter {
  final List<double> progresses;
  final Color color;
  final List<dynamic> arrows;
  final double strokeWidth;

  const _ArrowPainter({
    required this.progresses,
    required this.color,
    required this.arrows,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progresses.length < 4) return;

    final defs = arrows.isNotEmpty
        ? arrows.map((raw) {
            final map = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
            final startMap = map['startFraction'] is Map
                ? Map<String, dynamic>.from(map['startFraction'])
                : <String, dynamic>{};
            final endMap = map['endFraction'] is Map
                ? Map<String, dynamic>.from(map['endFraction'])
                : <String, dynamic>{};
            final controlMap = map['controlFraction'] is Map
                ? Map<String, dynamic>.from(map['controlFraction'])
                : <String, dynamic>{};

            return _ArrowDef(
              start: Offset(
                ((startMap['x'] as num?)?.toDouble() ?? 0.2) * size.width,
                ((startMap['y'] as num?)?.toDouble() ?? 0.14) * size.height,
              ),
              end: Offset(
                ((endMap['x'] as num?)?.toDouble() ?? 0.3) * size.width,
                ((endMap['y'] as num?)?.toDouble() ?? 0.2) * size.height,
              ),
              control: Offset(
                ((controlMap['x'] as num?)?.toDouble() ?? 0.21) * size.width,
                ((controlMap['y'] as num?)?.toDouble() ?? 0.18) * size.height,
              ),
            );
          }).toList()
        : [
            _ArrowDef(
              start: Offset(size.width * 0.20, size.height * 0.14),
              end: Offset(size.width * 0.30, size.height * 0.20),
              control: Offset(size.width * 0.21, size.height * 0.18),
            ),
            _ArrowDef(
              start: Offset(size.width * 0.80, size.height * 0.14),
              end: Offset(size.width * 0.70, size.height * 0.20),
              control: Offset(size.width * 0.79, size.height * 0.18),
            ),
            _ArrowDef(
              start: Offset(size.width * 0.12, size.height * 0.84),
              end: Offset(size.width * 0.22, size.height * 0.76),
              control: Offset(size.width * 0.22, size.height * 0.79),
            ),
            _ArrowDef(
              start: Offset(size.width * 0.88, size.height * 0.84),
              end: Offset(size.width * 0.78, size.height * 0.76),
              control: Offset(size.width * 0.78, size.height * 0.79),
            ),
          ];

    for (int i = 0; i < defs.length; i++) {
      final progress = (i < progresses.length ? progresses[i] : 1.0).clamp(0.0, 1.0);
      if (progress <= 0) continue;

      final paint = Paint()
        ..color = color.withOpacity((progress * 0.8).clamp(0.0, 0.8))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      _drawCurvedArrow(
          canvas, paint, defs[i].start, defs[i].end, defs[i].control, progress);
    }
  }

  void _drawCurvedArrow(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
    Offset control,
    double progress,
  ) {
    final fullPath = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    final metric = fullPath.computeMetrics().first;
    final partial = metric.extractPath(0, metric.length * progress);
    canvas.drawPath(partial, paint);

    // Arrowhead fades in at end
    if (progress > 0.85) {
      final opacity = ((progress - 0.85) / 0.15).clamp(0.0, 1.0);
      final arrowPaint = Paint()
        ..color = color.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final angle = (end - control).direction;
      const len = 5.0;
      const spread = 0.42;

      final arrowPath = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - len * math.cos(angle - spread),
            end.dy - len * math.sin(angle - spread))
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - len * math.cos(angle + spread),
            end.dy - len * math.sin(angle + spread));

      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(_ArrowPainter old) {
    if (old.color != color) return true;
    if (old.progresses.length != progresses.length) return true;
    for (int i = 0; i < progresses.length; i++) {
      if (old.progresses[i] != progresses[i]) return true;
    }
    return false;
  }
}

class _ArrowDef {
  final Offset start;
  final Offset end;
  final Offset control;
  const _ArrowDef({required this.start, required this.end, required this.control});
}