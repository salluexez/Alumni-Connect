import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../alumni_directory/data/datasources/user_remote_datasource.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final UserRemoteDataSource _dataSource;
  StreamSubscription? _activitySubscription;

  DashboardCubit({required UserRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const DashboardInitial());

  @override
  Future<void> close() {
    _activitySubscription?.cancel();
    return super.close();
  }

  Future<void> loadDashboard() async {
    emit(const DashboardLoading());
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(const DashboardError('Not authenticated'));
      return;
    }

    try {
      // 1. Initial fetch
      final results = await Future.wait([
        _dataSource.getUserById(uid),
        _dataSource.getDashboardStats(uid),
      ]);

      emit(DashboardLoaded(
        user: results[0] as dynamic,
        stats: results[1] as Map<String, int>,
      ));

      // 2. Start listening to activities
      _activitySubscription?.cancel();
      _activitySubscription = _dataSource.getUserActivities(uid).listen((activities) async {
        final currentState = state;
        if (currentState is DashboardLoaded) {
          // If activities changed, also refresh stats to ensure connection count is accurate
          final newStats = await _dataSource.getDashboardStats(uid);
          emit(currentState.copyWith(
            activities: activities,
            stats: newStats,
          ));
        }
      });
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
