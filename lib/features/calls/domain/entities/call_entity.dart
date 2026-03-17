import 'package:equatable/equatable.dart';

enum CallStatus { dialing, ringing, active, ended, declined }

class CallEntity extends Equatable {
  final String id;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String callerPhoto;
  final String receiverName;
  final String receiverPhoto;
  final CallStatus status;
  final String channelId;
  final DateTime timestamp;

  const CallEntity({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.callerName,
    required this.callerPhoto,
    required this.receiverName,
    required this.receiverPhoto,
    required this.status,
    required this.channelId,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        callerId,
        receiverId,
        callerName,
        callerPhoto,
        receiverName,
        receiverPhoto,
        status,
        channelId,
        timestamp,
      ];
}
