import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/activity_entity.dart';

class ActivityModel extends ActivityEntity {
  const ActivityModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.subtitle,
    required super.type,
    required super.createdAt,
  });

  factory ActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      type: data['type'] ?? 'system',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': super.userId,
      'title': super.title,
      'subtitle': super.subtitle,
      'type': super.type,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
