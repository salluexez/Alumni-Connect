import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../alumni_directory/data/datasources/user_remote_datasource.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final UserRemoteDataSource _dataSource;

  DashboardCubit({required UserRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const DashboardInitial());

  Future<void> loadDashboard() async {
    emit(const DashboardLoading());
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        emit(const DashboardError('Not authenticated'));
        return;
      }

      final results = await Future.wait([
        _dataSource.getUserById(uid),
        _dataSource.getDashboardStats(uid),
      ]);

      emit(DashboardLoaded(
        user: results[0] as dynamic,
        stats: results[1] as Map<String, int>,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
