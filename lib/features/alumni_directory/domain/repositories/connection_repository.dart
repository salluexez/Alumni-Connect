import 'package:alumni_connect/features/alumni_directory/data/datasources/connection_remote_datasource.dart';
import 'package:alumni_connect/features/alumni_directory/data/models/connection_request_model.dart';

abstract class ConnectionRepository {
  Future<void> sendConnectionRequest(ConnectionRequestModel request);
  Future<void> updateConnectionStatus(String requestId, ConnectionStatus status, {String? notificationId});
  Stream<List<ConnectionRequestModel>> getIncomingRequests(String uid);
  Future<ConnectionStatus?> getConnectionStatus(String uid1, String uid2);
}

class ConnectionRepositoryImpl implements ConnectionRepository {
  final ConnectionRemoteDataSource _dataSource;

  ConnectionRepositoryImpl(this._dataSource);

  @override
  Future<void> sendConnectionRequest(ConnectionRequestModel request) =>
      _dataSource.sendConnectionRequest(request);

  @override
  Future<void> updateConnectionStatus(String requestId, ConnectionStatus status, {String? notificationId}) =>
      _dataSource.updateConnectionStatus(requestId, status, notificationId: notificationId);

  @override
  Stream<List<ConnectionRequestModel>> getIncomingRequests(String uid) =>
      _dataSource.getIncomingRequests(uid);

  @override
  Future<ConnectionStatus?> getConnectionStatus(String uid1, String uid2) =>
      _dataSource.getConnectionStatus(uid1, uid2);
}
