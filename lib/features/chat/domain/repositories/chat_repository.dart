import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/chat_entity.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<ChatRoomEntity>>> getUserChatRooms(String uid);
  Stream<Either<Failure, ChatRoomEntity>> getRoom(String roomId);
  Stream<Either<Failure, List<MessageEntity>>> getMessages(String roomId);
  Future<Either<Failure, void>> sendMessage(MessageEntity message, String senderName);
  Future<Either<Failure, String>> createOrGetRoom(String uid1, String uid2, {String? name2, String? photo2});
}
