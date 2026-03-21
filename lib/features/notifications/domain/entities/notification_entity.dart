import 'package:equatable/equatable.dart';

class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // e.g., 'mentorship', 'chat', 'job', 'system'
  final String? relatedId; // ID of the related chat, job, or mentorship request
  final String? status; // 'accepted', 'rejected', or null
  final bool isRead;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    this.status,
    this.isRead = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        relatedId,
        status,
        isRead,
        createdAt,
      ];
}
