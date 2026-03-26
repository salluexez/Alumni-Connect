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
          .collection('posts')
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
      await _firestore.collection('posts').add(job.toMap());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> expressInterest({required String jobId, required String applicantUid, required Map<String, dynamic> interestData}) async {
    try {
      await _firestore
          .collection('job_interests')
          .doc('${jobId}_$applicantUid')
          .set({
        'jobId': jobId,
        'applicantUid': applicantUid,
        ...interestData,
        'expressedAt': FieldValue.serverTimestamp(),
      });

      // Update the post with the interested user id
      await _firestore.collection('posts').doc(jobId).update({
        'interestedUserIds': FieldValue.arrayUnion([applicantUid]),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> toggleLike(String jobId, String uid) async {
    try {
      final postDoc = _firestore.collection('posts').doc(jobId);
      final snapshot = await postDoc.get();
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final likedByUids = List<String>.from(data['likedByUids'] ?? []);

      if (likedByUids.contains(uid)) {
        await postDoc.update({
          'likedByUids': FieldValue.arrayRemove([uid]),
        });
      } else {
        await postDoc.update({
          'likedByUids': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
