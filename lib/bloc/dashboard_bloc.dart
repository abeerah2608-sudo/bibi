import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_models.dart';
import 'package:equatable/equatable.dart';
part 'dashboard_event.dart';
part 'dashboard_state.dart';

// ────────────────────────────────────────────────────────────────────────────
// BLOC
// ────────────────────────────────────────────────────────────────────────────

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final FirebaseFirestore _firestore;

  DashboardBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const DashboardInitial()) {
    on<FetchDashboardConfigEvent>(_onFetchDashboardConfig);
  }

  Future<void> _onFetchDashboardConfig(
    FetchDashboardConfigEvent event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      debugPrint('📱 DashboardBloc: Fetching dashboard config from Firebase...');
      emit(const DashboardLoading());

      final docSnapshot = await _firestore
          .collection('json_documents')
          .doc('dashboard')
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Firestore query timeout after 10 seconds'),
          );

      if (!docSnapshot.exists) {
        emit(const DashboardError('Dashboard configuration not found'));
        return;
      }

      final data = docSnapshot.data();
      if (data == null) {
        emit(const DashboardError('Dashboard configuration is empty'));
        return;
      }

      final config = DashboardConfig.fromJson(data);

      debugPrint('✅ Dashboard config parsed successfully');
      debugPrint('   - Background: ${config.backgroundColor}');
      debugPrint('   - Logo URL: ${config.logoUrl}');
      debugPrint('   - Tabs: ${config.tabs.length}');
      debugPrint('   - Video categories: ${config.videoCards.keys.toList()}');

      emit(DashboardLoaded(config));
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching dashboard config: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(DashboardError('Failed to load dashboard: ${e.toString()}'));
    }
  }
}