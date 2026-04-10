import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../widgets/onboarding_widgets_exports.dart';
import '../services/language_strings.dart';
import 'onboarding_page_7.dart';
import 'onboarding_page_9.dart';
import '../mixins/onboarding_audio_mixin.dart';

class OnboardingPage8 extends StatefulWidget {
  const OnboardingPage8({super.key});

  @override
  State<OnboardingPage8> createState() => _OnboardingPage8State();
}

class _OnboardingPage8State extends State<OnboardingPage8>
    with TickerProviderStateMixin, OnboardingAudioMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<AnimationController> _itemControllers = [];
  final List<Animation<double>> _itemAnimations = [];

  static const _staggerDelay = Duration(milliseconds: 350);
  static const _itemDuration = Duration(milliseconds: 500);

  @override
  String get englishAudioPath => 'assets/audio/onboarding_11.mp3';

  @override
  String get urduAudioPath => 'assets/audio/onboarding_11_urdu.mp3';

  @override
  void initState() {
    super.initState();

    // Init audio via mixin
    initAudio(
    );

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    for (final c in _itemControllers) {
      c.dispose();
    }
    disposeAudio(); // Clean up mixin audio
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
          onLanguageChanged(currentLanguage); // handled by mixin
        }

        final howToTreat =
            LanguageStrings.getTranslation(currentLanguage, 'how_to_treat_title');
        final labels = [
          LanguageStrings.getTranslation(currentLanguage, 'radiation'),
          LanguageStrings.getTranslation(currentLanguage, 'chemotherapy'),
          LanguageStrings.getTranslation(currentLanguage, 'hormonal_tablets'),
          LanguageStrings.getTranslation(currentLanguage, 'surgery'),
        ];

        return Scaffold(
          body: SafeArea(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: const Color(0xFFFFF4F4),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Image.asset('assets/images/Bibi_Logo_Vector 1.png',
                      height: 72, width: 72),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final h = constraints.maxHeight;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: Image.asset('assets/images/bibi1.png',
                                      fit: BoxFit.contain),
                                ),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          const Color(0xFFFFF4F4)
                                              .withOpacity(0.3),
                                          const Color(0xFFFFF4F4)
                                              .withOpacity(0.8),
                                        ],
                                        stops: const [0.0, 0.6, 1.0],
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
                                          color: const Color(0xFF8B5E3C)
                                              .withOpacity(0.6),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                // Labels
                                Positioned(
                                  top: h * 0.10,
                                  left: 0,
                                  child: FadeTransition(
                                    opacity: _itemAnimations[0],
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(-0.3, 0),
                                        end: Offset.zero,
                                      ).animate(_itemAnimations[0]),
                                      child: _buildBareLabel(labels[0]),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: h * 0.10,
                                  right: 0,
                                  child: FadeTransition(
                                    opacity: _itemAnimations[1],
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.3, 0),
                                        end: Offset.zero,
                                      ).animate(_itemAnimations[1]),
                                      child: _buildBareLabel(labels[1]),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 30,
                                  left: 4,
                                  child: FadeTransition(
                                    opacity: _itemAnimations[2],
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(-0.3, 0),
                                        end: Offset.zero,
                                      ).animate(_itemAnimations[2]),
                                      child: _buildBareLabel(labels[2]),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 30,
                                  right: 20,
                                  child: FadeTransition(
                                    opacity: _itemAnimations[3],
                                    child: SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(0.3, 0),
                                        end: Offset.zero,
                                      ).animate(_itemAnimations[3]),
                                      child: _buildBareLabel(labels[3]),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.center,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          howToTreat,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF8B5E3C),
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OnboardingNavigationButtons(
                      onBackPressed: () {
                        stopAudio();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const OnboardingPage7()),
                        );
                      },
                      onNextPressed: () {
                        stopAudio();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const OnboardingPage9()),
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

  Widget _buildBareLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Color(0xFF8B5E3C),
        letterSpacing: 0.1,
      ),
    );
  }
}

// ArrowPainter and _ArrowDef remain exactly as your original code
// ── Bezier arrow painter with staggered draw-on effect ────────────────────────
class _ArrowPainter extends CustomPainter {
  final List<double> progresses;
  final Color color;

  const _ArrowPainter({required this.progresses, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progresses.length < 4) return;

    final w = size.width;
    final h = size.height;

    // Each arrow: from label toward the figure
    // top-left curves inward toward left shoulder
    // top-right curves inward toward right shoulder
    // bottom-left curves inward toward left hip
    // bottom-right curves inward toward right hip
    final arrows = [
      // Radiation top-left — ends just outside figure, not touching it
      _ArrowDef(
        start: Offset(w * 0.20, h * 0.14),
        end: Offset(w * 0.30, h * 0.20),
        control: Offset(w * 0.21, h * 0.18),
      ),
      // Chemotherapy top-right
      _ArrowDef(
        start: Offset(w * 0.80, h * 0.14),
        end: Offset(w * 0.70, h * 0.20),
        control: Offset(w * 0.79, h * 0.18),
      ),
      // Hormonal Tablets bottom-left — same inward direction, stops before figure
      _ArrowDef(
        start: Offset(w * 0.12, h * 0.84),
        end: Offset(w * 0.22, h * 0.76),
        control: Offset(w * 0.22, h * 0.79),
      ),
      // Surgery bottom-right — same inward direction, stops before figure
      _ArrowDef(
        start: Offset(w * 0.88, h * 0.84),
        end: Offset(w * 0.78, h * 0.76),
        control: Offset(w * 0.78, h * 0.79),
      ),
    ];

    for (int i = 0; i < arrows.length; i++) {
      final progress = progresses[i].clamp(0.0, 1.0);
      if (progress <= 0) continue;

      final paint = Paint()
        ..color = color.withOpacity((progress * 0.8).clamp(0.0, 0.8))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..strokeCap = StrokeCap.round;

      _drawCurvedArrow(
          canvas, paint, arrows[i].start, arrows[i].end, arrows[i].control, progress);
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
        ..strokeWidth = 1.0
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