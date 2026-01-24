import 'package:equatable/equatable.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class SelectLanguageEvent extends LanguageEvent {
  final String language;

  const SelectLanguageEvent(this.language);

  @override
  List<Object> get props => [language];
}

class ResetLanguageEvent extends LanguageEvent {
  const ResetLanguageEvent();
}
