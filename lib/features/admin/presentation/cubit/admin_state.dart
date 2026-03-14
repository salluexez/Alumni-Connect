import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminStatsLoaded extends AdminState {
  final AdminDashboardStatsEntity stats;
  const AdminStatsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class AdminUsersLoaded extends AdminState {
  final List<UserEntity> users;
  const AdminUsersLoaded(this.users);
  @override
  List<Object?> get props => [users];
}

class AdminActionSuccess extends AdminState {
  final String message;
  const AdminActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}
