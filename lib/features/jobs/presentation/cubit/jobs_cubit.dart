import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import 'jobs_state.dart';

class JobsCubit extends Cubit<JobsState> {
  final JobRepository _repository;

  JobsCubit({required JobRepository repository})
      : _repository = repository,
        super(const JobsInitial());

  Future<void> loadJobs({bool referralsOnly = false}) async {
    emit(const JobsLoading());
    final result = await _repository.getJobs(referralsOnly: referralsOnly);
    result.fold(
      (failure) => emit(JobsError(failure.message)),
      (jobs) => emit(JobsLoaded(jobs: jobs, hasMore: jobs.length == 20)),
    );
  }

  Future<void> postJob(JobEntity job) async {
    final currentState = state;
    emit(const JobPosting());
    final result = await _repository.createJob(job);
    result.fold(
      (failure) => emit(JobsError(failure.message)),
      (_) {
        emit(const JobPosted());
        if (currentState is JobsLoaded) {
          emit(JobsLoaded(jobs: [job, ...currentState.jobs], hasMore: currentState.hasMore));
        } else {
          loadJobs();
        }
      },
    );
  }
}
