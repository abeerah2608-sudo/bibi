import 'package:flutter/material.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../services/language_strings.dart';
import 'onboarding_page_8.dart';
import 'onboarding_page_10.dart';

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
class OnboardingPage9 extends StatefulWidget {
  final String language;

  const OnboardingPage9({
    super.key,
    required this.language,
  });

  @override
  State<OnboardingPage9> createState() => _OnboardingPage9State();
}

class _OnboardingPage9State extends State<OnboardingPage9>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<AnimationController> _itemControllers = [];
  final List<Animation<double>> _itemAnimations = [];

  static const int _itemCount = 5;
  static const Duration _staggerDelay = Duration(milliseconds: 180);
  static const Duration _itemDuration = Duration(milliseconds: 550);

  static const List<_FoodItem> _items = [
    _FoodItem(
      asset: 'assets/images/milk.png',
      labelKey: 'drink_milk',
      labelFallback: 'Drink milk',
    ),
    _FoodItem(
      asset: 'assets/images/fish.png',
      labelKey: 'eat_protein_rich_food',
      labelFallback: 'Eat protein\nrich food',
    ),
    _FoodItem(
      asset: 'assets/images/brocoli.png',
      labelKey: 'increase_intake_of_vegetables',
      labelFallback: 'Increase intake\nof vegetables',
    ),
    _FoodItem(
      asset: 'assets/images/strawberry.png',
      labelKey: 'include_fruits_in_your_diet',
      labelFallback: 'Include fruits in\nyour diet',
    ),
    _FoodItem(
      asset: 'assets/images/nuts.png',
      labelKey: 'have_plenty_of_nuts',
      labelFallback: 'Have a plenty\namount of nuts',
    ),
  ];

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  String _label(int index) {
    final item = _items[index];
    if (widget.language == 'اردو') {
      return LanguageStrings.getTranslation(widget.language, item.labelKey);
    }
    return item.labelFallback;
  }

  Widget _buildItem(int index, {double circleDiameter = 104}) {
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
              _label(index),
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
    final howToPrevent =
        LanguageStrings.getTranslation(widget.language, 'how_to_prevent_title');

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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Center(child: _buildItem(0, circleDiameter: 112)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_buildItem(1), _buildItem(2)],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [_buildItem(3), _buildItem(4)],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            howToPrevent,
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
              ),

              const SizedBox(height: 8),

              OnboardingPageIndicator(currentPage: 8, totalPages: 10),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: OnboardingNavigationButtons(
                  // Back button goes to page 8
                  onBackPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => OnboardingPage8(language: widget.language),
                      ),
                    );
                  },
                  // Next button goes to page 10
                  onNextPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => OnboardingPage10(language: widget.language),
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
  }
}