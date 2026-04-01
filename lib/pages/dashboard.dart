import 'package:flutter/material.dart';
import 'quiz_page_1.dart';

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
  final String language;

  const DashboardScreen({
    super.key,
    this.language = 'English',
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['Basics', 'Care', 'Support'];

  // Tab content: each tab has a list of video cards
  final Map<String, List<VideoCardData>> _tabContent = {
    'Basics': [
      VideoCardData(
        title: 'What is Breast Cancer?',
        subtitle: 'Understanding the basics in 5 min',
        duration: '3:24',
        imagePlaceholder: 'whatIsIt.png',
      ),
      VideoCardData(
        title: 'Are you at Risk?',
        subtitle: 'When an abnormality is found',
        duration: '3:24',
        imagePlaceholder: 'risk.png',
      ),
    ],
    'Care': [
      VideoCardData(
        title: 'Preventive Screening',
        subtitle: 'Understanding concepts of preventive screening',
        duration: '3:24',
        imagePlaceholder: 'mammogram.jpg',
        accentColor: Color(0xFFE91E8C),
      ),
      VideoCardData(
        title: 'How to Treat?',
        subtitle: 'Care options after detection',
        duration: '5:24',
        imagePlaceholder: 'treat.jpg',
      ),
      VideoCardData(
        title: 'How to Confirm?',
        subtitle: 'Tests and checks to know for sure',
        duration: '3:24',
        imagePlaceholder: 'check.jpg',
      ),
    ],
    'Support': [
      VideoCardData(
        title: 'How to Prevent?',
        subtitle: 'Simple steps to lower the risk',
        duration: '5:24',
        imagePlaceholder: 'prevent.jpg',
      ),
      VideoCardData(
        title: 'How to Support?',
        subtitle: 'Ways to help with care and comfort',
        duration: '3:24',
        imagePlaceholder: 'support.jpg',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
backgroundColor: const Color(0xFFFFF4F4),      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Welcome Banner ──────────────────────────────────────────
                _WelcomeBanner(),

                const SizedBox(height: 16),

                // ── Quiz / Progress Card ─────────────────────────────────────
                _QuizCard(language: widget.language),

                const SizedBox(height: 16),

                // ── Tab Bar ──────────────────────────────────────────────────
                _buildTabBar(),

                const SizedBox(height: 16),

                // ── Tab Content ──────────────────────────────────────────────
                _buildTabContent(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
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
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      ),
      dividerColor: Colors.transparent,
      tabs: _tabs.map((t) => Tab(text: t)).toList(),
    ),
  );
}

  Widget _buildTabContent() {
    // Read current tab index
    final currentTab = _tabs[_tabController.index];
    final cards = _tabContent[currentTab] ?? [];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Column(
        key: ValueKey(currentTab),
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _VideoCard(data: card),
                ))
            .toList(),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Welcome Banner
// ────────────────────────────────────────────────────────────────────────────
class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF48FB1).withOpacity(0.25),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Welcome Back ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF888888),
                              ),
                            ),
                            Text('👋', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Text(
                              'Hi Bibi ',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            Text('💗', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Take best care of your body.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Avatar — aligned to bottom of container, taller
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.asset(
                    'assets/images/miss_bibi2.png',
                    width: 130,
                    height: 200,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
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

// ────────────────────────────────────────────────────────────────────────────
// Quiz / Progress Card
// ────────────────────────────────────────────────────────────────────────────
class _QuizCard extends StatelessWidget {
  final String language;

  const _QuizCard({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const RadialGradient(
          center: Alignment.center,
          radius: 1.2,
          colors: [
            Color(0xFFFFBACB), // lighter center
            Color(0xFFFF7198), // darker outer
          ],
        ),
      ),
      child: Row(
        children: [
          // Timer image
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                'assets/images/timer.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Know Your Breast Health',
                  style: TextStyle(
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
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Answer 6 questions to learn more\nabout breast cancer risk.',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizPage1(language: language),
                ),
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start your quiz'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14),
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

  const VideoCardData({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.imagePlaceholder,
    this.accentColor,
  });
}

// ────────────────────────────────────────────────────────────────────────────
// Video Card Widget
// ────────────────────────────────────────────────────────────────────────────
class _VideoCard extends StatelessWidget {
  final VideoCardData data;

  const _VideoCard({required this.data});

  @override
  Widget build(BuildContext context) {
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
          // ── Thumbnail ────────────────────────────────────────────────────
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

                // Duration badge
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
                        Text(
                          data.duration,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card Footer ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Row(
              children: [
                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        data.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Watch now button
                      GestureDetector(
                        onTap: () {},
                       child: Container(
  padding: const EdgeInsets.symmetric(
      horizontal: 14, vertical: 7),
  decoration: BoxDecoration(
    color: const Color(0xFFF4A7B9).withOpacity(0.15),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: const Color(0xFFFFB2C7),
      width: 1.2,
    ),
  ),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Watch now',
        style: TextStyle(
          color: Color(0xFFE86A8D),
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
      ),
      SizedBox(width: 2),
      Icon(Icons.chevron_right,
          size: 14, color: Color(0xFFE86A8D)),
    ],
  ),
),
                      ),
                    ],
                  ),
                ),

                // Favourite heart
               GestureDetector(
  onTap: () {},
  child: const Icon(
    Icons.favorite_border,
    size: 22,
    color: Color(0xFF8B5E3C),
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