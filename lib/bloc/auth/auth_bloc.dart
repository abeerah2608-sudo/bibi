import 'package:bloc/bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<SubmitUserDataEvent>(_onSubmitUserData);
    on<ResetAuthEvent>(_onResetAuth);
  }

  Future<void> _onSubmitUserData(
    SubmitUserDataEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (event.fullName.isEmpty || event.city.isEmpty || event.age.isEmpty) {
        emit(const AuthFailure('Please fill all fields'));
        return;
      }
      
      emit(
        AuthSuccess(
          fullName: event.fullName,
          city: event.city,
          age: event.age,
        ),
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onResetAuth(
    ResetAuthEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthInitial());
  }
}
