import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';
import '../models/job_model.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource _remoteDataSource;

  JobRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs({
    dynamic lastDocument,
    int limit = 20,
    bool referralsOnly = false,
  }) async {
    try {
      final jobs = await _remoteDataSource.getJobs(
        lastDocument: lastDocument,
        limit: limit,
        referralsOnly: referralsOnly,
      );
      return Right(jobs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createJob(JobEntity job) async {
    try {
      final model = JobModel(
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
        likedByUids: job.likedByUids,
      );
      await _remoteDataSource.createJob(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> expressInterest({
    required String jobId,
    required String applicantUid,
    required Map<String, dynamic> interestData,
  }) async {
    try {
      await _remoteDataSource.expressInterest(
        jobId: jobId,
        applicantUid: applicantUid,
        interestData: interestData,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike(String jobId, String uid) async {
    try {
      await _remoteDataSource.toggleLike(jobId, uid);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
