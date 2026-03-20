import 'package:equatable/equatable.dart';
import '../../domain/entities/mentorship_entity.dart';

abstract class MentorshipState extends Equatable {
  const MentorshipState();
  @override
  List<Object?> get props => [];
}

class MentorshipInitial extends MentorshipState {
  const MentorshipInitial();
}

class MentorshipLoading extends MentorshipState {
  const MentorshipLoading();
}

class MentorshipLoaded extends MentorshipState {
  final List<MentorshipRequestEntity> requests;
  const MentorshipLoaded(this.requests);
  @override
  List<Object?> get props => [requests];
}

class MentorshipError extends MentorshipState {
  final String message;
  const MentorshipError(this.message);
  @override
  List<Object?> get props => [message];
}

class MentorshipActionLoading extends MentorshipState {
  const MentorshipActionLoading();
}

class MentorshipActionSuccess extends MentorshipState {
  final String message;
  const MentorshipActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
