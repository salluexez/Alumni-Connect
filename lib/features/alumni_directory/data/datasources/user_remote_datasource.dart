import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/data/models/user_model.dart';

class UserRemoteDataSource {
  final FirebaseFirestore _firestore;
  UserRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Fetch a single user by UID
  Future<UserModel> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) throw const NotFoundException(message: 'User not found');
      return UserModel.fromFirestore(doc);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Fetch paginated alumni list with optional search/filter
  Future<List<UserModel>> getAlumniList({
    String? searchQuery,
    String? filterCompany,
    int? filterBatchYear,
    String? filterField,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('users')
          .where('role', whereIn: ['alumni', 'student'])
          .orderBy('name')
          .limit(limit);

      if (filterCompany != null && filterCompany.isNotEmpty) {
        query = query.where('company', isEqualTo: filterCompany);
      }
      if (filterBatchYear != null) {
        query = query.where('batchYear', isEqualTo: filterBatchYear);
      }
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      var users = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();

      // Client-side search filter on name
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        users = users.where((u) {
          final name = u.name.toLowerCase();
          final company = (u.company ?? '').toLowerCase();
          final position = (u.position ?? '').toLowerCase();
          return name.contains(q) || company.contains(q) || position.contains(q);
        }).toList();
      }

      return users;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Get dashboard stats for a user
  Future<Map<String, int>> getDashboardStats(String uid) async {
    try {
      final results = await Future.wait([
        _firestore
            .collection('connections')
            .where('participants', arrayContains: uid)
            .count()
            .get(),
        _firestore
            .collection('mentorships')
            .where('menteeId', isEqualTo: uid)
            .where('status', isEqualTo: 'active')
            .count()
            .get(),
        _firestore
            .collection('jobs')
            .where('isActive', isEqualTo: true)
            .count()
            .get(),
      ]);
      return {
        'connections': results[0].count ?? 0,
        'mentors': results[1].count ?? 0,
        'jobs': results[2].count ?? 0,
      };
    } catch (_) {
      return {'connections': 0, 'mentors': 0, 'jobs': 0};
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
