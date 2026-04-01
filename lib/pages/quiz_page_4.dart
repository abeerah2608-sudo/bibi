import 'package:flutter/material.dart';
import '../widgets/quiz_yes_no_button.dart';
import 'quiz_page_5.dart';

class QuizPage4 extends StatefulWidget {
  final String language;

  const QuizPage4({super.key, required this.language});

  @override
  State<QuizPage4> createState() => _QuizPage4State();
}

class _QuizPage4State extends State<QuizPage4> {
  String? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
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
                                    '04',
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
                                'Question 4/6',
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
                              QuizPage5(language: widget.language),
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
  }
}
