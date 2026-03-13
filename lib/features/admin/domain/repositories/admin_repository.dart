import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/admin_stats_entity.dart';
import '../../../auth/domain/entities/user_entity.dart';

abstract class AdminRepository {
  Future<Either<Failure, AdminDashboardStatsEntity>> getDashboardStats();
  Future<Either<Failure, void>> suspendUser(String uid, bool isSuspended);
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);
}
