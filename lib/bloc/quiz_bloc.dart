import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quiz_models.dart';
import '../services/language_strings.dart';
import 'package:equatable/equatable.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

// ────────────────────────────────────────────────────────────────────────────
// BLOC
// ────────────────────────────────────────────────────────────────────────────

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final FirebaseFirestore _firestore;

  QuizBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const QuizInitial()) {
    on<FetchQuizConfigEvent>(_onFetchQuizConfig);
    on<FetchQuizCompletionConfigEvent>(_onFetchQuizCompletionConfig);
  }

  Future<Map<String, dynamic>?> _resolveConfigData({
    required String preferredDocId,
    required String sectionKey,
    required String expectedConfigId,
  }) async {
    const collectionsToCheck = ['app_config', 'json_documents'];

    // 1) Prefer direct lookups first (e.g., app_config/quiz)
    for (final collection in collectionsToCheck) {
      final directSnapshot = await _firestore
          .collection(collection)
          .doc(preferredDocId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Firestore query timeout after 10 seconds'),
          );

      if (directSnapshot.exists) {
        final directData = directSnapshot.data();
        if (directData != null) {
          debugPrint('✅ QuizBloc: Found direct config at $collection/$preferredDocId');
          return directData;
        }
      }
    }

    // 2) Fallback: scan both collections for nested section or matching id
    for (final collection in collectionsToCheck) {
      final allDocs = await _firestore
          .collection(collection)
          .limit(50)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Firestore query timeout after 10 seconds'),
          );

      for (final doc in allDocs.docs) {
        final data = doc.data();

        if (data.containsKey(sectionKey) && data[sectionKey] is Map<String, dynamic>) {
          debugPrint('✅ QuizBloc: Found $sectionKey inside $collection/${doc.id}');
          return data;
        }

        final id = data['id'];
        if (id is String && id == expectedConfigId) {
          debugPrint('✅ QuizBloc: Found $expectedConfigId at $collection/${doc.id}');
          return data;
        }
      }
    }

    return null;
  }

  /// Fetch questions from the flat questions collection
  Future<List<QuestionData>> _fetchQuestions(String configCollection, String configDocId) async {
    try {
      debugPrint('📱 QuizBloc: Fetching questions collection...');

      final questionsSnapshot = await _firestore
          .collection(configCollection)
          .doc(configDocId)
          .collection('questions')
          .orderBy('number')
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw Exception('Questions fetch timeout after 15 seconds'),
          );

      if (questionsSnapshot.docs.isEmpty) {
        debugPrint('⚠️ No questions found in questions collection');
        return [];
      }

      debugPrint('📚 Found ${questionsSnapshot.docs.length} questions');

      final questions = <QuestionData>[];

      for (final questionDoc in questionsSnapshot.docs) {
        final questionData = questionDoc.data();
        debugPrint('   Processing question: ${questionDoc.id}');

        final questionTranslationsRaw = questionData['translations'];
        final questionTextRaw = questionData['questionText'];
        final questionTranslations = _normalizeTranslationMap(
          questionTranslationsRaw is Map<String, dynamic>
              ? questionTranslationsRaw
              : questionTextRaw is Map<String, dynamic>
                  ? questionTextRaw
                  : const <String, dynamic>{},
        );

        final optionsRaw = questionData['options'];
        final options = <AnswerOption>[];
        if (optionsRaw is List) {
          for (final optionEntry in optionsRaw) {
            if (optionEntry is! Map<String, dynamic>) {
              continue;
            }

            final translationsRaw = optionEntry['translations'];
            options.add(AnswerOption(
              label: optionEntry['label']?.toString() ?? '',
              translations: _normalizeTranslationMap(
                translationsRaw is Map<String, dynamic>
                    ? translationsRaw
                    : const <String, dynamic>{},
              ),
            ));
          }
        }

        options.sort((a, b) => a.label.compareTo(b.label));
        debugPrint('      Options loaded: ${options.map((o) => o.label).join(", ")}');

        final explanationsRaw = questionData['explanation'] ?? questionData['explanations'];
        final explanations = _normalizeTranslationMap(
          explanationsRaw is Map<String, dynamic>
              ? explanationsRaw
              : const <String, dynamic>{},
        );

        debugPrint('      Explanations loaded: ${explanations.keys.join(", ")}');

        questions.add(QuestionData(
          number: questionData['number'] ?? 0,
          textKey: questionData['textKey']?.toString() ?? '',
          correctOption: questionData['correctOption']?.toString() ?? '',
          translations: questionTranslations,
          options: options,
          explanation: explanations,
        ));
      }

      debugPrint('✅ Successfully loaded ${questions.length} questions');
      return questions;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching questions: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  Map<String, String> _normalizeTranslationMap(Map<String, dynamic> raw) {
    final translations = <String, String>{};

    for (final entry in raw.entries) {
      final key = entry.key.toString();
      final normalizedKey = switch (key) {
        'english' => 'English',
        'English' => 'English',
        'urdu' => 'Urdu',
        'Urdu' => 'Urdu',
        'roman_urdu' => 'Roman Urdu',
        'Roman Urdu' => 'Roman Urdu',
        _ => key,
      };

      translations[normalizedKey] = entry.value?.toString() ?? '';
    }

    return translations;
  }

  Future<void> _onFetchQuizConfig(
    FetchQuizConfigEvent event,
    Emitter<QuizState> emit,
  ) async {
    try {
      debugPrint('📱 QuizBloc: Fetching quiz config from Firebase...');
      emit(const QuizLoading());

      // First, find the config document
      const collectionsToCheck = ['app_config', 'json_documents'];
      Map<String, dynamic>? configData;
      String? foundCollection;
      String? foundDocId;

      // Try direct lookup first
      for (final collection in collectionsToCheck) {
        final directSnapshot = await _firestore
            .collection(collection)
            .doc('quiz')
            .get()
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => throw Exception('Firestore query timeout after 10 seconds'),
            );

        if (directSnapshot.exists) {
          configData = directSnapshot.data();
          foundCollection = collection;
          foundDocId = 'quiz';
          debugPrint('✅ QuizBloc: Found direct config at $collection/quiz');
          break;
        }
      }

      // Fallback to scanning
      if (configData == null) {
        configData = await _resolveConfigData(
          preferredDocId: 'quiz',
          sectionKey: 'quiz',
          expectedConfigId: 'quiz_page',
        );
        
        if (configData != null) {
          foundCollection = 'app_config';
          foundDocId = 'quiz';
        }
      }

      if (configData == null) {
        emit(const QuizError(
          'Quiz configuration not found. Expected app_config/quiz (preferred) or json_documents/quiz, or a document containing a top-level "quiz" object.',
        ));
        return;
      }

      // Fetch questions from subcollection
      List<QuestionData> questions = [];
      if (foundCollection != null && foundDocId != null) {
        questions = await _fetchQuestions(foundCollection, foundDocId);
      }

      // Merge questions into configData before parsing
      if (questions.isNotEmpty) {
        configData['totalQuestions'] = questions.length;
      }
      configData['questions'] = questions.map((q) => {
        'number': q.number,
        'textKey': q.textKey,
        'translations': q.translations,
        'options': q.options.map((o) => {'label': o.label, 'translations': o.translations}).toList(),
        'correctOption': q.correctOption ?? '',
        'explanation': q.explanation,
      }).toList();
      
      final config = QuizConfig.fromJson(configData);

      debugPrint('✅ Quiz config parsed successfully');
      debugPrint('   - Quiz ID: ${config.quizId}');
      debugPrint('   - Total questions: ${config.totalQuestions}');
      debugPrint('   - Questions loaded: ${config.questions.length}');
      debugPrint('   - Background: ${config.backgroundColor}');

      if (questions.isEmpty) {
        debugPrint('⚠️ Warning: No questions loaded from subcollection!');
      }

      emit(QuizLoaded(config));
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching quiz config: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(QuizError('Failed to load quiz: ${e.toString()}'));
    }
  }

  Future<void> _onFetchQuizCompletionConfig(
    FetchQuizCompletionConfigEvent event,
    Emitter<QuizState> emit,
  ) async {
    try {
      debugPrint('📱 QuizBloc: Fetching quiz completion config from Firebase...');
      emit(const QuizCompletionLoading());

      final data = await _resolveConfigData(
        preferredDocId: 'quiz_completion',
        sectionKey: 'quiz_completion',
        expectedConfigId: 'quiz_completion_page',
      );

      if (data == null) {
        emit(const QuizCompletionError(
          'Quiz completion configuration not found. Expected app_config/quiz_completion (preferred) or json_documents/quiz_completion, or a document containing a top-level "quiz_completion" object.',
        ));
        return;
      }

      final config = QuizCompletionConfig.fromJson(data);

      debugPrint('✅ Quiz completion config parsed successfully');
      debugPrint('   - Background: ${config.backgroundColor}');
      debugPrint('   - Completion circle size: ${config.completionCircle.size}');

      emit(QuizCompletionLoaded(config));
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching quiz completion config: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(QuizCompletionError('Failed to load quiz completion: ${e.toString()}'));
    }
  }
}