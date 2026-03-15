import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/connection_request_model.dart';
import '../../domain/repositories/connection_repository.dart';

abstract class ConnectionState extends Equatable {
  const ConnectionState();
  @override
  List<Object?> get props => [];
}

class ConnectionInitial extends ConnectionState {}
class ConnectionLoading extends ConnectionState {}
class ConnectionStatusLoaded extends ConnectionState {
  final ConnectionStatus? status;
  const ConnectionStatusLoaded(this.status);
  @override
  List<Object?> get props => [status];
}
class ConnectionError extends ConnectionState {
  final String message;
  const ConnectionError(this.message);
  @override
  List<Object?> get props => [message];
}

class ConnectionCubit extends Cubit<ConnectionState> {
  final ConnectionRepository _repository;

  ConnectionCubit({required ConnectionRepository repository})
      : _repository = repository,
        super(ConnectionInitial());

  Future<void> checkConnectionStatus(String uid1, String uid2) async {
    emit(ConnectionLoading());
    try {
      final status = await _repository.getConnectionStatus(uid1, uid2);
      emit(ConnectionStatusLoaded(status));
    } catch (e) {
      emit(ConnectionError(e.toString()));
    }
  }

  Future<void> sendRequest(ConnectionRequestModel request) async {
    final previousStatus = (state is ConnectionStatusLoaded) 
        ? (state as ConnectionStatusLoaded).status 
        : null;
        
    emit(ConnectionLoading());
    try {
      await _repository.sendConnectionRequest(request);
      emit(const ConnectionStatusLoaded(ConnectionStatus.pending));
    } catch (e) {
      emit(ConnectionError(e.toString()));
      emit(ConnectionStatusLoaded(previousStatus));
    }
  }
}
