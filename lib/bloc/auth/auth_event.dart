import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SubmitUserDataEvent extends AuthEvent {
  final String fullName;
  final String city;
  final String age;

  const SubmitUserDataEvent({
    required this.fullName,
    required this.city,
    required this.age,
  });

  @override
  List<Object> get props => [fullName, city, age];
}

class ResetAuthEvent extends AuthEvent {
  const ResetAuthEvent();
}
