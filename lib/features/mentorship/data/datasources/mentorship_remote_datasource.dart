import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/mentorship_model.dart';

class MentorshipRemoteDataSource {
  final FirebaseFirestore _firestore;

  MentorshipRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Future<List<MentorshipRequestModel>> getRequestsForUser(String uid, {bool asMentor = true}) async {
    try {
      final field = asMentor ? 'mentorId' : 'menteeId';
      final snapshot = await _firestore
          .collection('mentorships')
          .where(field, isEqualTo: uid)
          .orderBy('updatedAt', descending: true)
          .get();
          
      return snapshot.docs
          .map((doc) => MentorshipRequestModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> sendRequest(MentorshipRequestModel request) async {
    try {
      final batch = _firestore.batch();

      // 1. Create mentorship request
      final requestRef = _firestore.collection('mentorships').doc();
      batch.set(requestRef, request.toMap());

      // 2. Create notification for the mentor
      final notificationRef = _firestore.collection('notifications').doc();
      batch.set(notificationRef, {
        'userId': request.mentorId,
        'title': 'New Mentorship Request',
        'body': '${request.menteeName} wants you as their mentor.',
        'type': 'mentorship',
        'relatedId': requestRef.id,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      // Fetch request to get menteeId for notification
      final doc = await _firestore.collection('mentorships').doc(requestId).get();
      final menteeId = doc.data()?['menteeId'];

      final batch = _firestore.batch();

      // 1. Update status
      final requestRef = _firestore.collection('mentorships').doc(requestId);
      batch.update(requestRef, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Create notification for the mentee
      if (menteeId != null) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': menteeId,
          'title': 'Mentorship Update',
          'body': 'Your mentorship request was $status.',
          'type': 'mentorship',
          'relatedId': requestId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
