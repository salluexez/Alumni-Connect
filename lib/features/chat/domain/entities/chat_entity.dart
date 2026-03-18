import 'package:equatable/equatable.dart';

class ChatRoomEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final String lastSenderId;
  final DateTime lastMessageTime;
  final Map<String, String> participantNames;
  final Map<String, String> participantPhotos;
  final Map<String, int> unreadCounts;

  const ChatRoomEntity({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastMessageTime,
    required this.participantNames,
    required this.participantPhotos,
    required this.unreadCounts,
  });

  @override
  List<Object?> get props => [
        id,
        participantIds,
        lastMessage,
        lastSenderId,
        lastMessageTime,
        participantNames,
        participantPhotos,
        unreadCounts,
      ];
}

class MessageEntity extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String text;
  final String type; // 'text' or 'call'
  final String? callStatus; // 'missed', 'declined', 'ended'
  final int? callDuration; // in seconds
  final DateTime sentAt;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.text,
    this.type = 'text',
    this.callStatus,
    this.callDuration,
    required this.sentAt,
    this.isRead = false,
  });

  @override
  List<Object?> get props => [id, roomId, senderId, text, type, callStatus, callDuration, sentAt, isRead];
}
