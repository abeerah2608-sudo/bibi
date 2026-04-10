import 'package:bibi/pages/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../services/language_strings.dart';
import 'onboarding_page_9.dart';
import 'onboarding_page_11.dart';

import '../mixins/onboarding_audio_mixin.dart';


// ── Data model ────────────────────────────────────────────────────────────────
class _FoodItem {
  final String asset;
  final String labelKey;
  final String labelFallback;

  const _FoodItem({
    required this.asset,
    required this.labelKey,
    required this.labelFallback,
  });
}

// ── Page ──────────────────────────────────────────────────────────────────────
class OnboardingPage10 extends StatefulWidget {
  const OnboardingPage10({super.key});

  @override
  State<OnboardingPage10> createState() => _OnboardingPage10State();
}

class _OnboardingPage10State extends State<OnboardingPage10>
    with TickerProviderStateMixin, OnboardingAudioMixin<OnboardingPage10> {

  // ── Implement required getters for the mixin ──
  @override
  String get englishAudioPath => 'assets/audio/onboarding_12.mp3';

  @override
  String get urduAudioPath => 'assets/audio/onboarding_12_urdu.mp3';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<AnimationController> _itemControllers = [];
  final List<Animation<double>> _itemAnimations = [];

  static const int _itemCount = 5;
  static const Duration _staggerDelay = Duration(milliseconds: 180);
  static const Duration _itemDuration = Duration(milliseconds: 550);

  static const List<_FoodItem> _items = [
    _FoodItem(
      asset: 'assets/images/CHARACTER.png',
      labelKey: 'listen',
      labelFallback: 'Listen',
    ),
    _FoodItem(
      asset: 'assets/images/fish.png',
      labelKey: 'eat_protein_rich_food',
      labelFallback: 'Eat protein\nrich food',
    ),
    _FoodItem(
      asset: 'assets/images/Group.png',
      labelKey: 'help',
      labelFallback: 'Help the patients in chores',
    ),
    _FoodItem(
      asset: 'assets/images/Vector.png',
      labelKey: 'checkup',
      labelFallback: 'Regularly get your checkup done',
    ),
    _FoodItem(
      asset: 'assets/images/doctor.png',
      labelKey: 'doctor',
      labelFallback: 'Consult a doctor regularly',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Initialize audio from mixin
    initAudio();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    for (int i = 0; i < _itemCount; i++) {
      final ctrl = AnimationController(vsync: this, duration: _itemDuration);
      final anim = CurvedAnimation(parent: ctrl, curve: Curves.elasticOut);
      _itemControllers.add(ctrl);
      _itemAnimations.add(anim);
    }

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _fadeController.forward();
    });
    for (int i = 0; i < _itemCount; i++) {
      final delay =
          Duration(milliseconds: 300 + i * _staggerDelay.inMilliseconds);
      Future.delayed(delay, () {
        if (mounted) _itemControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }

    // Dispose audio from mixin
    disposeAudio();

    super.dispose();
  }

  String _label(int index, String currentLanguage) {
    final item = _items[index];
    if (currentLanguage == 'اردو') {
      return LanguageStrings.getTranslation(currentLanguage, item.labelKey);
    }
    return item.labelFallback;
  }

  Widget _buildItem(int index, String currentLanguage,
      {double circleDiameter = 104}) {
    final item = _items[index];
    final anim = _itemAnimations[index];

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
            width: circleDiameter,
            height: circleDiameter,
            decoration: const BoxDecoration(
              color: Color(0xFFF68AA8),
              shape: BoxShape.circle,
            ),
            child: FractionallySizedBox(
              widthFactor: 0.85,
              heightFactor: 0.85,
              child: Image.asset(item.asset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: circleDiameter + 12,
            child: Text(
              _label(index, currentLanguage),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5A3E2B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
          onLanguageChanged(currentLanguage); // from mixin
        }

        final howToSupport =
            LanguageStrings.getTranslation(currentLanguage, 'how_to_support_title');

        return Scaffold(
          body: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFFFF4F4),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/Bibi_Logo_Vector 1.png',
                    height: 72,
                    width: 72,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Center(
                                  child: _buildItem(0, currentLanguage,
                                      circleDiameter: 112)),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildItem(1, currentLanguage),
                                  _buildItem(2, currentLanguage)
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildItem(3, currentLanguage),
                                  _buildItem(4, currentLanguage)
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              howToSupport,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF8B5E3C),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OnboardingPageIndicator(currentPage: 12, totalPages: 14),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OnboardingNavigationButtons(
                      onBackPressed: () {
                         stopAudio(); 
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingPage9(),
                          ),
                        );
                      },
                       onNextPressed: () {
                         stopAudio(); 
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const OnboardingPage11(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}