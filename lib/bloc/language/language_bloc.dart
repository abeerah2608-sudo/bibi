import 'package:bloc/bloc.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageInitial()) {
    on<SelectLanguageEvent>(_onSelectLanguage);
    on<ResetLanguageEvent>(_onResetLanguage);
  }

  Future<void> _onSelectLanguage(
    SelectLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageSelected(event.language));
  }

  Future<void> _onResetLanguage(
    ResetLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(const LanguageInitial());
  }
}
