import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/connection_request_model.dart';
import '../../../dashboard/data/models/activity_model.dart';

class ConnectionRemoteDataSource {
  final FirebaseFirestore _firestore;

  ConnectionRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  /// Send a connection request and create a notification for the receiver
  Future<void> sendConnectionRequest(ConnectionRequestModel request) async {
    try {
      if (request.senderId == request.receiverId) {
        throw const ServerException(message: 'You cannot send a connection request to yourself');
      }

      // Check for existing pending or accepted requests
      final existingRequest = await _firestore
          .collection('connection_requests')
          .where('senderId', isEqualTo: request.senderId)
          .where('receiverId', isEqualTo: request.receiverId)
          .where('status', whereIn: ['pending', 'accepted'])
          .get();

      if (existingRequest.docs.isNotEmpty) {
        throw const ServerException(message: 'A connection request already exists');
      }

      final batch = _firestore.batch();

      // 1. Create connection request
      final requestRef = _firestore.collection('connection_requests').doc();
      batch.set(requestRef, request.toMap());

      // 2. Create notification for the receiver
      final notificationRef = _firestore.collection('notifications').doc();
      batch.set(notificationRef, {
        'userId': request.receiverId,
        'title': 'New Connection Request',
        'body': '${request.senderName} wants to connect with you.',
        'type': 'connection_request',
        'relatedId': requestRef.id,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  /// Update the status of a connection request
  Future<void> updateConnectionStatus(String requestId, ConnectionStatus status, {String? notificationId}) async {
    try {
      final requestDoc = await _firestore.collection('connection_requests').doc(requestId).get();
      if (!requestDoc.exists) throw const ServerException(message: 'Request not found');

      final requestData = requestDoc.data() as Map<String, dynamic>;
      final currentStatus = requestData['status'] as String?;
      
      // Prevent redundant processing if already accepted or rejected
      if (currentStatus != 'pending') return;

      final request = ConnectionRequestModel.fromFirestore(requestDoc);
      final batch = _firestore.batch();

      // 1. Update request status
      batch.update(_firestore.collection('connection_requests').doc(requestId), {
        'status': status.name,
      });

      // 1.1 Update original notification if provided
      if (notificationId != null) {
        batch.update(_firestore.collection('notifications').doc(notificationId), {
          'status': status.name,
          'isRead': true,
        });
      }

      // 2. If accepted, create a bidirectional connection record and log activities
      if (status == ConnectionStatus.accepted) {
        // Use deterministic ID to prevent duplicates (e.g., sorted UIDs joined)
        final ids = [request.senderId, request.receiverId]..sort();
        final connectionId = ids.join('_');
        
        final connectionRef = _firestore.collection('connections').doc(connectionId);
        batch.set(connectionRef, {
          'participants': [request.senderId, request.receiverId],
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Create notification for the sender
        final senderNotificationRef = _firestore.collection('notifications').doc();
        batch.set(senderNotificationRef, {
          'userId': request.senderId,
          'title': 'Request Accepted',
          'body': '${request.receiverName} accepted your connection request!',
          'type': 'connection_accepted',
          'relatedId': requestId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Add activity for Receiver (Current User)
        final receiverActivityRef = _firestore.collection('recent_activity').doc();
        batch.set(receiverActivityRef, ActivityModel(
          id: '',
          userId: request.receiverId,
          title: 'New Connection',
          subtitle: 'You connected with ${request.senderName}',
          type: 'connection',
          createdAt: DateTime.now(),
        ).toMap());

        // Add activity for Sender
        final senderActivityRef = _firestore.collection('recent_activity').doc();
        batch.set(senderActivityRef, ActivityModel(
          id: '',
          userId: request.senderId,
          title: 'Request Accepted',
          subtitle: '${request.receiverName} accepted your connection request',
          type: 'connection',
          createdAt: DateTime.now(),
        ).toMap());
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  /// Get pending requests for a user
  Stream<List<ConnectionRequestModel>> getIncomingRequests(String uid) {
    return _firestore
        .collection('connection_requests')
        .where('receiverId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConnectionRequestModel.fromFirestore(doc))
            .toList());
  }

  /// Check connection status between two users
  Future<ConnectionStatus?> getConnectionStatus(String uid1, String uid2) async {
    try {
      final query = await _firestore
          .collection('connection_requests')
          .where('senderId', isEqualTo: uid1)
          .where('receiverId', isEqualTo: uid2)
          .get();

      if (query.docs.isNotEmpty) {
        return ConnectionStatus.values.firstWhere(
          (e) => e.name == query.docs.first.data()['status'],
          orElse: () => ConnectionStatus.pending,
        );
      }

      // Check reverse if both can send requests
      final queryReverse = await _firestore
          .collection('connection_requests')
          .where('senderId', isEqualTo: uid2)
          .where('receiverId', isEqualTo: uid1)
          .get();

      if (queryReverse.docs.isNotEmpty) {
        return ConnectionStatus.values.firstWhere(
          (e) => e.name == queryReverse.docs.first.data()['status'],
          orElse: () => ConnectionStatus.pending,
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
