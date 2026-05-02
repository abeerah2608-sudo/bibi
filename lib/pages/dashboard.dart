import 'package:bibi/pages/discover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/bloc_exports.dart';
import '../bloc/dashboard_bloc.dart';
import '../models/dashboard_models.dart';
import '../models/video_card_data.dart';
import '../services/language_strings.dart';
import '../services/quiz_service.dart';
import '../services/remote_asset_service.dart';
import '../widgets/cached_logo_image.dart';
import 'quiz_page_1.dart';
import 'favourites.dart';
import 'video_card.dart';
import 'quiz_completion_page.dart';
import 'audio_player_page.dart'
    show
        AudioPlayerPage,
        allAudioContent,
        AudioContent,
        audioContent1,
        audioContent2,
        audioContent3,
        audioContent4,
        audioContent5,
        audioContent6,
        audioContent7;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin  {
  late TabController _tabController;
  DashboardConfig? _config;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    debugPrint("🚀 DashboardScreen initState START");
    
    try {
      _tabController = TabController(length: 3, vsync: this); // Default 3 tabs
      debugPrint("✅ TabController initialized with 3 tabs");
    } catch (e) {
      debugPrint("❌ Error creating TabController: $e");
    }

    // Fetch dashboard config on next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        debugPrint("📱 DashboardScreen: Post-frame callback executing");
        if (!mounted) {
          debugPrint("⚠️ DashboardScreen: Widget unmounted, skipping initialization");
          return;
        }
        
        final dashboardState = context.read<DashboardBloc>().state;
        debugPrint("📊 DashboardScreen: Current bloc state = ${dashboardState.runtimeType}");
        
        if (dashboardState is DashboardLoaded) {
          debugPrint('⚡ DashboardScreen: Using existing DashboardLoaded state (${dashboardState.config.tabs.length} tabs)');
          _hydrateFromLoadedState(dashboardState);
        } else {
          debugPrint("📡 DashboardScreen: Fetching dashboard config from Firebase...");
          context.read<DashboardBloc>().add(const FetchDashboardConfigEvent());
        }
      } catch (e, st) {
        debugPrint("❌ DashboardScreen initState Error: $e");
        debugPrint("   Stack: $st");
      }
    });
  }

  void _hydrateFromLoadedState(DashboardLoaded state) {
    debugPrint("🔄 DashboardScreen: _hydrateFromLoadedState called");
    
    if (!mounted) {
      debugPrint("⚠️ DashboardScreen: Widget unmounted in _hydrateFromLoadedState, skipping");
      return;
    }

    try {
      final previousController = _tabController;
      final newLength = state.config.tabs.isEmpty ? 1 : state.config.tabs.length;
      
      debugPrint("📝 DashboardScreen: Creating new TabController with $newLength tabs");
      
      _tabController = TabController(
        length: newLength,
        vsync: this,
      );
      
      setState(() {
        _config = state.config;
        _isInitialized = true;
      });
      
      previousController.dispose();
      debugPrint("✅ DashboardScreen: Hydration complete, config loaded with ${state.config.tabs.length} tabs");
    } catch (e, st) {
      debugPrint("❌ DashboardScreen: Error in _hydrateFromLoadedState: $e");
      debugPrint("   Stack: $st");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _languageKey(String language) {
    switch (language) {
      case 'Urdu':
      case 'اردو':
        return 'اردو';
      case 'Roman Urdu':
        return 'Roman Urdu';
      case 'English':
      default:
        return 'English';
    }
  }

  void _showLanguageDialog() {
    if (_config == null) return;
    
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (context) => _LanguageDialog(config: _config!.languageDialog),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🏗️ DashboardScreen build() called - _isInitialized=$_isInitialized, _config=${_config != null}");
    
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        debugPrint("📡 DashboardScreen BlocListener: new state = ${state.runtimeType}");
        try {
          if (state is DashboardLoaded) {
            debugPrint("✅ DashboardScreen BlocListener: Received DashboardLoaded state");
            _hydrateFromLoadedState(state);
          } else if (state is DashboardError) {
            debugPrint("❌ DashboardScreen BlocListener: Received DashboardError - ${state.message}");
          }
        } catch (e, st) {
          debugPrint("❌ DashboardScreen BlocListener error: $e");
          debugPrint("   Stack: $st");
        }
      },
      child: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, languageState) {
          String currentLanguage = 'English';
          if (languageState is LanguageSelected) {
            currentLanguage = languageState.language;
          }
          debugPrint("🌐 DashboardScreen: currentLanguage=$currentLanguage");

          return BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, dashboardState) {
              debugPrint("🧱 DashboardScreen builder: DashboardState=${dashboardState.runtimeType}");

              // If bloc reports loaded but widget not yet hydrated, schedule hydration.
              if (dashboardState is DashboardLoaded && !_isInitialized) {
                debugPrint('🔔 DashboardScreen detected DashboardLoaded but not hydrated yet — scheduling hydration');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  try {
                    if (mounted) _hydrateFromLoadedState(dashboardState);
                  } catch (e, st) {
                    debugPrint('❌ Error scheduling _hydrateFromLoadedState: $e');
                    debugPrint('   Stack: $st');
                  }
                });
              }
              
              if (dashboardState is DashboardLoading) {
                debugPrint("⏳ DashboardScreen: Loading state");
                return _buildLoadingScreen();
              }

              if (dashboardState is DashboardError) {
                debugPrint("❌ DashboardScreen: Error state - ${dashboardState.message}");
                return _buildErrorScreen(dashboardState.message);
              }

              if (!_isInitialized || _config == null) {
                debugPrint("⏳ DashboardScreen: Not initialized yet (_isInitialized=$_isInitialized, _config=${_config != null})");
                return _buildLoadingScreen();
              }

              debugPrint("✅ DashboardScreen: Rendering dashboard with language=$currentLanguage");
              return _buildDashboard(currentLanguage);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: const Color(0xFFFFF4F4),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE91E8C),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    debugPrint("🚨 DashboardScreen error screen: $message");
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
                  'Error loading dashboard',
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    message,
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
                    debugPrint("🔄 DashboardScreen: Retry button pressed");
                    context
                        .read<DashboardBloc>()
                        .add(const FetchDashboardConfigEvent());
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

  Widget _buildDashboard(String language) {
    debugPrint("🎨 DashboardScreen _buildDashboard START - language=$language");
    
    try {
      if (_config == null) {
        debugPrint("❌ DashboardScreen _buildDashboard: _config is null!");
        return _buildErrorScreen("Config not loaded");
      }
      
      debugPrint("📊 DashboardScreen config details:");
      debugPrint("   - tabs count: ${_config!.tabs.length}");
      debugPrint("   - backgroundColor: ${_config!.backgroundColor}");
      
      final config = _config!;
      final backgroundColor = _parseHexColor(config.backgroundColor);

      return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  _WelcomeBanner(
                    config: config.welcomeBanner,
                    logoUrl: config.logoUrl,
                    language: language,
                    onLanguageTap: _showLanguageDialog,
                  ),
                  SizedBox(height: 16.h),
                  _QuizCard(
                    config: config.quizCard,
                    language: language,
                  ),
                  SizedBox(height: 16.h),
                  _buildTabBar(language),
                  SizedBox(height: 16.h),
                  _buildTabContent(language),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e, st) {
      debugPrint("❌ DashboardScreen _buildDashboard ERROR: $e");
      debugPrint("   Stack: $st");
      return _buildErrorScreen("Error building dashboard: $e");
    }
  }

  Widget _buildTabBar(String language) {
    final config = _config!;
    final key = _languageKey(language);
    
    final tabLabels = config.tabs.map((tab) {
      return tab.translations[key] ?? 
             tab.translations['English'] ?? 
             tab.labelKey;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(
          color: const Color(0xFFF98CA9),
          width: 1.2.w,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicator: BoxDecoration(
          color: const Color(0xFFF98CA9),
          borderRadius: BorderRadius.circular(30.r),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF8B5E3C),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
        ),
        dividerColor: Colors.transparent,
        tabs: tabLabels.map((label) => Tab(text: label)).toList(),
      ),
    );
  }

  Widget _buildTabContent(String language) {
    final config = _config!;
    
    try {
      // Guard against invalid tab index
      if (config.tabs.isEmpty) {
        debugPrint('⚠️ DashboardScreen: No tabs configured');
        return Center(
          child: Text(
            'No tabs configured',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        );
      }
      
      final currentIndex = _tabController.index;
      if (currentIndex >= config.tabs.length) {
        debugPrint('⚠️ DashboardScreen: Tab index out of bounds: $currentIndex >= ${config.tabs.length}');
        return Center(
          child: Text(
            'Invalid tab index',
            style: TextStyle(fontSize: 14.sp, color: Colors.red),
          ),
        );
      }
      
      final currentTabId = config.tabs[currentIndex].id;
      final cards = config.videoCards[currentTabId] ?? [];
      debugPrint('🎬 DashboardScreen: Building tab content for tab=$currentTabId with ${cards.length} cards');

      if (cards.isEmpty) {
        return Center(
          child: Text(
            'No content for this tab',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
        );
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: ListView.separated(
          key: ValueKey(currentTabId),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          separatorBuilder: (_, __) => SizedBox(height: 16.h),
          itemBuilder: (context, index) {
            try {
              return _VideoCardFromFirebase(
                data: cards[index],
                language: language,
              );
            } catch (e, st) {
              debugPrint('❌ Error building video card $index: $e');
              debugPrint('   Stack: $st');
              return SizedBox(
                height: 100.h,
                child: Center(
                  child: Text('Error loading card: $e', textAlign: TextAlign.center),
                ),
              );
            }
          },
        ),
      );
    } catch (e, st) {
      debugPrint('❌ DashboardScreen _buildTabContent ERROR: $e');
      debugPrint('   Stack: $st');
      return Center(
        child: Text('Error: $e', textAlign: TextAlign.center),
      );
    }
  }

  Color _parseHexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return const Color(0xFFFFF4F4);
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Language Dialog
// ────────────────────────────────────────────────────────────────────────────

class _LanguageDialog extends StatefulWidget {
  final LanguageDialogConfig config;
  
  const _LanguageDialog({required this.config});

  @override
  State<_LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<_LanguageDialog> {
  String _selected = 'English';

  String _languageKey(String language) {
    return language == 'Urdu' ? 'اردو' : language;
  }

  @override
  void initState() {
    super.initState();
    final currentState = context.read<LanguageBloc>().state;
    if (currentState is LanguageSelected) {
      _selected = currentState.language;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = context.read<LanguageBloc>().state is LanguageSelected
        ? (context.read<LanguageBloc>().state as LanguageSelected).language
        : 'English';
    final languageKey = _languageKey(currentLanguage);

    final dialogTitle = widget.config.chooseLangTranslations[languageKey] ??
        widget.config.chooseLangTranslations['English'] ??
        'Choose Language';

    final dialogSubtitle = widget.config.selectLangTranslations[languageKey] ??
        widget.config.selectLangTranslations['English'] ??
        'Select the language you prefer';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 28.h),
        decoration: BoxDecoration(
          color: _parseHexColor(widget.config.backgroundColor),
          borderRadius: BorderRadius.circular(widget.config.borderRadius.toDouble().r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.close,
                  size: 20.r,
                  color: const Color(0xFF888888),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              dialogTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              dialogSubtitle,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF888888),
              ),
            ),
            SizedBox(height: 20.h),
            ...widget.config.languages.map((lang) {
              final isSelected = _selected == lang.label;
              return GestureDetector(
                onTap: () {
                  setState(() => _selected = lang.label);
                  context
                      .read<LanguageBloc>()
                      .add(SelectLanguageEvent(lang.label));
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF98CA9)
                          : const Color(0xFFEDD5D5),
                      width: 1.2.w,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            lang.label,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          if (lang.sublabel.isNotEmpty) ...[
                            SizedBox(width: 8.w),
                            Text(
                              lang.sublabel,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF888888),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFF98CA9)
                                : const Color(0xFFCCCCCC),
                            width: 1.5.w,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10.r,
                                  height: 10.r,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFF98CA9),
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _parseHexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return const Color(0xFFFFF8F8);
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Welcome Banner
// ────────────────────────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  final WelcomeBannerConfig config;
  final String logoUrl;
  final String language;
  final VoidCallback onLanguageTap;

  const _WelcomeBanner({
    required this.config,
    required this.logoUrl,
    required this.language,
    required this.onLanguageTap,
  });

  @override
  Widget build(BuildContext context) {
    final key = language == 'Urdu' ? 'اردو' : language;

    final greetingText = config.greetingTranslations[key] ??
        config.greetingTranslations['English'] ??
        'Good Morning, Bibi';

    final careText = config.careTextTranslations[key] ??
        config.careTextTranslations['English'] ??
        'Here\'s your daily dose of breast care!';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: _parseHexColor(config.backgroundColor),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      greetingText,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    Text(config.emoji, style: TextStyle(fontSize: 14.sp)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  careText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DiscoverPage()),
                  );
                },
                child: Icon(
                  Icons.star_border,
                  color: const Color(0xFF888888),
                  size: 22.r,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: onLanguageTap,
                child: Icon(
                  Icons.language,
                  color: const Color(0xFF888888),
                  size: 22.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _parseHexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return const Color(0xFFFFF4F4);
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Quiz Card
// ────────────────────────────────────────────────────────────────────────────

class _QuizCard extends StatefulWidget {
  final QuizCardConfig config;
  final String language;

  const _QuizCard({
    required this.config,
    required this.language,
  });

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  QuizProgress? _quizProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizProgress();
  }

  Future<void> _loadQuizProgress() async {
    final progress = await QuizService.getQuizProgress(widget.config.quizId);
    if (mounted) {
      setState(() {
        _quizProgress = progress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.language == 'Urdu' ? 'اردو' : widget.language;

    final quizTitle = widget.config.titleTranslations[key] ??
        widget.config.titleTranslations['English'] ??
        'How to self-examine?';

    final quizDesc = widget.config.subtitleTranslations[key] ??
        widget.config.subtitleTranslations['English'] ??
        'Understanding the basics in 3 min';

    final startBtn = widget.config.getStartedTranslations[key] ??
        widget.config.getStartedTranslations['English'] ??
        'Get Started';

    final completeText = widget.config.quizCompleteTranslations[key] ??
        widget.config.quizCompleteTranslations['English'] ??
        'Quiz completed! Retake to improve your score.';

    final questionsText = widget.config.questionsAnsweredTranslations[key] ??
        widget.config.questionsAnsweredTranslations['English'] ??
        'questions answered';

    final progressPercentage = _isLoading
        ? 0
        : (_quizProgress?.progressPercentage.toStringAsFixed(0) ?? '0');

    final isCompleted = _quizProgress?.isCompleted ?? false;
    final buttonText = isCompleted
        ? startBtn
        : ((_quizProgress != null && _quizProgress!.questionsCompleted > 0)
            ? 'Resume'
            : startBtn);

    void navigateToQuiz() {
      if (isCompleted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizCompletionPage(
              quizId: widget.config.quizId,
              completedQuestions: _quizProgress?.questionsCompleted ?? 0,
              totalQuestions: _quizProgress?.totalQuestions ?? widget.config.totalQuestions,
            ),
          ),
        ).then((_) => _loadQuizProgress());
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizPage1()),
        ).then((_) => _loadQuizProgress());
      }
    }

    return GestureDetector(
      onTap: navigateToQuiz,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFFFFBACB), Color(0xFFFF7198)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52.r,
              height: 52.r,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: Padding(
                padding: EdgeInsets.all(10.r),
                child: Image.asset(
                  'assets/images/timer.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quizTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$progressPercentage% ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'complete',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  if (_quizProgress != null && !isCompleted)
                    Text(
                      '${_quizProgress!.questionsCompleted}/${_quizProgress!.totalQuestions} $questionsText',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    )
                  else if (isCompleted)
                    Text(
                      completeText,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    )
                  else
                    Text(
                      quizDesc,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: navigateToQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF7198),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 8.h,
                ),
                textStyle: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(buttonText),
                  SizedBox(width: 4.w),
                  Icon(Icons.arrow_forward, size: 14.r),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Video Card from Firebase
// ────────────────────────────────────────────────────────────────────────────

class _VideoCardFromFirebase extends StatelessWidget {
  final VideoCardFirebaseData data;
  final String language;

  const _VideoCardFromFirebase({
    required this.data,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final key = language == 'Urdu' ? 'اردو' : language;

    debugPrint('🎬 _VideoCardFromFirebase for card: ${data.id}');
    debugPrint('   Language: $language, Key: $key');
    debugPrint('   Title translations available: ${data.titleTranslations.keys.toList()}');
    debugPrint('   Title translations: ${data.titleTranslations}');
    debugPrint('   Subtitle translations available: ${data.subtitleTranslations.keys.toList()}');
    debugPrint('   Subtitle translations: ${data.subtitleTranslations}');

    final title = data.titleTranslations[key] ??
        data.titleTranslations['English'] ??
        data.titleKey;

    final subtitle = data.subtitleTranslations[key] ??
        data.subtitleTranslations['English'] ??
        data.subtitleKey;

    debugPrint('   Final title: $title');
    debugPrint('   Final subtitle: $subtitle');

    // Map Firebase data to AudioContent
    final audioContent = _getAudioContent(data.audioContentId);

    final videoCardData = VideoCardData(
      title: title,
      subtitle: subtitle,
      videoUrl: data.videoUrl.isEmpty ? null : data.videoUrl,
      duration: data.duration,
      imagePlaceholder: _extractFileName(data.thumbnail),
      remoteImageUrl: data.thumbnail,
      audioContent: audioContent,
      accentColor: _parseHexColor(data.accentColor),
      titleKey: data.titleKey,
      subtitleKey: data.subtitleKey,
      favoriteId: data.favoriteId,
    );

    return VideoCard(
      data: videoCardData,
      language: language,
    );
  }

  AudioContent? _getAudioContent(String contentId) {
    // Map contentId to the corresponding AudioContent
    switch (contentId) {
      case 'audio_content_1':
        return audioContent1;
      case 'audio_content_2':
        return audioContent2;
      case 'audio_content_3':
        return audioContent3;
      case 'audio_content_4':
        return audioContent4;
      case 'audio_content_5':
        return audioContent5;
      case 'audio_content_6':
        return audioContent6;
      case 'audio_content_7':
        return audioContent7;
      default:
        return null;
    }
  }

  String _extractFileName(String url) {
    // Extract filename from Firebase Storage URL
    // e.g., "gs://bucket/images/whatIsIt.png" -> "whatIsIt.png"
    final parts = url.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }

  Color _parseHexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return const Color(0xFFE91E8C);
    }
  }
}