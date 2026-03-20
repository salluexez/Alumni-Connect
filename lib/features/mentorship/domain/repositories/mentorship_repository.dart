import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/mentorship_entity.dart';

abstract class MentorshipRepository {
  Future<Either<Failure, List<MentorshipRequestEntity>>> getRequestsForUser(
      String uid, {bool asMentor = true});
      
  Future<Either<Failure, void>> sendRequest(MentorshipRequestEntity request);
  
  Future<Either<Failure, void>> updateRequestStatus(String requestId, String status);
}
