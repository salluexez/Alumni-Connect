import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/admin_stats_entity.dart';

// Admin data typically requires aggregation, either via Cloud Functions
// writing to a 'metadata/stats' doc or doing count queries.
// Here we'll use Firestore count queries for real-time accurate counts.
class AdminRemoteDataSource {
  final FirebaseFirestore _firestore;

  AdminRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<AdminDashboardStatsEntity> getDashboardStats() async {
    try {
      // Use efficient aggregate queries
      final usersFuture = _firestore.collection('users').count().get();
      final studentsFuture = _firestore.collection('users').where('role', isEqualTo: 'student').count().get();
      final alumniFuture = _firestore.collection('users').where('role', isEqualTo: 'alumni').count().get();
      final jobsFuture = _firestore.collection('jobs').where('isActive', isEqualTo: true).count().get();
      final mentorshipsFuture = _firestore.collection('mentorships').count().get();

      final results = await Future.wait([
        usersFuture,
        studentsFuture,
        alumniFuture,
        jobsFuture,
        mentorshipsFuture,
      ]);

      return AdminDashboardStatsEntity(
        totalUsers: results[0].count ?? 0,
        totalStudents: results[1].count ?? 0,
        totalAlumni: results[2].count ?? 0,
        activeJobs: results[3].count ?? 0,
        totalMentorships: results[4].count ?? 0,
        usersByRole: {
          'Students': results[1].count ?? 0,
          'Alumni': results[2].count ?? 0,
          'Admins': (results[0].count ?? 0) - (results[1].count ?? 0) - (results[2].count ?? 0),
        },
      );
    } catch (e) {
      throw ServerException(message: 'Failed to load admin stats: $e');
    }
  }

  // Example admin action
  Future<void> suspendUser(String uid, bool isSuspended) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isSuspended': isSuspended,
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
