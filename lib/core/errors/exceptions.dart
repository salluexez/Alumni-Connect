class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Server error occurred'});

  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException({this.message = 'Resource not found'});

  @override
  String toString() => message;
}
