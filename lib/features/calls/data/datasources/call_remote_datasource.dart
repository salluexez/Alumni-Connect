import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/call_model.dart';
import '../../domain/entities/call_entity.dart';

class CallRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> startCall(CallModel call) async {
    await _firestore.collection('calls').doc(call.id).set(call.toFirestore());
  }

  Future<void> updateCallStatus(String callId, CallStatus status) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': status.name,
    });
  }

  Future<void> endCall(String callId) async {
    await _firestore.collection('calls').doc(callId).update({
      'status': CallStatus.ended.name,
    });
    // Optional: Delete the call document after a few seconds or mark as inactive
  }

  Stream<CallModel?> getCallStream(String uid) {
    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: uid)
        .where('status', whereIn: [CallStatus.dialing.name, CallStatus.ringing.name, CallStatus.active.name])
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          return CallModel.fromFirestore(snapshot.docs.first);
        });
  }
  
  Stream<CallModel?> getActiveCallStream(String callId) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return CallModel.fromFirestore(doc);
        });
  }
}
