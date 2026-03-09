import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

// ── Alumni Directory States ───────────────────────────────
abstract class AlumniState extends Equatable {
  const AlumniState();
  @override
  List<Object?> get props => [];
}

class AlumniInitial extends AlumniState {
  const AlumniInitial();
}

class AlumniLoading extends AlumniState {
  const AlumniLoading();
}

class AlumniLoaded extends AlumniState {
  final List<UserEntity> alumni;
  final bool hasMore;
  final String? searchQuery;

  const AlumniLoaded({
    required this.alumni,
    this.hasMore = false,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [alumni, hasMore, searchQuery];
}

class AlumniError extends AlumniState {
  final String message;
  const AlumniError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Profile States ────────────────────────────────────────
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserEntity user;
  const ProfileLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {
  final UserEntity user;
  const ProfileUpdating(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileUpdated extends ProfileState {
  final UserEntity user;
  const ProfileUpdated(this.user);
  @override
  List<Object?> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
