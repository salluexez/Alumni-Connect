import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<Either<Failure, List<NotificationEntity>>> getUserNotifications(String userId);
  Future<Either<Failure, void>> markAsRead(String notificationId);
  Future<Either<Failure, void>> markAllAsRead(String userId);
}
