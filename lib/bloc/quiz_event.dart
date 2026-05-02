part of 'quiz_bloc.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class FetchQuizConfigEvent extends QuizEvent {
  const FetchQuizConfigEvent();
}

class FetchQuizCompletionConfigEvent extends QuizEvent {
  const FetchQuizCompletionConfigEvent();
}
