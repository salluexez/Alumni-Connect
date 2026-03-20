import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/mentorship_entity.dart';
import '../../domain/repositories/mentorship_repository.dart';
import '../datasources/mentorship_remote_datasource.dart';
import '../models/mentorship_model.dart';

class MentorshipRepositoryImpl implements MentorshipRepository {
  final MentorshipRemoteDataSource _remoteDataSource;

  MentorshipRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<MentorshipRequestEntity>>> getRequestsForUser(
      String uid, {bool asMentor = true}) async {
    try {
      final requests = await _remoteDataSource.getRequestsForUser(uid, asMentor: asMentor);
      return Right(requests);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendRequest(MentorshipRequestEntity request) async {
    try {
      final model = MentorshipRequestModel(
        id: request.id,
        mentorId: request.mentorId,
        menteeId: request.menteeId,
        menteeName: request.menteeName,
        subject: request.subject,
        message: request.message,
        status: request.status,
        createdAt: request.createdAt,
        updatedAt: request.updatedAt,
      );
      await _remoteDataSource.sendRequest(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRequestStatus(String requestId, String status) async {
    try {
      await _remoteDataSource.updateRequestStatus(requestId, status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
