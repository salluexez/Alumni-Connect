import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.title,
    required super.company,
    required super.location,
    required super.type,
    required super.description,
    required super.postedByUid,
    required super.postedByName,
    required super.postedAt,
    super.isReferral,
    super.externalLink,
    super.isActive,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      location: data['location'] ?? '',
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      postedByUid: data['postedByUid'] ?? '',
      postedByName: data['postedByName'] ?? '',
      postedAt: (data['postedAt'] as Timestamp).toDate(),
      isReferral: data['isReferral'] ?? false,
      externalLink: data['externalLink'],
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'type': type,
      'description': description,
      'postedByUid': postedByUid,
      'postedByName': postedByName,
      'postedAt': Timestamp.fromDate(postedAt),
      'isReferral': isReferral,
      'externalLink': externalLink,
      'isActive': isActive,
    };
  }
}
