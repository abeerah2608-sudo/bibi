import 'package:equatable/equatable.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {
  const LanguageInitial();
}

class LanguageSelected extends LanguageState {
  final String language;

  const LanguageSelected(this.language);

  @override
  List<Object?> get props => [language];
}
