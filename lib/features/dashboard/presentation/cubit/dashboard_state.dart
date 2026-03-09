import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

// ── Dashboard States ──────────────────────────────────────
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
  final UserEntity user;
  final Map<String, int> stats;

  const DashboardLoaded({required this.user, required this.stats});

  @override
  List<Object?> get props => [user, stats];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
