import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/job_entity.dart';

abstract class JobRepository {
  Future<Either<Failure, List<JobEntity>>> getJobs({
    dynamic lastDocument,
    int limit = 20,
    bool referralsOnly = false,
  });
  
  Future<Either<Failure, void>> createJob(JobEntity job);
}
