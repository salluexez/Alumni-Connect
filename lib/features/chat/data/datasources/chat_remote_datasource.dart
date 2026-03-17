import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/chat_model.dart';

class ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Stream<List<ChatRoomModel>> getUserChatRooms(String uid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatRoomModel.fromFirestore(doc))
            .toList());
  }

  Stream<ChatRoomModel> getRoom(String roomId) {
    return _firestore
        .collection('chats')
        .doc(roomId)
        .snapshots()
        .map((doc) => ChatRoomModel.fromFirestore(doc));
  }

  Stream<List<MessageModel>> getMessages(String roomId) {
    return _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  Future<void> sendMessage(MessageModel message, String senderName) async {
    try {
      // 0. Fetch room to get participants for notification
      final roomDoc = await _firestore.collection('chats').doc(message.roomId).get();
      final participants = List<String>.from(roomDoc.data()?['participants'] ?? []);
      final recipientId = participants.firstWhere((id) => id != message.senderId, orElse: () => '');

      final batch = _firestore.batch();
      
      // 1. Add message
      final msgRef = _firestore
          .collection('chats')
          .doc(message.roomId)
          .collection('messages')
          .doc();
      
      final msgData = message.toMap();
      msgData['roomId'] = message.roomId;
      batch.set(msgRef, msgData);

      // 2. Update room last message info
      final roomRef = _firestore.collection('chats').doc(message.roomId);
      batch.update(roomRef, {
        'lastMessage': message.text,
        'lastSenderId': message.senderId,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // 3. Create notification for the recipient
      if (recipientId.isNotEmpty) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': recipientId,
          'title': 'New Message',
          'body': '$senderName: ${message.text}',
          'type': 'chat',
          'relatedId': message.roomId,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<String> createOrGetRoom(String uid1, String uid2, {String? name2, String? photo2}) async {
    try {
      // Create a deterministic ID (e.g., sorted_uid1_uid2)
      final sortedIds = [uid1, uid2]..sort();
      final roomId = sortedIds.join('_');

      final roomDoc = await _firestore.collection('chats').doc(roomId).get();

      if (roomDoc.exists) {
        return roomId;
      }

      // If it doesn't exist, we need to create it. 
      // We should fetch basic info for both users if not provided
      // For now, we'll use the provided name2/photo2 and get current user info
      final currentUserDoc = await _firestore.collection('users').doc(uid1).get();
      final currentUserName = currentUserDoc.data()?['name'] ?? 'User';
      final currentUserPhoto = currentUserDoc.data()?['photoUrl'] ?? '';

      // We also need name1/photo1 for the second user to see
      // If name2/photo2 are missing, we should fetch them too
      String otherName = name2 ?? 'User';
      String otherPhoto = photo2 ?? '';
      
      if (name2 == null) {
        final otherUserDoc = await _firestore.collection('users').doc(uid2).get();
        otherName = otherUserDoc.data()?['name'] ?? 'User';
        otherPhoto = otherUserDoc.data()?['photoUrl'] ?? '';
      }

      await _firestore.collection('chats').doc(roomId).set({
        'participants': [uid1, uid2],
        'lastMessage': '',
        'lastSenderId': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCounts': {uid1: 0, uid2: 0},
        'participantNames': {
          uid1: currentUserName,
          uid2: otherName,
        },
        'participantPhotos': {
          uid1: currentUserPhoto,
          uid2: otherPhoto,
        },
      });

      return roomId;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  Future<void> saveCallLog({
    required String roomId,
    required String callerId,
    required String callStatus,
    required int duration,
  }) async {
    try {
      final msgRef = _firestore
          .collection('chats')
          .doc(roomId)
          .collection('messages')
          .doc();

      final timestamp = DateTime.now();
      
      await msgRef.set({
        'roomId': roomId,
        'senderId': callerId,
        'text': 'Voice Call',
        'type': 'call',
        'callStatus': callStatus,
        'callDuration': duration,
        'sentAt': Timestamp.fromDate(timestamp),
        'isRead': false,
      });

      // Update room last message info
      final roomRef = _firestore.collection('chats').doc(roomId);
      await roomRef.update({
        'lastMessage': 'Voice Call ($callStatus)',
        'lastSenderId': callerId,
        'lastMessageTime': Timestamp.fromDate(timestamp),
      });
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
