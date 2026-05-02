part of 'dashboard_bloc.dart';

// ────────────────────────────────────────────────────────────────────────────
// STATES
// ────────────────────────────────────────────────────────────────────────────

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final DashboardConfig config;

  const DashboardLoaded(this.config); // positional (matches bloc usage)

  @override
  List<Object?> get props => [config];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}