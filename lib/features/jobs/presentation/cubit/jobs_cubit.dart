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

  Future<void> expressInterest({
    required String jobId,
    required String applicantUid,
    required Map<String, dynamic> interestData,
  }) async {
    final result = await _repository.expressInterest(
      jobId: jobId,
      applicantUid: applicantUid,
      interestData: interestData,
    );
    result.fold(
      (failure) => emit(JobsError(failure.message)),
      (_) => null,
    );
  }

  Future<void> toggleLike(String jobId, String uid) async {
    final currentState = state;
    if (currentState is JobsLoaded) {
      final updatedJobs = currentState.jobs.map((job) {
        if (job.id == jobId) {
          final isLiked = job.likedByUids.contains(uid);
          final updatedLikes = isLiked
              ? job.likedByUids.where((id) => id != uid).toList()
              : [...job.likedByUids, uid];
          
          // Return a new job model/entity with updated likes
          // For simplicity in this demo, we clone the list
          return JobEntity(
            id: job.id,
            title: job.title,
            company: job.company,
            location: job.location,
            type: job.type,
            description: job.description,
            postedByUid: job.postedByUid,
            postedByName: job.postedByName,
            postedAt: job.postedAt,
            isReferral: job.isReferral,
            externalLink: job.externalLink,
            isActive: job.isActive,
            interestedUserIds: job.interestedUserIds,
            postType: job.postType,
            likedByUids: updatedLikes,
          );
        }
        return job;
      }).toList();
      
      emit(JobsLoaded(jobs: updatedJobs, hasMore: currentState.hasMore));
    }

    final result = await _repository.toggleLike(jobId, uid);
    result.fold(
      (failure) {
        // Option: Revert state on failure
      },
      (_) => null,
    );
  }
}
