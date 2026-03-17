import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/call_entity.dart';

class CallModel extends CallEntity {
  const CallModel({
    required super.id,
    required super.callerId,
    required super.receiverId,
    required super.callerName,
    required super.callerPhoto,
    required super.receiverName,
    required super.receiverPhoto,
    required super.status,
    required super.channelId,
    required super.timestamp,
  });

  factory CallModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CallModel(
      id: doc.id,
      callerId: data['callerId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      callerName: data['callerName'] ?? '',
      callerPhoto: data['callerPhoto'] ?? '',
      receiverName: data['receiverName'] ?? '',
      receiverPhoto: data['receiverPhoto'] ?? '',
      status: CallStatus.values.byName(data['status'] ?? 'dialing'),
      channelId: data['channelId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'callerPhoto': callerPhoto,
      'receiverName': receiverName,
      'receiverPhoto': receiverPhoto,
      'status': status.name,
      'channelId': channelId,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
