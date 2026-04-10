import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../services/quiz_service.dart';
import '../widgets/quiz_yes_no_button.dart';
import 'quiz_completion_page.dart';
import 'package:bibi/pages/dashboard.dart';

class QuizPage1 extends StatefulWidget {
  const QuizPage1({super.key});

  @override
  State<QuizPage1> createState() => _QuizPage1State();
}

class _QuizPage1State extends State<QuizPage1> {
  int _currentQuestion = 0;
  String? _selectedAnswer;
  late List<QuizQuestion> _questions;
  late List<String?> _allAnswers;
  static const int _quizId = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizProgress();
  }

  Future<void> _loadQuizProgress() async {
    _questions = [
      QuizQuestion(number: 1, textKey: 'quiz_q1'),
      QuizQuestion(number: 2, textKey: 'quiz_q2'),
      QuizQuestion(number: 3, textKey: 'quiz_q3'),
      QuizQuestion(number: 4, textKey: 'quiz_q4'),
      QuizQuestion(number: 5, textKey: 'quiz_q5'),
      QuizQuestion(number: 6, textKey: 'quiz_q6'),
    ];

    await QuizService.initializeQuizProgress(_quizId, _questions.length);

    final progress = await QuizService.getQuizProgress(_quizId);
    if (progress != null && mounted) {
      setState(() {
        _currentQuestion = progress.currentQuestion;
        _allAnswers = progress.answers;
        _selectedAnswer = _allAnswers[_currentQuestion];
        _isLoading = false;
      });
    } else {
      setState(() {
        _allAnswers = List<String?>.filled(_questions.length, null);
        _isLoading = false;
      });
    }
  }

  void _nextQuestion() async {
    if (_selectedAnswer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an option before continuing'),
          backgroundColor: Color(0xFFE86A8D),
        ),
      );
      return;
    }

    _allAnswers[_currentQuestion] = _selectedAnswer;
    await QuizService.saveAnswer(_quizId, _currentQuestion, _selectedAnswer!);

    if (_currentQuestion < _questions.length - 1) {
      await QuizService.updateCurrentQuestion(_quizId, _currentQuestion + 1);

      setState(() {
        _currentQuestion++;
        _selectedAnswer = _allAnswers[_currentQuestion];
      });
    } else {
      await QuizService.completeQuiz(_quizId);

      final completedCount =
          _allAnswers.where((a) => a != null).length;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizCompletionPage(
              quizId: _quizId,
              completedQuestions: completedCount,
              totalQuestions: _questions.length,
            ),
          ),
        );
      }
    }
  }

  void _previousQuestion() async {
    if (_currentQuestion > 0) {
      if (_selectedAnswer != null) {
        _allAnswers[_currentQuestion] = _selectedAnswer;
        await QuizService.saveAnswer(
          _quizId,
          _currentQuestion,
          _selectedAnswer!,
        );
      }

      await QuizService.updateCurrentQuestion(_quizId, _currentQuestion - 1);

      setState(() {
        _currentQuestion--;
        _selectedAnswer = _allAnswers[_currentQuestion];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';

        if (state is LanguageSelected) {
          currentLanguage = state.language;
        }

        if (_isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFFCEEF3),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE86A8D),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFCEEF3),

          body: Stack(
            children: [
              // 🔥 TOP HEADER WITH BUBBLES
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: _CurvedBottomClipper(),
                  child: SizedBox(
                    height: 230,
                    child: Stack(
                      children: [
                        Container(
                          color: const Color(0xFFFFA6BD),
                        ),

                        Positioned.fill(
                          child: CustomPaint(
                            painter: _BubblePainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // BACK BUTTON
              Positioned(
                top: 48,
                left: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DashboardScreen()),
                    (route) => false,
                  ),
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

              // MAIN CONTENT
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 56),

                      // QUESTION CARD
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 44),
                            padding: const EdgeInsets.fromLTRB(
                                28, 52, 28, 32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFA6BD)
                                      .withOpacity(0.25),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Question ${_questions[_currentQuestion].number}/6',
                                  style: const TextStyle(
                                    color: Color(0xFFE86A8D),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  LanguageStrings.getTranslation(
                                    currentLanguage,
                                    _questions[_currentQuestion].textKey,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF5D3A3A),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            top: 0,
                            child: _ProgressCircle(
                              current: _questions[_currentQuestion].number,
                              total: 6,
                              label: _questions[_currentQuestion]
                                  .number
                                  .toString()
                                  .padLeft(2, '0'),
                              size: 80,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _AnswerButton(
                        label: 'A',
                        text: 'Yes',
                        isSelected: _selectedAnswer == 'Yes',
                        onPressed: () =>
                            setState(() => _selectedAnswer = 'Yes'),
                      ),
                      const SizedBox(height: 12),
                      _AnswerButton(
                        label: 'B',
                        text: 'No',
                        isSelected: _selectedAnswer == 'No',
                        onPressed: () =>
                            setState(() => _selectedAnswer = 'No'),
                      ),

                      const Spacer(),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentQuestion > 0)
                            ElevatedButton(
                              onPressed: _previousQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFFE86A8D),
                              ),
                              child: const Icon(Icons.arrow_back),
                            )
                          else
                            const SizedBox(width: 56),

                          ElevatedButton(
                            onPressed: _nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFE86A8D),
                            ),
                            child: const Icon(Icons.arrow_forward),
                          ),
                        ],
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

// ── Progress circle widget ────────────────────────────────────────────────────

class _ProgressCircle extends StatelessWidget {
  final int current;
  final int total;
  final String label;
  final double size;

  const _ProgressCircle({
    required this.current,
    required this.total,
    required this.label,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: CustomPaint(
        painter: _ArcPainter(
          progress: current / total,
          trackColor: const Color(0xFFFFD6E5),
          arcColor: const Color(0xFFE86A8D),
          strokeWidth: 4.5,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE86A8D),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  const _ArcPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track — full circle in light pink
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc — starts at 12 o'clock, sweeps 1/6 clockwise
    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi / 2,           // 12 o'clock
      2 * math.pi * progress, // 1/6 of full circle
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ── Curved-bottom clipper ─────────────────────────────────────────────────────
// Perfectly straight vertical sides + one smooth symmetrical curve at bottom.

class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 36);
    // Single symmetric quadratic Bézier — control point sits below centre
    path.quadraticBezierTo(
      size.width / 2, size.height + 18, // control point (gentle downward bulge)
      0, size.height - 36,              // mirror end point
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_CurvedBottomClipper old) => false;
}

// ── Answer button ─────────────────────────────────────────────────────────────

class _AnswerButton extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const _AnswerButton({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCE4EC) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFE86A8D) : const Color(0xFFEECDD7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE86A8D).withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFFE86A8D)
                    : const Color(0xFFFCEEF3),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFFE86A8D),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFE86A8D)
                    : const Color(0xFF5D3A3A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class QuizQuestion {
  final int number;
  final String textKey;

  QuizQuestion({
    required this.number,
    required this.textKey,
  });
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // 🎯 SAFE-SPACED layout (manually collision-proof)
    final bubbles = [
      // top row
      _Bubble(Offset(size.width * 0.20, size.height * 0.20), 40),
      _Bubble(Offset(size.width * 0.50, size.height * 0.18), 45),
      _Bubble(Offset(size.width * 0.80, size.height * 0.22), 38),

      // bottom row
      _Bubble(Offset(size.width * 0.25, size.height * 0.55), 48),
      _Bubble(Offset(size.width * 0.70, size.height * 0.58), 42),
    ];

    // 🧠 Draw main bubbles (guaranteed no overlap by design)
    for (final b in bubbles) {
      paint.color = Colors.white.withOpacity(0.12);
      canvas.drawCircle(b.offset, b.radius, paint);
    }

    // 🌫 Edge semi-circles (kept OUTSIDE layout space)
    paint.color = Colors.white.withOpacity(0.08);

    // left edge cut bubble
    canvas.drawCircle(
      Offset(-30, size.height * 0.25),
      65,
      paint,
    );

    // right edge cut bubble
    canvas.drawCircle(
      Offset(size.width + 30, size.height * 0.40),
      70,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Bubble {
  final Offset offset;
  final double radius;

  _Bubble(this.offset, this.radius);
}