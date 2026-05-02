part of 'dashboard_bloc.dart';

// ────────────────────────────────────────────────────────────────────────────
// EVENTS
// ────────────────────────────────────────────────────────────────────────────

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class FetchDashboardConfigEvent extends DashboardEvent {
  const FetchDashboardConfigEvent();
}