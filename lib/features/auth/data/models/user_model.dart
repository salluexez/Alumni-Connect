import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.name,
    super.photoUrl,
    required super.role,
    super.batchYear,
    super.bio,
    super.company,
    super.position,
    super.skills,
    super.isAvailableForMentoring,
    required super.createdAt,
    super.lastSeen,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      role: _parseRole(data['role']),
      batchYear: data['batchYear'],
      bio: data['bio'],
      company: data['company'],
      position: data['position'],
      skills: List<String>.from(data['skills'] ?? []),
      isAvailableForMentoring: data['isAvailableForMentoring'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      role: _parseRole(data['role']),
      batchYear: data['batchYear'],
      bio: data['bio'],
      company: data['company'],
      position: data['position'],
      skills: List<String>.from(data['skills'] ?? []),
      isAvailableForMentoring: data['isAvailableForMentoring'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSeen: (data['lastSeen'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role.name,
      'batchYear': batchYear,
      'bio': bio,
      'company': company,
      'position': position,
      'skills': skills,
      'isAvailableForMentoring': isAvailableForMentoring,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
    };
  }

  static UserRole _parseRole(String? role) => switch (role) {
        'alumni' => UserRole.alumni,
        'admin' => UserRole.admin,
        _ => UserRole.student,
      };
}
