import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../services/language_strings.dart';
import '../services/quiz_service.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        String currentLanguage = 'English';
        if (state is LanguageSelected) {
          currentLanguage = state.language;
        }

        final isUrdu = currentLanguage == 'اردو';
        final percentage = ((completedQuestions / totalQuestions) * 100).toStringAsFixed(0);
        final isPerfect = completedQuestions == totalQuestions;

        return Scaffold(
          backgroundColor: const Color(0xFFFCEEF3),
          body: Stack(
            children: [
              // ── Top pink panel
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

              // ── Main content
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 56),

                      // ── Completion card
                      Container(
                        padding: const EdgeInsets.all(32),
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
                          children: [
                            // ── Congratulations icon
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isPerfect
                                    ? const Color(0xFFFFD700)
                                    : const Color(0xFFF0A8C7),
                              ),
                              child: Icon(
                                isPerfect ? Icons.star : Icons.done_all,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Title
                            Text(
                              isPerfect ? '🎉 Perfect!' : '✨ Great Job!',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5D3A3A),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Results summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCEEF3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            'Completed',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: const Color(0xFF9A7070),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$completedQuestions/$totalQuestions',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFE86A8D),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            'Score',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: const Color(0xFF9A7070),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '$percentage%',
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFE86A8D),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // ── Progress bar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: completedQuestions / totalQuestions,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFE8C5D5),
                                      valueColor: const AlwaysStoppedAnimation<Color>(
                                        Color(0xFFE86A8D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // ── Encouragement message
                            Text(
                              isPerfect
                                  ? 'You answered all questions correctly!'
                                  : 'You can retake the quiz to improve your score.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9A7070),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // ── Action buttons
                      Column(
                        children: [
                          // Retake button
                          ElevatedButton(
                            onPressed: () async {
                              await QuizService.resetQuizProgress(quizId);
                              if (context.mounted) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE86A8D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFFE86A8D).withOpacity(0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
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

                          // Back to dashboard button
                          OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              side: const BorderSide(
                                color: Color(0xFFE86A8D),
                                width: 2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.home,
                                  color: Color(0xFFE86A8D),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
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
