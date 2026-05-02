import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuizProgress {
  final int quizId;
  final int currentQuestion;
  final int totalQuestions;
  final List<String?> answers;
  final bool isCompleted;
  final DateTime lastAccessedTime;

  QuizProgress({
    required this.quizId,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.answers,
    required this.isCompleted,
    required this.lastAccessedTime,
  });

  int get questionsCompleted => answers.where((a) => a != null).length;

  double get progressPercentage {
    if (totalQuestions == 0) return 0;
    return (questionsCompleted / totalQuestions) * 100;
  }

  Map<String, dynamic> toJson() => {
    'quizId': quizId,
    'currentQuestion': currentQuestion,
    'totalQuestions': totalQuestions,
    'answers': answers,
    'isCompleted': isCompleted,
    'lastAccessedTime': lastAccessedTime.toIso8601String(),
  };

  factory QuizProgress.fromJson(Map<String, dynamic> json) => QuizProgress(
    quizId: json['quizId'] as int,
    currentQuestion: json['currentQuestion'] as int,
    totalQuestions: json['totalQuestions'] as int,
    answers: List<String?>.from(json['answers'] ?? []),
    isCompleted: json['isCompleted'] as bool,
    lastAccessedTime: DateTime.parse(json['lastAccessedTime'] as String),
  );
}

class QuizService {
  static const String _prefix = 'quiz_';

  static Future<void> initializeQuizProgress(int quizId, int totalQuestions) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_prefix}progress_$quizId';

    final existingData = prefs.getString(key);
    if (existingData == null) {
      final progress = QuizProgress(
        quizId: quizId,
        currentQuestion: 0,
        totalQuestions: totalQuestions,
        answers: List<String?>.filled(totalQuestions, null),
        isCompleted: false,
        lastAccessedTime: DateTime.now(),
      );

      await prefs.setString(key, jsonEncode(progress.toJson()));
      return;
    }

    final progress = QuizProgress.fromJson(jsonDecode(existingData));
    if (progress.totalQuestions == totalQuestions && progress.answers.length == totalQuestions) {
      return;
    }

    final resizedAnswers = List<String?>.filled(totalQuestions, null);
    final copyLength = progress.answers.length < totalQuestions
        ? progress.answers.length
        : totalQuestions;
    for (var i = 0; i < copyLength; i++) {
      resizedAnswers[i] = progress.answers[i];
    }

    final updated = QuizProgress(
      quizId: quizId,
      currentQuestion: progress.currentQuestion.clamp(0, totalQuestions == 0 ? 0 : totalQuestions - 1),
      totalQuestions: totalQuestions,
      answers: resizedAnswers,
      isCompleted: progress.isCompleted,
      lastAccessedTime: DateTime.now(),
    );

    await prefs.setString(key, jsonEncode(updated.toJson()));
  }

  static Future<QuizProgress?> getQuizProgress(int quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_prefix}progress_$quizId';
    final data = prefs.getString(key);

    if (data == null) return null;

    return QuizProgress.fromJson(jsonDecode(data));
  }

  static Future<void> saveAnswer(int quizId, int questionIndex, String answer) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_prefix}progress_$quizId';
    final data = prefs.getString(key);

    if (data != null) {
      final progress = QuizProgress.fromJson(jsonDecode(data));
      final updatedAnswers = List<String?>.from(progress.answers);

      if (questionIndex >= updatedAnswers.length) {
        updatedAnswers.length = questionIndex + 1;
      }

      updatedAnswers[questionIndex] = answer;

      final updated = QuizProgress(
        quizId: progress.quizId,
        currentQuestion: progress.currentQuestion,
        totalQuestions: progress.totalQuestions > updatedAnswers.length
            ? progress.totalQuestions
            : updatedAnswers.length,
        answers: updatedAnswers,
        isCompleted: progress.isCompleted,
        lastAccessedTime: DateTime.now(),
      );

      await prefs.setString(key, jsonEncode(updated.toJson()));
    }
  }

  static Future<void> updateCurrentQuestion(int quizId, int questionIndex) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_prefix}progress_$quizId';
    final data = prefs.getString(key);

    if (data != null) {
      final progress = QuizProgress.fromJson(jsonDecode(data));
      final updated = QuizProgress(
        quizId: progress.quizId,
        currentQuestion: questionIndex,
        totalQuestions: progress.totalQuestions,
        answers: progress.answers,
        isCompleted: progress.isCompleted,
        lastAccessedTime: DateTime.now(),
      );

      await prefs.setString(key, jsonEncode(updated.toJson()));
    }
  }

  static Future<void> completeQuiz(int quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_prefix}progress_$quizId';
    final data = prefs.getString(key);

    if (data != null) {
      final progress = QuizProgress.fromJson(jsonDecode(data));
      final completed = QuizProgress(
        quizId: progress.quizId,
        currentQuestion: progress.currentQuestion,
        totalQuestions: progress.totalQuestions,
        answers: progress.answers,
        isCompleted: true,
        lastAccessedTime: DateTime.now(),
      );

      await prefs.setString(key, jsonEncode(completed.toJson()));
    }
  }

  static Future<void> resetQuizProgress(int quizId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${_prefix}progress_$quizId';
    await prefs.remove(key);
  }

  static Future<List<QuizProgress>> getAllQuizProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final quizzes = <QuizProgress>[];

    for (final key in keys) {
      if (key.startsWith(_prefix) && key.contains('progress_')) {
        final data = prefs.getString(key);
        if (data != null) {
          quizzes.add(QuizProgress.fromJson(jsonDecode(data)));
        }
      }
    }

    return quizzes;
  }
}
