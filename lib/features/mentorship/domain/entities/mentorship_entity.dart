import 'package:equatable/equatable.dart';

class MentorshipRequestEntity extends Equatable {
  final String id;
  final String mentorId;
  final String menteeId;
  final String menteeName;
  final String subject;
  final String message;
  final String status; // pending, accepted, rejected, completed
  final DateTime createdAt;
  final DateTime updatedAt;

  const MentorshipRequestEntity({
    required this.id,
    required this.mentorId,
    required this.menteeId,
    required this.menteeName,
    required this.subject,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        mentorId,
        menteeId,
        menteeName,
        subject,
        message,
        status,
        createdAt,
        updatedAt,
      ];
}
