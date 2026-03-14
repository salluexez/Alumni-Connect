import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRepository _repository;

  AdminCubit({required AdminRepository repository})
      : _repository = repository,
        super(const AdminInitial());

  Future<void> loadDashboardStats() async {
    emit(const AdminLoading());
    final result = await _repository.getDashboardStats();
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (stats) => emit(AdminStatsLoaded(stats)),
    );
  }

  Future<void> suspendUser(String uid, bool isSuspended) async {
    final currentState = state;
    emit(const AdminLoading());
    final result = await _repository.suspendUser(uid, isSuspended);
    result.fold(
      (failure) {
        emit(AdminError(failure.message));
        if (currentState is AdminStatsLoaded) {
          emit(currentState); // Revert to stats
        }
      },
      (_) {
        final action = isSuspended ? 'suspended' : 'reactivated';
        emit(AdminActionSuccess('User successfully $action.'));
        loadDashboardStats(); // refresh if from dashboard
      },
    );
  }

  Future<void> searchUsers(String query) async {
    emit(const AdminLoading());
    final result = await _repository.searchUsers(query);
    result.fold(
      (failure) => emit(AdminError(failure.message)),
      (users) => emit(AdminUsersLoaded(users)),
    );
  }
}
