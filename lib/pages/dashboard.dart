import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../services/quiz_service.dart';
import 'quiz_page_1.dart';
import 'quiz_completion_page.dart';
import 'audio_player_page.dart' show AudioPlayerPage,  allAudioContent, AudioContent, audioContent1, audioContent2, audioContent3, audioContent4, audioContent5, audioContent6, audioContent7;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Breast Health Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE91E8C)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['Basics', 'Care', 'Support'];

  final Map<String, List<VideoCardData>> _tabContent = {
    'Basics': [
      VideoCardData(
        title: 'What is Breast Cancer?',
        subtitle: 'Understanding the basics in 5 min',
        duration: '0:21',
        imagePlaceholder: 'whatIsIt.png',
        titleKey: 'cancer_cell',
        subtitleKey: 'what_subtitle',
        audioContent: audioContent1,
      ),
      VideoCardData(
        title: 'Are you at risk?',
        subtitle: 'When an abnormality is found',
        duration: '0:16',
        imagePlaceholder: 'risk.png',
        titleKey: 'family_tree',
        subtitleKey: 'risk_subtitle',
        audioContent: audioContent2,
      ),
    ],
    'Care': [
      VideoCardData(
        title: 'Preventive Screening',
        subtitle: 'Understanding concepts of preventive screening',
        duration: '0:25',
        imagePlaceholder: 'mammogram.jpg',
        accentColor: Color(0xFFE91E8C),
        titleKey: 'self_examine_card_title',
        subtitleKey: 'screening_subtitle',
        audioContent: audioContent3,
      ),
      VideoCardData(
        title: 'How to Treat?',
        subtitle: 'Care options after detection',
        duration: '0:24',
        imagePlaceholder: 'treat.jpg',
        titleKey: 'how_to_treat_title',
        subtitleKey: 'treat_subtitle',
        audioContent: audioContent4,
      ),
      VideoCardData(
        title: 'How to Confirm?',
        subtitle: 'Tests and checks to know for sure',
        duration: '0:19',
        imagePlaceholder: 'check.jpg',
        titleKey: 'self_examine_title',
        subtitleKey: 'check_subtitle',
        audioContent: audioContent5,
      ),
    ],
    'Support': [
      VideoCardData(
        title: 'How to Prevent?',
        subtitle: 'Simple steps to lower the risk',
        duration: '0:17',
        imagePlaceholder: 'prevent.jpg',
        titleKey: 'how_to_prevent_title',
        subtitleKey: 'prevent_subtitle',
        audioContent: audioContent6,
      ),
      VideoCardData(
        title: 'How to Support?',
        subtitle: 'Ways to help with care and comfort',
        duration: '0:22',
        imagePlaceholder: 'support.jpg',
        titleKey: 'how_to_support_title',
        subtitleKey: 'support_subtitle',
        audioContent: audioContent7,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black38,
      builder: (context) => const _LanguageDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFF4F4),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Welcome Banner (now contains globe icon) ──────────
                    _WelcomeBanner(
                      language: currentLanguage,
                      onLanguageTap: _showLanguageDialog,
                    ),

                    const SizedBox(height: 16),
                    _QuizCard(language: currentLanguage),
                    const SizedBox(height: 16),
                    _buildTabBar(currentLanguage),
                    const SizedBox(height: 16),
                    _buildTabContent(currentLanguage),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar(String language) {
    final tabs = [
      LanguageStrings.getTranslation(language, 'basics_tab'),
      LanguageStrings.getTranslation(language, 'care_tab'),
      LanguageStrings.getTranslation(language, 'support_tab'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFF98CA9),
          width: 1.2,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        onTap: (_) => setState(() {}),
        indicator: BoxDecoration(
          color: const Color(0xFFF98CA9),
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF8B5E3C),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  Widget _buildTabContent(String language) {
    final currentTab = _tabs[_tabController.index];
    final cards = _tabContent[currentTab] ?? [];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Column(
        key: ValueKey(currentTab),
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _VideoCard(data: card, language: language),
                ))
            .toList(),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Language Dialog
// ────────────────────────────────────────────────────────────────────────────
class _LanguageDialog extends StatefulWidget {
  const _LanguageDialog();

  @override
  State<_LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<_LanguageDialog> {
  String _selected = 'English';

  final List<Map<String, String>> _languages = [
    {'label': 'English', 'sub': ''},
    {'label': 'Urdu', 'sub': 'اردو'},
    {'label': 'Roman Urdu', 'sub': ''},
  ];

  @override
  Widget build(BuildContext context) {
    final dialogTitle = LanguageStrings.getTranslation(
      context.read<LanguageBloc>().state is LanguageSelected
          ? (context.read<LanguageBloc>().state as LanguageSelected).language
          : 'English',
      'choose_language',
    );
    final dialogSubtitle = LanguageStrings.getTranslation(
      context.read<LanguageBloc>().state is LanguageSelected
          ? (context.read<LanguageBloc>().state as LanguageSelected).language
          : 'English',
      'select_language_preference',
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F8),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close,
                    size: 20, color: Color(0xFF888888)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dialogTitle,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333)),
            ),
            const SizedBox(height: 6),
            Text(
              dialogSubtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
            ),
            const SizedBox(height: 20),
            ..._languages.map((lang) {
              final isSelected = _selected == lang['label'];
              return GestureDetector(
                onTap: () {
                  setState(() => _selected = lang['label']!);
                  context
                      .read<LanguageBloc>()
                      .add(SelectLanguageEvent(lang['label']!));
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFF98CA9)
                          : const Color(0xFFEDD5D5),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            lang['label']!,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF333333)),
                          ),
                          if (lang['sub']!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(lang['sub']!,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF888888))),
                          ],
                        ],
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFF98CA9)
                                : const Color(0xFFCCCCCC),
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
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
}

// ────────────────────────────────────────────────────────────────────────────
// Welcome Banner
// ────────────────────────────────────────────────────────────────────────────
class _WelcomeBanner extends StatefulWidget {
  final String language;
  final VoidCallback onLanguageTap;
  const _WelcomeBanner(
      {required this.language, required this.onLanguageTap});

  @override
  State<_WelcomeBanner> createState() => _WelcomeBannerState();
}

class _WelcomeBannerState extends State<_WelcomeBanner> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final greetingText = LanguageStrings.getTranslation(widget.language, 'good_morning');
    final careText =
        LanguageStrings.getTranslation(widget.language, 'breast_care')
            .replaceAll('[b]', '')
            .replaceAll('[/b]', '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const Text('👋', style: TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  careText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() => _isFavorite = !_isFavorite);
                },
                child: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? const Color(0xFFF68AA8) : const Color(0xFF888888),
                  size: 22,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onLanguageTap,
                child: const Icon(Icons.language,
                    color: Color(0xFF888888), size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Quiz Card
// ────────────────────────────────────────────────────────────────────────────
class _QuizCard extends StatefulWidget {
  final String language;
  const _QuizCard({required this.language});

  @override
  State<_QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<_QuizCard> {
  QuizProgress? _quizProgress;
  bool _isLoading = true;
  static const int _quizId = 1;

  @override
  void initState() {
    super.initState();
    _loadQuizProgress();
  }

  Future<void> _loadQuizProgress() async {
    final progress = await QuizService.getQuizProgress(_quizId);
    if (mounted) {
      setState(() {
        _quizProgress = progress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quizTitle = LanguageStrings.getTranslation(widget.language, 'self_examine_card_title');
    final quizDesc  = LanguageStrings.getTranslation(widget.language, 'self_examine_subtitle');
    final startBtn  = LanguageStrings.getTranslation(widget.language, 'get_started');
    final completeText = LanguageStrings.getTranslation(widget.language, 'quiz_complete');
    final questionsText = LanguageStrings.getTranslation(widget.language, 'questions_answered');

    final progressPercentage = _isLoading 
        ? 0 
        : (_quizProgress?.progressPercentage.toStringAsFixed(0) ?? '0');

    final isCompleted = _quizProgress?.isCompleted ?? false;
    final buttonText = isCompleted ? startBtn : ((_quizProgress != null && _quizProgress!.questionsCompleted > 0) ? 'Resume' : startBtn);

    void _navigateToQuiz() {
      if (isCompleted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizCompletionPage(
              quizId: 1,
              completedQuestions: _quizProgress?.questionsCompleted ?? 0,
              totalQuestions: _quizProgress?.totalQuestions ?? 6,
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
      onTap: _navigateToQuiz,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Color(0xFFFFBACB), Color(0xFFFF7198)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Image.asset('assets/images/timer.png', fit: BoxFit.contain),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quizTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$progressPercentage% ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: 'complete',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (_quizProgress != null && !isCompleted)
                    Text(
                      '${_quizProgress!.questionsCompleted}/${_quizProgress!.totalQuestions} $questionsText',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    )
                  else if (isCompleted)
                    Text(
                      completeText,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    )
                  else
                    Text(
                      quizDesc,
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: _navigateToQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF7198),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(buttonText),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 14),
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
// Video Card Data Model
// ────────────────────────────────────────────────────────────────────────────
class VideoCardData {
  final String title;
  final String subtitle;
  final String duration;
  final String imagePlaceholder;
  final Color? accentColor;
  final String? titleKey;
  final String? subtitleKey;
  final AudioContent audioContent;

  const VideoCardData({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.imagePlaceholder,
    required this.audioContent,
    this.accentColor,
    this.titleKey,
    this.subtitleKey,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Video Card Widget
// ────────────────────────────────────────────────────────────────────────────
class _VideoCard extends StatefulWidget {
  final VideoCardData data;
  final String language;
  const _VideoCard({required this.data, required this.language});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final title = widget.data.titleKey != null
        ? LanguageStrings.getTranslation(widget.language, widget.data.titleKey!)
            .replaceAll('[b]', '')
            .replaceAll('[/b]', '')
        : widget.data.title;

    final subtitle = widget.data.subtitleKey != null
        ? LanguageStrings.getTranslation(widget.language, widget.data.subtitleKey!)
        : widget.data.subtitle;

    final watchNow =
        LanguageStrings.getTranslation(widget.language, 'watch_now');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/${widget.data.imagePlaceholder}',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 3),
                        Text(widget.data.duration,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF222222)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888)),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AudioPlayerPage(
                                audioContent: widget.data.audioContent,
                                  allContent: allAudioContent,

                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4A7B9).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFFFB2C7), width: 1.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(watchNow,
                                  style: const TextStyle(
                                      color: Color(0xFFE86A8D),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12)),
                              const SizedBox(width: 2),
                              const Icon(Icons.chevron_right,
                                  size: 14, color: Color(0xFFE86A8D)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() => _isFavorite = !_isFavorite);
                  },
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 22,
                    color: _isFavorite ? const Color(0xFFF68AA8) : const Color(0xFF8B5E3C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}