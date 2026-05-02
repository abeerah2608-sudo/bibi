part of 'quiz_bloc.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuizLoaded extends QuizState {
  final QuizConfig config;

  const QuizLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}

class QuizCompletionLoading extends QuizState {
  const QuizCompletionLoading();
}

class QuizCompletionLoaded extends QuizState {
  final QuizCompletionConfig config;

  const QuizCompletionLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

class QuizCompletionError extends QuizState {
  final String message;

  const QuizCompletionError(this.message);

  @override
  List<Object?> get props => [message];
}
