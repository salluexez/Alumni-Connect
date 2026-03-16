import 'package:equatable/equatable.dart';

enum UserRole { student, alumni, admin }

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final UserRole role;
  final int? batchYear;
  final String? bio;
  final String? company;
  final String? position;
  final List<String> skills;
  final bool isAvailableForMentoring;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final bool isSuspended;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.role,
    this.batchYear,
    this.bio,
    this.company,
    this.position,
    this.skills = const [],
    this.isAvailableForMentoring = false,
    required this.createdAt,
    this.lastSeen,
    this.isSuspended = false,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isAlumni => role == UserRole.alumni;
  bool get isStudent => role == UserRole.student;

  String get roleLabel => switch (role) {
        UserRole.student => 'Student',
        UserRole.alumni => 'Alumni',
        UserRole.admin => 'Admin',
      };

  @override
  List<Object?> get props => [
        uid, email, name, photoUrl, role, batchYear, bio,
        company, position, skills, isAvailableForMentoring, createdAt, lastSeen, isSuspended,
      ];
}
