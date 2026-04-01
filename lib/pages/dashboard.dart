import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import 'quiz_page_1.dart';
import 'audio_player_page.dart';

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
        duration: '3:24',
        imagePlaceholder: 'whatIsIt.png',
        titleKey: 'cancer_cell',
        subtitleKey: 'self_examine_subtitle',
      ),
      VideoCardData(
        title: 'Are you at Risk?',
        subtitle: 'When an abnormality is found',
        duration: '3:24',
        imagePlaceholder: 'risk.png',
        titleKey: 'family_tree',
        subtitleKey: 'self_examine_subtitle',
      ),
    ],
    'Care': [
      VideoCardData(
        title: 'Preventive Screening',
        subtitle: 'Understanding concepts of preventive screening',
        duration: '3:24',
        imagePlaceholder: 'mammogram.jpg',
        accentColor: Color(0xFFE91E8C),
        titleKey: 'self_examine_card_title',
        subtitleKey: 'self_examine_subtitle',
      ),
      VideoCardData(
        title: 'How to Treat?',
        subtitle: 'Care options after detection',
        duration: '5:24',
        imagePlaceholder: 'treat.jpg',
        titleKey: 'how_to_treat_title',
        subtitleKey: 'self_examine_subtitle',
      ),
      VideoCardData(
        title: 'How to Confirm?',
        subtitle: 'Tests and checks to know for sure',
        duration: '3:24',
        imagePlaceholder: 'check.jpg',
        titleKey: 'self_examine_title',
        subtitleKey: 'self_examine_subtitle',
      ),
    ],
    'Support': [
      VideoCardData(
        title: 'How to Prevent?',
        subtitle: 'Simple steps to lower the risk',
        duration: '5:24',
        imagePlaceholder: 'prevent.jpg',
        titleKey: 'how_to_prevent_title',
        subtitleKey: 'self_examine_subtitle',
      ),
      VideoCardData(
        title: 'How to Support?',
        subtitle: 'Ways to help with care and comfort',
        duration: '3:24',
        imagePlaceholder: 'support.jpg',
        titleKey: 'how_to_support_title',
        subtitleKey: 'self_examine_subtitle',
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
                    _buildTabBar(),
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

  Widget _buildTabBar() {
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
        tabs: _tabs.map((t) => Tab(text: t)).toList(),
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
            const Text(
              'Choose Language',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333333)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select the language you prefer',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
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
class _WelcomeBanner extends StatelessWidget {
  final String language;
  final VoidCallback onLanguageTap;
  const _WelcomeBanner(
      {required this.language, required this.onLanguageTap});

  @override
  Widget build(BuildContext context) {
    final careText =
        LanguageStrings.getTranslation(language, 'life_is_too_short')
            .replaceAll('[b]', '')
            .replaceAll('[/b]', '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // ── Left: text ─────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Good Morning, Bibi ',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text('👋', style: TextStyle(fontSize: 14)),
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

          // ── Right: star + globe icons ───────────────────────────────
          Row(
            children: [
              const Icon(Icons.star_border,
                  color: Color(0xFF888888), size: 22),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onLanguageTap,
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
class _QuizCard extends StatelessWidget {
  final String language;
  const _QuizCard({required this.language});

  @override
  Widget build(BuildContext context) {
    final quizTitle = LanguageStrings.getTranslation(language, 'self_examine_card_title');
    final quizDesc  = LanguageStrings.getTranslation(language, 'self_examine_subtitle');
    final startBtn  = LanguageStrings.getTranslation(language, 'get_started');

    return Container(
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
          // ── Timer icon ───────────────────────────────────────────────
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

          // ── Text ─────────────────────────────────────────────────────
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
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '0% ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'complete',
                        style: TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  quizDesc,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),

          // ── Start button ─────────────────────────────────────────────
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QuizPage1()),
              );
            },
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
                Text(startBtn),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 14),
              ],
            ),
          ),
        ],
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

  const VideoCardData({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.imagePlaceholder,
    this.accentColor,
    this.titleKey,
    this.subtitleKey,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Video Card Widget
// ────────────────────────────────────────────────────────────────────────────
class _VideoCard extends StatelessWidget {
  final VideoCardData data;
  final String language;
  const _VideoCard({required this.data, required this.language});

  @override
  Widget build(BuildContext context) {
    final title = data.titleKey != null
        ? LanguageStrings.getTranslation(language, data.titleKey!)
            .replaceAll('[b]', '')
            .replaceAll('[/b]', '')
        : data.title;

    final subtitle = data.subtitleKey != null
        ? LanguageStrings.getTranslation(language, data.subtitleKey!)
        : data.subtitle;

    final watchNow =
        LanguageStrings.getTranslation(language, 'watch_now');

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
                  'assets/images/${data.imagePlaceholder}',
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
                        Text(data.duration,
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
                                title: title,
                                subtitle: subtitle,
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
                  onTap: () {},
                  child: const Icon(Icons.favorite_border,
                      size: 22, color: Color(0xFF8B5E3C)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}