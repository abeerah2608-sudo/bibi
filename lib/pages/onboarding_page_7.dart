import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import '../bloc/bloc_exports.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/onboarding_models.dart';
import '../services/remote_asset_service.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../mixins/onboarding_audio_mixin.dart';
import '../services/app_route_observer.dart';
import 'onboarding_page_6.dart';
import '../models/video_card_data.dart';

import 'onboarding_page_8.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingPage7 extends StatefulWidget {
  const OnboardingPage7({super.key});

  @override
  State<OnboardingPage7> createState() => _OnboardingPage7State();
}

class _OnboardingPage7State extends State<OnboardingPage7>
  with OnboardingAudioMixin<OnboardingPage7>, WidgetsBindingObserver, RouteAware {
  static const String _pageId = 'page_10';

  OnboardingPageData? _page;
  String? _resolvedThumbnailUrl;
  bool _isInitialized = false;
  bool _showContinue = false;
  String? _debugMessage;
  String? _lastOnboardingStateType;
  Timer? _renderWatchdog;
  bool _isNavigatingAway = false;
  bool _isRouteSubscribed = false;

  OnboardingPageData? get _currentPageData => _page;

  @override
  String get englishAudioPath => _currentPageData?.englishAudio ?? '';

  @override
  String get urduAudioPath => _currentPageData?.urduAudio ?? '';

  String _localizedValue(
    Map<String, String> values,
    String language,
    String fallback,
  ) {
    final result = values[language] ?? values['English'] ?? fallback;
    return result.trim();
  }

  String _localizedContinue(String language) {
    switch (language) {
      case 'اردو':
        return 'جاری رکھیں';
      case 'Roman Urdu':
        return 'Jari rakhain';
      default:
        return 'Continue';
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

  Future<void> _launchVideo(String? videoUrl) async {
    if (videoUrl == null || videoUrl.isEmpty) {
      debugPrint('⚠️ Page7: Cannot launch empty video URL');
      return;
    }
    try {
      final uri = Uri.parse(videoUrl);
      stopAudio();
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) setState(() => _showContinue = true);
    } catch (e) {
      debugPrint('❌ Page7: Error launching video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open video')),
        );
      }
    }
  }

  void _navigateNext() {
    if (_isNavigatingAway) return;
    _isNavigatingAway = true;
    debugPrint('➡️ Page7 navigateNext -> OnboardingPage8');
    _renderWatchdog?.cancel();
    stopAudio();
    () async {
      await disposeAudio();
      if (!mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => const OnboardingPage8(),
        ),
      );
    }();
  }

  void _navigateBack() {
    if (_isNavigatingAway) return;
    _isNavigatingAway = true;
    debugPrint('⬅️ Page7 navigateBack -> OnboardingPage6');
    _renderWatchdog?.cancel();
    stopAudio();
    () async {
      await disposeAudio();
      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        await Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
            pageBuilder: (_, __, ___) => const OnboardingPage6(),
          ),
        );
      }
    }();
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
    _isNavigatingAway = false;
    _showContinue = false;

    final languageState = context.read<LanguageBloc>().state;
    var currentLanguage = 'English';
    if (languageState is LanguageSelected) {
      currentLanguage = languageState.language;
    }

    initAudio(currentLanguage);

    final page = _page;
    if (page != null) {
      _primePageAssets(page);
    }
  }

  @override
  void didPushNext() {
    stopAudio();
  }

  Future<void> _primePageAssets(OnboardingPageData page) async {
    if (_isNavigatingAway) return;
    try {
      final thumbnail = page.videoCard?.thumbnailImage ?? '';
      final audioUrls = <String>[
        page.englishAudio,
        page.urduAudio,
      ].where((url) => url.isNotEmpty).toList();

      if (thumbnail.isNotEmpty) {
        _resolvedThumbnailUrl = await RemoteAssetService.resolveDownloadUrl(thumbnail)
            .timeout(const Duration(seconds: 10));
        debugPrint('🔀 Page7 thumbnail resolved: $thumbnail -> $_resolvedThumbnailUrl');

        if (_resolvedThumbnailUrl != null &&
            _resolvedThumbnailUrl!.isNotEmpty &&
            mounted &&
            !_isNavigatingAway) {
          try {
            await precacheImage(
              CachedNetworkImageProvider(_resolvedThumbnailUrl!),
              context,
            ).timeout(const Duration(seconds: 10));
          } catch (precacheError) {
            debugPrint('⚠️ Precache failed for thumbnail: $precacheError');
          }
        }
      }

      final resolvedAudio = await Future.wait(
        audioUrls.map((url) => RemoteAssetService.resolveDownloadUrl(url)
            .timeout(const Duration(seconds: 10))),
      );
      if (!_isNavigatingAway) {
        await RemoteAssetService().preloadAssets(resolvedAudio);
      }
    } catch (e, st) {
      debugPrint('⚠️ Page7 asset priming failed: $e');
      debugPrint('   stack: $st');
      if (mounted && !_isNavigatingAway) {
        setState(() {
          _resolvedThumbnailUrl = null;
        });
      }
    }
  }

  void _hydrateFromLoadedState(OnboardingLoaded state) {
    final foundPage = state.pages.cast<OnboardingPageData?>().firstWhere(
          (page) => page != null &&
              (page.id == _pageId ||
                  page.pageType == 'video_card' ||
                  page.textKey == 'self_examine_card_title'),
          orElse: () => null,
        );

    if (foundPage == null) {
      debugPrint('⚠️ Page7 hydrate: Could not find page_10 or video_card page');
      return;
    }

    setState(() {
      _page = foundPage;
      _isInitialized = true;
      _debugMessage = null;
    });

    debugPrint('📌 Page7 selected id=${foundPage.id}, type=${foundPage.pageType}, textKey=${foundPage.textKey}');

    final languageState = context.read<LanguageBloc>().state;
    var currentLanguage = 'English';
    if (languageState is LanguageSelected) {
      currentLanguage = languageState.language;
    }

    initAudio(currentLanguage);
    _primePageAssets(foundPage);
  }

  Widget _buildCard(BuildContext context, OnboardingPageData page, String currentLanguage) {
    final videoCard = page.videoCard;
    final videoUrl = videoCard?.videoUrl ?? '';
    
    final title = _localizedValue(
      page.titleTranslations,
      currentLanguage,
      'How to self-examine?',
    );
    
    final subtitle = _localizedValue(
      page.subtitleTranslations,
      currentLanguage,
      'Understanding the basics in 3 min',
    );
    
    final watchNow = _localizedValue(
      page.watchNowTranslations,
      currentLanguage,
      'Watch now',
    );
    
    final continueText = _localizedContinue(currentLanguage);
    
    // Debug page_10 data
    if (page.id == 'page_10') {
      debugPrint('🎥 PAGE_10 RENDER DEBUG:');
      debugPrint('  title: $title');
      debugPrint('  subtitle: $subtitle');
      debugPrint('  watchNow: $watchNow');
      debugPrint('  videoUrl: $videoUrl');
      debugPrint('  titleTranslations: ${page.titleTranslations}');
      debugPrint('  subtitleTranslations: ${page.subtitleTranslations}');
      debugPrint('  watchNowTranslations: ${page.watchNowTranslations}');
      debugPrint('  videoCard: ${page.videoCard}');
    }
    
    final isUrdu = currentLanguage == 'اردو';
    final cardBackgroundColor = _parseColor(
      videoCard?.cardBackgroundColor,
      const Color(0xFFEFA7BC),
    );
    final titleColor = _parseColor(page.textStyle.color, const Color(0xFF8B5E3C));
    final titleFontSize = page.textStyle.titleFontSize ?? page.textStyle.fontSize ?? 15;
    final subtitleFontSize = page.textStyle.subtitleFontSize ?? 12;
    final bottomTitleFontSize = page.textStyle.bottomTitleFontSize ?? 24;
    final favoriteId = videoCard?.favoriteId ?? page.textKey;

    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xFFFFF4F4),
          child: Column(
            children: [
              SizedBox(height: 12.h),

              // Logo
              Image.asset(
                'assets/images/Bibi_Logo_Vector 1.png',
                height: 72.h,
                width: 72.w,
              ),

              SizedBox(height: 14.h),

              // Video Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28.r),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
                      width: 1.2.w,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28.r),
                    child: Column(
                      children: [
                        // Thumbnail Section
                        Container(
                          height: 320.h,
                          width: double.infinity,
                          color: cardBackgroundColor,
                          child: Stack(
                            children: [
                              // Thumbnail Image
                              Positioned.fill(
                                child: _resolvedThumbnailUrl != null && _resolvedThumbnailUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: _resolvedThumbnailUrl!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                        errorWidget: (context, url, error) {
                                          debugPrint('❌ Failed to load thumbnail: $error');
                                          return Image.asset(
                                            'assets/images/miss_bibi.png',
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/miss_bibi.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              
                              // Duration Badge
                              Positioned(
                                top: 12.h,
                                left: 12.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.play_circle_filled,
                                        color: const Color(0xFFE86A8D),
                                        size: 13.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        videoCard?.duration ?? '3:57',
                                        style: TextStyle(
                                          color: const Color(0xFFE86A8D),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Favorite Button
                              Positioned(
                                top: 12.h,
                                right: 12.w,
                                child: BlocBuilder<FavoritesBloc, FavoritesState>(
                                  builder: (context, favoritesState) {
                                    final isFavourite = favoritesState.favoriteIds.contains(favoriteId);
                                    return GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        context.read<FavoritesBloc>().add(
                                              ToggleFavoriteEvent(
                                                VideoCardData(
                                                  title: favoriteId,
                                                  subtitle: subtitle.isNotEmpty ? subtitle : 'Video',
                                                  videoUrl: videoUrl.isEmpty ? null : videoUrl,
                                                  duration: videoCard?.duration ?? '3:57',
                                                  imagePlaceholder: 'miss_bibi.png',
                                                  titleKey: favoriteId,
                                                  subtitleKey: page.subtitleKey,
                                                ),
                                              ),
                                            );
                                      },
                                      child: Container(
                                        width: 44.r,
                                        height: 44.r,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isFavourite ? Icons.favorite : Icons.favorite_border,
                                          color: isFavourite
                                              ? const Color(0xFFE91E63)
                                              : const Color(0xFF8B5E3C),
                                          size: 18.sp,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Text and Button Section
                        Container(
                          color: const Color(0xFFFFF4F4),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          child: Directionality(
                            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (title.isNotEmpty)
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: titleFontSize.sp,
                                      color: titleColor,
                                    ),
                                  ),
                                if (title.isNotEmpty) SizedBox(height: 6.h),
                                if (subtitle.isNotEmpty)
                                  Text(
                                    subtitle,
                                    style: TextStyle(
                                      fontSize: subtitleFontSize.sp,
                                      color: const Color(0xFF888888),
                                    ),
                                  ),
                                SizedBox(height: 14.h),
                                Row(
                                  children: [
                                    if (!_showContinue && videoUrl.isNotEmpty)
                                      GestureDetector(
                                        onTap: () => _launchVideo(videoUrl),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                            vertical: 7.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF4A7B9).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                          child: Text(
                                            watchNow.isNotEmpty ? watchNow : 'Watch now',
                                            style: TextStyle(
                                              color: const Color(0xFFE86A8D),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (_showContinue)
                                      GestureDetector(
                                        onTap: _navigateNext,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                            vertical: 7.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE86A8D),
                                            borderRadius: BorderRadius.circular(20.r),
                                          ),
                                          child: Text(
                                            continueText.isNotEmpty ? continueText : 'Continue',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Bottom Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  title.isNotEmpty ? title : 'Self Examination',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: bottomTitleFontSize.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8B5E3C),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Navigation Buttons
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: OnboardingNavigationButtons(
                  onBackPressed: _navigateBack,
                  onNextPressed: _navigateNext,
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      stopAudio();
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🧭 Page7 initState entered');
    WidgetsBinding.instance.addObserver(this);

    _renderWatchdog = Timer(const Duration(seconds: 8), () {
      if (!mounted || _isInitialized) return;
      final onboardingState = context.read<OnboardingBloc>().state;
      final languageState = context.read<LanguageBloc>().state;
      final message =
          'Page7 still not initialized after 8s. OnboardingState=${onboardingState.runtimeType}, LanguageState=${languageState.runtimeType}';
      debugPrint('⏱️ $message');
      setState(() {
        _debugMessage = message;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final onboardingState = context.read<OnboardingBloc>().state;
        debugPrint('🧭 Page7 postFrame current OnboardingState=${onboardingState.runtimeType}');
        if (onboardingState is OnboardingLoaded) {
          debugPrint('🧭 Page7 using existing loaded onboarding state (no refetch)');
          _hydrateFromLoadedState(onboardingState);
        } else {
          debugPrint('🧭 Page7 dispatching FetchOnboardingFlowEvent');
          context.read<OnboardingBloc>().add(const FetchOnboardingFlowEvent());
        }
      } catch (e) {
        final message = 'Page7 failed to dispatch FetchOnboardingFlowEvent: $e';
        debugPrint('❌ $message');
        if (mounted) {
          setState(() {
            _debugMessage = message;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    if (_isRouteSubscribed) {
      appRouteObserver.unsubscribe(this);
    }
    _renderWatchdog?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('🧭 Page7 dispose called');
    disposeAudio();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        debugPrint('📡 Page7 BlocListener state=${state.runtimeType}');
        if (state is OnboardingLoaded) {
          try {
            debugPrint('📦 Page7 loaded pages count=${state.pages.length}');
            for (var i = 0; i < state.pages.length; i++) {
              final page = state.pages[i];
              debugPrint('   [Page7][$i] id=${page.id}, type=${page.pageType}, textKey=${page.textKey}, order=${page.order}');
            }
            _hydrateFromLoadedState(state);
          } catch (e, st) {
            debugPrint('❌ Page7: Error in BlocListener: $e');
            debugPrint('   stack: $st');
            if (mounted) {
              setState(() {
                _debugMessage = 'Page7 listener error: $e';
              });
            }
          }
        }

        if (state is OnboardingError && mounted) {
          setState(() {
            _debugMessage = 'OnboardingError: ${state.message}';
          });
        }
      },
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          var currentLanguage = 'English';
          if (languageState is LanguageSelected) {
            currentLanguage = languageState.language;
            if (_isInitialized) {
              onLanguageChanged(currentLanguage);
            }
          }

          return BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, onboardingState) {
              final stateType = onboardingState.runtimeType.toString();
              if (_lastOnboardingStateType != stateType) {
                _lastOnboardingStateType = stateType;
                debugPrint('🧱 Page7 build with OnboardingState=$stateType, isInitialized=$_isInitialized, hasPage=${_page != null}');
              }

              // Loading State
              if (onboardingState is OnboardingLoading) {
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
                            if (_debugMessage != null) ...[
                              SizedBox(height: 14.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Text(
                                  _debugMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Error State
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

              // Page Not Found
              final page = _currentPageData;
              if (page == null) {
                debugPrint('⚠️ Page7 build: _currentPageData is null. debug=$_debugMessage');
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
                            if (_debugMessage != null) ...[
                              SizedBox(height: 14.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Text(
                                  _debugMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              debugPrint('📄 Page7 render id: ${page.id}');
              debugPrint('🎞️ Page7 type: ${page.pageType}');

              // Wrong Page Type
              if (page.pageType != 'video_card') {
                return Scaffold(
                  body: SafeArea(
                    child: Container(
                      color: const Color(0xFFFFF4F4),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Unexpected page type: ${page.pageType}',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              SizedBox(height: 16.h),
                              ElevatedButton(
                                onPressed: _navigateNext,
                                child: const Text('Continue'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Render Card
              try {
                return _buildCard(context, page, currentLanguage);
              } catch (e, st) {
                debugPrint('❌ Page7 render crash: $e');
                debugPrint('   stack: $st');
                return Scaffold(
                  body: SafeArea(
                    child: Container(
                      color: const Color(0xFFFFF4F4),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Text(
                            'Page7 render error: $e',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}