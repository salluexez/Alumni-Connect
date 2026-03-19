import 'package:equatable/equatable.dart';
import '../../domain/entities/job_entity.dart';

abstract class JobsState extends Equatable {
  const JobsState();
  @override
  List<Object?> get props => [];
}

class JobsInitial extends JobsState {
  const JobsInitial();
}

class JobsLoading extends JobsState {
  const JobsLoading();
}

class JobsLoaded extends JobsState {
  final List<JobEntity> jobs;
  final bool hasMore;

  const JobsLoaded({required this.jobs, this.hasMore = false});

  @override
  List<Object?> get props => [jobs, hasMore];
}

class JobsError extends JobsState {
  final String message;
  const JobsError(this.message);
  @override
  List<Object?> get props => [message];
}

class JobPosting extends JobsState {
  const JobPosting();
}

class JobPosted extends JobsState {
  const JobPosted();
}
