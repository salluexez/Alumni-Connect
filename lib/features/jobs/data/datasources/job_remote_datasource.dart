import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/job_model.dart';

class JobRemoteDataSource {
  final FirebaseFirestore _firestore;

  JobRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<JobModel>> getJobs({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    bool referralsOnly = false,
  }) async {
    try {
      Query query = _firestore
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .orderBy('postedAt', descending: true)
          .limit(limit);

      if (referralsOnly) {
        query = query.where('isReferral', isEqualTo: true);
      }
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => JobModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> createJob(JobModel job) async {
    try {
      await _firestore.collection('jobs').add(job.toMap());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
