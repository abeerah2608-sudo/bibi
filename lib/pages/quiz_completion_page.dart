import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../services/quiz_service.dart';
import 'package:bibi/pages/dashboard.dart';
import 'package:bibi/pages/quiz_page_1.dart';


class QuizCompletionPage extends StatelessWidget {
  final int quizId;
  final int completedQuestions;
  final int totalQuestions;

  const QuizCompletionPage({
    super.key,
    required this.quizId,
    required this.completedQuestions,
    required this.totalQuestions,
  });

void _goToDashboard(BuildContext context) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const DashboardScreen()),
    (route) => false,
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

        final percentage =
            ((completedQuestions / totalQuestions) * 100).toStringAsFixed(0);
        final isPerfect = completedQuestions == totalQuestions;

        return Scaffold(
          backgroundColor: const Color(0xFFFCEEF3),
          body: Stack(
            children: [
              // ── Top pink curved panel
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: _CurvedBottomClipper(),
                  child: Container(
                    height: 230,
                    color: const Color(0xFFFFA6BD),
                  ),
                ),
              ),

              // ── Back arrow
              Positioned(
                top: 48,
                left: 20,
                child: GestureDetector(
                  onTap: () => _goToDashboard(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),

              // ── Main content
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),

                      // ── Floating completion circle + white card
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 56),
                            padding: const EdgeInsets.fromLTRB(28, 64, 28, 28),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFA6BD).withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StatRow(
                                  label: 'Completion',
                                  value: '$percentage%',
                                ),
                                const SizedBox(height: 16),
                                const Divider(
                                  color: Color(0xFFF5DCE5),
                                  thickness: 1,
                                ),
                                const SizedBox(height: 16),
                                _StatRow(
                                  label: 'Total Question',
                                  value: totalQuestions.toString().padLeft(2, '0'),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0,
                            child: _CompletionCircle(
                              percentage: percentage,
                              size: 104,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      Text(
                        isPerfect
                            ? 'Consult a doctor or a\nhealth worker!'
                            : 'Keep learning to\nstay informed!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF5D3A3A),
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 32),

                      Center(child: _GiftIcon(size: 110)),

                      const SizedBox(height: 40),

                      // ── Retake button
                     ElevatedButton(
  onPressed: () async {
    await QuizService.resetQuizProgress(quizId);
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const QuizPage1()),
        (route) => false,
      );
    }
  },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE86A8D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 4,
                          shadowColor: const Color(0xFFE86A8D).withOpacity(0.4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.refresh, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Retake Quiz',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Back to dashboard button
                      OutlinedButton(
                        onPressed: () => _goToDashboard(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          side: const BorderSide(
                            color: Color(0xFFE86A8D),
                            width: 2,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.home, color: Color(0xFFE86A8D), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Back to Dashboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE86A8D),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Floating completion circle ────────────────────────────────────────────────

class _CompletionCircle extends StatelessWidget {
  final String percentage;
  final double size;

  const _CompletionCircle({required this.percentage, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFA6BD).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Completion',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB07A8A),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                percentage,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF5D3A3A),
                  height: 1.1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  '%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF5D3A3A),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Bullet stat row ───────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFE86A8D),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF5D3A3A),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFB07A8A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Gift icon ─────────────────────────────────────────────────────────────────

class _GiftIcon extends StatelessWidget {
  final double size;
  const _GiftIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GiftPainter()),
    );
  }
}

class _GiftPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink = Paint()..color = const Color(0xFFF0A8C7);
    final w = size.width;
    final h = size.height;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.42, w * 0.8, h * 0.5),
        const Radius.circular(8),
      ),
      pink,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.06, h * 0.32, w * 0.88, h * 0.14),
        const Radius.circular(6),
      ),
      pink,
    );

    final ribbonV = Paint()
      ..color = const Color(0xFF8B5E3C)
      ..strokeWidth = w * 0.07;
    canvas.drawLine(Offset(w * 0.5, h * 0.32), Offset(w * 0.5, h * 0.92), ribbonV);
    canvas.drawLine(Offset(w * 0.1, h * 0.46), Offset(w * 0.9, h * 0.46), ribbonV);

    final bowPaint = Paint()
      ..color = const Color(0xFF8B5E3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.30)
        ..cubicTo(w * 0.35, h * 0.10, w * 0.10, h * 0.14, w * 0.25, h * 0.28)
        ..cubicTo(w * 0.32, h * 0.34, w * 0.5, h * 0.30, w * 0.5, h * 0.30),
      bowPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.30)
        ..cubicTo(w * 0.65, h * 0.10, w * 0.90, h * 0.14, w * 0.75, h * 0.28)
        ..cubicTo(w * 0.68, h * 0.34, w * 0.5, h * 0.30, w * 0.5, h * 0.30),
      bowPaint,
    );
  }

  @override
  bool shouldRepaint(_GiftPainter old) => false;
}

// ── Curved-bottom clipper ─────────────────────────────────────────────────────

class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 36);
    path.quadraticBezierTo(
      size.width / 2, size.height + 18,
      0, size.height - 36,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_CurvedBottomClipper old) => false;
}