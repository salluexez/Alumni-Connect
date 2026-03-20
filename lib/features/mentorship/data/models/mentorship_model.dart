import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/mentorship_entity.dart';

class MentorshipRequestModel extends MentorshipRequestEntity {
  const MentorshipRequestModel({
    required super.id,
    required super.mentorId,
    required super.menteeId,
    required super.menteeName,
    required super.subject,
    required super.message,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory MentorshipRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MentorshipRequestModel(
      id: doc.id,
      mentorId: data['mentorId'] ?? '',
      menteeId: data['menteeId'] ?? '',
      menteeName: data['menteeName'] ?? '',
      subject: data['subject'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mentorId': mentorId,
      'menteeId': menteeId,
      'menteeName': menteeName,
      'subject': subject,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
