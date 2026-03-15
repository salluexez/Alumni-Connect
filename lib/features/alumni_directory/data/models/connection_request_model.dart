import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum ConnectionStatus { pending, accepted, rejected }

class ConnectionRequestModel extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String receiverId;
  final String receiverName;
  final ConnectionStatus status;
  final DateTime createdAt;

  const ConnectionRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.receiverId,
    required this.receiverName,
    required this.status,
    required this.createdAt,
  });

  factory ConnectionRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConnectionRequestModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'],
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      status: ConnectionStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [id, senderId, senderName, senderPhotoUrl, receiverId, receiverName, status, createdAt];
}
