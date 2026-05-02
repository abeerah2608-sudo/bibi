import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/bloc_exports.dart';
import '../models/quiz_models.dart';
import '../services/language_strings.dart';
import '../services/quiz_service.dart';
import 'quiz_completion_page.dart';
import 'package:bibi/pages/dashboard.dart';

// ────────────────────────────────────────────────────────────────────────────
// UTILITY FUNCTIONS
// ────────────────────────────────────────────────────────────────────────────

Color _parseHexColor(String hexColor) {
  hexColor = hexColor.replaceAll('#', '');
  if (hexColor.length == 8) {
    return Color(int.parse('0x$hexColor'));
  }
  return Color(int.parse('0xff$hexColor'));
}

class QuizPage1 extends StatefulWidget {
  const QuizPage1({super.key});

  @override
  State<QuizPage1> createState() => _QuizPage1State();
}

class _QuizPage1State extends State<QuizPage1> {
  int _currentQuestion = 0;
  String? _selectedAnswer;
  List<String?> _allAnswers = <String?>[];
  static const int _quizId = 1;
  int _syncedQuestionCount = 0;

  String _normalizeLanguageKey(String language) {
    if (language == 'اردو' || language == 'Urdu' || language.toLowerCase() == 'urdu') {
      return 'Urdu';
    }
    if (language == 'Roman Urdu') {
      return 'Roman Urdu';
    }
    return 'English';
  }

  String _localizedText(
    Map<String, String> translations,
    String language, {
    String fallbackKey = 'English',
  }) {
    final normalizedLanguage = _normalizeLanguageKey(language);
    return translations[normalizedLanguage] ??
        translations[fallbackKey] ??
        (translations.isNotEmpty ? translations.values.first : '') ??
        '';
  }

  List<String?> _resizeAnswers(List<String?> answers, int totalQuestions) {
    final resized = List<String?>.filled(totalQuestions, null);
    for (var i = 0; i < math.min(answers.length, totalQuestions); i++) {
      resized[i] = answers[i];
    }
    return resized;
  }

  int _correctAnswersCount(QuizConfig config) {
    var count = 0;
    for (var i = 0; i < math.min(_allAnswers.length, config.questions.length); i++) {
      final selected = _allAnswers[i];
      final correct = config.questions[i].correctOption;
      if (selected != null && selected == correct) {
        count++;
      }
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    context.read<QuizBloc>().add(const FetchQuizConfigEvent());
    _initializeProgress();
  }

  Future<void> _initializeProgress() async {
    // Initialize quiz progress tracking in local storage
    await QuizService.initializeQuizProgress(_quizId, 5);

    final progress = await QuizService.getQuizProgress(_quizId);
    if (progress != null && mounted) {
      setState(() {
        _currentQuestion = progress.currentQuestion;
        _allAnswers = progress.answers;
        _selectedAnswer = _allAnswers[_currentQuestion];
      });
    } else {
      setState(() {
        _allAnswers = List<String?>.filled(5, null);
      });
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

  void _nextQuestion(int totalQuestions) async {
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
    await QuizService.saveAnswer(
      _quizId,
      _currentQuestion,
      _selectedAnswer!,
    );

    if (_currentQuestion < totalQuestions - 1) {
      await QuizService.updateCurrentQuestion(_quizId, _currentQuestion + 1);

      setState(() {
        _currentQuestion++;
        _selectedAnswer = _allAnswers[_currentQuestion];
      });
    } else {
      await QuizService.completeQuiz(_quizId);

      final completedCount = _allAnswers.where((a) => a != null).length;
      final correctCount = context.read<QuizBloc>().state is QuizLoaded
          ? _correctAnswersCount((context.read<QuizBloc>().state as QuizLoaded).config)
          : completedCount;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizCompletionPage(
              quizId: _quizId,
              completedQuestions: completedCount,
              totalQuestions: totalQuestions,
              correctAnswers: correctCount,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizBloc, QuizState>(
      builder: (context, quizState) {
        // Handle quiz config loading states
        if (quizState is QuizLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFFFCEEF3),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE86A8D),
              ),
            ),
          );
        }

        if (quizState is QuizError) {
          return Scaffold(
            backgroundColor: const Color(0xFFFCEEF3),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Color(0xFFE86A8D),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    quizState.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (quizState is! QuizLoaded) {
          return const Scaffold(
            backgroundColor: Color(0xFFFCEEF3),
            body: Center(
              child: Text('No quiz data available'),
            ),
          );
        }

        final config = quizState.config;

        if (_syncedQuestionCount != config.questions.length) {
          _syncedQuestionCount = config.questions.length;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await QuizService.initializeQuizProgress(_quizId, config.questions.length);
            final progress = await QuizService.getQuizProgress(_quizId);
            if (!mounted || progress == null) {
              return;
            }

            final resizedAnswers = _resizeAnswers(progress.answers, config.questions.length);
            if (!mounted) {
              return;
            }

            setState(() {
              _allAnswers = resizedAnswers;
              if (_currentQuestion >= config.questions.length) {
                _currentQuestion = 0;
              }
              _selectedAnswer = _allAnswers[_currentQuestion];
            });
          });
        }

        return BlocBuilder<LanguageBloc, LanguageState>(
          builder: (context, langState) {
            String currentLanguage = 'English';
            if (langState is LanguageSelected) {
              currentLanguage = langState.language;
            }

            final normalizedLanguage = _normalizeLanguageKey(currentLanguage);

            // Ensure allAnswers is initialized
            if (_allAnswers.isEmpty) {
              _allAnswers = List<String?>.filled(config.questions.length, null);
            }

            if (_currentQuestion >= config.questions.length) {
              _currentQuestion = 0;
            }

            final question = config.questions[_currentQuestion];
            final questionText = _localizedText(
              question.translations,
              normalizedLanguage,
            );
            final explanationText = _localizedText(
              question.explanation,
              normalizedLanguage,
            );

            return Scaffold(
              backgroundColor: _parseHexColor(config.backgroundColor),
              body: Stack(
                children: [
                  // TOP HEADER
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipPath(
                      clipper: _CurvedBottomClipper(),
                      child: SizedBox(
                        height: config.topHeaderConfig.height.h,
                        child: Stack(
                          children: [
                            Container(
                              color: _parseHexColor(
                                  config.topHeaderConfig.backgroundColor),
                            ),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _ConfigurableBubblePainter(
                                  bubbles: config.topHeaderConfig.bubbles,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // BACK BUTTON
                  Positioned(
                    top: config.backButton.top.h,
                    left: config.backButton.left.w,
                    child: GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DashboardScreen()),
                        (route) => false,
                      ),
                      child: Container(
                        width: config.backButton.size.r,
                        height: config.backButton.size.r,
                        decoration: BoxDecoration(
                          color:
                              _parseHexColor(config.backButton.backgroundColor),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: _parseHexColor(config.backButton.iconColor),
                          size: config.backButton.iconSize.r,
                        ),
                      ),
                    ),
                  ),

                  // MAIN CONTENT
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: config.questionCard.horizontalPadding.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 56.h),

                          // QUESTION CARD
                          Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: config.questionCard.topMargin.h),
                                padding: EdgeInsets.fromLTRB(
                                  config.questionCard.horizontalPadding.w,
                                  config.questionCard.topPadding.h,
                                  config.questionCard.horizontalPadding.w,
                                  config.questionCard.bottomPadding.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _parseHexColor(
                                      config.questionCard.backgroundColor),
                                  borderRadius: BorderRadius.circular(
                                      config.questionCard.borderRadius.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _parseHexColor(
                                              config.questionCard.shadowColor)
                                          .withOpacity(0.25),
                                      blurRadius: config
                                          .questionCard.shadowBlurRadius.r,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${config.questionText.numberPrefix}${question.number}${config.questionText.numberSuffix}',
                                      style: TextStyle(
                                        color: _parseHexColor(
                                            config.questionText.numberColor),
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            config.questionText.numberFontSize.sp,
                                      ),
                                    ),
                                    SizedBox(
                                        height: config.questionText.spacing.h),
                                    Text(
                                      questionText,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: config
                                            .questionText.questionFontSize.sp,
                                        color: _parseHexColor(
                                            config.questionText.questionColor),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                top: 0,
                                child: _ProgressCircle(
                                  current: question.number,
                                  total: config.totalQuestions,
                                  label: question.number
                                      .toString()
                                      .padLeft(2, '0'),
                                  size: config.progressCircle.size.r,
                                  config: config.progressCircle,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: config.answerButtons.spacing.h * 2),

                          // ANSWER OPTIONS
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (final option in question.options)
                                    Column(
                                      children: [
                                        _AnswerButton(
                                          label: option.label,
                                          text: _localizedText(
                                            option.translations,
                                            normalizedLanguage,
                                            fallbackKey: 'English',
                                          ),
                                          isSelected: _selectedAnswer == option.label,
                                          isCorrectAnswer:
                                              option.label == question.correctOption,
                                          showResult: _selectedAnswer != null,
                                          onPressed: () => setState(() =>
                                              _selectedAnswer = option.label),
                                          config: config.answerButtons,
                                        ),
                                        if (option != question.options.last)
                                          SizedBox(
                                              height: config
                                                  .answerButtons.spacing.h),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),

                          if (_selectedAnswer != null) ...[
                            SizedBox(height: 16.h),
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: _parseHexColor(config.questionCard.backgroundColor),
                                borderRadius: BorderRadius.circular(18.r),
                                border: Border.all(
                                  color: _selectedAnswer == question.correctOption
                                      ? const Color(0xFF2EAE63)
                                      : const Color(0xFFE86A8D),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        _selectedAnswer == question.correctOption
                                            ? Icons.check_circle
                                            : Icons.info_outline,
                                        color: _selectedAnswer == question.correctOption
                                            ? const Color(0xFF2EAE63)
                                            : const Color(0xFFE86A8D),
                                        size: 18.sp,
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        _selectedAnswer == question.correctOption
                                            ? 'Correct answer'
                                            : 'Correct option',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF5D3A3A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    '${question.correctOption} - ${_localizedText(
                                      question.options.firstWhere(
                                        (option) => option.label == question.correctOption,
                                        orElse: () => question.options.first,
                                      ).translations,
                                      normalizedLanguage,
                                    )}',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFF5D3A3A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (explanationText.isNotEmpty) ...[
                                    SizedBox(height: 10.h),
                                    Text(
                                      explanationText,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: const Color(0xFF5D3A3A),
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: 16.h),

                          // NAVIGATION BUTTONS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_currentQuestion > 0)
                                ElevatedButton(
                                  onPressed: _previousQuestion,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _parseHexColor(config
                                        .navigationButtons.backgroundColor),
                                    foregroundColor: _parseHexColor(config
                                        .navigationButtons.foregroundColor),
                                    minimumSize: Size(56.w, 44.h),
                                  ),
                                  child: Icon(Icons.arrow_back,
                                      size: config.navigationButtons.iconSize.r),
                                )
                              else
                                SizedBox(width: 56.w),

                              ElevatedButton(
                                onPressed: () =>
                                    _nextQuestion(config.totalQuestions),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _parseHexColor(config
                                      .navigationButtons.backgroundColor),
                                  foregroundColor: _parseHexColor(config
                                      .navigationButtons.foregroundColor),
                                  minimumSize: Size(56.w, 44.h),
                                ),
                                child: Icon(Icons.arrow_forward,
                                    size: config.navigationButtons.iconSize.r),
                              ),
                            ],
                          ),

                          SizedBox(height: 28.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Progress circle widget (with config) ──────────────────────────────────────

class _ProgressCircle extends StatelessWidget {
  final int current;
  final int total;
  final String label;
  final double size;
  final ProgressCircleConfig config;

  const _ProgressCircle({
    required this.current,
    required this.total,
    required this.label,
    required this.size,
    required this.config,
  });

  Color _parseHexColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor'));
    }
    return Color(int.parse('0xff$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _parseHexColor(config.labelColor).withOpacity(0.1),
      ),
      child: CustomPaint(
        painter: _ArcPainter(
          progress: current / total,
          trackColor: _parseHexColor(config.trackColor),
          arcColor: _parseHexColor(config.arcColor),
          strokeWidth: config.strokeWidth,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: config.labelFontSize.sp,
              fontWeight: FontWeight.bold,
              color: _parseHexColor(config.labelColor),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Arc painter ─────────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
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

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress;
}

// ── Curved-bottom clipper ──────────────────────────────────────────────────────

class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 36);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 18,
      0,
      size.height - 36,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_CurvedBottomClipper old) => false;
}

// ── Answer button (with config) ────────────────────────────────────────────────

class _AnswerButton extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool showResult;
  final VoidCallback onPressed;
  final AnswerButtonsConfig config;

  const _AnswerButton({
    required this.label,
    required this.text,
    required this.isSelected,
    required this.isCorrectAnswer,
    required this.showResult,
    required this.onPressed,
    required this.config,
  });

  Color _parseHexColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor'));
    }
    return Color(int.parse('0xff$hexColor'));
  }

  @override
  Widget build(BuildContext context) {
    final isWrongSelection = showResult && isSelected && !isCorrectAnswer;
    final isRevealedCorrect = showResult && isCorrectAnswer;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: config.horizontalPadding.w,
          vertical: config.verticalPadding.h,
        ),
        decoration: BoxDecoration(
          color: isRevealedCorrect
              ? const Color(0xFFEAF8EF)
              : isWrongSelection
                  ? const Color(0xFFFDECEF)
                  : isSelected
              ? _parseHexColor(config.selectedBackgroundColor)
              : _parseHexColor(config.unselectedBackgroundColor),
          borderRadius: BorderRadius.circular(config.borderRadius.r),
          border: Border.all(
            color: isRevealedCorrect
                ? const Color(0xFF2EAE63)
                : isWrongSelection
                    ? const Color(0xFFE86A8D)
                    : isSelected
                ? _parseHexColor(config.selectedBorderColor)
                : _parseHexColor(config.unselectedBorderColor),
            width: config.borderWidth.w,
          ),
          boxShadow: [
            BoxShadow(
              color: _parseHexColor(config.shadowColor).withOpacity(0.12),
              blurRadius: config.shadowBlurRadius.r,
              offset: Offset(
                config.shadowOffset['x'] ?? 0,
                config.shadowOffset['y'] ?? 3,
              ),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: config.labelCircleSize.r,
              height: config.labelCircleSize.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isRevealedCorrect
                    ? const Color(0xFF2EAE63)
                    : isWrongSelection
                        ? const Color(0xFFE86A8D)
                        : isSelected
                    ? _parseHexColor(config.selectedLabelBackground)
                    : _parseHexColor(config.unselectedLabelBackground),
              ),
              child: Center(
                child: isRevealedCorrect
                    ? Icon(Icons.check, size: config.labelFontSize.sp + 2, color: Colors.white)
                    : isWrongSelection
                        ? Icon(Icons.close, size: config.labelFontSize.sp + 2, color: Colors.white)
                        : Text(
                            label,
                            style: TextStyle(
                              fontSize: config.labelFontSize.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? _parseHexColor(config.selectedLabelColor)
                                  : _parseHexColor(config.unselectedLabelColor),
                            ),
                          ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: config.textFontSize.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? _parseHexColor(config.selectedTextColor)
                      : _parseHexColor(config.unselectedTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Configurable bubble painter ────────────────────────────────────────────────

class _ConfigurableBubblePainter extends CustomPainter {
  final List<BubbleConfig> bubbles;

  const _ConfigurableBubblePainter({required this.bubbles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final bubble in bubbles) {
      paint.color = Colors.white.withOpacity(bubble.opacity);
      canvas.drawCircle(
        Offset(size.width * bubble.x, size.height * bubble.y),
        bubble.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ConfigurableBubblePainter old) => false;
}