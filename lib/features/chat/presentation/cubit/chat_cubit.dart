import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;
  StreamSubscription? _roomsSubscription;
  StreamSubscription? _messagesSubscription;

  ChatCubit({required ChatRepository repository})
      : _repository = repository,
        super(const ChatInitial());

  @override
  Future<void> close() {
    _roomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    return super.close();
  }

  void loadUserRooms() {
    emit(const ChatLoading());
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(const ChatError('User not authenticated'));
      return;
    }

    _roomsSubscription?.cancel();
    _roomsSubscription = _repository.getUserChatRooms(uid).listen(
      (result) {
        result.fold(
          (failure) => emit(ChatError(failure.message)),
          (rooms) => emit(ChatRoomsLoaded(rooms)),
        );
      },
    );
  }

  void loadMessages(String roomId) {
    emit(const ChatLoading());
    _messagesSubscription?.cancel();
    _roomsSubscription?.cancel();

    List<MessageEntity>? latestMessages;
    ChatRoomEntity? latestRoom;

    void updateState() {
      if (latestMessages != null && latestRoom != null) {
        emit(ChatMessagesLoaded(latestMessages!, latestRoom!));
      }
    }

    _messagesSubscription = _repository.getMessages(roomId).listen(
      (result) {
        result.fold(
          (failure) => emit(ChatError(failure.message)),
          (messages) {
            latestMessages = messages;
            updateState();
          },
        );
      },
    );

    _roomsSubscription = _repository.getRoom(roomId).listen(
      (result) {
        result.fold(
          (failure) => emit(ChatError(failure.message)),
          (room) {
            latestRoom = room;
            updateState();
          },
        );
      },
    );
  }

  Future<void> sendMessage(MessageEntity message, String senderName) async {
    final result = await _repository.sendMessage(message, senderName);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (_) {}, // State will update via stream automatically
    );
  }

  Future<void> startChat(String otherUserId, {String? name, String? photoUrl, String? initialMessage}) async {
    emit(const ChatLoading());
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    final result = await _repository.createOrGetRoom(uid, otherUserId, 
        name2: name, photo2: photoUrl);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (roomId) {
        if (initialMessage != null && initialMessage.isNotEmpty) {
          final currentUserName = FirebaseAuth.instance.currentUser?.displayName ?? 'User';
          final message = MessageEntity(
            id: '',
            roomId: roomId,
            senderId: uid,
            text: initialMessage,
            sentAt: DateTime.now(),
          );
          sendMessage(message, currentUserName);
        }
        emit(ChatRoomCreated(roomId));
      },
    );
  }
}
