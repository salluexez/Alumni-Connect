import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoomEntity> rooms;
  const ChatRoomsLoaded(this.rooms);
  @override
  List<Object?> get props => [rooms];
}

class ChatMessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  final ChatRoomEntity chatRoom;
  const ChatMessagesLoaded(this.messages, this.chatRoom);
  @override
  List<Object?> get props => [messages, chatRoom];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatRoomCreated extends ChatState {
  final String roomId;
  const ChatRoomCreated(this.roomId);
  @override
  List<Object?> get props => [roomId];
}
