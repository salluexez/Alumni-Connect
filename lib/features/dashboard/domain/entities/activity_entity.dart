import 'package:equatable/equatable.dart';

class ActivityEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String subtitle;
  final String type; // connection, mentorship, job, system
  final DateTime createdAt;

  const ActivityEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, title, subtitle, type, createdAt];
}
