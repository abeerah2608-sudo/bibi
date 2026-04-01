import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/bloc_exports.dart';
import '../widgets/quiz_yes_no_button.dart';
import 'quiz_page_4.dart';

class QuizPage3 extends StatefulWidget {
  const QuizPage3({super.key});

  @override
  State<QuizPage3> createState() => _QuizPage3State();
}

class _QuizPage3State extends State<QuizPage3> {
  String? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5A6C2), Color(0xFFFFB6D9)],
          ),
        ),
        child: Stack(
          children: [
            // Back arrow button
            Positioned(
              top: 50,
              left: 24,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFFE86A8D),
                    size: 20,
                  ),
                ),
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Column(
                            children: [
                              // Question number circle
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFFFF4F4),
                                  border: Border.fromBorderSide(
                                    BorderSide(
                                      color: Color(0xFFE86A8D),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '03',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFE86A8D),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Question counter
                              const Text(
                                'Question 3/6',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFE86A8D),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Question text (placeholder - user will edit)
                              const Text(
                                'Question Text Here',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF8B5E3C),
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Yes button
                              QuizYesNoButton(
                                label: 'Yes',
                                isSelected: _selectedAnswer == 'Yes',
                                onPressed: () {
                                  setState(() => _selectedAnswer = 'Yes');
                                },
                              ),
                              const SizedBox(height: 12),
                              // No button
                              QuizYesNoButton(
                                label: 'No',
                                isSelected: _selectedAnswer == 'No',
                                isYes: false,
                                onPressed: () {
                                  setState(() => _selectedAnswer = 'No');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation buttons
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE86A8D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const QuizPage4(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE86A8D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}
