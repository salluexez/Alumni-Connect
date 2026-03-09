class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Server error occurred'});
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection'});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException({this.message = 'Resource not found'});
}
