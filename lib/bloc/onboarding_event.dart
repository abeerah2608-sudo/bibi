part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class FetchOnboardingFlowEvent extends OnboardingEvent {
  final bool forceRefresh;

  const FetchOnboardingFlowEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}
