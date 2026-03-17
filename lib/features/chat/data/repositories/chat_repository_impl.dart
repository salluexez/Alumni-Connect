import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';
import '../models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;

  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Stream<Either<Failure, List<ChatRoomEntity>>> getUserChatRooms(
    String uid,
  ) async* {
    try {
      await for (final rooms in _remoteDataSource.getUserChatRooms(uid)) {
        yield Right(rooms);
      }
    } catch (e) {
      yield Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, ChatRoomEntity>> getRoom(String roomId) async* {
    try {
      await for (final room in _remoteDataSource.getRoom(roomId)) {
        yield Right(room);
      }
    } catch (e) {
      yield Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<MessageEntity>>> getMessages(
    String roomId,
  ) async* {
    try {
      await for (final messages in _remoteDataSource.getMessages(roomId)) {
        yield Right(messages);
      }
    } catch (e) {
      yield Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(MessageEntity message, String senderName) async {
    try {
      final model = MessageModel(
        id: message.id,
        roomId: message.roomId,
        senderId: message.senderId,
        text: message.text,
        sentAt: message.sentAt,
        isRead: message.isRead,
      );
      await _remoteDataSource.sendMessage(model, senderName);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createOrGetRoom(
    String uid1,
    String uid2, {
    String? name2,
    String? photo2,
  }) async {
    try {
      final roomId = await _remoteDataSource.createOrGetRoom(uid1, uid2,
          name2: name2, photo2: photo2);
      return Right(roomId);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
