import 'package:equatable/equatable.dart';

class AdminDashboardStatsEntity extends Equatable {
  final int totalUsers;
  final int totalStudents;
  final int totalAlumni;
  final int activeJobs;
  final int totalMentorships;
  final Map<String, int> usersByRole;

  const AdminDashboardStatsEntity({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalAlumni,
    required this.activeJobs,
    required this.totalMentorships,
    required this.usersByRole,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        totalStudents,
        totalAlumni,
        activeJobs,
        totalMentorships,
        usersByRole,
      ];
}
