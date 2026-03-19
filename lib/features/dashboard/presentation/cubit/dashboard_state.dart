import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/activity_entity.dart';

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
  final List<ActivityEntity> activities;

  const DashboardLoaded({
    required this.user, 
    required this.stats,
    this.activities = const [],
  });

  @override
  List<Object?> get props => [user, stats, activities];

  DashboardLoaded copyWith({
    UserEntity? user,
    Map<String, int>? stats,
    List<ActivityEntity>? activities,
  }) {
    return DashboardLoaded(
      user: user ?? this.user,
      stats: stats ?? this.stats,
      activities: activities ?? this.activities,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
